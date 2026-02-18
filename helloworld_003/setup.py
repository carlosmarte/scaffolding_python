from setuptools import setup, find_packages

setup(
    name="helloworld-003",
    version="0.1.0",
    description="Simple Hello World with setuptools",
    packages=find_packages(),
    python_requires=">=3.11",
    entry_points={
        "console_scripts": [
            "hello=helloworld_003.hello:main",
        ],
    },
)
