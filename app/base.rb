# This is for common functions that units and spawners need

class Base
    def damage(damage_info)
        @health -= damage_info
    end
end