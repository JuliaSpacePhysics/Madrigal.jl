# MadrigalWeb

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Beforerr.github.io/MadrigalWeb.jl/dev/)
[![Build Status](https://github.com/Beforerr/MadrigalWeb.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Beforerr/MadrigalWeb.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Beforerr/MadrigalWeb.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Beforerr/MadrigalWeb.jl)

A Julia API to access the Madrigal database.

```julia
using MadrigalWeb
using Dates

MadrigalWeb.set_default_server("https://cedar.openmadrigal.org")
MadrigalWeb.set_default_user("xxx", "xxx@xxx.com", "xxx")

download_files(8100, 10216, "2000-01-01", "2000-01-02")
```