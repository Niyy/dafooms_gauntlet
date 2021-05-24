class Game
    attr_accessor :state, :inputs, :grid, :outputs, :current_command


    def initialize(init_args)
        @state = init_args[:state]
        @inputs = init_args[:inputs]
        @grid = init_args[:grid]
        @outputs = init_args[:outputs]

        @state.enemies = []
        @state.spawners = []
        
        @state.unit = Unit.new({
            x: 620,
            y: 360,
            w: 32,
            h:32,
            path: "sprites/circle/blue.png",
            speed: 10
        })
        enemy_prefab = Enemy.new({
            x: 620,
            y: 360,
            w: 32,
            h:32,
            path: "sprites/circle/red.png",
            speed: 6
        })
        @state.spawners << Spawner.new({
            x: 100,
            y: 100,
            w: 32,
            h: 32,
            path: "sprites/square/red.png",
            spawn_interval: 3,
            health: 4,
            enemy_prefab: enemy_prefab

        })
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
        @outputs.sprites << @state.spawners.map do |spawner|
            spawner
        end
        @outputs.sprites << @state.enemies.map do |enemy|
            enemy
        end

        @outputs.sprites << @state.unit
    end


    def logic()
        @state.spawners.each do |spawner|
            spawner.spawn_enemy(@state, @state.tick_count)
            @state.unit.check_collision_with_class(spawner)
        end

        @state.enemies.each do |enemy|
            enemy.get_move_vector_from_class(@state.unit)

            @state.unit.check_collision_with_class(enemy)
            enemy.check_collision_with_class(@state.unit)

            enemy.move_this_tick()
        end

        @state.unit.move_this_tick()
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