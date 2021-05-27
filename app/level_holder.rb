class Level_Holder 
    attr_accessor :level, :dimensions, :size, :adj, :rooms


    def initialize()
        @level = {}
        @rooms = {}
    end


    def generate_level(dimensions, size)
        @level = {}
        @rooms = {}
        @dimensions = dimensions
        @size = size
        min_room_size = [5, 5]
        @color_marks = [
            (min_room_size[0] * 255) / dimensions[:x], 
            (min_room_size[1] * 255) / dimensions[:y],
            (dimensions[:y] * size[:y]) + (dimensions[:x] * size[:x]) / min_room_size[1],
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
    end


    def assign_tile_to_room(min_room_size, tile, tile_coord)
        room_x = (tile_coord[1] / min_room_size[0]).floor()
        room_y = (tile_coord[0] / min_room_size[1]).floor()
        puts "room_x: #{room_x}, room_y: #{room_y}"

        @rooms[room_x * room_y] ||= []
        @rooms[room_x * room_y] << tile
        tile[:sprite][:r] = (@color_marks[0] * room_x)
        tile[:sprite][:g] = (@color_marks[1] * room_y)
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