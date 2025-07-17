param(
    [string]$Version = "0.1.0"
)

# 取得所有 *_pb2.py 檔案名稱（不含副檔名）
$pyModules = Get-ChildItem -Path . -Filter "*_pb2.py" | ForEach-Object { $_.BaseName }
$pyModulesList = $pyModules -join '", "'
$pyModulesList = '"' + $pyModulesList + '"'

$setupContent = @"
from setuptools import setup

setup(
    name="mizar-proto",
    version="$Version",
    description="MIZAR 私有協定 Python 產生檔案（嚴禁未經授權使用、散布、修改、公開、衍生、商業行為）",
    author="MIZAR PRIVATE",
    author_email="no-reply@mizar.local",
    license="Proprietary",
    py_modules=[$pyModulesList],
    package_dir={"": "."},
    install_requires=[],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: Other/Proprietary License",
        "Operating System :: OS Independent",
        "Private :: Do Not Distribute",
    ],
)
"@

Set-Content -Path "./setup.py" -Value $setupContent -Encoding UTF8
Write-Host "setup.py 已產生，版號 $Version，模組：$pyModulesList" 