# MIZAR PROTO Compiler
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MIZAR PROTO Compiler" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if protoc exists
if (-not (Test-Path "compiler\bin\win64\protoc.exe")) {
    Write-Host "Error: protoc.exe not found" -ForegroundColor Red
    Write-Host "Please ensure compiler\bin\win64\protoc.exe exists" -ForegroundColor Red
    Read-Host "按 Enter 繼續"
    exit 1
}

# Check Go environment
Write-Host "Checking Go environment..." -ForegroundColor Cyan
try {
    $goVersion = go version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Go not found"
    }
    Write-Host "Go is installed" -ForegroundColor Green
    Write-Host $goVersion -ForegroundColor White
}
catch {
    Write-Host "Error: Go not found" -ForegroundColor Red
    Write-Host "Please install Go 1.21+ and ensure it's in PATH" -ForegroundColor Red
    Write-Host "Download: https://golang.org/dl/" -ForegroundColor Yellow
    Read-Host "按 Enter 繼續"
    exit 1
}

# Check protoc-gen-go
try {
    $null = protoc-gen-go --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "protoc-gen-go not found"
    }
    Write-Host "protoc-gen-go is installed" -ForegroundColor Green
}
catch {
    Write-Host "Installing protoc-gen-go..." -ForegroundColor Yellow
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to install protoc-gen-go" -ForegroundColor Red
        Read-Host "按 Enter 繼續"
        exit 1
    }
    Write-Host "protoc-gen-go installed" -ForegroundColor Green
}

# Create output directories
if (-not (Test-Path "go")) { New-Item -ItemType Directory -Path "go" | Out-Null }
if (-not (Test-Path "python")) { New-Item -ItemType Directory -Path "python" | Out-Null }

# Clear output directories (keep .gitkeep)
Write-Host ""
Write-Host "Clearing output directories..." -ForegroundColor Cyan
if (Test-Path "go\*.pb.go") { Remove-Item "go\*.pb.go" -Force }
if (Test-Path "python\*_pb2.py") { Remove-Item "python\*_pb2.py" -Force }

Write-Host "Starting compilation..." -ForegroundColor Green
Write-Host ""

# Compile to Go
Write-Host "[1/2] Compiling to Go..." -ForegroundColor Cyan
& "compiler\bin\win64\protoc.exe" --proto_path=proto --go_out=go --go_opt=paths=source_relative proto\*.proto

if ($LASTEXITCODE -ne 0) {
    Write-Host "Go compilation failed" -ForegroundColor Red
    Read-Host "按 Enter 繼續"
    exit 1
}
Write-Host "Go compilation completed" -ForegroundColor Green

# Compile to Python
Write-Host "[2/3] Compiling to Python..." -ForegroundColor Cyan
& "compiler\bin\win64\protoc.exe" --proto_path=proto --python_out=python proto\*.proto

if ($LASTEXITCODE -ne 0) {
    Write-Host "Python compilation failed" -ForegroundColor Red
    Read-Host "按 Enter 繼續"
    exit 1
}
Write-Host "Python compilation completed" -ForegroundColor Green

# Compile to Python with mypy types (讓PYTHON能提供程式碼自動完成的資訊)
Write-Host "[3/3] Compiling to Python with mypy types..." -ForegroundColor Cyan

# Check if uv is available
try {
    $null = uv --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "uv not found"
    }
    Write-Host "uv is available" -ForegroundColor Green
    
    # Sync dependencies from pyproject.toml
    Write-Host "Syncing dependencies..." -ForegroundColor Yellow
    uv sync --dev
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to sync dependencies" -ForegroundColor Red
        Read-Host "按 Enter 繼續"
        exit 1
    }
    
    # Generate mypy stubs
    Write-Host "Generating mypy stubs..." -ForegroundColor Yellow
    uv run compiler\bin\win64\protoc.exe --proto_path=proto --mypy_out=python proto\*.proto
    if ($LASTEXITCODE -ne 0) {
        Write-Host "mypy stub generation failed" -ForegroundColor Red
        Read-Host "按 Enter 繼續"
        exit 1
    }
    Write-Host "mypy stubs generated" -ForegroundColor Green
    
}
catch {
    Write-Host "uv not available, skipping mypy stub generation" -ForegroundColor Yellow
    Write-Host "To enable mypy support, install uv: https://docs.astral.sh/uv/getting-started/installation/" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Compilation completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Compilation completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Generated files:" -ForegroundColor Cyan
Write-Host "  - Go:     go/*.pb.go" -ForegroundColor White
Write-Host "  - Python: python/*_pb2.py" -ForegroundColor White
Write-Host "  - Types:  python/*_pb2.pyi" -ForegroundColor White
Write-Host ""
