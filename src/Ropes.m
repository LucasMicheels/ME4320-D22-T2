classdef Ropes < handle
	
    properties
        ropes                 % n x 8 matrix; [ropeNum, x(mm), y(mm), velocityX(mm/s), velocityY(mm/s), accelerationX(mm^2/s), accelerationY(mm^2/s), isHoistRope?]
		previousFrameRopes    % n x 8 matrix; [ropeNum, x(mm), y(mm), velocityX(mm/s), velocityY(mm/s), accelerationX(mm^2/s), accelerationY(mm^2/s), isHoistRope?]
		timeBetweenFrames     % time in seconds between frames
		numRopes              % expected number of ropes
    end
    
    methods
		% object instantiation
		function obj = Rope()
		end

		% setup function to setup initial zero matrices
		function setRopes(obj, numRopes, time)
			obj.ropes = zeros(size(ropePoints,1), 8);
			obj.previousFrameRopes = zeros(size(ropePoints,1), 8);
			obj.timeBetweenFrames = time;
			obj.numRopes = numRopes;
		end

		% manually updates the previous rope kinematics and current rope
		% kinematics with a given matrix
		function updatePos(obj, ropes)
            obj.previousFrameRopes = obj.ropes;
			obj.ropes = ropes;
		end

		function assignRopes(obj, ropePoints)
			for i = 1:size(ropePoints,1)
				obj.ropes(i, 1) = i;
				obj.ropes(i, 2) = ropePoints(i, 1);
				obj.ropes(i, 3) = ropePoints(i, 2);
			end
		end

		% does the linear programming to figure out which ropes in the
		% current frame belong to which ropes in the previous frame;
		% currentFrame is in the form of a nx2 matrix which is the list of
		% points of the current frame; updates the rope positions
		function trackRope(obj, currentFrame)
			if size(currentFrame, 1) == obj.numRopes
				obj.previousFrameRopes = obj.ropes;
				% linear programming magic
			else
				disp("error; number of ropes in current frame does not match expected number of ropes")
			end
		end

		% calculates kinematics based on the current properties of the
		% ropes class
		function calKinematics(obj)
			% calculates the kinematics based on x and y positions of
			% current ropes
		end


    end
end


