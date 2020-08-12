# Building Python Extension Modules in Assembly

![GitHub Actions](https://github.com/tonybaloney/python-assembly-poc/workflows/Python%20package/badge.svg)


This repository is a proof-of-concept to demonstrate how you can create a Python Extension in 
100% assembly.

Demonstrates: 

 - How to write a Python module in pure assembly
 - How to write a function in pure assembly and call it from Python with Python objects
 - How to call the C API to create a PyObject and parse PyTuple (arguments) into raw pointers
 - How to pass data back into Python
 - How to register a module from assembly
 - How to create a method definition in assembly
 - How to write back to the Python stack using the dynamic module loader
 - How to package a NASM/Assembly Python extension with distutils

The simple proof-of-concept function takes 2 parameters,

```default
>>> import pymult
>>> pymult.multiply(2, 4)
8  
```
 
## But, Why?

Just because it can be done.

Also, I want to see if some AVX/AVX2 instructions (high-performance matrix multiplication especially) can be used
directly from Python.
