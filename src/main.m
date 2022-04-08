clc;
clf;
clear;


% Setup user variables
sensorPosX = 140;
sensorPosY = 205;
elevatorDimensionsX = 975;
elevatorDimensionsY = 1200;
numRopes = 2;

% Setup classes
frame = Frame;
frame.setFrame(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY, numRopes);

% Main script
rawData = frame.loadData('New System test 4-1.xlsx');
lastFrame = max(rawData(:, 3));

for f = 1:lastFrame
	filteredData = frame.wallFilteringDIMENSIONS(rawData, 1, false);
	singularPoints = frame.mergeDataPoints(filteredData);
	figure(f)
	frame.elevatorPlotter(singularPoints, "Only Ropes")
end

% FOR DEBUGGING ONLY
disp("debugging section")
expectedRopePositions_X_Y = [540, 480; 595, 1000]

disp("program completed successfully")


