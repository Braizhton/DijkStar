function display_path(map::Matrix{Int64},
                      prec::Matrix{Tuple{Int64,Int64}},
                      cost::Matrix{Int64},
                      ori::Tuple{Int64,Int64},
                      dest::Tuple{Int64,Int64},
                      nbVisited::Int64)
    pathLength = 0
    pathCost = 0
    (x,y) = dest
    while (x,y) != ori
        pathLength += 1
        println((y,x))
        cur = (x,y)
        (x,y) = prec[x,y]
        pathCost += cost[map[x,y],map[cur[1],cur[2]]]
    end
    println(ori)
    println("Path length from  ", (ori[2],ori[1]), " to ", (dest[2],dest[1]), " : ", pathLength)
    println("Path cost : ", pathCost)
    println("Number of visits : ", nbVisited)
end

function draw_map_window(map::Matrix{Int64},
                         prec::Matrix{Tuple{Int64,Int64}},
                         state::Matrix{State},
                         ori::Tuple{Int64,Int64},
                         dest::Tuple{Int64,Int64},
                         title::String)
    h, w  = size(map)
    scale = ceil(Int, 950/h)
    if scale*h > 1080
        scale -= 1
    end
    hc = scale*h
    wc = scale*w
   
    # Defining some colors
    visited_color = colorant"cyan"
    path_color = colorant"mediumpurple"
    path_slow_color = colorant"mediumorchid"
    gradEnd = colorant"red"
    gradStart = colorant"lime"
    oriColor = colorant"magenta"
    
    colorSet = [colorant"black",
                colorant"wheat",
                colorant"darkkhaki",
                colorant"dodgerblue",
                colorant"forestgreen"]
    
    grad = convert.(RGB,
                    range(HSL(gradStart),
                         stop=HSL(gradEnd),
                         length=floor(Int, sqrt(h^2+w^2))))

                    
    # Setting canvas and window
    canvas = @GtkCanvas(wc,hc)
    box = GtkBox(:h)
    push!(box,canvas)
    set_gtk_property!(box,:expand,canvas,true)
    mapWindow = GtkWindow(box, title, resizable=false)

    # Drawing
    @guarded draw(canvas) do widget
        # Initiating graphical context
        ctx = getgc(canvas)
        hc = height(canvas)
        wc = width(canvas)
        scaleh = ceil(hc/h)
        scalew = ceil(wc/w)

        # Drawing map
        for i = 1:w, j = 1:h
            rectangle(ctx, (i-1)*scalew, (j-1)*scaleh, scalew, scaleh)
            if state[j,i] == closed
                set_source(ctx, grad[floor(Int, sqrt(abs(ori[1]-j)^2+abs(ori[2]-i)^2)+1)])
            elseif state[j,i] == openned
                set_source(ctx, visited_color)
            else
                set_source(ctx, colorSet[map[j,i]])
            end
            fill(ctx) # Printing
        end
        
        # Drawing source
        rectangle(ctx, (ori[2]-1)*scalew, (ori[1]-1)*scaleh, scalew, scaleh)
        set_source(ctx, oriColor)
        fill(ctx)
        
        # Drawing shortest path
        set_source(ctx, path_color)
        (x,y) = dest
        while (x,y) != ori
            rectangle(ctx, (y-1)*scalew, (x-1)*scaleh, scalew, scaleh)
            if map[x,y] == 'S'
                set_source(ctx, path_slow_color) # Showing that the section is slowed
            else
                set_source(ctx, path_color)      # Showing normal path
            end
            fill(ctx)
            (x,y) = prec[x,y]
        end
        
        # Drawing destination
        rectangle(ctx, (dest[2]-1)*scalew, (dest[1]-1)*scaleh, scalew, scaleh)
        set_source(ctx, gradEnd)
        fill(ctx)
    end
    showall(mapWindow)
end
