# src/train_model.py
import os
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import classification_report, confusion_matrix
import joblib
import argparse
import warnings

warnings.filterwarnings("ignore")

# Optional Keras (only used if --use_nn)
try:
    from tensorflow import keras
    from tensorflow.keras import layers
    HAS_KERAS = True
except Exception:
    HAS_KERAS = False

# -------------------------
# Utility functions
# -------------------------
def load_dataset(csv_path="data/dataset.csv", sample_frac=None):
    print(f"Loading CSV: {csv_path}")
    df = pd.read_csv(csv_path)
    if sample_frac is not None:
        df = df.sample(frac=sample_frac, random_state=42).reset_index(drop=True)
    print("Rows:", len(df), "Columns:", len(df.columns))
    return df

def build_feature_matrix(df, use_angles=True, use_landmarks=True):
    """
    Build X matrix and return X, feature_names.
    - If landmarks stored as x0..x32, y0..y32, v0..v32 they will be used.
    - Angles columns: elbow_angle, knee_angle, hip_angle, shoulder_angle (if present).
    """
    features = []
    feature_names = []

    # Angle features
    angle_cols = [c for c in ["elbow_angle", "knee_angle", "hip_angle", "shoulder_angle"] if c in df.columns]
    if use_angles and angle_cols:
        features.append(df[angle_cols].astype(float).values)
        feature_names += angle_cols

    # Landmark features: x0..x32 and y0..y32 (we ignore visibility by default)
    if use_landmarks:
        x_cols = [c for c in df.columns if c.startswith("x")]
        y_cols = [c for c in df.columns if c.startswith("y")]
        if x_cols and y_cols:
            # ensure sorted order x0..x32
            x_cols = sorted(x_cols, key=lambda s: int(s[1:]))
            y_cols = sorted(y_cols, key=lambda s: int(s[1:]))
            coords = df[x_cols + y_cols].astype(float).values
            features.append(coords)
            feature_names += x_cols + y_cols

    if not features:
        raise ValueError("No features found. Check dataset columns.")

    # concatenate horizontally
    X = np.hstack(features)
    return X, feature_names

def encode_labels(df, label_col):
    le = LabelEncoder()
    y = le.fit_transform(df[label_col].astype(str).values)
    return y, le

def train_rf(X_train, y_train, n_estimators=150, max_depth=None, class_weight="balanced"):
    clf = RandomForestClassifier(
        n_estimators=n_estimators,
        max_depth=max_depth,
        n_jobs=-1,
        random_state=42,
        class_weight=class_weight
    )
    clf.fit(X_train, y_train)
    return clf

def train_nn(X_train, y_train, X_val, y_val, num_classes, epochs=25, batch_size=64):
    model = keras.Sequential([
        layers.Input(shape=(X_train.shape[1],)),
        layers.Dense(256, activation="relu"),
        layers.Dropout(0.3),
        layers.Dense(128, activation="relu"),
        layers.Dropout(0.2),
        layers.Dense(num_classes, activation="softmax")
    ])
    model.compile(optimizer="adam", loss="sparse_categorical_crossentropy", metrics=["accuracy"])
    model.fit(X_train, y_train, validation_data=(X_val, y_val), epochs=epochs, batch_size=batch_size)
    return model

