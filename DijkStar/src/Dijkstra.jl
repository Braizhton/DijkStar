function dijkstra(mapTitle::String,
                  ori::Tuple{Int64,Int64},
                  dest::Tuple{Int64,Int64},
                  displayOn::Bool)

    # INITIATIONS
    inf = typemax(Int64)
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
   
    dist = fill(inf, (height,width))                          # Distance of each point from the origin
    visited = fill(false, (height,width))                     # Indicates if the shortest path to a point has been found
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)   # Indicates for each point the path preceding point
    pq = PriorityQueue{Tuple{Int64, Int64}, Int64}()          # Tracking the unprocessed point with minimum distance to the origin

    adj = Vector{Tuple{Int64,Int64}}(undef, 4)  # To collect adjacent points
    
    # -1 for non passable 
    #              @   .  S  W  T
    costMatrix = [-1 -1 -1 -1 -1; # @
                  -1  1  3 -1 -1; # .
                  -1  3  5 -1 -1; # S
                  -1 -1 -1  1 -1; # W
                  -1 -1 -1 -1 -1] # T

    # BEGIN
    dist[ori[1], ori[2]] = 0    # Setting the origin's distance from itself
    push!(pq, ori => 0)         # Initiating the priority queue

    newPoints = true
    while newPoints
        new = false

        (mx, my), min = dequeue_pair!(pq)   # Getting the point with minimum distance
        if (mx, my) == dest                 # Breaking if destination is visited
            break
        end
        visited[mx, my] = true              # Setting point as visited        
        
        
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
                tc = costMatrix[mapMatrix[mx,my], mapMatrix[x,y]]
                # Checking if the point is a wall
                if tc < 0
                    visited[x,y] = true # Set as visited and skip the process
                    continue
                end
                
                newDist = dist[mx,my] + tc # Current distance + cost to the adjacent point
                if (!visited[x,y] && newDist < dist[x,y])# && dist[mx,my] <= inf-tc)
                    dist[x,y] = newDist         # Updating shortest distance to (x,y)
                    prec[x,y] = (mx,my)         # Setting parent
                    push!(pq, (x,y) => newDist) # Adding the new distance to the queue
                    newPoints = true            # Indicating that new points have to be processed
                end
            end
        end
    end
    # END

    # PRINTING
    if displayOn
        ### COMMAND LINE ###
        display_path(prec, ori, dest)

        ###   GRAPHICS   ###
        draw_map_window(mapMatrix, prec, ori, dest, mapTitle)
    end
end
