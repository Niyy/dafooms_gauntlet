class Level_Holder 
    attr_accessor :level, :dimensions, :size, :adj, :rooms, :width, :height


    def initialize()
        @level = {}
        @rooms = {}
        @adj = {}
    end


    def generate_level(init_args)
        @level = {}
        @rooms = {}
        @adj = {}
        @dimensions = !init_args[:dimensions].nil? ? init_args[:dimensions] : [5, 5]
        @size = !init_args[:size].nil? ? init_args[:size] : [10, 10]
        min_room_size = !init_args[:min_room_size].nil? ? 
            init_args[:min_room_size] : [5, 5]
        @color_marks = [
            (min_room_size[0] * 255) / dimensions[:x], 
            (min_room_size[1] * 255) / dimensions[:y]
        ]
        @width = @size[:x] / min_room_size[0]
        @height = @size[:y] / min_room_size[1]

        (0...size[:y]).each do |row|
            (0...size[:x]).each do |col|
                @level[[row, col]] = {
                    sprite: {
                        x: col * dimensions[:x],
                        y: row * dimensions[:y],
                        w: dimensions[:x],
                        h: dimensions[:y],
                        path: "sprites/square/white.png",
                        r: 0,
                        g: 0,
                        b: 0 
                    },
                    tile: {
                        row: row, 
                        col: col
                    },
                    border: false
                }

                assign_tile_to_room(min_room_size, @level[[row, col]], [row, col])
            end
        end

        create_adj_list(min_room_size, @dimensions) 
    end


    def create_adj_list(min_room_size, dimensions)
        counter = 0

        @rooms.each_pair do |key, room|
            room[:x_median] /= room[:tiles].size()
            room[:y_median] /= room[:tiles].size()
            room[:x_median] = room[:x_median].floor() / dimensions[:x]
            room[:y_median] = room[:y_median].floor() / dimensions[:y]
#            puts "--------#{key}----------"
#            puts "x_median: #{room[:x_median]}, y_median: #{room[:y_median]}"

            @adj[key] ||= {} 

            up_key = (key + 1) % @height != 0 ? key + 1 : -1   
            down_key = (key) % @height != 0 ? key - 1 : -1
            right_key = key + (@width)
            left_key = key - (@width)

            @adj[key][up_key] = up_key if(@rooms.has_key?(up_key)) 
            @adj[key][down_key] = down_key if(@rooms.has_key?(down_key)) 
            @adj[key][left_key] = left_key if(@rooms.has_key?(left_key)) 
            @adj[key][right_key] = right_key if(@rooms.has_key?(right_key)) 

            counter += 1;
            counter = 0 if(counter == 4)
        end
    end


    def assign_tile_to_room(min_room_size, tile, tile_coord)
        room_col = (tile_coord[1] / min_room_size[1]).floor()
        room_row = (tile_coord[0] / min_room_size[0]).floor()

        room_number = room_row + (room_col * @width).floor()
        @rooms[room_number] ||= {}
        room = @rooms[room_number]

        room[:tiles] ||= {} 
        room[:x_median] ||= 0
        room[:y_median] ||= 0
        room[:tiles][tile_coord] = tile

        tile[:sprite][:r] = (@color_marks[1] * room_col)
        tile[:sprite][:g] = (@color_marks[0] * room_row)

        room[:x_median] += tile[:sprite][:x]
        room[:y_median] += tile[:sprite][:y]
    end


    def combine_rooms()
        random_room = @rooms.keys.to_a.sample()
        if(@adj[random_room].size <= 0)
            return false
        end

        adj_room_consume = @adj[random_room].keys.sample()
        tile_in_room = @rooms[random_room][:tiles].keys.sample()

        @rooms[adj_room_consume][:tiles].each_pair do |key, tile|
            tile[:sprite][:r] = @rooms[random_room][:tiles][tile_in_room][:sprite][:r]
            tile[:sprite][:g] = @rooms[random_room][:tiles][tile_in_room][:sprite][:g]
            @rooms[random_room][:tiles][key] = tile
        end

        @adj[adj_room_consume].keys.each do |adj_room|
            @adj[adj_room].delete(adj_room_consume)
            if(adj_room != random_room)
                if(!@adj[adj_room].has_key?(random_room))
                    @adj[adj_room][random_room] = random_room
                end
                if(!@adj[adj_room].has_key?(adj_room))
                    @adj[random_room][adj_room] = adj_room
                end
            end
        end

        @adj.delete(adj_room_consume)
        @rooms.delete(adj_room_consume)

        return true
    end


    def exists(index, value)
        @adj[index].values.each do |child|
            if(child == value)
                return true
            end
        end

        return false
    end


    def define_level_layout(min_room_count)
        while(@rooms.size - 1 >= min_room_count)
            if(!combine_rooms())
                break
            end
        end

        place_walls()
    end


    def place_walls()
        @rooms.each_pair do |room_key, room|
            room[:tiles].each_pair do |tile_key, tile|
                #puts "#{room_key} adj list: #{@adj[room_key]}"
                if(has_border?(room[:tiles], tile[:tile]) && ( 
                !neighbor_has_border?(@adj[room_key], @rooms, tile[:tile]) ||
                is_corner(room[:tiles], tile[:tile])))
                    tile[:sprite][:r] = 255
                    tile[:sprite][:g] = 255
                    tile[:border] = true
                end
            end
        end
    end


    def has_border?(tiles, tile)
        up = [tile[:row] + 1, tile[:col]]
        down = [tile[:row] - 1, tile[:col]]
        left = [tile[:row], tile[:col] - 1]
        right = [tile[:row], tile[:col] + 1]

        return !(tiles.has_key?(up) && 
        tiles.has_key?(down) && 
        tiles.has_key?(left) && 
        tiles.has_key?(right))
    end


    def neighbor_has_border?(adj_rooms, rooms, tile)
        up = [tile[:row] + 1, tile[:col]]
        down = [tile[:row] - 1, tile[:col]]
        left = [tile[:row], tile[:col] - 1]
        right = [tile[:row], tile[:col] + 1]

        adj_rooms.values.each do |room|
            details = rooms[room][:tiles]

            if((details.has_key?(up) && details[up][:border]) ||
            (details.has_key?(down) && details[down][:border]) ||
            (details.has_key?(right) && details[right][:border]) ||
            (details.has_key?(left) && details[left][:border]))
                return true
            end
        end

        return false
    end


    def is_corner(tiles, tile)
        hits = 0
        
        (0...3).each do |y|
            (0...3).each do |x|
                hits += 1 if(tiles.has_key?([tile[:row] + y - 1, tile[:col] + x - 1])) 
            end
        end

        return true if(hits == 4)
        return false
    end


    def serialize()
        { level: @level }
    end


    def inspect()
        serialize.to_s
    end

    
    def to_s
        serialize.to_s
    end
end