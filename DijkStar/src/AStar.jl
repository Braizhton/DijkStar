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
               dest::Tuple{Int64,Int64})

    # INITIATIONS
    inf = typemax(Int64)            # Infinity
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
   
    dist = fill(inf, (height,width))
    visited = fill(false, (height,width))
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)
    pq = PriorityQueue{Tuple{Int64, Int64}, Tuple{Int64, Int64}}(AStarOrder())

    adj = Dict('N' => (0,0),
               'S' => (0,0),
               'W' => (0,0),
               'E' => (0,0))

    tileIndex::Dict{Char, Int64} = Dict('@' => 1,
                                        'O' => 1,
                                        'T' => 1,
                                        '.' => 2,
                                        'G' => 2,
                                        'S' => 3,
                                        'W' => 4)

                                # @   .   S   W
    costMatrix::Matrix{Int64} = [inf inf inf inf; # @
                                 inf  1   3  inf; # .
                                 inf  3   5  inf; # S
                                 inf inf inf  1]  # W
    # BEGIN
    dist[ori[1], ori[2]] = 0
    push!(pq, ori => (0,abs(dest[1]-ori[1]) + abs(dest[2]-ori[2])))

    newPoints = true
    while newPoints
        new = false

        (min_x, min_y), min = first(pq) # Getting the point with minimum distance
        min = dist[min_x, min_y]        # Setting right minium distance
        dequeue!(pq)                    # Removing the point being processed
        visited[min_x, min_y] = true    # Setting point as visited        
        
        if (min_x, min_y) == dest       # Breaking if a shortest path has been found for the destination
            break
        end
        
        # Collecting adjacent points
        adj['N'] = (min_x-1, min_y)
        adj['S'] = (min_x+1, min_y)
        adj['W'] = (min_x, min_y-1)
        adj['E'] = (min_x, min_y+1)

        # Processing adjacent points
        for key in keys(adj)
            x, y = adj[key]
            # Checking if the point is inbounds
            if (x >= 1 && x <= width && y >= 1 && y <= height)
                # Calculating transition cost
                tc = costMatrix[tileIndex[mapMatrix[min_x,min_y]],
                                tileIndex[mapMatrix[x,y]]]
                # Checking if the point is a wall
                if tc == inf
                    visited[x,y] = true
                    continue
                end

                newDist = dist[min_x,min_y] + tc
                distToDest = abs(dest[1]-x) + abs(dest[2]-y)

                if (!visited[x,y] && newDist < dist[x,y] && dist[min_x,min_y]!=inf)
                    dist[x,y] = newDist
                    prec[x,y] = (min_x,min_y)
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
