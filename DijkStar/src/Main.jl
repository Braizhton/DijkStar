function main(mapTitle::String,
              src::Tuple{Int64,Int64}, goal::Tuple{Int64,Int64},
              quiet::Bool,
              algorithm::String)

    # INITIATIONS
    inf = typemax(Int64)            # Infinity
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
    nbVisited = 0
    ori = (src[2],src[1])
    dest = (goal[2],goal[1])
   
    dist = fill(inf, (height,width))
    visited = fill(false, (height,width))
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)
    adj = Vector{Tuple{Int64,Int64}}(undef, 4)  # To collect adjacent points

    # -1 for non passable
    #              @   .  S  W  T
    costMatrix = [-1 -1 -1 -1 -1; # @
                  -1  1  3 -1 -1; # .
                  -1  3  5 -1 -1; # S
                  -1 -1 -1  1 -1; # W
                  -1 -1 -1 -1 -1] # T

    if algorithm == "dijkstra"
        dijkstra(mapMatrix, dist, visited, prec, adj,
                 width, height,
                 nbVisited,
                 ori, dest)
    elseif algorithm == "astar"
        astar(mapMatrix, dist, visited, prec, adj,
              width, height,
              nbVisited,
              ori, dest)
    else
        println("Unknown algorithm")
        return
    end

    if !quiet
        display_path(mapMatrix, prec, costMatrix, ori, dest)
        draw_map_window(mapMatrix, prec, visited, ori, dest, mapTitle)
    end
end
