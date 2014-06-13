# Class the represents the directed weighted graph. 
# Contains the methods that are used to produce solutions for the given questions about distances and routes
require 'pp'
class Map
	# Map constructor. 
	# Accepts an array of edges in the format ["AB3", "BC4", "CD5"] 
	def initialize(graph)
		@distances = {}
		graph.each do |e|
			from, to, dist = e.split('')
			
			if @distances.has_key?(from)
				@distances[from][to] = dist
			else
				@distances[from] = {"#{to}"=> dist}
			end
		end
		# puts @distances.flatten.to_a
	end

	#get distance between 2 connected nodes
	private
	def distance_between(from, to)
		total_distance = 0
		if @distances.key?(from) && @distances[from].key?(to)
			total_distance = @distances[from][to].to_i
		else
			raise ArgumentError, "No path from #{from} to #{to}"
		end

		return total_distance
	end

	#get the total cost of the path represented by an array of nodes
	private 
	def get_path_cost(path)
		total_cost = 0
		if path.length < 2
			return 0
		end

		from = path.shift
		path.each do |node|
			total_cost += distance_between(from, node)
			from = node
		end
		return total_cost
	end

	#Get all possible destinations from the given node
	private
	def destinations_from(from)
	    return @distances[from].keys
	end

	# Reverse the path back from destination to source
	private
  	def forward_path(backwards, from, to)
    	path = go_back_recursively(backwards, from, to)
    	path.kind_of?(Array) ? path.reverse : path
  	end
 
  	# Recursively backup through the backwards array to find the forward path: from -> to
  	private
  	def go_back_recursively(backwards, from, to)
    	if from == to
    		return from
    	end

    	raise ArgumentError, "NO SUCH ROUTE" if backwards[to].nil?

    	return [to, go_back_recursively(backwards, from, backwards[to])].flatten
  	end

	# Determines the distance along the given path
	# Accepts an arbitrary number of string arguments. Each argument is a node along the path.
	public
	def given_path_distance(*nodes)
		total_distance = 0
		i=0
		while i < nodes.length - 1
			if nodes[i+1]
				total_distance += distance_between(nodes[i], nodes[i+1])
			end
			i += 1

		end
		return total_distance

		rescue ArgumentError
			return "NO SUCH ROUTE"
	end

	

	# A modified Breadth-First Search implementation. Instead of stopping after the first match, we continue looking for other matches.
	# The matched paths can be limited by the number of stops or by the total cost of the path.
	# Accepts starting and ending nodes as well as min and max number of stops and an optional max_cost parameter.
	public
	def bfs_limited(from, to, min_stops, max_stops, max_cost=nil)
		graph = @distances.clone		
		path = [from]
		queue = [path]
		valid_trips = []
		
		#check whether both source and destination are in our graph before doing any work
		raise ArgumentError, "NO SUCH ROUTE" if !graph.keys.include?(from) 
		dest_exists = false
		graph.keys.each do |src|
			if graph[src].has_key?(to)
				dest_exists = true
				break
			end
		end
		raise ArgumentError, "NO SUCH ROUTE" if !dest_exists 

		while !queue.empty?

			path = queue.shift
			cost = get_path_cost(path.clone)
			current = path[path.length-1]
		
			if current == to and path.length.between?(min_stops+1, max_stops+1) and (max_cost.nil? || cost < max_cost)
				valid_trips.push(path)
			end

			raise ArgumentError, "NO SUCH ROUTE" if graph[current].nil?

			destinations = graph[current].keys
			destinations.each do |node|
				if path.length <= max_stops and (max_cost.nil? || cost < max_cost)
					new_path = [path, node].flatten
					queue.push(new_path)
				end
			end
		end

		return valid_trips.length

		rescue ArgumentError
			return "NO SUCH ROUTE"
	end

	

	# Variation of the Dijkstra's shortest path algorithm
	# Modifications from the classic algorithm are done to support loop paths that are more that 1 stop long.
	public
	def shortest_path(from, to)
		nodes = @distances.keys.clone
		shortest_dist = {}
		backwards = {}
		steps = 0
		
		#check whether both source and destination are in our graph before doing any work
		raise ArgumentError, "NO SUCH ROUTE" if !nodes.include?(from) 
		dest_exists = false
		nodes.each do |src|
			if @distances[src].has_key?(to)
				dest_exists = true
				break
			end
		end
		raise ArgumentError, "NO SUCH ROUTE" if !dest_exists 

		#Set up with all distances as Infinity. Backwards paths are nil
		@distances.keys.each do |node|
			shortest_dist[node] = Float::INFINITY
			backwards[node] = nil
		end
		shortest_dist[from] = 0

		until nodes.empty?
			#find the node with the shortest distance
			nearest_node = nodes.inject do |a, b|
				next a if shortest_dist[a] < shortest_dist[b]
				b
			end

			break if shortest_dist[nearest_node] == Float::INFINITY
			 
			# If nearest node is our final destination - we're done
			if nearest_node == to and steps > 0
				path = forward_path(backwards, from, to)
				# puts path
				return shortest_dist[to]
			end

			# We're not done yet, so lets explore all destinations from the current node
			destinations = destinations_from(nearest_node)
			destinations.each do |node|
				alt = shortest_dist[nearest_node] + distance_between(nearest_node, node)
				if alt < shortest_dist[node]
					shortest_dist[node] = alt
					backwards[node] = nearest_node
				end
			end

			if steps == 0
				shortest_dist[nearest_node] = Float::INFINITY
			end

			if nearest_node != from
				nodes.delete(nearest_node)
			end

			steps += 1
		end

		# If we've reached this, the path does not exist
		return "NO SUCH ROUTE"

		rescue ArgumentError
			return "NO SUCH ROUTE"
	end

end