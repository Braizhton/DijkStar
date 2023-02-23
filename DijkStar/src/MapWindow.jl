using Gtk
using Colors

function set_rgb(c::Char, ctx)
    if c == '.' || c == 'G'
        set_source_rgb(ctx, 0.933,0.914,0.678) # Ground
    elseif c == 'S'
        set_source_rgb(ctx, 0.796,0.639,0.0)   # Swamp
    elseif c == 'W'
        set_source_rgb(ctx, 0.2,0.576,1.0)     # Water
    elseif c == 'T'
        set_source_rgb(ctx, 0.18,0.545,0.22)   # Trees 
    elseif c == '@' || c == 'O'
        set_source_rgb(ctx, 0.0, 0.0, 0.0)     # Black (out of bounds)
    end
end

function draw_map_window(map::Matrix{Char},
                         prec::Matrix{Tuple{Int64,Int64}},
                         ori::Tuple{Int64,Int64},
                         dest::Tuple{Int64,Int64},
                         title::String, 
                         scale::Int64)
    h, w = size(map)
   
    # Defining some colors
    purple = (0.655,0.424,0.902)
    orange = (1.0,0.584,0.09)
    red    = (0.922,0.0,0.0)
    green  = (0.408,0.827,0.255)
   
    # Setting canvas and window
    canvas = @GtkCanvas(h*scale,w*scale)
    box = GtkBox(:h)
    push!(box,canvas)
    set_gtk_property!(box,:expand,canvas,true)
    mapWindow = GtkWindow(box, title)

    # Drawing
    @guarded draw(canvas) do widget
        # Initiating graphical context
        ctx = getgc(canvas)
        hc = height(canvas)
        wc = width(canvas)
        scaleh = hc/h
        scalew = wc/w

        #println(hc, "\n", wc, "\n", scaleh, "\n", scalew)

        # Drawing map
        for i = 1:w, j = 1:h
            rectangle(ctx, (i-1)*scalew, (j-1)*scaleh, scalew, scaleh)
            set_rgb(map[j,i], ctx)   # Setting graphic context color
            fill(ctx)                # Filling canvas
        end
        
        # Drawing source
        rectangle(ctx, (ori[2]-1)*scalew, (ori[1]-1)*scaleh, scalew, scaleh)
        set_source_rgb(ctx, green[1], green[2], green[3])
        fill(ctx)
        
        # Drawing shortest path
        set_source_rgb(ctx, purple[1], purple[2], purple[3])
        (x,y) = dest
        while (x,y) != ori
            rectangle(ctx, (y-1)*scalew, (x-1)*scaleh, scalew, scaleh)
            if map[x,y] == 'S'
                set_source_rgb(ctx, orange[1], orange[2], orange[3]) # Showing that the section is slowed
            else
                set_source_rgb(ctx, purple[1], purple[2], purple[3]) # Showing normal path
            end
            fill(ctx)
            (x,y) = prec[x,y]
        end
        
        # Drawing destination
        rectangle(ctx, (dest[2]-1)*scalew, (dest[1]-1)*scaleh, scalew, scaleh)
        set_source_rgb(ctx, red[1], red[2], red[3])
        fill(ctx)
    end
    showall(mapWindow)
end