# -------------------------
# Main training routine
# -------------------------
def main(args):
    os.makedirs("models", exist_ok=True)

    df = load_dataset(args.csv, sample_frac=args.sample)
    # drop frames with missing data
    df = df.dropna().reset_index(drop=True)
    print("After dropna rows:", len(df))

    # Build features
    X, feature_names = build_feature_matrix(df, use_angles=True, use_landmarks=True)
    print("Feature dim:", X.shape)

    # Form classifier (good / bad)
    if "form_label" in df.columns:
        y_form, le_form = encode_labels(df, "form_label")
        X_train_f, X_test_f, y_train_f, y_test_f = train_test_split(X, y_form, test_size=0.2, stratify=y_form, random_state=42)

        # scale
        scaler_f = StandardScaler()
        X_train_f = scaler_f.fit_transform(X_train_f)
        X_test_f = scaler_f.transform(X_test_f)

        print("\n=== Training FORM classifier (RandomForest) ===")
        rf_form = train_rf(X_train_f, y_train_f, n_estimators=args.trees)
        y_pred_f = rf_form.predict(X_test_f)
        print("Form classifier report:")
        print(classification_report(y_test_f, y_pred_f, target_names=le_form.classes_))
        print("Confusion matrix:\n", confusion_matrix(y_test_f, y_pred_f))

        # Save
        joblib.dump(rf_form, "models/form_classifier_rf.pkl")
        joblib.dump(scaler_f, "models/form_scaler.pkl")
        joblib.dump(le_form, "models/form_label_encoder.pkl")
        print("Saved form classifier to models/form_classifier_rf.pkl")

        # Optional NN
        if args.use_nn:
            if not HAS_KERAS:
                print("Keras not available. Skipping NN training for form.")
            else:
                print("Training NN for form (this may take longer)...")
                X_tr, X_val, y_tr, y_val = train_test_split(X_train_f, y_train_f, test_size=0.2, random_state=42)
                model_form_nn = train_nn(X_tr, y_tr, X_val, y_val, num_classes=len(le_form.classes_), epochs=args.epochs)
                model_form_nn.save("models/form_classifier_nn.h5")
                print("Saved NN form model to models/form_classifier_nn.h5")

    else:
        print("No 'form_label' column found in dataset. Skipping form classifier.")

    # Exercise classifier (which exercise)
    if "exercise" in df.columns:
        y_ex, le_ex = encode_labels(df, "exercise")
        X_train_e, X_test_e, y_train_e, y_test_e = train_test_split(X, y_ex, test_size=0.2, stratify=y_ex, random_state=42)

        scaler_e = StandardScaler()
        X_train_e = scaler_e.fit_transform(X_train_e)
        X_test_e = scaler_e.transform(X_test_e)

        print("\n=== Training EXERCISE classifier (RandomForest) ===")
        rf_ex = train_rf(X_train_e, y_train_e, n_estimators=args.trees)
        y_pred_e = rf_ex.predict(X_test_e)
        print("Exercise classifier report:")
        print(classification_report(y_test_e, y_pred_e, target_names=le_ex.classes_))
        print("Confusion matrix:\n", confusion_matrix(y_test_e, y_pred_e))

        joblib.dump(rf_ex, "models/exercise_classifier_rf.pkl")
        joblib.dump(scaler_e, "models/exercise_scaler.pkl")
        joblib.dump(le_ex, "models/exercise_label_encoder.pkl")
        print("Saved exercise classifier to models/exercise_classifier_rf.pkl")

        if args.use_nn:
            if not HAS_KERAS:
                print("Keras not available. Skipping NN training for exercise.")
            else:
                print("Training NN for exercise (this may take longer)...")
                X_tr, X_val, y_tr, y_val = train_test_split(X_train_e, y_train_e, test_size=0.2, random_state=42)
                model_ex_nn = train_nn(X_tr, y_tr, X_val, y_val, num_classes=len(le_ex.classes_), epochs=args.epochs)
                model_ex_nn.save("models/exercise_classifier_nn.h5")
                print("Saved NN exercise model to models/exercise_classifier_nn.h5")
    else:
        print("No 'exercise' column found in dataset. Skipping exercise classifier.")

    print("\n✅ Training finished. Models and scalers saved in ./models/")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", type=str, default="data/dataset.csv", help="Path to dataset CSV")
    parser.add_argument("--trees", type=int, default=150, help="Number of trees for RandomForest")
    parser.add_argument("--use_nn", action="store_true", help="Also train Keras neural network (optional)")
    parser.add_argument("--epochs", type=int, default=25, help="Epochs for Keras model (if used)")
    parser.add_argument("--sample", type=float, default=None, help="Sample fraction of dataset (for quick tests)")
    args = parser.parse_args()
    main(args)
