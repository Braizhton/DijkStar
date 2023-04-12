struct AStarOrder <: Ordering end
# Order is based on the distance to origin + the distance to destination
# In case of equality, on distance to destination
lt(::AStarOrder, (x1, y1), (x2, y2)) = x1 + y1 < x2 + y2 || x1 + y1 == x2 + y2 && y1 < y2

function findPathAStar(canvas::GtkCanvas,
                      ori::Tuple{Int64,Int64},
                      dest::Tuple{Int64, Int64},
                      mapMatrix::Matrix{Int64},
                      colorMatrix::Matrix{RGB{FixedPointNumbers.N0f8}},
                      stepByStep::Bool = false)#, speed::Float64)
    # Colors
    gradStart = colorant"lime"
    gradEnd = colorant"red"
    normalPath = colorant"mediumpurple"
    slowPath = colorant"mediumorchid"
    visitedColor = colorant"cyan"
    
    # Initiations
    h, w = size(mapMatrix) 
    nbVisited = 0

    grad = convert.(RGB,
                   range(HSL(gradStart),
                         stop=HSL(gradEnd),
                         length=floor(Int, sqrt(h^2+w^2))))

    dist = Matrix{Int64}(undef, h, w)
    state = fill(unvisited, h, w)
    prec = Matrix{Tuple{Int64,Int64}}(undef, h, w)
    pq = PriorityQueue{Tuple{Int64, Int64}, Tuple{Int64, Int64}}(AStarOrder())
    
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
    dist[ori[1], ori[2]] = 0
    push!(pq, ori => (0,0))

    (mx,my) = ori
    while !((mx,my) == dest || isempty(pq))

        (mx, my) = dequeue!(pq) # Getting the point with minimum distance
        state[mx, my] = closed  # Setting point as visited        

        if !((mx,my) == ori || (mx,my) == dest)
            # Setting visited on canvas
            colorMatrix[mx, my] =
                grad[floor(Int, sqrt(abs(ori[1]-mx)^2+abs(ori[2]-my)^2)+1)]
        end
        
        if stepByStep
            draw(canvas) # Refreshing
        end
        #sleep(speed)
        
        # Collecting adjacent points
        adj[1] = (mx-1, my)
        adj[2] = (mx+1, my)
        adj[3] = (mx, my-1)
        adj[4] = (mx, my+1)

        # Processing adjacent points
        for (x,y) in adj
            # Checking if the point is inbounds
            if (x >= 1 && x <= w && y >= 1 && y <= h)
                nstate = state[x,y]

                # Calculating transition cost
                tc = costMatrix[mapMatrix[mx,my], mapMatrix[x,y]]
                # Checking if the point is a wall
                if tc < 0
                    state[x,y] = closed # Set as visited and skip the process
                    #=
                    colorMatrix[x,y] = last(grad) # Setting as unreachable on canvas
                    if stepByStep
                         draw(canvas) # Refreshing
                    end
                    sleep(speed)
                    =#
                    continue
                end

                newDist = dist[mx,my] + tc
                if nstate != closed
                    newDist = dist[mx,my] + tc
                    distToDest = abs(dest[1]-x) + abs(dest[2]-y)

                    if nstate == unvisited
                        nbVisited += 1
                        colorMatrix[x,y] = visitedColor
                        state[x,y] = openned
                        dist[x,y] = newDist
                        prec[x,y] = (mx,my)
                        push!(pq, (x,y) => (newDist, distToDest))

                    elseif nstate == openned && newDist < dist[x,y]
                        dist[x,y] = newDist
                        prec[x,y] = (mx,my)
                        push!(pq, (x,y) => (newDist, distToDest))
                    end
                end
            end
        end
    end

    # Drawing shortest path
    pathLength = 1
    colorMatrix[dest[1],dest[2]] = gradEnd
    (x,y) = prec[dest[1], dest[2]]
    pathCost = costMatrix[mapMatrix[dest[1],dest[2]],mapMatrix[x,y]]
    while (x,y) != ori
        pathLength += 1
        if mapMatrix[x,y] == 'S'
            colorMatrix[x,y] = slowPath
        else
            colorMatrix[x,y] = normalPath
        end
        cur = (x,y)
        (x,y) = prec[x,y]
        pathCost += costMatrix[mapMatrix[x,y],mapMatrix[cur[1],cur[2]]]

        #if stepByStep
        #    draw(canvas) # Refreshing
        #end
        #sleep(speed)
    end
    println("Path length from  ", ori, " to ", dest, " : ", pathLength)
    println("Path cost : ", pathCost)
    println("Visited nodes : ", nbVisited)
    draw(canvas)
    #END
end

function astarGUI(title::String, stepByStep::Bool = false)#, speed::Float64)
    # INITIATIONS
    oriColor = colorant"magenta"
    destColor = colorant"red"

    colorSet = [colorant"black",
                colorant"wheat",
                colorant"darkkhaki",
                colorant"dodgerblue",
                colorant"forestgreen"]
   
    mapMatrix = read_map(title)
    global colorMatrix = map((x -> colorSet[x]), mapMatrix)

    # Setting canvas and window
    h, w = size(mapMatrix)
    scale = ceil(Int, 950/h)
    if scale*h > 1080
        scale -= 1
    end
    hc = scale*h
    wc = scale*w
    canvas = @GtkCanvas(wc,hc)
    canvas.draw = mapDraw # Setting new draw function
    box = GtkBox(:h)
    push!(box,canvas)
    set_gtk_property!(box,:expand,canvas,true)
    mapWindow = GtkWindow(box, title, resizable=false)
           
    # Initiating origin and destination by clicking on the canvas
    ori = (0,0)
    dest = (0,0)
    waitOrigin = true
    waitDest = true
    done = false

    id = signal_connect(canvas, "button-press-event") do widget, event
        if event.button == 1
            x = ceil(Int, event.y/scale) # Index i (height)
            y = ceil(Int, event.x/scale) # Index j (width)
            #=if !done
                println("x : ", y)
                println("y : ", x)
            end=#
            if waitOrigin
                waitOrigin = false
                ori = (x,y)
                colorMatrix[x,y] = oriColor
                draw(canvas)
            elseif waitDest && (x,y) != ori
                waitDest = false
                dest = (x,y)
                colorMatrix[x,y] = destColor
                draw(canvas)
            end
        end
        
        # Calling pathfinding function after origin and destination are set
        if !waitOrigin && !waitDest && !done
            done = true
            println("---------------------------")
            @time findPathAStar(canvas,
                                ori, dest,
                                mapMatrix, colorMatrix,
                                stepByStep)#, speed)
            #println("---------------------------")
        elseif done
            # Reset !
            done = false
            waitOrigin = waitDest = true
            colorMatrix = (x -> colorSet[x]).(mapMatrix)
            draw(canvas)
        end
    end
    showall(mapWindow)
end
