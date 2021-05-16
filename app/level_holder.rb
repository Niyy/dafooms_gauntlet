class Level_Holder 
    attr_accessor :level, :dimensions, :size


    def initialize()
        @level = {}
    end


    def generate_level(dimensions, size)
        @level = {}
        @dimensions = dimensions
        @size = size

        (0..size[:y]).each do |row|
            (0..size[:x]).each do |col|
                @level[[row, col]] = {
                    sprite: {
                        x: row * dimensions[:x],
                        y: col * dimensions[:y],
                        w: dimensions[:x],
                        h: dimensions[:y],
                        path: "sprites/square/gray.png"
                    }
                }
            end
        end
    end


    def create_spiral_room(sprial_width)
        corners = [[0, 0], [size[:x], 0], [size[:x], size[:y]], [0, size[:y]]]
    end


    def serialize()
        { level: @level}
    end


    def inspect()
        serialize.to_s
    end

    
    def to_s
        serialize.to_s
    end
end