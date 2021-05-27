require "app/unit.rb"


class Enemy < Unit
    attr_accessor


    def get_move_vector_from_class(target)
        x_comp = (target.x - @x)
        y_comp = (target.y - @y)
        mag = Math.sqrt(x_comp**2 + y_comp**2)

        @velocity[:x] = (x_comp / mag) * @speed
        @velocity[:y] = (y_comp / mag) * @speed
    end
end