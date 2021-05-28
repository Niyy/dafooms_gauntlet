class Level_Holder 
    attr_accessor :level, :dimensions, :size, :adj, :rooms


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

        (0...size[:y]).each do |row|
            (0...size[:x]).each do |col|
                @level[[row, col]] = {
                    sprite: {
                        x: row * dimensions[:x],
                        y: col * dimensions[:y],
                        w: dimensions[:x],
                        h: dimensions[:y],
                        path: "sprites/square/white.png",
                        r: 255,
                        g: 0,
                        b: 0 
                    }
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

            @adj[key] ||= []

            up_key = counter < 3 ? key + 1 : -1   
            down_key =  counter != 0? key - 1 : -1
            left_key = key - (min_room_size[1] - 1)
            right_key = key + (min_room_size[1] - 1)

            @adj[key] << up_key if(@rooms.has_key?(up_key)) 
            @adj[key] << down_key if(@rooms.has_key?(down_key)) 
            @adj[key] << left_key if(@rooms.has_key?(left_key)) 
            @adj[key] << right_key if(@rooms.has_key?(right_key)) 

            counter += 1;
            counter = 0 if(counter == 4)
        end
    end


    def assign_tile_to_room(min_room_size, tile, tile_coord)
        room_x = (tile_coord[1] / min_room_size[0]).floor()
        room_y = (tile_coord[0] / min_room_size[1]).floor()

        room_number = room_x + (room_y * (min_room_size[0] - 1))
        @rooms[room_number] ||= {}
        room = @rooms[room_number]

        room[:tiles] ||= []
        room[:x_median] ||= 0
        room[:y_median] ||= 0
        room[:tiles] << tile

        tile[:sprite][:r] = (@color_marks[0] * room_x)
        tile[:sprite][:g] = (@color_marks[1] * room_y)

        room[:x_median] += tile[:sprite][:x]
        room[:y_median] += tile[:sprite][:y]
    end


    def combine_rooms(max_room_count)
        random_room = @rooms.keys.to_a.sample()
        adj_room_consume = @adj[random_room].sample()

        puts "Room Chosen: #{random_room}, Adj_room: #{adj_room_consume}"

        @rooms[adj_room_consume][:tiles].each do |tile|
            puts "checking adj"
            tile[:sprite][:r] = @rooms[random_room][:tiles][0][:sprite][:r]
            tile[:sprite][:g] = @rooms[random_room][:tiles][0][:sprite][:g]
            @rooms[random_room][:tiles] << tile
        end

        @rooms.delete(adj_room_consume)
        puts "removing"

        puts @adj[random_room].delete(adj_room_consume)
        @adj[adj_room_consume].each do |adj_room|
            if(adj_room != random_room)
                @adj[adj_room].delete(adj_room_consume)
                @adj[adj_room] << random_room 
            end
        end         
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