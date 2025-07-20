# MIZAR PROTO 發布工具
param(
    [string]$Version = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MIZAR PROTO 發布工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 自動版本遞增邏輯
if ($Version -eq "") {
    # 檢查是否有現有的 tag
    $latestTag = git describe --tags --abbrev=0 2>$null
    if ($LASTEXITCODE -eq 0 -and $latestTag) {
        # 有現有 tag，解析版本號並遞增
        if ($latestTag -match "^v?(\d+)\.(\d+)\.(\d+)$") {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            $patch = [int]$matches[3]
            $patch++
            $Version = "v$major.$minor.$patch"
            Write-Host "檢測到最新版本: $latestTag" -ForegroundColor Yellow
            Write-Host "自動遞增為: $Version" -ForegroundColor Green
        }
        else {
            Write-Host "❌ 無法解析現有版本號格式: $latestTag" -ForegroundColor Red
            Write-Host "請手動指定版本號，例如: .\publish.ps1 v1.0.1" -ForegroundColor Yellow
            Read-Host "按 Enter 繼續"
            exit 1
        }
    }
    else {
        # 沒有現有 tag，使用初始版本
        $Version = "v0.0.1"
        Write-Host "專案中沒有現有 tag，使用初始版本: $Version" -ForegroundColor Green
    }
}
else {
    # 檢查指定的版本號格式
    if ($Version -notmatch "^v?(\d+)\.(\d+)\.(\d+)$") {
        Write-Host "❌ 版本號格式錯誤: $Version" -ForegroundColor Red
        Write-Host "請使用語意化版本號格式，例如: v1.0.1 或 1.0.1" -ForegroundColor Yellow
        Read-Host "按 Enter 繼續"
        exit 1
    }
    
    # 確保版本號有 v 前綴
    if ($Version -notmatch "^v") {
        $Version = "v$Version"
    }
    
    Write-Host "使用指定版本: $Version" -ForegroundColor Green
}

Write-Host ""
Write-Host "準備發布版本: $Version" -ForegroundColor Green
Write-Host ""

# 檢查是否有未提交的變更
$status = git status --porcelain
if ($status -match "^[^?]") {
    Write-Host "警告: 發現未提交的變更" -ForegroundColor Yellow
    Write-Host "請先手動 commit 所有變更再發布（commit message 很重要）" -ForegroundColor Yellow
    Read-Host "按 Enter 繼續"
    exit 1
}

# 執行編譯測試
Write-Host "執行編譯測試..." -ForegroundColor Cyan
& .\compile.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 編譯測試失敗，發布取消" -ForegroundColor Red
    Read-Host "按 Enter 繼續"
    exit 1
}

Write-Host ""
Write-Host "編譯測試通過，開始發布流程..." -ForegroundColor Green
Write-Host ""

# 編譯到正式目錄
Write-Host "[1/4] 編譯到正式目錄..." -ForegroundColor Cyan
& .\compile.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 正式編譯失敗" -ForegroundColor Red
    Read-Host "按 Enter 繼續"
    exit 1
}

# 生成 Python setup.py
Write-Host "[1.5/4] 生成 Python setup.py..." -ForegroundColor Cyan
Push-Location python/
& .\_gen_setup.ps1 -Version $Version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 生成 setup.py 失敗" -ForegroundColor Red
    Pop-Location
    Read-Host "按 Enter 繼續"
    exit 1
}
Pop-Location

# 提交編譯結果
Write-Host "[2/4] 提交編譯結果..." -ForegroundColor Cyan
git add go/, python/
$status = git status --porcelain
if ($status -match "^[^?]") {
    git commit -m "Build: Compile proto files and generate setup.py for $Version"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 提交編譯結果失敗" -ForegroundColor Red
        Read-Host "按 Enter 繼續"
        exit 1
    }
}
else {
    Write-Host "沒有編譯結果需要提交" -ForegroundColor Yellow
}

# 建立 tag
Write-Host "[3/4] 建立 tag $Version..." -ForegroundColor Cyan
git tag -a $Version -m "Release $Version"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 建立 tag 失敗" -ForegroundColor Red
    Read-Host "按 Enter 繼續"
    exit 1
}

# Push 到遠端
Write-Host "[4/4] Push 到遠端..." -ForegroundColor Cyan
git push origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Push main 分支失敗" -ForegroundColor Red
    Read-Host "按 Enter 繼續"
    exit 1
}

git push origin $Version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Push tag 失敗" -ForegroundColor Red
    Read-Host "按 Enter 繼續"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "🎉 發布完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "版本 $Version 已成功發布：" -ForegroundColor Green
Write-Host "  ✓ 編譯測試通過" -ForegroundColor Green
Write-Host "  ✓ 正式編譯完成" -ForegroundColor Green
Write-Host "  ✓ 編譯結果已提交" -ForegroundColor Green
Write-Host "  ✓ Tag 已建立" -ForegroundColor Green
Write-Host "  ✓ 已推送到遠端" -ForegroundColor Green
Write-Host ""
Write-Host "其他專案現在可以使用：" -ForegroundColor Cyan
Write-Host "  go get github.com/honeymagico/mizar-proto@$Version" -ForegroundColor White
Write-Host ""
Write-Host "GitHub Release 頁面：" -ForegroundColor Cyan
Write-Host "  https://github.com/honeymagico/mizar-proto/releases/tag/$Version" -ForegroundColor White
Write-Host ""

Read-Host "按 Enter 繼續" 