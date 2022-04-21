classdef Ropes < handle
	
    properties
        ropes                 % n x 7 matrix; [x(mm), y(mm), velocityX(mm/s), velocityY(mm/s), accelerationX(mm^2/s), accelerationY(mm^2/s), isHoistRope?]
		previousFrameRopes    % n x 7 matrix; [x(mm), y(mm), velocityX(mm/s), velocityY(mm/s), accelerationX(mm^2/s), accelerationY(mm^2/s), isHoistRope?]
		timeBetweenFrames     % time in seconds between frames
		numRopes              % expected number of ropes
		skippedScans = 0;     % number of scans skipped over
    end
    
    methods
		% object instantiation
		function obj = Rope()
		end

		% setup function to setup initial zero matrices
		function setRopes(obj, numRopes, time)
			obj.ropes = zeros(numRopes, 7);
			obj.previousFrameRopes = zeros(numRopes, 7);
			for i = 1:numRopes
				for j = 1:7
					obj.ropes(i,j) = -1;
					obj.previousFrameRopes = -1;
				end
			end
			obj.timeBetweenFrames = time;
			obj.numRopes = numRopes;
		end

		function ropes = getRope(obj)
			ropes = obj.ropes;
		end

		% manually updates the previous rope kinematics and current rope
		% kinematics with a given matrix
		function updatePos(obj, ropes)
            obj.previousFrameRopes = obj.ropes;
			obj.ropes = ropes;
		end

		% arbitrarily assigns points to the ropes property
		function assignRopes(obj, ropePoints)
			for i = 1:size(ropePoints,1)
				obj.ropes(i, 1) = ropePoints(i, 1);
				obj.ropes(i, 2) = ropePoints(i, 2);
			end
		end

		% does the linear programming to figure out which ropes in the
		% current frame belong to which ropes in the previous frame;
		% currentFrame is in the form of a nx2 matrix which is the list of
		% points of the current frame; updates the rope positions
		function trackRope(obj, currentFrame)
			if size(currentFrame,1) == obj.numRopes
				referenceTable = zeros(obj.numRopes);
				
				% sets up the reference table for the possible objects;
				% need to figure out field of view logic
				deltaTime = obj.timeBetweenFrames * (1 + obj.skippedScans);
				if obj.ropes(1, 1) >= 0
					reducedSearchRadius = 30;   % in mm
					for i = 1:obj.numRopes
						for j = 1:obj.numRopes
							ropeDistance = sqrt((obj.ropes(i, 1) - currentFrame(j, 1))^2 + (obj.ropes(i, 2) - currentFrame(j, 2))^2);
							ropeVelocity = ropeDistance / deltaTime;
							previousVelocity = sqrt((obj.ropes(i, 3))^2 + (obj.ropes(i, 4))^2);
							ropeAcceleration = (previousVelocity - ropeVelocity) / deltaTime;
							unitVector = [currentFrame(j, 1) - obj.ropes(i, 1), currentFrame(j, 2) - obj.ropes(i, 2)] / ropeDistance;
							
							kinematicDistance = previousVelocity * deltaTime + 0.5 * ropeAcceleration * (deltaTime)^2;
							positionEstimate = unitVector * kinematicDistance;

                			if reducedSearchRadius^2 >= (positionEstimate(1) - currentFrame(j, 1))^2 + (positionEstimate(2) - currentFrame(j, 2))^2
								referenceTable(i, j) = 1;
							end
						end
					end
				else
					for i = 1:obj.numRopes
						radius = 1000; % in mm
						for j = 1:obj.numRopes
                			if radius^2 >= (obj.ropes(i, 1) - currentFrame(j, 1))^2 + (obj.ropes(i, 2) - currentFrame(j, 2))^2
								referenceTable(i, j) = 1;
							end
						end
					end
				end
	
				% sets up the reference ropes and object numbers; goal is
				% to find the newRopes which is an array from 1-5 with the
				% number corresponding to the object for the index rope
				newRopes = zeros(obj.numRopes, 1);
				ropesLeft = [];
				objectsLeft = [];
				for i = 1:size(newRopes)
					newRopes(i) = -1;
					ropesLeft = [ropesLeft, i];
					objectsLeft = [objectsLeft, i];
				end
				objectPos = currentFrame;

				for i = 1:obj.numRopes  % edit for loop to while loop so it keeps going until no changes to reference table has occurs after going through each rope
					if sum(referenceTable(i,:)) == 1
						for j = 1:obj.numRopes
							if referenceTable(i, j) == 1
								newRopes(i) = j;
								referenceTable(:,j) = 0;
								ropesLeft(find(ropesLeft, i)) = [];
								objectsLeft(find(objectsLeft, i)) = [];
								break
							end
						end
					end
				end

				if size(ropesLeft,2) >= 1            % if ambiguous points, then find closest points to previous frame
					for g = 1:size(ropesLeft, 2)
						x = obj.ropes(ropesLeft(g),1);
						y = obj.ropes(ropesLeft(g),2);
						closestDist = -1;
						closestObject = -1;
						for h = 1:size(objectsLeft, 2)
							xt = objectPos(objectsLeft(h), 1);
							yt = objectPos(objectsLeft(h), 2);
							D = sqrt((x - xt)^2 + (y - yt)^2);
							if closestDist > D || closestDist == -1
								closestDist = D;
								closestObject = objectsLeft(h);
							end
						end
						newRopes(g) = closestObject;
						objectsLeft(find(objectsLeft == closestObject)) = [];
					end
				end

				% sets the current rope positions to the corresponding
				% object positions
				if min(newRopes) > 0                                   % double checks to make sure there are no issues with tracking the ropes
					newRopePos = zeros(obj.numRopes, 7);
					for i = 1:obj.numRopes
						newRopePos(i, 1) = objectPos(newRopes(i), 1);
						newRopePos(i, 2) = objectPos(newRopes(i), 2);
					end
					obj.updatePos(newRopePos)
				else
					disp("error in tracking ropes!")
				end
			else
				disp("error in tracking ropes")
			end
		end

		% calculates kinematics based on the current properties of the
		% ropes class
		function calKinematics(obj)
			% calculates the kinematics based on x and y positions of
			% current ropes
            for i=1:obj.numRopes
                % calculate velocities
                obj.ropes(i, 3) = (obj.ropes(i,1)-obj.previousFrameRopes(i,1))/obj.timeBetweenFrames;
                obj.ropes(i, 4) = (obj.ropes(i,2)-obj.previousFrameRopes(i,2))/obj.timeBetweenFrames;
                % calculate accels
                obj.ropes(i, 5) = (obj.ropes(i,3)-obj.previousFrameRopes(i,3))/obj.timeBetweenFrames;
                obj.ropes(i, 6) = (obj.ropes(i,4)-obj.previousFrameRopes(i,4))/obj.timeBetweenFrames;
            end
		end


    end
end


