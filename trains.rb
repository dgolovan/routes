require_relative 'map'

# graph is the list of arguments provided
graph = ARGV

if graph.empty? or !graph.kind_of?(Array)
	puts "Please provide a list of arguments in the form 'AB4 BC3 CD4'"
	exit
end

# Create our map
map = Map.new(graph)

# 1. The distance of the route A-B-C. 
dist = map.given_path_distance("A", "B", "C")
puts "#1. #{dist}"

# 2. The distance of the route A-D. 
dist = map.given_path_distance("A", "D")
puts "#2. #{dist}"

# 3. The distance of the route A-D-C. 
dist = map.given_path_distance("A", "D", "C")
puts "#3. #{dist}"

# 4. The distance of the route A-E-B-C-D. 
dist = map.given_path_distance("A", "E", "B", "C", "D")
puts "#4. #{dist}"

# 5. The distance of the route A-E-D. 
dist = map.given_path_distance("A", "E", "D")
puts "#5. #{dist}"

# 6. The number of trips starting at C and ending at C with a maximum of 3 stops.
trips = map.bfs_limited("C", "C", 1, 3)
puts "#6. #{trips}"

# 7. The number of trips starting at A and ending at C with exactly 4 stops
trips = map.bfs_limited("A", "C", 4, 4)
puts "#7. #{trips}"

# 8. The length of the shortest route (in terms of distance to travel) from A to C.
shortest = map.shortest_path("A", "C")
puts "#8. #{shortest}"

# 9. The length of the shortest route (in terms of distance to travel) from B to B
shortest = map.shortest_path("B", "B")
puts "#9. #{shortest}"

# 10. The number of different routes from C to C with a distance of less than 30
trips = map.bfs_limited("C", "C", 1, Float::INFINITY, 30)
puts "#10. #{trips}"
