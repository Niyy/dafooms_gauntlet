class Game
    attr_accessor :state, :inputs, :grid, :outputs, :current_command


    def initialize(init_args)
        @state = init_args[:state]
        @inputs = init_args[:inputs]
        @grid = init_args[:grid]
        @outputs = init_args[:outputs]
        
        @state.unit = Unit.new({
            x: 620,
            y: 360,
            w: 32,
            h:32,
            path: "sprites/circle/blue.png"
        })
        @state.enemy_prefab
        @state.level_holder = Level_Holder.new()
        @state.projectiles = []
        @state.projectile_speed = 10
    end

    
    def set_up()
        @state.level_holder.generate_level({x: 32, y: 32}, {x: 20, y: 20})
    end


    def inputs()
        @state.unit.add_move_velocity(@inputs, @state)
    end


    def renders()
        @outputs.sprites << @state.level_holder.level.values.map do |tile|
            tile[:sprite]
        end
        @outputs.sprites << @state.projectiles.map do |projectile|
            projectile[:sprite]
        end

        @outputs.sprites << @state.unit
    end


    def logic()
        @state.unit.move_player_this_tick()
        @state.unit.fire_projectile(@state, @inputs, @state.projectiles)

        @state.projectiles.each do |projectile|
            projectile[:sprite][:x] += projectile[:fire_direction][:x] * 
                @state.projectile_speed
            projectile[:sprite][:y] += projectile[:fire_direction][:y] * 
                @state.projectile_speed
        end
    end


    def tick()
        set_up() if(@state.tick_count == 0)

        inputs()
        logic()
        renders()
    end
end