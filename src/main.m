clc;
clf;
clear;


% Setup user variables
sensorPosX = 1160;
sensorPosY = 160;
elevatorDimensionsX = 2030;
elevatorDimensionsY = 2030;
numRopes = 2;	
timeBetweenFrames = 0.1;

% Setup classes
frame = Frame;
frame.setFrame(sensorPosX, sensorPosY, elevatorDimensionsX, elevatorDimensionsY, numRopes);
ropeSet = Ropes;
ropeSet.setRopes(numRopes, timeBetweenFrames)

% Main script
rawData = frame.loadData('4.23.22 Test 2 - 2 Ropes Swing Together.xlsx');
figure(1)
frame.elevatorPlotter(rawData, "trans Raw Data");
lastFrame = max(rawData(:, 3));


for f = 1:lastFrame
	[filteredData, dataToRemove] = frame.wallFilteringDIMENSIONS(rawData, f);
	f1 = figure(2);
	clf(f1)
	frame.elevatorPlotter(rawData(1:dataToRemove, :), "Raw Frame Data")
	rawData(1:dataToRemove, :) = [];
	f2 = figure(3);
	clf(f2)
	frame.elevatorPlotter(filteredData, "Filtered Data")
	singularPoints = frame.mergeDataPoints(filteredData);
	f3 = figure(4);
	clf(f3)
	frame.elevatorPlotter(singularPoints, "Only Ropes");

	if f > 1
		ropeSet.trackRope(singularPoints)
		ropeSet.calKinematics();
		ropeSet.getRope()
	else
		ropeSet.assignRopes(singularPoints)
	end
    pause(1); 
end

% FOR DEBUGGING ONLY
disp("debugging section")

disp("program completed successfully")