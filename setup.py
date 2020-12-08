from setuptools import setup
from codecs import open
from os import path

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='xontrib-powerline2',
    version='1.2.2',
    description='Powerline for Xonsh shell',
    long_description=open('README.md').read(),
    long_description_content_type="text/markdown",
    url='https://github.com/vaaaaanquish/xontrib-powerline2',
    author='vaaaaanquish',
    author_email='6syun9@gmail.com',
    license='MIT',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
    ],
    packages=['xontrib'],
    package_dir={'xontrib': 'xontrib'},
    package_data={'xontrib': ['*.xsh']},
    platforms='any',
)
