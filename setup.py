#!/usr/bin/env python
# -*- encoding: utf-8 -*-

import io
import os
import platform
import re
from glob import glob
from os.path import basename
from os.path import dirname
from os.path import join
from os.path import relpath
from os.path import splitext

from setuptools import Extension, Command
from setuptools import find_packages
from setuptools import setup
from setuptools.command.build_ext import build_ext
from distutils.sysconfig import customize_compiler
from nasmcompiler import NasmCompiler


class NasmBuildCommand(build_ext):
    description = "build NASM extensions (compile/link to build directory)"

    def run(self):
        try:
            if self.distribution.has_c_libraries():
                build_clib = self.get_finalized_command('build_clib')
                self.libraries.extend(build_clib.get_library_names() or [])
                self.library_dirs.append(build_clib.build_clib)
            self.compiler = NasmCompiler(verbose=True)
            customize_compiler(self.compiler)

            # incase someone tries.
            if os.name == 'nt':
                raise NotImplementedError("Windows support not implemented for NASM")

            if self.include_dirs is not None:
                self.compiler.set_include_dirs(self.include_dirs)

            if self.define is not None:
                # 'define' option is a list of (name,value) tuples
                for (name, value) in self.define:
                    self.compiler.define_macro(name, value)
            if self.undef is not None:
                for macro in self.undef:
                    self.compiler.undefine_macro(macro)
            if self.libraries is not None:
                self.compiler.set_libraries(self.libraries)
            if self.library_dirs is not None:
                self.compiler.set_library_dirs(self.library_dirs)
            if self.rpath is not None:
                self.compiler.set_runtime_library_dirs(self.rpath)
            if self.link_objects is not None:
                self.compiler.set_link_objects(self.link_objects)

            self.build_extensions()
        except Exception as e:
            self._unavailable(e)
            self.extensions = []  # avoid copying missing files (it would fail).

    def _unavailable(self, e):
        print('*' * 80)
        print('''WARNING:

    An optional code optimization (C extension) could not be compiled.

    Optimizations for this package will not be available!
        ''')

        print('CAUSE:')
        print('')
        print('    ' + repr(e))
        print('*' * 80)


def read(*names, **kwargs):
    with io.open(
            join(dirname(__file__), *names),
            encoding=kwargs.get('encoding', 'utf8')
    ) as fh:
        return fh.read()


setup(
    name='pymult',
    version='0.0.0',
    license='BSD-2-Clause',
    description='An example Python package written in x86-64 assembly.',
    long_description= read('README.md'),
    author='Anthony Shaw',
    author_email='anthonyshaw@apache.org',
    url='https://github.com/tonybaloney/python-assembly-poc',
    packages=find_packages('src'),
    package_dir={'': 'src'},
    py_modules=[splitext(basename(path))[0] for path in glob('src/*.py')],
    include_package_data=True,
    zip_safe=False,
    classifiers=[
        # complete classifier list: http://pypi.python.org/pypi?%3Aaction=list_classifiers
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Operating System :: Unix',
        'Operating System :: POSIX',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Topic :: Utilities',
    ],
    python_requires='>=3.7',
    install_requires=[
    ],
    extras_require={
    },
    cmdclass={'build_ext': NasmBuildCommand},
    ext_modules=[
        Extension(
            splitext(relpath(path, 'src').replace(os.sep, '.'))[0],
            sources=[path],
            extra_compile_args=[],
            extra_link_args=[],
            include_dirs=[dirname(path)]
        )
        for root, _, _ in os.walk('src')
        for path in glob(join(root, '*.asm'))
    ],
)
