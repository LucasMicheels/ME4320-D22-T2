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
rawData = frame.loadData('Copy of New System test 4-11.xlsx');
figure(1)
frame.elevatorPlotter(rawData, "Raw Data")

filteredData = frame.wallFilteringDIMENSIONS(rawData, false);
figure(2)
frame.elevatorPlotter(filteredData, "Filtered Data")

singularPoints = frame.mergeDataPoints(filteredData);
figure(3)
frame.elevatorPlotter(singularPoints, "Only Ropes")

% FOR DEBUGGING ONLY
disp("debugging section")
expectedRopePositions_X_Y = [540, 480; 595, 1000]

disp("program completed successfully")


