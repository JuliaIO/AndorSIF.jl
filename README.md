# AndorSIF

[![Build status](https://github.com/JuliaIO/AndorSIF.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaIO/AndorSIF.jl/actions/workflows/CI.yml)

This implements support for reading Andor SIF image files in the Julia programming language.

## Usage

```jl
using Images
load(filename)
```
where `filename` is a `*.sif` file.
