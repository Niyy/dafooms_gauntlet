require 'app/base.rb'


class Unit < Base
    attr_sprite
    attr_accessor :velocity, :fire_direction, :fire_cooldown, :health, 
    :melee_cooldown, :projectile_damage, :melee_damage, :next_melee


    def initialize(init_args)
        @x = init_args[:x]
        @y = init_args[:y]
        @w = init_args[:w]
        @h = init_args[:h]
        @path = init_args[:path]
        @projectile_damage = !init_args[:projectile_damage].nil? ? 
            init_args[:projectile_damage] : 1
        @melee_cooldown = !init_args[:melee_cooldown].nil? ?
            init_args[:melee_cooldown] : 10
        @melee_damage = !init_args[:melee_damage].nil? ?
            init_args[:melee_damage] : 1
        @next_melee = !init_args[:next_melee].nil? ?
            init_args[:next_melee] : 0
        @velocity = {x: 0, y: 0}
        @fire_cooldown = 0
        @next_melee = 0

        @speed = !init_args[:speed].nil? ? init_args[:speed] : 3
    end


    def move_this_tick()
        @x += @velocity[:x]
        @y += @velocity[:y]
    end


    def add_move_velocity(inputs, state)
        @velocity[:x] = 0
        @velocity[:y] = 0

        if(inputs.keyboard.key_held.w)
            @velocity[:y] += @speed
        end
        if(inputs.keyboard.key_held.s)
            @velocity[:y] += -@speed
        end

        if(inputs.keyboard.key_held.d)
            @velocity[:x] += @speed
        end
        if(inputs.keyboard.key_held.a)
            @velocity[:x] += -@speed
        end
    end


    def check_movement_collision(obj_rect, obj, tick_count)
        x_rect = [@x + @velocity[:x], @y, @w, @h]
        y_rect = [@x, @y + @velocity[:y], @w, @h]

        if(x_rect.intersect_rect?(obj_rect))
            @velocity[:x] = 0
            if(melee_damage?(tick_count))
                obj.damage(@melee_damage)
            end
        end
        if(y_rect.intersect_rect?(obj_rect))
            @velocity[:y] = 0
            if(melee_damage?(tick_count))
                obj.damage(@melee_damage)
            end
        end
    end


    def rect()
        [@x, @y, @w, @h]
    end


    def spawn_projectile(tick_count, projectiles)
        @fire_cooldown = tick_count
        projectiles << {
            sprite: {
                x: @x + (@w / 2) - 4 + @velocity[:x],
                y: @y + (@h / 2) - 4 + @velocity[:y],
                w: 8,
                h: 8,
                path: "sprites/circle/black.png"
            },
            fire_direction: @fire_direction,
            tags: ["PROJECTILE", "PLAYER"],
            damage: @projectile_damage
        }
    end


    def fire_projectile(state, inputs, projectiles)
        if(state.tick_count - @fire_cooldown > 3)
            @fire_direction = {x: 0, y: 0}

            if(inputs.keyboard.key_down.up)
                @fire_direction = {x: 0, y: 1}
                spawn_projectile(state.tick_count, projectiles)
            elsif(inputs.keyboard.key_down.down)
                @fire_direction = {x: 0, y: -1}
                spawn_projectile(state.tick_count, projectiles)
            elsif(inputs.keyboard.key_down.right)
                @fire_direction = {x: 1, y: 0}
                spawn_projectile(state.tick_count, projectiles)
            elsif(inputs.keyboard.key_down.left)
                @fire_direction = {x: -1, y: 0}
                spawn_projectile(state.tick_count, projectiles)
            end
        end
    end


    def melee_damage?(tick_count)
        if(@next_melee <= tick_count)
            @next_melee = tick_count + @melee_cooldown
            return true
        end

        return false
    end


    def serialize()
        { x: @x, y: @y, w: @w, h: @h, path: @path, next_melee: @next_melee }
    end


    def inspect()
        serialize.to_s
    end

    
    def to_s
        serialize.to_s
    end
end