module DijkStar

@enum State unvisited openned closed

# For PriorityQueues
using DataStructures
# For GUI
using Gtk, Colors, FixedPointNumbers

# Used in AStarOrder
import Base.Ordering
import Base.lt

include("ReadMap.jl")
include("InitDijkStar.jl")
include("Displays.jl")

export dijkstra
include("Dijkstra.jl")

export astar
include("AStar.jl")

export dijkstraGUI
include("DijkstraFullGUI.jl")

end # module DijkStar
