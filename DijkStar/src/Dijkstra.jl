function dijkstra(mapTitle::String,
                  o::Tuple{Int64,Int64},
                  d::Tuple{Int64,Int64},
                  displayOn::Bool)

    # INITIATIONS
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
    # Inversing coords to have (x,y) points and note (y,x) points
    ori = (o[2],o[1])
    dest = (d[2],d[1])
    
    nbVisited = 0
   
    dist = Matrix{Int64}(undef, height, width)                # Points' distance from origin
    state = fill(unvisited, height, width)                    # Indicates nodes' state
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)   # Points' parent
    pq = PriorityQueue{Tuple{Int64, Int64}, Int64}()          # Queue of visited points

    adj = Vector{Tuple{Int64,Int64}}(undef, 4)  # To collect adjacent points
    
    #= -1 for non passable 
    #              @  .  S  W  T
    costMatrix = [-1 -1 -1 -1 -1; # @
                  -1  1  3 -1 -1; # .
                  -1  3  5 -1 -1; # S
                  -1 -1 -1  1 -1; # W
                  -1 -1 -1 -1 -1] # T
    =#
    costMatrix = [-1 -1 -1 -1 -1; # @
                  -1  1  5  8 -1; # .
                  -1  1  5  8 -1; # S
                  -1  1  5  8 -1; # W
                  -1 -1 -1 -1 -1] # T

    # BEGIN
    dist[ori[1], ori[2]] = 0    # Setting the origin's distance from itself
    push!(pq, ori => 0)         # Initiating the priority queue

    (mx,my) = ori
    while !((mx,my) == dest || isempty(pq))

        (mx, my) = dequeue!(pq) # Getting the next point with minimum distance
        state[mx, my] = closed  # Setting node as closed        
        
        # Collecting adjacent points
        adj[1] = (mx-1, my)
        adj[2] = (mx+1, my)
        adj[3] = (mx, my-1)
        adj[4] = (mx, my+1)

        # Processing adjacent points
        for (x,y) in adj
            # Checking if the point is inbounds
            if x >= 1 && x <= width && y >= 1 && y <= height
                nstate = state[x,y]

                # Calculating transition cost
                tc = costMatrix[mapMatrix[mx,my],mapMatrix[x,y]]
                # Checking if the point is a wall
                if tc < 0
                    #state[x,y] = closed # Set as closed and skip the process
                    continue
                end
                
                if nstate != closed
                    newDist = dist[mx,my] + tc      # Current distance + transition cost
                    if nstate == unvisited
                        nbVisited += 1
                        state[x,y] = openned        # Setting as open
                        dist[x,y] = newDist         # Setting distance from origin
                        prec[x,y] = (mx,my)         # Setting parent
                        push!(pq, (x,y) => newDist) # Adding in priority queue

                    elseif nstate == openned && newDist < dist[x,y]
                        dist[x,y] = newDist         # Updating shortest distance
                        prec[x,y] = (mx,my)         # Setting parent
                        push!(pq, (x,y) => newDist) # Updating priority queue
                    end
                end
            end
        end
    end
    # END

    # PRINTING
    if (mx,my) != dest
        println("No path were found from ", ori, " to ", dest, "!!")
    elseif displayOn && (mx,my) == dest
        # COMMAND LINE
        display_path(mapMatrix, prec, costMatrix, ori, dest, nbVisited)

        # GRAPHICS
        draw_map_window(mapMatrix, prec, state, ori, dest, mapTitle)
    end
end
