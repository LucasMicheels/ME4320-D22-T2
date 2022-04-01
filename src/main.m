clc;
clear;


% Setup user variables
sensorPosX = 60;
sensorPosY = 238;
elevatorDimensionsX = 870;
elevatorDimensionsY = 850;

% Setup classes
frame = Frame;
frame.setPosition(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY);

% Main script
its_RAW = frame.loadData('360 2 static ropes 87cm x 85cm 23.75cm from the back and 6cm from the left side.xlsx');
BS = frame.wallFilteringDIMENSIONS(its_RAW, false);
% figure(1)
%frame.justPlotPls(BS)
% singular = frame.mergeDataPoints(BS);
% figure(2)
% frame.justPlotPls(singular)