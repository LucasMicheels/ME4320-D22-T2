clc;
clf;
clear;


% Setup user variables
sensorPosX = 140;
sensorPosY = 205;
elevatorDimensionsX = 975;
elevatorDimensionsY = 1200;
numRopes = 2;
timeBetweenFrames = -1;

% Setup classes
frame = Frame;
frame.setFrame(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY, numRopes);
ropeSet = Ropes;
ropeSet.setRopes(numRopes, timeBetweenFrames)

% Main script
rawData = frame.loadData('New System test 4-1.xlsx');
lastFrame = max(rawData(:, 3));

figure(1)
for f = 1:lastFrame
	[filteredData, dataToRemove] = frame.wallFilteringDIMENSIONS(rawData, f);
	rawData(1:dataToRemove, :) = [];
	singularPoints = frame.mergeDataPoints(filteredData);
	frame.elevatorPlotter(singularPoints, "Only Ropes");
    pause(0.1);
end

% FOR DEBUGGING ONLY
disp("debugging section")

disp("program completed successfully")