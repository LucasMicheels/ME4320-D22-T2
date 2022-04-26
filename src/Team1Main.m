clc;
clf;
clear;


% Setup user variables
sensorPosX = 1160;
sensorPosY = 160;
elevatorDimensionsX = 2030;
elevatorDimensionsY = 2030;
numRopes = 1;	
timeBetweenFrames = 0.1;

% Setup classes
frame = Frame;
frame.setFrame(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY, numRopes);
ropeSet = Ropes;
ropeSet.setRopes(numRopes, timeBetweenFrames)

% Main script
rawData = frame.manualLoadR2000Data('R2000-P5MidMvmtPerp.xlsx');

lastFrame = max(rawData(:, 3));
data = ["Distance", "Number of Data Points"];

for f = 1:lastFrame
	disp("Processing frame " + f + " out of " + lastFrame)
	[filteredData, dataToRemove] = frame.wallFilteringDIMENSIONS(rawData, f);
    disp("Removing " + dataToRemove + " data points")
	rawData(1:dataToRemove, :) = [];
	singularPoints = frame.mergeDataPoints(filteredData);

	f1 = figure(1);
	clf(f1)
	frame.elevatorPlotter(singularPoints, "Only Ropes")

	distanceFromSensor = sqrt((singularPoints(1, 1) - sensorPosX)^2 + (singularPoints(1, 2) - sensorPosY)^2);
	
	data = [data; distanceFromSensor, singularPoints(1,3)];
end

data
%mean(data)

disp("program completed successfully")