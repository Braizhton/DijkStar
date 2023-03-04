struct AStarOrder <: Ordering end
# Order is based on the distance to origin + the distance to destination
# In case of equality, on distance to destination
lt(::AStarOrder, (x1, y1), (x2, y2)) = x1 + y1 < x2 + y2 || x1 + y1 == x2 + y2 && y1 > y2

function astar(mapTitle::String,
               o::Tuple{Int64,Int64},
               d::Tuple{Int64,Int64},
               displayOn::Bool)

    # INITIATIONS
    inf = typemax(Int64)            # Infinity
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
    nbVisited = 0
    ori = (o[2],o[1])
    dest = (d[2],d[1])
   
    dist = fill(inf, (height,width))
    visited = fill(false, (height,width))
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)
    pq = PriorityQueue{Tuple{Int64, Int64}, Tuple{Int64, Int64}}(AStarOrder())

    adj = Vector{Tuple{Int64,Int64}}(undef, 4)  # To collect adjacent points

    # -1 for non passable
    #              @   .  S  W  T
    costMatrix = [-1 -1 -1 -1 -1; # @
                  -1  1  3 -1 -1; # .
                  -1  3  5 -1 -1; # S
                  -1 -1 -1  1 -1; # W
                  -1 -1 -1 -1 -1] # T

    # BEGIN
    dist[ori[1], ori[2]] = 0
    push!(pq, ori => (0,0))

    newPoints = true
    while newPoints
        new = false

        (mx, my) = dequeue!(pq) # Getting the point with minimum distance
        min = dist[mx, my]      # Setting minium distance
        if (mx, my) == dest     # Breaking if a shortest path has been found
            break
        end
        visited[mx, my] = true  # Setting point as visited
        nbVisited += 1
        
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
                tc = costMatrix[mapMatrix[mx,my],
                                mapMatrix[x,y]]
                # Checking if the point is a wall
                if tc < 0
                    visited[x,y] = true
                    continue
                end

                newDist = dist[mx,my] + tc
                distToDest = abs(dest[1]-x) + abs(dest[2]-y)

                if (!visited[x,y] && newDist < dist[x,y])# && dist[mx,my]<=inf-tc)
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
    if displayOn
        ### COMMAND LINE ### 
        display_path(mapMatrix, prec, costMatrix, ori, dest)

        ###   GRAPHICS   ###
        draw_map_window(mapMatrix, prec, visited, ori, dest, mapTitle)
    end
end
