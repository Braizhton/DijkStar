include("ReadMap.jl")
include("TransitionCost.jl")
include("MapWindow.jl")
using DataStructures

function dijkstra(mapTitle::String, ori::Tuple{Int64,Int64}, dest::Tuple{Int64,Int64}, scale::Int64)

    # INITIATIONS
    inf = typemax(Int64)            # Infinity
    mapMatrix = read_map(mapTitle)  # Map matrix
    height, width = size(mapMatrix) # Dimensions
   
    dist = fill(inf, (height,width))                          # Distance of each point from the origin
    visited = fill(false, (height,width))                     # Indicates if the shortest path to a point has been found
    prec = Matrix{Tuple{Int64,Int64}}(undef, height, width)   # Indicates for each point the path preceding point
    pq = PriorityQueue{Tuple{Int64, Int64}, Int64}()          # Tracking the unprocessed point with minimum distance to the origin

    adj = Dict('N' => (0,0),    # Setting a dictionnary to process adjacent points
               'S' => (0,0),
               'W' => (0,0),
               'E' => (0,0))

    # BEGIN
    dist[ori[1], ori[2]] = 0    # Setting the origin's distance from itself
    push!(pq, ori => 0)         # Initiating the priority queue

    newPoints = true
    while newPoints
        new = false

        (min_x, min_y), min = first(pq)     # Getting the point with minimum distance
        dequeue!(pq)                        # Removing the point being processed
        visited[min_x, min_y] = true        # Setting point as visited        
        
        if (min_x, min_y) == dest           # Breaking if a shortest path has been found for the destination
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
                tc = transition_cost(mapMatrix[min_x,min_y], mapMatrix[x,y])
                # Checking if the point is a wall
                if tc == inf
                    visited[x,y] = true # Set as visited and skip the process
                    continue
                end

                newDist = dist[min_x,min_y] + tc # Current distance + cost to the adjacent point
                if (!visited[x,y] && newDist < dist[x,y] && dist[min_x,min_y]!=inf)
                    dist[x,y] = newDist          # Updating shortest distance to (x,y)
                    prec[x,y] = (min_x,min_y)    # Setting parent
                    push!(pq, (x,y) => newDist)  # Adding the new distance to the queue
                    newPoints = true             # Indicating that new points have to be processed
                end
            end
        end
    end
    # END

    # PRINTING
    (x,y) = dest
    while (x,y) != ori
        println((x,y))
        (x,y) = prec[x,y]
    end
    println(ori)

    ### GRAPHICS ###
    draw_map_window(mapMatrix, prec, ori, dest, mapTitle, scale)
end

