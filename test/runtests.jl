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

testfile_multi_frame = joinpath(@__DIR__, "testfiles/test_multiframe.sif")
img_multi_frame = load(testfile_multi_frame)
@test size(img_multi_frame) == (121, 51, 10)
@test img_multi_frame[1:2, 1:2, 1] == [494 503; 483 500]
@test img_multi_frame[end-1:end, end-1:end, end] == [518 500; 524 502]
@test maximum(img_multi_frame.data) < 1024
@test minimum(img_multi_frame.data) >= 0
