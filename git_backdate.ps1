# Ensure we are inside a git repository
if (-not (Test-Path .git)) {
    Write-Host "Initializing Git repository..." -ForegroundColor Cyan
    git init
}

# Helper function to commit with a specific date
function Commit-Backdated ($date, $message) {
    $env:GIT_AUTHOR_DATE = $date
    $env:GIT_COMMITTER_DATE = $date
    git commit -m $message
    # Clear env variables after commit
    Remove-Item Env:\GIT_AUTHOR_DATE
    Remove-Item Env:\GIT_COMMITTER_DATE
}

# --- DAY 1: July 2, 2026 ---
Write-Host "Staging Day 1 changes..." -ForegroundColor Green
git add pubspec.yaml pubspec.lock analysis_options.yaml .gitignore README.md
Commit-Backdated "2026-07-02T10:14:22+05:30" "feat: initialize refine launcher project & basic configuration"

# --- DAY 2: July 3, 2026 ---
Write-Host "Staging Day 2 changes..." -ForegroundColor Green
git add lib/database/
Commit-Backdated "2026-07-03T11:45:10+05:30" "feat: set up database collections and schemas"

# --- DAY 3: July 4, 2026 ---
Write-Host "Staging Day 3 changes..." -ForegroundColor Green
git add lib/features/onboarding/ lib/features/home/ lib/features/launcher/
Commit-Backdated "2026-07-04T14:20:05+05:30" "feat: implement onboarding flow, launcher layout, and home screen"

# --- DAY 4: July 5, 2026 ---
Write-Host "Staging Day 4 changes..." -ForegroundColor Green
git add lib/features/dashboard/ lib/features/app_search/ lib/features/app_locker/
Commit-Backdated "2026-07-05T09:30:45+05:30" "feat: add dashboard widgets, app locker, and search capabilities"

# --- DAY 5: July 6, 2026 ---
Write-Host "Staging Day 5 changes..." -ForegroundColor Green
git add lib/features/motivation/ lib/features/journal/
Commit-Backdated "2026-07-06T16:15:00+05:30" "feat: integrate motivation provider and daily journaling feature"

# --- DAY 6: July 7, 2026 ---
Write-Host "Staging Day 6 changes..." -ForegroundColor Green
git add lib/features/workout/ lib/features/todo/ lib/features/timetable/
Commit-Backdated "2026-07-07T13:05:12+05:30" "feat: add workout tracker, todo lists, and timetable planner"

# --- DAY 7: July 8, 2026 (Today) ---
Write-Host "Staging Day 7 changes..." -ForegroundColor Green
git add .
Commit-Backdated "2026-07-08T12:00:00+05:30" "feat: final UI polish, main integration, and birthday tracking"

Write-Host "Done! Your 7-day commit history has been generated." -ForegroundColor Cyan
Write-Host "You can now link it to GitHub using:" -ForegroundColor Yellow
Write-Host "  git remote add origin <your-repo-url>"
Write-Host "  git branch -M main"
Write-Host "  git push -u origin main"
