from setuptools import setup

setup(
    name='xontrib-powerline',
    version='0.1.0',
    url='https://github.com/santagada/xontrib-powerline',
    license='MIT',
    author='Leonardo Santagada',
    author_email='santagada@gmail.com',
    description='Powerline for Xonsh shell',
    packages=['xontrib'],
    package_dir={'xontrib': 'xontrib'},
    package_data={'xontrib': ['*.xsh']},
    platforms='any',
)
