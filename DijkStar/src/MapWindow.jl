using Gtk
using Colors

function draw_map_window(map::Matrix{Char},
                         prec::Matrix{Tuple{Int64,Int64}},
                         ori::Tuple{Int64,Int64},
                         dest::Tuple{Int64,Int64},
                         title::String)
    h, w  = size(map)
    scale = ceil(Int, 950/h)
    if scale*h > 1000
        scale -= 1
    end
    hc = scale*h
    wc = scale*w
   
    # Defining some colors
    purple  = colorant"mediumpurple"
    purpleb = colorant"mediumorchid"
    red     = colorant"red"
    green   = colorant"lime"
    
    colorSet::Dict{Char, RGB} =
            Dict('.' => colorant"wheat",
                 'G' => colorant"wheat",
                 'S' => colorant"darkkhaki",
                 'W' => colorant"dodgerblue",
                 'T' => colorant"forestgreen",
                 '@' => colorant"black",
                 'O' => colorant"black")
   
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
            set_source(ctx, colorSet[map[j,i]]) # Setting graphic context color
            fill(ctx)                           # Filling canvas
        end
        
        # Drawing source
        rectangle(ctx, (ori[2]-1)*scalew, (ori[1]-1)*scaleh, scalew, scaleh)
        set_source(ctx, green)
        fill(ctx)
        
        # Drawing shortest path
        set_source(ctx, purple)
        (x,y) = dest
        while (x,y) != ori
            rectangle(ctx, (y-1)*scalew, (x-1)*scaleh, scalew, scaleh)
            if map[x,y] == 'S'
                set_source(ctx, purpleb) # Showing that the section is slowed
            else
                set_source(ctx, purple) # Showing normal path
            end
            fill(ctx)
            (x,y) = prec[x,y]
        end
        
        # Drawing destination
        rectangle(ctx, (dest[2]-1)*scalew, (dest[1]-1)*scaleh, scalew, scaleh)
        set_source(ctx, red)
        fill(ctx)
    end
    showall(mapWindow)
end

#=
function set_color(c::Char, ctx)
    if c == '.' || c == 'G'
        set_source(ctx, colorant"wheat2")      # Ground
    elseif c == 'S'
        set_source(ctx, colorant"darkkhaki")   # Swamp
    elseif c == 'W'
        set_source(ctx, colorant"dodgerblue")  # Water
    elseif c == 'T'
        set_source(ctx, colorant"forestgreen") # Trees 
    elseif c == '@' || c == 'O'
        set_source(ctx, colorant"black")       # Black (out of bounds)
    end
end
=#

