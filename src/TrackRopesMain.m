clc;
clf;
clear;


% Setup user variables
sensorPosX = 889;
sensorPosY = 76.2;
elevatorDimensionsX = 975;
elevatorDimensionsY = 1200;
numRopes = 2;
timeBetweenFrames = 1;

% Setup classes
frame = Frame;
frame.setFrame(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY, numRopes);
ropeSet = Ropes;
ropeSet.setRopes(numRopes, timeBetweenFrames)

% Main script
rawData = frame.justloadrawData('R2000-P2CornMvmtPara.xlsx');
figure(2)
frame.elevatorPlotter(rawData, "Raw Data");
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