using AndorSIF
using Test
import FileIO: load

testfile_2d = joinpath(@__DIR__, "testfiles/2d_testfile.sif")
testfile_1d = joinpath(@__DIR__, "testfiles/1d_testfile.sif")

img_2d = load(testfile_2d)
img_1d = load(testfile_1d)

@test size(img_2d) == (512, 512, 1)
@test size(img_1d) == (512, 1, 1)
@test img_1d[1:2] == [789.0, 783.0]
@test img_1d[end-1:end] == [765.0, 768.0]
@test img_1d.ixon["exposure_time"] == 5.0
