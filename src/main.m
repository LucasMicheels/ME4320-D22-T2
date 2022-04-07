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
its_RAW = frame.loadData('Copy of New System test 4-11.xlsx');
figure(1)
frame.justPlotPls(its_RAW, "Raw Data")

BS = frame.wallFilteringDIMENSIONS(its_RAW, false);
figure(2)
frame.justPlotPls(BS, "Filtered Data")

singular = frame.mergeDataPoints(BS);
figure(3)
frame.justPlotPls(singular, "Only Ropes")

disp('finished')


