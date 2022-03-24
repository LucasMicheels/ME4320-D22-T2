%% Loading the Data

data = readtable('318_Data.xlsx');
columnNames = upper(data.Properties.VariableNames);

% Finding Time Values
timeLocation = strfind(columnNames, 'TIME');
timeLocation = find(~cellfun(@isempty,timeLocation));
time = data(:,timeLocation);
time = table2array(time);
time = str2double(time);
length = size(time,1);

% Finding Amplitude Values
amplitudeLocation = strfind(columnNames, 'AMPLITUTE');
amplitudeLocation = find(~cellfun(@isempty,amplitudeLocation));
amplitude = data(:,amplitudeLocation);
amplitude = table2array(amplitude);
amplitude = str2double(amplitude);

% Finding Distance Values
distanceLocation = strfind(columnNames, 'DISTANCE');
distanceLocation = find(~cellfun(@isempty,distanceLocation));
distance = data(:,distanceLocation);
distance = table2array(distance);
distance = str2double(distance);

% Finding Angle Values
angleLocation = strfind(columnNames, 'ANGLE');
angleLocation = find(~cellfun(@isempty,angleLocation));
angle = data(:,angleLocation);
angle = table2array(angle);
angle = str2double(angle);

clear data timeLocation amplitudeLocation distanceLocation angleLocation columnNames;
