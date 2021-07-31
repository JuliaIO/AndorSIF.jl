module AndorSIF

using Images, FileIO

# SIF.jl, adds an imread function for Andor .sif images
# 2013 Ronald S. Rock, Jr.

function load(f::File{format"AndorSIF"})
    open(f) do s
        skipmagic(s)
        load(s)
    end
end

function load(fs::Stream{format"AndorSIF"})
    # line 1
    io = stream(fs)
    # line 2
    l = ""
    while !eof(io) && isempty(l)
        l = strip(readline(io))
    end
    l == "65538 1" || error("Unknown Andor version number at line 2: " * l)

    # line 3 TInstaImage thru "Head model"
    l = strip(readline(io))
    fields = split(l)
    fields[1] == "65547" || fields[1] == "65558" || fields[1] == "65567" ||
        error("Unknown TInstaImage version number at line 3: " * fields[1])

    ixon = Dict{Any,Any}()
    ixon["data_type"] = parse(Int,fields[2])
    ixon["active"] = parse(Int,fields[3])
    ixon["structure_vers"] = parse(Int,fields[4]) # (== 1)
    # date is recored as seconds counted from 1970.1.1 00:00:00
    ixon["date"] = parse(Int,fields[5]) # need to convert to actual date
    ixon["temperature"] = max(parse(Float64,fields[6]), parse(Float64,fields[48]))
    ixon["temperature_stable"] = parse(Float64,fields[6]) != -999
    ixon["head"] = fields[7]
    ixon["store_type"] = fields[8]
    ixon["data_type"] = fields[9]
    ixon["mode"] = fields[10]
    ixon["trigger_source"] = fields[11]
    ixon["trigger_level"] = fields[12]
    ixon["exposure_time"] = parse(Float64,fields[13])
    ixon["frame_delay"] = parse(Float64,fields[14])
    ixon["integration_cycle_time"] = parse(Float64,fields[15])
    ixon["no_integrations"] = parse(Int,fields[16])
    ixon["sync"] = fields[17]
    ixon["kin_cycle_time"] = parse(Float64,fields[18])
    ixon["pixel_readout_time"] = parse(Float64,fields[19])
    ixon["no_points"] = parse(Int,fields[20])
    ixon["fast_track_height"] = parse(Int,fields[21])
    ixon["gain"] = parse(Int,fields[22])
    ixon["gate_delay"] = parse(Float64,fields[23])
    ixon["gate_width"] = parse(Float64,fields[24])
    ixon["gate_step"] = parse(Float64,fields[25])
    ixon["track_height"] = parse(Int,fields[26])
    ixon["series_length"] = parse(Int,fields[27])
    ixon["read_pattern"] = fields[28]
    ixon["shutter_delay"] = fields[29]
    ixon["st_center_row"] = parse(Int,fields[30])
    ixon["mt_offset"] = parse(Int,fields[31])
    ixon["operation_mode"] = fields[32]
    ixon["flipx"] = fields[33]
    ixon["flipy"] = fields[34]
    ixon["clock"] = fields[35]
    ixon["aclock"] = fields[36]
    ixon["MCP"] = fields[37]
    ixon["prop"] = fields[38]
    ixon["IOC"] = fields[39]
    ixon["freq"] = fields[40]
    ixon["vert_clock_amp"] = fields[41]
    ixon["data_v_shift_speed"] = parse(Float64,fields[42])
    ixon["output_amp"] = fields[43]
    ixon["pre_amp_gain"] = parse(Float64,fields[44])
    ixon["serial"] = parse(Int,fields[45])
    ixon["num_pulses"] = parse(Int,fields[46])
    ixon["m_frame_transfer_acq_mode"] = parse(Int,fields[47])
    ixon["unstabilized_temperature"] = parse(Float64,fields[48])
    ixon["m_baseline_clamp"] = parse(Int,fields[49])
    ixon["m_pre_scan"] = parse(Int,fields[50])
    ixon["m_em_real_gain"] = parse(Int,fields[51])
    ixon["m_baseline_offset"] = parse(Int,fields[52])
    _ = fields[53]
    _ = fields[54]
    ixon["sw_vers1"] = parse(Int,fields[55])
    ixon["sw_vers2"] = parse(Int,fields[56])
    ixon["sw_vers3"] = parse(Int,fields[57])
    ixon["sw_vers4"] = parse(Int,fields[58])

    # line 4
    ixon["camera_model"] = strip(readline(io))

    # line 5 something like camera dimensions??
    _ = readline(io)

    # line 6
    ixon["original_filename"] = strip(readline(io))

    # line 7
    l = strip(readline(io))
    fields = split(l)
    fields[1] == "65538" || error("Unknown TUserText version number in line 7: $fields[1]")
    usertextlen = parse(Int,fields[2]) # don't need?

    # line 8
    usertext = strip(readline(io))
    # ixon["usertext"] = usertext # Not useful

    # line 9 TShutter
    l = strip(readline(io)) # Weird!

    # line 10 TCalibImage
    l = strip(readline(io))

    # Skip a number of lines until we get to this part:
    # -1
    # 65538 0 512 512 512 512 1 1 1 1
    # 65540
    # 0 1 0 0
    # 0 1 0 0
    # 0 1 0 0
    l = strip(readline(io))
    while l != "-1"
        # repeat until we get there
        l = strip(readline(io))
    end
    # Then skip some lines
    for i = 1:9
        _ = strip(readline(io))
    end

    # what a bizarre file format here
    # length of the next string is in this line
    next_str_len = parse(Int,strip(readline(io)))
    # and here is the next string, followed by the length
    # of the following string, with no delimeter in between!
    l = strip(readline(io))
    next_str_len = parse(Int,l[(next_str_len + 1):end])
    # lather, rinse, repeat...
    l = strip(readline(io))
    next_str_len = parse(Int,l[(next_str_len + 1):end])

    l = strip(readline(io))
    l = l[(next_str_len + 1):end]
    fields = split(l)
    fields[1] == "65538" || fields[1] == "65541" ||
        error("Unknown version number at image dims record")
    ixon["image_format_left"] = parse(Int,fields[2])
    ixon["image_format_top"] = parse(Int,fields[3])
    ixon["image_format_right"] = parse(Int,fields[4])
    ixon["image_format_bottom"] = parse(Int,fields[5])
    frames = parse(Int,fields[6])
    ixon["frames"] = frames
    ixon["num_subimages"] = parse(Int,fields[7])
    ixon["total_length"] = parse(Int,fields[8]) # in pixels across all frames
    ixon["single_frame_length"] = parse(Int,fields[9])

    # Now at the first (and only) subimage
    l = strip(readline(io))
    fields = split(l)
    fields[1] == "65538" || error("unknown TSubImage version number: " * fields[1])
    left = parse(Int,fields[2])
    top = parse(Int,fields[3])
    right = parse(Int,fields[4])
    bottom = parse(Int,fields[5])
    vertical_bin = parse(Int,fields[6])
    horizontal_bin = parse(Int,fields[7])
    subimage_offset = parse(Int,fields[8])

    # calculate frame width, height, with binning
    width = right - left + 1
    mod = width%horizontal_bin
    width = (width - mod) ÷ horizontal_bin
    height = top - bottom + 1
    mod = height%vertical_bin
    height = (height - mod) ÷ vertical_bin

    ixon["left"] = left
    ixon["top"] = top
    ixon["right"] = right
    ixon["bottom"] = bottom
    ixon["vertical_bin"] = vertical_bin
    ixon["horizontal_bin"] = horizontal_bin
    ixon["subimage_offset"] = subimage_offset

    # rest of the header is a timestamp for each frame
    # (actually, just a bunch of zeros). Skip
    for i = 1:frames
        _ = readline(io)
    end

    # two additional lines?
    _ = readline(io)
    _ = readline(io)

    offset = position(io) # start of the actual pixel data, 32-bit float, little-endian

    pixelmatrix = Array{Gray{Float32}}(undef, height, width, frames)
    read!(io, pixelmatrix)
    properties = Dict(
        :ixon => ixon,
    )
    ImageMeta(pixelmatrix, properties)
end

end # module
