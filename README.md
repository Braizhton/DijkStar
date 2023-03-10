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

astar("path/to/map/file.map", (s1,s2), (d1,d2), displayOn)
dijkstra("path/to/map/file.map", (s1,s2), (d1,d2), displayOn)  
dijkstraGUI("path/to/map/file.map", stepByStep) # Not recommanded for more than 50x50 maps
```
*See DijkStar/test/tests_commands.txt for concrete examples*
