clc;
clear;

% Setup classes
frame = Frame;


% Main script
its_RAW = frame.loadData('360 2 static ropes 87cm x 85cm 23.75cm from the back and 6cm from the left side.xlsx');
BS = frame.wallFilteringDIMENSIONS(its_RAW, 870, 850, 60, 238, false);
figure(1)
frame.justPlotPls(BS)
singular = frame.mergeDataPoints(BS);
figure(2)
frame.justPlotPls(singular)