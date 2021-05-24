class Spawner
    attr_sprite
    attr_accessor :health, :spawn_interval, :enemy_prefab


    def initialize(init_args)
        @x = init_args[:x]
        @y = init_args[:y]
        @w = init_args[:w]
        @h = init_args[:h]
        @path = init_args[:path]
        @spawn_interval = init_args[:spawn_interval]
        @enemy_prefab = init_args[:enemy_prefab]
        @health = init_args[:health]
    end


    def spawn_enemy(state, tick_count)
        if(tick_count % (spawn_interval * 60).floor() == 0)
            new_enemy = enemy_prefab.dup()
            new_enemy.x = @x
            new_enemy.y = @y

            state.enemies << new_enemy
        end
    end


    def serialize()
        { x: @x, y: @y, w: @w, h: @h, health: @health, spawn_interval: @spawn_interval, 
            enemy_prefab: enemy_prefab }
    end


    def inspect()
        serialize.to_s
    end

    
    def to_s
        serialize.to_s
    end
end