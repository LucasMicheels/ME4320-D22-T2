%
%   Process_LIDAR_75M_95M.m
%
%    A matlab routine from Otis that looks at data collected using the 
%    P&F LIDAR sensor at the Bristol Test Tower

clear;
load scan75M_95M;   % loads in the P&F data, a (20000001,2) matrix with
                    % theta being in first column, range is 2nd
data=scan75M_95M;
clear scan75M_95M;
datasize = length(data);
framesize = 1800;   % the sensor sweeps in 0.2deg increments, hench 
                    % 1800 values constitute a full 360 degree scan
framestart = 602;
frames = floor((datasize-framestart)/framesize);
theta = data(framestart+1:framestart+frames*framesize,1);
dist = data(framestart+1:framestart+frames*framesize,2);

% below loop just plots out a frame at a time, coverting polar coordinates
% into cartesian coordinates

for i=300:800;
    frame_begin = framestart+1+(i-1)*framesize;
    frame_end = framestart+i*framesize;   framei = frame_begin:frame_end;
    xframe = dist(framei).*sind(theta(framei))+1000;
    yframe = dist(framei).*cosd(theta(framei))-1300;
    [ii,xf]=find(abs(xframe<250));
    [ii,yf]=find(abs(xframe<250));
    xm=mean(xf); ym=mean(yf);
    
   plot(yframe,-xframe,'r*',[-1000 1000 1000 -1000 -1000],...
        [-800 -800 1000 1000 -800],'w',...
        xm,ym,'k*');
   % change "axis" command below to look at various zoom windows of the
   % data (units in mm)

    axis([-2000 2000 -2000 2000]);    % wide angle view
    %axis([-250 250 -250 250]);       % narrow in on rope section
    title('Raw LIDAR data'); xlabel('X distance (mm)'); 
    ylabel('Y distance (mm)'); grid;i; pause(0.07);
end;

% Note: the "axis" command above was set to include just readings from
% within the elevator hoistway cross-section.  The actual values of
% [X,Y] from the {theta,range) recordings have much larger values as
% many range values are large because the signal was not reflected back.

