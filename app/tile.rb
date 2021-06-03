require 'app/grid_object.rb'
require 'app/sprite_grid_object.rb'


class Tile < Sprite_Grid_Object
    attr_accessor :binary, :marked, :is_grounded_level, :paths, :cost,
    :border, :prefix


    def initialize(init_args)
        super(init_args)
        @marked = 0
        @is_grounded_level = init_args[:is_grounded_level] != nil ? 
            init_args[:is_grounded_level] : true
        @binary = init_args[:binary] != nil ? init_args[:binary] : 0
        @cost = 1
        @border = false
        @prefix = !init_args[:prefix].nil? ? init_args[:prefix] : "wall-"
    end


    def update_sprite(marked, direction)
        @binary ^= (marked & direction) & @marked 
        @path = "sprites/tile/#{prefix}#{"%04b" % @binary}.png"
    end


    def validate_placement(tile_below)
        if(@is_grounded_level)
            return true
        end

        tile = tile_below[get_tile_position()] 

        return tile.marked != 0
    end


    def assign_binary_status(left, bottom, right, top)
        left_marked = left != nil ? left.marked : 0
        bottom_marked = bottom != nil ? bottom.marked : 0
        right_marked = right != nil ? right.marked : 0
        top_marked = top != nil ? top.marked : 0

        next_binary = 0 
        full = 15
        next_binary ^= ~left_marked & 1
        next_binary ^= ~bottom_marked & 2 
        next_binary ^= ~right_marked & 4
        next_binary ^= ~top_marked & 8

        @path = "sprites/tile/#{prefix}#{"%04b" % next_binary}.png"
        @binary = next_binary
    end


    def assign_binary_status_eight(left, bottom, right, top)
        left_marked = left != nil ? left.marked : 0
        bottom_marked = bottom != nil ? bottom.marked : 0
        right_marked = right != nil ? right.marked : 0
        top_marked = top != nil ? top.marked : 0

        next_binary = 0 
        full = 15
        next_binary = ~left_marked & 1
        next_binary = ~bottom_marked & 2 
        next_binary = ~right_marked & 4
        next_binary = ~top_marked & 8

        @path = "sprites/tile/#{prefix}#{"%04b" % next_binary}.png"
        @binary = next_binary       
    end


    # Look into distilling these two function down better.
    def place_tile_on_grid_with_zed(all_tiles, left, right, bottom, up)
        if(validate_placement(all_tiles[@z - 1]))
            tiles = all_tiles[@z]
            @marked = -1
        
            assign_binary_status(left, bottom, right, top)
            propagate_to_adj(left, bottom, right, top)
        end
    end


    def place_tile_on_grid(left, right, bottom, up)
        @marked = -1
    
        assign_binary_status(left, bottom, right, up)
        propagate_to_adj(left, bottom, right, up)
    end


    def left(tiles)
        tiles[[@row, @col - 1]]
    end


    def right(tiles)
        tiles[[@row, @col + 1]]
    end


    def up(tiles)
        tiles[[@row + 1, @col]]
    end


    def down(tiles)
        tiles[[@row - 1, @col]]
    end


    def propagate_to_adj(left, bottom, right, top)
        left&.update_sprite(@marked, 4)
        bottom&.update_sprite(@marked, 8)
        right&.update_sprite(@marked, 1)
        top&.update_sprite(@marked, 2)
    end
end