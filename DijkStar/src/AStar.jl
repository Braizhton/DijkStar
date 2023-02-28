include("ReadMap.jl")
#include("TransitionCost.jl")
include("MapWindow.jl")
using DataStructures

import Base.Ordering
import Base.lt
struct AStarOrder <: Ordering end
# Order is based on the distance to origin + the distance to destination
# In case of equality, on distance to destination
lt(::AStarOrder, (x1, y1), (x2, y2)) = x1 + y1 < x2 + y2 || x1 + y1 == x2 + y2 && y1 > y2

function astar(mapTitle::String,
               ori::Tuple{Int64,Int64},
               dest::Tuple{Int64,Int64},
               drawOn::Bool)

    # INITIATIONS
    inf = typemax(Int64)            # Infinity
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
   
    dist = fill(inf, (height,width))
    visited = fill(false, (height,width))
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)
    pq = PriorityQueue{Tuple{Int64, Int64}, Tuple{Int64, Int64}}(AStarOrder())

    
    adj = Vector{Tuple{Int64,Int64}}(undef, 4)  # Setting a vector to process adjacent points

    tileIndex::Dict{Char, Int64} = Dict('@' => 1,
                                        'O' => 1,
                                        'T' => 1,
                                        '.' => 2,
                                        'G' => 2,
                                        'S' => 3,
                                        'W' => 4)

                                # @  .  S  W
    costMatrix::Matrix{Int64} = [-1 -1 -1 -1; # @
                                 -1  1  3 -1; # .
                                 -1  3  5 -1; # S
                                 -1 -1 -1  1] # W
    # BEGIN
    dist[ori[1], ori[2]] = 0
    push!(pq, ori => (0,0))

    newPoints = true
    while newPoints
        new = false

        (mx, my) = dequeue!(pq) # Getting the point with minimum distance
        min = dist[mx, my]      # Setting right minium distance
        visited[mx, my] = true  # Setting point as visited        
        
        if (mx, my) == dest     # Breaking if a shortest path has been found for the destination
            break
        end
        
        # Collecting adjacent points
        adj[1] = (mx-1, my)
        adj[2] = (mx+1, my)
        adj[3] = (mx, my-1)
        adj[4] = (mx, my+1)

        # Processing adjacent points
        for (x,y) in adj
            # Checking if the point is inbounds
            if (x >= 1 && x <= width && y >= 1 && y <= height)
                # Calculating transition cost
                tc = costMatrix[tileIndex[mapMatrix[mx,my]],
                                tileIndex[mapMatrix[x,y]]]
                # Checking if the point is a wall
                if tc < 0
                    visited[x,y] = true
                    continue
                end

                newDist = dist[mx,my] + tc
                distToDest = abs(dest[1]-x) + abs(dest[2]-y)

                if (!visited[x,y] && newDist < dist[x,y] && dist[mx,my]<=inf-tc)
                    dist[x,y] = newDist
                    prec[x,y] = (mx,my)
                    # Pushing with an existing key isn't a problem
                    # Because it just updates the value associated with the key
                    push!(pq, (x,y) => (newDist,distToDest))
                    newPoints = true
                end
            end
        end
    end
    # END

    # PRINTING
    if drawOn
        pathLength = 1
        (x,y) = prec[dest[1], dest[2]]
        while (x,y) != ori
            pathLength += 1
            println((x,y))
            (x,y) = prec[x,y]
        end
        println(ori)
        println("Path length from  ", ori, " to ", dest, ": ", pathLength)

        ### GRAPHICS ###
        draw_map_window(mapMatrix, prec, ori, dest, mapTitle)
    end
end
