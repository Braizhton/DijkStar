function read_map(map::String)
    mapInput::IOStream = open(map, "r")

    s::String = readline(mapInput) # Reading the first line and testing file format
    if s != "type octile"
        print("Wrong file format !")
        return
    end

    # Reading line with height value
    height::Int64 = parse(Int64, readline(mapInput)[8:end]) 
    # Reading line with width value
    width::Int64 = parse(Int64, readline(mapInput)[7:end])

    #print("Height : ", height, "\n")
    #print("Width : ", width, "\n")

    trash = readline(mapInput)

    mapMatrix::Matrix{Char} = Matrix{Char}(undef, height, width)
   
    i::Int64 = 1
    for line in eachline(mapInput)
        mapMatrix[i,:] = collect(line)
        i = i + 1
    end

    tileIndex::Dict{Char, Int64} = Dict('@' => 1,
                                        'O' => 1,
                                        '.' => 2,
                                        'G' => 2,
                                        'S' => 3,
                                        'W' => 4,
                                        'T' => 5)

    finalMatrix = (x -> tileIndex[x]).(mapMatrix)

    return finalMatrix
end

# read_map(ARGS[1])
# mapInput = open(ARGS[1], "r")
