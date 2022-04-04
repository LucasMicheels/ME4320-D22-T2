clc;
clf;
clear;


% Setup user variables
sensorPosX = 140;
sensorPosY = 205;
elevatorDimensionsX = 975;
elevatorDimensionsY = 1200;

% Setup classes
frame = Frame;
frame.setPosition(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY);

% Main script
its_RAW = frame.loadData('New System test 4-1.xlsx');
figure(1)
frame.justPlotPls(its_RAW, "Raw Data")

BS = frame.wallFilteringDIMENSIONS(its_RAW, false);
figure(2)
frame.justPlotPls(BS, "Filtered Data")

singular = frame.mergeDataPoints(BS);
figure(3)
frame.justPlotPls(singular, "Only Ropes")

% dubular = frame.mergeDataPoints2(singular);
% figure(4)
% frame.justPlotPls(dubular, "Only Ropes2")

disp('finished')


