clc;
sensorPosY = 205;
elevatorDimensionsX = 975;
elevatorDimensionsY = 1200;
numRopes = 2;

% Setup classes
frame = Frame;
frame.setFrame(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY, numRopes);

% Main script
clf;
clear;


% Setup user variables
sensorPosX = 140;
% purerawData = frame.manualLoadData('A2M8_concrete_Team2_close_straight_wall_test.xlsx');
% figure(1)
% frame.elevatorPlotter(purerawData, "pure Raw Data");
% A2M8 rplidar rope to sensor x 81cm   rope to sensor y 88cm
% concrete to sensor x 65cm      rope to sensor x 63cm     ropeto sensor y
% 25cm
% A1M8 rplidar  test 1 uses same as test two of last     test 2 84cm sensor
% concrete    82cm rope to sensor     38cm rope to sensor       wood to
% sensor 92cm       

rawData = frame.justloadrawData('Cardboard Test.xlsx');
figure(2)
frame.elevatorPlotter(rawData, "trans Raw Data");
lastFrame = max(rawData(:, 3));

% figure(1)
% for f = 1:lastFrame
% 	[filteredData, dataToRemove] = frame.wallFilteringDIMENSIONS(rawData, f);
% 	rawData(1:dataToRemove, :) = [];
% 	singularPoints = frame.mergeDataPoints(filteredData);
% 	frame.elevatorPlotter(singularPoints, "Only Ropes");
%     pause(0.1);
% end

% FOR DEBUGGING ONLY
disp("debugging section")
expectedRopePositions_X_Y = [540, 480; 595, 1000]

disp("program completed successfully")