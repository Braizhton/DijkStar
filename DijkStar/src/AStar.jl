struct AStarOrder <: Ordering end
# Order is based on the distance to origin + the distance to destination
# In case of equality, on distance to destination
lt(::AStarOrder, (x1, y1), (x2, y2)) = x1 + y1 < x2 + y2 || x1 + y1 == x2 + y2 && y1 < y2

function astar(mapTitle::String,
               o::Tuple{Int64,Int64},
               d::Tuple{Int64,Int64},
               displayOn::Bool)

    # INITIATIONS
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
    nbVisited = 0
    ori = (o[2],o[1])
    dest = (d[2],d[1])
   
    dist = Matrix{Int64}(undef, height, width)
    state = fill(unvisited, height, width)
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)
    pq = PriorityQueue{Tuple{Int64, Int64}, Tuple{Int64, Int64}}(AStarOrder())

    adj = Vector{Tuple{Int64,Int64}}(undef, 4)

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
    dist[ori[1], ori[2]] = 0
    push!(pq, ori => (0,0))

    (mx,my) = ori
    while !((mx,my) == dest || isempty(pq))

        (mx, my) = dequeue!(pq)
        state[mx, my] = closed
        
        # Collecting adjacent points
        adj[1] = (mx-1, my)
        adj[2] = (mx+1, my)
        adj[3] = (mx, my-1)
        adj[4] = (mx, my+1)

        # Processing adjacent points
        for (x,y) in adj
            if (x >= 1 && x <= width && y >= 1 && y <= height)
                nstate = state[x,y]

                tc = costMatrix[mapMatrix[mx,my],mapMatrix[x,y]]
                if tc < 0
                    #state[x,y] = closed
                    continue
                end

                if nstate != closed
                    newDist = dist[mx,my] + tc
                    distToDest = abs(dest[1]-x) + abs(dest[2]-y)

                    if nstate == unvisited
                        nbVisited += 1
                        state[x,y] = openned
                        dist[x,y] = newDist
                        prec[x,y] = (mx,my)
                        push!(pq, (x,y) => (newDist,distToDest))

                    elseif nstate == openned && newDist < dist[x,y]    
                        dist[x,y] = newDist
                        prec[x,y] = (mx,my)
                        push!(pq, (x,y) => (newDist,distToDest))
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
