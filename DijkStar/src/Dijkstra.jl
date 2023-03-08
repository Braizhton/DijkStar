function dijkstra(mapTitle::String,
                  o::Tuple{Int64,Int64},
                  d::Tuple{Int64,Int64},
                  displayOn::Bool)

    # INITIATIONS
    @enum State openned visited closed
    inf = typemax(Int64)
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
    nbVisited = 0
    ori = (o[2],o[1])
    dest = (d[2],d[1])
   
    dist = Matrix{Int64}(undef, height, width)                # Points' distance from origin
    state = fill(openned, height, width)                      # Indicates nodes' state
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)   # Points' parent
    pq = PriorityQueue{Tuple{Int64, Int64}, Int64}()          # Queue of visited points

    adj = Vector{Tuple{Int64,Int64}}(undef, 4)  # To collect adjacent points
    
    # -1 for non passable 
    #              @  .  S  W  T
    costMatrix = [-1 -1 -1 -1 -1; # @
                  -1  1  3 -1 -1; # .
                  -1  3  5 -1 -1; # S
                  -1 -1 -1  1 -1; # W
                  -1 -1 -1 -1 -1] # T

    # BEGIN
    dist[ori[1], ori[2]] = 0    # Setting the origin's distance from itself
    push!(pq, ori => 0)         # Initiating the priority queue

    update = true
    while update
        update = false

        (mx, my), min = dequeue_pair!(pq)   # Getting the point with minimum distance
        if (mx, my) == dest                 # Breaking if destination is visited
            break
        end
        state[mx, my] = closed              # Closing node        
        
        # Collecting adjacent points
        adj[1] = (mx-1, my)
        adj[2] = (mx+1, my)
        adj[3] = (mx, my-1)
        adj[4] = (mx, my+1)

        # Processing adjacent points
        for (x,y) in adj
            # Checking if the point is inbounds
            if (x >= 1 && x <= width && y >= 1 && y <= height)
                nbVisited += 1

                # Calculating transition cost
                tc = costMatrix[mapMatrix[mx,my], mapMatrix[x,y]]

                # Checking if the point is a wall
                if tc < 0
                    state[x,y] = closed # Set as closed and skip the process
                    continue
                end
                
                if state[x,y] != closed
                    newDist = dist[mx,my] + tc  # Current distance + cost to the adjacent point
                    if (state[x,y] == visited && newDist < dist[x,y])
                        dist[x,y] = newDist     # Updating shortest distance
                    else
                        dist[x,y] = tc          # Setting shortest distance
                    end
                    prec[x,y] = (mx,my)         # Setting parent
                    push!(pq, (x,y) => newDist) # Updating priority queue
                    update = true               # Indicating continuation
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
        draw_map_window(mapMatrix, prec, state, ori, dest, mapTitle)
    end
end
