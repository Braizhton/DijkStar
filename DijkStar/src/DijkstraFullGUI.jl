include("ReadMap.jl")
include("TransitionCost.jl")
include("Dijkstra.jl")
using DataStructures, Gtk, Colors

function set_color(c::Char)
    if c == '.' || c == 'G'
        return colorant"wheat"        # Ground
    elseif c == 'S'
        return colorant"darkkhaki"    # Swamp
    elseif c == 'W'
        return colorant"dodgerblue"   # Water
    elseif c == 'T'
        return colorant"forestgreen"  # Trees 
    elseif c == '@' || c == 'O'
        return colorant"black"        # Out of bounds
    #=
    elseif c == 'X'
        return colorant"lime"         # Source
    elseif c == 'Y'
        return colorant"red"          # Destination
    elseif c == 'P'
        return colorant"mediumpurple" # Path
    elseif c == 'Q'
        return colorant"mediumorchid" # Slowed path
    =#
    end
end

function mapDraw(canvas::GtkCanvas)
    ctx = getgc(canvas)

    h, w = size(colorMatrix)
    hc = height(canvas)
    wc = width(canvas)
    scale = ceil(Int, hc/h)

    # Drawing map
    for i = 1:w, j = 1:h
        rectangle(ctx, (i-1)*scale, (j-1)*scale, scale, scale)
        set_source(ctx, colorMatrix[j,i])   # Setting graphic context color
        fill(ctx)                           # Filling canvas
    end
    show(canvas)
end

function findShowPath(canvas::GtkCanvas,
                      ori::Tuple{Int64,Int64},
                      dest::Tuple{Int64, Int64},
                      mapMatrix::Matrix{Char},
                      colorMatrix,
                      gradOn::Bool)#, speed::Float64)
    # Colors
    gradStart = colorant"lime"
    gradEnd = colorant"red"
    normalPath = colorant"mediumpurple"
    slowPath = colorant"mediumorchid"

    # Initiations
    h, w = size(mapMatrix) 
    inf = typemax(Int64)
    dist = fill(inf, (h,w))
    visited = fill(false, (h,w))
    prec = Matrix{Tuple{Int64,Int64}}(undef, h, w)
    pq = PriorityQueue{Tuple{Int64, Int64}, Int64}()
    grad = convert.(RGB,
                   range(HSL(gradStart),
                         stop=HSL(gradEnd),
                         length=floor(Int, sqrt(h^2+w^2))))

    adj = Dict('N' => (0,0),
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
        if (min_x, min_y) == dest           # Breaking if a shortest path has been found for the destination
            break
        end
        visited[min_x, min_y] = true               # Setting point as visited        
        if (min_x,min_y) != ori
            # Setting visited on canvas
            colorMatrix[min_x, min_y] = grad[floor(Int, sqrt(
                                                        (ori[1]-min_x)^2 +
                                                        (ori[2]-min_y)^2)+1)]
        end
        
        if gradOn
            draw(canvas) # Refreshing
        end
        #sleep(speed)
        
        # Collecting adjacent points
        adj['N'] = (min_x-1, min_y)
        adj['S'] = (min_x+1, min_y)
        adj['W'] = (min_x, min_y-1)
        adj['E'] = (min_x, min_y+1)

        # Processing adjacent points
        for key in keys(adj)
            x, y = adj[key]
            # Checking if the point is inbounds
            if (x >= 1 && x <= w && y >= 1 && y <= h)
                # Calculating transition cost
                tc = transition_cost(mapMatrix[min_x,min_y], mapMatrix[x,y])
                # Checking if the point is a wall
                if tc == inf
                    visited[x,y] = true # Set as visited and skip the process
                    #colorMatrix[x,y] = last(grad) # Setting as unreachable on canvas
                    # if gradOn
                        # draw(canvas) # Refreshing
                    # end
                    #sleep(speed)
                    continue
                end

                newDist = dist[min_x,min_y] + tc # Current distance + cost to the adjacent point
                if (!visited[x,y] && newDist < dist[x,y] && dist[min_x,min_y]!=inf)
                    dist[x,y] = newDist          # Updating shortest distance
                    prec[x,y] = (min_x,min_y)    # Setting parent
                    push!(pq, (x,y) => newDist)  # Adding the new distance
                    newPoints = true             # Indicating new points to process
                end
            end
        end
    end

    # Drawing shortest path
    pathLength = 1
    (x,y) = prec[dest[1], dest[2]]
    while (x,y) != ori
        pathLength += 1
        if mapMatrix[x,y] == 'S'
            colorMatrix[x,y] = slowPath
        else
            colorMatrix[x,y] = normalPath
        end
        (x,y) = prec[x,y]

        if gradOn
            draw(canvas) # Refreshing
        end
        #sleep(speed)
    end
    println("Path length from  ", ori, " to ", dest, " : ", pathLength)
    draw(canvas)
    #END
end

function dijkstraGUI(title::String, guiOn::Bool, gradOn::Bool)#, speed::Float64)
    # INITIATIONS
    oriColor = colorant"magenta"
    destColor = colorant"red"
    mapMatrix = read_map(title)
    global colorMatrix = map(set_color, mapMatrix)

    # Setting canvas and window
    h, w = size(mapMatrix)
    scale = ceil(Int, 950/h)
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
            # println("x : ", x)
            # println("y : ", y)
            if waitOrigin
                waitOrigin = false
                ori = (x,y)
                colorMatrix[x,y] = oriColor
                draw(canvas)
            elseif waitDest
                waitDest = false
                dest = (x,y)
                colorMatrix[x,y] = destColor
                draw(canvas)
            end
        end
        
        # Calling pathfinding function after origin and destination are set
        if !waitOrigin && !waitDest && !done
            done = true
            if guiOn
                findShowPath(canvas,
                             ori, dest,
                             mapMatrix, colorMatrix,
                             gradOn)#, speed)
            else
                dijkstra(title, ori, dest)
            end
        elseif done
            # Reset !
            done = false
            waitOrigin = waitDest = true
            colorMatrix = map(set_color, mapMatrix)
            draw(canvas)
        end
    end
    showall(mapWindow)
end
