class Unit 
    attr_sprite
    attr_accessor :velocity, :fire_direction, :fire_cooldown


    def initialize(init_args)
        @x = init_args[:x]
        @y = init_args[:y]
        @w = init_args[:w]
        @h = init_args[:h]
        @path = init_args[:path]
        @velocity = {x: 0, y: 0}
        @fire_cooldown = 0

        @speed = !init_args[:speed].nil? ? init_args[:speed] : 3
    end


    def move_player_this_tick()
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


    def check_collision_with_class(col_object)
        x_rect = [@x + @velocity[:x], @y, @w, @h]
        y_rect = [@x, @y + @velocity[:y], @w, @h]

        if(x_rect.intersect_rect?(col_object.rect()))
            @velocity[:x] = 0
        end
        if(y_rect.intersect_rect?(col_object.rect()))
            @velocity[:y] = 0
        end
    end


    def check_collision_with_object(col_object)

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
            tags: ["PROJECTILE", "PLAYER"]
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


    def serialize()
        {}
    end


    def inspect()
        serialize.to_s
    end

    
    def to_s
        serialize.to_s
    end
end