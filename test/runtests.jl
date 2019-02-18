using AndorSIF
using Test
import FileIO: load

testfile = joinpath(@__DIR__, "testfiles/2d_testfile.sif")
@test load(testfile)
