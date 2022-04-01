clc;
clear;

% Setup classes
frame = Frame;


% Main script
its_RAW = frame.loadData('360 2 static ropes 87cm x 85cm 23.75cm from the back and 6cm from the left side.xlsx');
BS = frame.wallFilteringDIMENSIONS(its_RAW, 10000, 10000, 60, 60, false);
%singular = frame.mergeDataPoints(BS);
frame.justPlotPls(BS)