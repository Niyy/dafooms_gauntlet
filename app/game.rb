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
            speed: 6
        })
        enemy_prefab = Enemy.new({
            x: 620,
            y: 360,
            w: 32,
            h:32,
            path: "sprites/circle/red.png",
            speed: 4
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
        @state.level_holder.generate_level({
            dimensions: {x: 32, y: 32}, 
            size: {x: 20, y: 20},
            min_room_size: [4, 4]
        })

        @state.level_holder.define_level_layout(4)
    end


    def inputs()
        @state.unit.add_move_velocity(@inputs, @state)
    end


    def renders()
        @outputs.sprites << @state.level_holder.level.values.map do |tile|
            tile        
        end
        @outputs.labels << @state.level_holder.rooms.to_a.map do |room|
            [
                room[1][:x_median] * @state.level_holder.dimensions[:x] + 6, 
                room[1][:y_median] * @state.level_holder.dimensions[:y] + 25, 
                "#{room[0]}"
            ]
        end
#        @outputs.sprites << @state.projectiles.map do |projectile|
#            projectile[:sprite]
#        end
#        @outputs.sprites << @state.spawners.map do |spawner|
#            spawner
#        end
#        @outputs.sprites << @state.enemies.map do |enemy|
#            enemy
#        end
#
#        @outputs.sprites << @state.unit
    end


    def logic()
        @state.spawners.each do |spawner|
            spawner.spawn_enemy(@state, @state.tick_count)
            @state.unit.check_movement_collision(rect(spawner), spawner, 
                @state.tick_count)
        end

        @state.enemies.each.with_index do |enemy, enemy_index|
            if(enemy.health <= 0)
                @state.enemies.delete_at(enemy_index)
            end

            enemy.get_move_vector_from_class(@state.unit)

            @state.unit.check_movement_collision(enemy, enemy, @state.tick_count)
            enemy.check_movement_collision(@state.unit, @state.unit, @state.tick_count)

            enemy.move_this_tick()
        end

        @state.unit.move_this_tick()
        @state.unit.fire_projectile(@state, @inputs, @state.projectiles)

        @state.projectiles.each.with_index do |projectile, index|
            projectile[:sprite][:x] += projectile[:fire_direction][:x] * 
                @state.projectile_speed
            projectile[:sprite][:y] += projectile[:fire_direction][:y] * 
                @state.projectile_speed

            @state.enemies.each.with_index do |enemy, enemy_index|
                check_projectile_collision(enemy, projectile, index)
            end

            @state.spawners.each.with_index do |spawner, spawner_index|
                check_projectile_collision(spawner, projectile, index)

                if(spawner.health <= 0)
                    @state.spawners.delete_at(spawner_index)
                end
            end
        end
    end


    def check_projectile_collision(object, projectile, projectile_index)
        if(projectile[:sprite].intersect_rect?(rect(object)))
            object.damage(projectile[:damage])
            @state.projectiles.delete_at(projectile_index)
        end
    end


    def rect(class_object)
        [class_object.x, class_object.y, class_object.w, class_object.h]
    end


    def tick()
        set_up() if(@state.tick_count == 0)

        inputs()
        logic()
        renders()
    end
end