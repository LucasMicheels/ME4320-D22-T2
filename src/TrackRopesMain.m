clc;
clf;
clear;


% Setup user variables
sensorPosX = 900;
sensorPosY = 50;
elevatorDimensionsX = 990;
elevatorDimensionsY = 1160;
numRopes = 2;
timeBetweenFrames = 0.1;

% Setup classes
frame = Frame;
frame.setFrame(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY, numRopes);
ropeSet = Ropes;
ropeSet.setRopes(numRopes, timeBetweenFrames)

% Main script
purerawData = frame.justloadrawData('R2000-2CableCorn-C1P2-C2P3.xlsx');
figure(1)
frame.elevatorPlotter(purerawData, "pure Raw Data");
rawData = frame.loadData('R2000-2CableCorn-C1P2-C2P3.xlsx');
figure(2)
frame.elevatorPlotter(rawData, "trans Raw Data");
lastFrame = max(rawData(:, 3));


for f = 1:lastFrame
	[filteredData, dataToRemove] = frame.wallFilteringDIMENSIONS(rawData, f);
	rawData(1:dataToRemove, :) = [];
	f1 = figure(3);
	clf(f1)
	frame.elevatorPlotter(filteredData, "Filtered Data")
	singularPoints = frame.mergeDataPoints(filteredData);
	f2 = figure(4);
	clf(f2)
	frame.elevatorPlotter(singularPoints, "Only Ropes");

	if f > 1
		ropeSet.trackRope(singularPoints)
		ropeSet.calKinematics();
		ropeSet.getRope()
	else
		ropeSet.assignRopes(singularPoints)
	end
    pause(2);
end

% FOR DEBUGGING ONLY
disp("debugging section")

disp("program completed successfully")