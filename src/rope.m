classdef Rope < handle
    
    properties
        x = 0;
        y = 0;
        hoistRope = true;
    end
    
    methods
        function updatePos(obj, distance,angle)
            set.x(obj, distance*cosd(angle))
            set.y(obj, distance*sind(angle))
        end
        
        function toggleRopeType(obj)
            set.hoistRope(obj, not(obj.hoistRope))
        end
  
    end
end


