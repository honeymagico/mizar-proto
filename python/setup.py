from setuptools import setup

setup(
    name="mizar-proto",
    version="0.0.5",
    description="MIZAR 私有協定 Python 產生檔案（嚴禁未經授權使用、散布、修改、公開、衍生、商業行為）",
    author="MIZAR PRIVATE",
    author_email="no-reply@mizar.local",
    license="Proprietary",
    py_modules=["mizar_common_pb2", "mizar_info_pb2", "mizar_pb2", "mizar_portfolio_pb2", "mizar_quote_pb2", "mizar_stream_pb2", "mizar_trade_pb2"],
    package_dir={"": "."},
    install_requires=[],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: Other/Proprietary License",
        "Operating System :: OS Independent",
        "Private :: Do Not Distribute",
    ],
)
