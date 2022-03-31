clc;
clear;

% Setup classes
frame = Frame;


% Main script
try
	its_RAW = frame.loadData('DryWall 1 meter.xlsx');
	BS = frame.wallFilteringDIMENSIONS(its_RAW, 1000, 1000, 60, 60, false);
	frame.justPlotPls(BS)
catch exception
	disp('Exited on error');
end