const inf::Int64 = typemax(Int64)

# -1 for non passable               @   .  S  W  T
const costMatrix::Matrix{Int64} = [-1 -1 -1 -1 -1; # @
                                   -1  1  3 -1 -1; # .
                                   -1  3  5 -1 -1; # S
                                   -1 -1 -1  1 -1; # W
                                   -1 -1 -1 -1 -1] # T

function init_pathfinders(mapTitle::String)
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
     
    dist = fill(inf, (height,width))       # Indicates distance from origin
    visited = fill(false, (height,width))  # Indicates processed points
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)  # Indicates parent
    pq = PriorityQueue{Tuple{Int64, Int64}, Int64}()         # Tracking openned points
    adj = Vector{Tuple{Int64,Int64}}(undef, 4)  # Collects adjacent points
        
    dist[ori[1], ori[2]] = 0    # Setting the origin's distance from itself
    newPoints = true
end
