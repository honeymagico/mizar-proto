from setuptools import setup

setup(
    name="mizar-proto",
    version="0.1.0",
    description="Mizar proto generated python files",
    author="Your Name",
    author_email="your@email.com",
    py_modules=["mizar_common_pb2", "mizar_info_pb2", "mizar_pb2", "mizar_portfolio_pb2", "mizar_quote_pb2", "mizar_stream_pb2", "mizar_trade_pb2"],
    package_dir={"": "."},
    install_requires=[],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
)
