clc;
clf;
clear;


% Setup user variables
sensorPosX = 20;
sensorPosY = 50;
elevatorDimensionsX = 960;
elevatorDimensionsY = 1000;
numRopes = 1;
timeBetweenFrames = 0.1;
sensorRotationCorrection = 5;
clusterRadius = 30;

% Setup classes
frame = Frame;
frame.setFrame(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY, numRopes, sensorRotationCorrection, clusterRadius);
ropeSet = Ropes;
ropeSet.setRopes(numRopes, timeBetweenFrames)

% Main script
rawData = frame.loadCyglidarData('Cyglidar-Corner-Moving-P4-Perpendicular.xlsx');
figure(1)
frame.elevatorPlotter(rawData, "Complete Raw Data");

lastFrame = max(rawData(:, 3));
allKinematics = zeros((numRopes * lastFrame), 7);
skippedFrames = 0;
listOfSkippedFrames = [];

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
			skippedFrames = 0;
			for i = 1:numRopes
				allKinematics(((f - 1) * numRopes) + i, :) = currentKinematics(i, :);
			end
			clf(f3)
			frame.elevatorPlotter(currentKinematics, "Only Ropes");
		else
			skippedFrames = skippedFrames + 1;
			ropeSet.setSkippedFrames(skippedFrames);
			listOfSkippedFrames = [listOfSkippedFrames; f];
		end
	else
		ropeSet.assignRopes(singularPoints)
		clf(f3)
		frame.elevatorPlotter(singularPoints, "Only Ropes - First Frame");
	end
	pause(1)
end

disp(skippedFrames)
disp(listOfSkippedFrames)
disp(ropeSet.getTotalErrors)


%figure(5)
%ropeSet.kinematicsPlotter(allKinematics, "Kinematics vs Time", elevatorDimensionsX, elevatorDimensionsY)

% FOR DEBUGGING ONLY
disp("debugging section")

disp("program completed successfully")