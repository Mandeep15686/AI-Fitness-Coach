# fix_git_push.ps1
# This script fixes "src refspec main does not match any" and pushes your Flutter project to GitHub

Write-Host "🔧 Fixing Git push issue for AI-Fitness-Coach project..." -ForegroundColor Cyan

# Step 1: Initialize repo if missing
if (-not (Test-Path ".git")) {
    git init
    Write-Host "✅ Initialized a new Git repository."
}

# Step 2: Ensure we are on a branch (main)
$currentBranch = git branch --show-current
if (-not $currentBranch) {
    git checkout -b main
    Write-Host "✅ Created and switched to branch 'main'."
} elseif ($currentBranch -ne "main") {
    git branch -M main
    Write-Host "✅ Renamed branch to 'main'."
} else {
    Write-Host "✅ Already on branch 'main'."
}

# Step 3: Stage all files
git add .
Write-Host "📦 Staged all project files."

# Step 4: Make an initial commit if needed
$commitCount = git rev-list --count HEAD 2>$null
if ($LASTEXITCODE -ne 0 -or $commitCount -eq 0) {
    git commit -m "Initial commit"
    Write-Host "✅ Created initial commit."
} else {
    Write-Host "ℹ️ Existing commits detected, skipping new commit."
}

# Step 5: Reset and re-add GitHub remote
$remoteExists = git remote | Select-String "origin"
if ($remoteExists) {
    git remote remove origin
    Write-Host "🔄 Removed existing remote 'origin'."
}

git remote add origin https://github.com/Mandeep15686/AI-Fitness-Coach.git
Write-Host "✅ Added GitHub remote repository."

# Step 6: Push to GitHub
git push -u origin main
if ($LASTEXITCODE -eq 0) {
    Write-Host "🚀 Successfully pushed code to GitHub main branch!" -ForegroundColor Green
} else {
    Write-Host "❌ Push failed. Please check your GitHub credentials or internet connection." -ForegroundColor Red
}
