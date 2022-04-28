clc;
clf;
clear;


% Setup user variables
sensorPosX = 1105;
sensorPosY = 35;
elevatorDimensionsX = 2030;
elevatorDimensionsY = 2030;
numRopes = 2;
timeBetweenFrames = 0.1;
sensorRotationCorrection = -177;

% Setup classes
frame = Frame;
frame.setFrame(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY, numRopes, sensorRotationCorrection);
ropeSet = Ropes;
ropeSet.setRopes(numRopes, timeBetweenFrames)

% Main script
rawData = frame.loadData('R2000-TestRig-Wall-Moving3.xlsx');
figure(1)
frame.elevatorPlotter(rawData, "Complete Raw Data");

lastFrame = max(rawData(:, 3));
allKinematics = zeros((numRopes * lastFrame), 7);
skippedFrames = 0;

for f = 1:lastFrame
	disp("Processing frame " + f + " out of " + lastFrame)
	[filteredData, dataToRemove] = frame.wallFilteringDIMENSIONS(rawData, f);
	f1 = figure(2);
	clf(f1)
	frame.elevatorPlotter(rawData(1:dataToRemove, :), "Raw Frame Data")
    disp("Removing " + dataToRemove + " data points")
	rawData(1:dataToRemove, :) = [];
	f2 = figure(3);
	clf(f2)
	frame.elevatorPlotter(filteredData, "Filtered Data")
	singularPoints = frame.mergeDataPoints(filteredData);
	f3 = figure(4);
	
	if f > 1
		if min(min(singularPoints(:, 1:2), [], 1), [], 'all') >= 0
			ropeSet.trackRope(singularPoints)
			ropeSet.calKinematics();
			currentKinematics = ropeSet.getRope()
			ropeSet.setSkippedFrames(0);
			for i = 1:numRopes
				allKinematics(((f - 1) * numRopes) + i, :) = currentKinematics(i, :);
			end
			clf(f3)
			frame.elevatorPlotter(currentKinematics, "Only Ropes");
		else
			skippedFrames = skippedFrames + 1;
			ropeSet.setSkippedFrames(skippedFrames);
		end
	else
		ropeSet.assignRopes(singularPoints)
		clf(f3)
		frame.elevatorPlotter(singularPoints, "Only Ropes - First Frame");
	end
	
% 	if f == 11
% 		stopHere = input("about to start frame 23")
% 	end
%     pause(1);
end

%figure(5)
%ropeSet.kinematicsPlotter(allKinematics, "Kinematics vs Time", elevatorDimensionsX, elevatorDimensionsY)

% FOR DEBUGGING ONLY
disp("debugging section")

disp("program completed successfully")