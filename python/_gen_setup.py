import sys
import os

version = "0.1.0"
if len(sys.argv) > 1:
    version = sys.argv[1]

# 取得所有 *_pb2.py 檔案名稱（不含副檔名）
py_modules = [f[:-3] for f in os.listdir('.') if f.endswith('_pb2.py')]
py_modules_list = '\", \"'.join(py_modules)

setup_content = f'''from setuptools import setup

setup(
    name="mizar-proto",
    version="{version}",
    description="MIZAR 私有協定 Python 產生檔案（嚴禁未經授權使用、散布、修改、公開、衍生、商業行為）",
    author="MIZAR PRIVATE",
    author_email="no-reply@mizar.local",
    license="Proprietary",
    py_modules=["{py_modules_list}"],
    package_dir={{"": "."}},
    install_requires=[],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: Other/Proprietary License",
        "Operating System :: OS Independent",
        "Private :: Do Not Distribute",
    ],
)
'''

with open("setup.py", "w", encoding="utf-8") as f:
    f.write(setup_content)

print(f"setup.py 已產生，版號 {version}，模組：{py_modules_list}") 