# DijkStar
2D Pathfinding Benchmarks :
https://movingai.com/benchmarks/grids.html

## Dependencies
- Gtk
- Colors
- DataStructures
- FixedPointNumbers (needed for RGB{FixedPointNumbers.N0f8})

## Running tests
```julia
include("src/DijkStar") ; using .DijkStar

astar(mapfile, origin, destination, metricsOn, displayOn)
dijkstra(mapfile, origin, destination, metricsOn, displayOn)  
dijkstraGUI(mapfile, stepByStep) # stepByStep not recommanded for more than 50x50 maps
```
Where :
- **mapfile**     | type String               | Path to "file.map"
- **origin**      | type Tuple{Int64, Int64}  | Starting point
- **destination** | type Tuple{Int64, Int64}  | Arrival point
- **metricsOn**   | type Bool                 | Switch on/off metrics displays      | Defaults to *true*
- **displayOn**   | type Bool                 | Switch on/off graphic displays      | Defaults to *false*
- **stepByStep**  | type Bool                 | Switch on/off step by step displays | Defaults to *false* 

## Examples 
```julia
dijkstra("test/maps/arena.map", (5,4), (45,45))                     # metricsOn = true & displayOn = false
dijkstra("test/maps/test.map", (2,2), (14,10), true, true, false)   # Same
dijkstra("test/maps/bootybay.map", (5,4), (45,45), false)           # metricsOn = false & displayOn = false
dijkstra("test/maps/den012d.map", (8,99), (179,149), false, true)   # metricsOn = false & displayOn = true

astar("test/maps/FloodedPlains.map", (1,1), (743,768))              # ...
astar("test/maps/bootybay.map", (91,157), (412,147), true)
astar("test/maps/arena.map", (91,157), (412,147), true, true)

dijkstraGUI("test/maps/test.map")         ## Displaying result after computation is complete 
dijkstraGUI("test/maps/test.map", true)   ## Displaying step by step (extremely slow for more than 50x50 maps)
```

## DijkstraGUI details
Run the function and click on the map to set origin and destination. Once it's done, the algorithm Dijkstra is used to calculate shortest path and then result is displayed on the screen. Click again to erase and reset the parameters, and start again. Enjoy !
