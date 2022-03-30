%% Loading the Data yep it's walter

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


% Assuming format of column vectors of [time, angle, distance, amplitude]
% Will take in filtered data (so only the ropes) and merge data points that
% are close together; will need to do some brainstorming for edge cases;
% maybe instead of just looking at the mean, we can make an imaginary
% circle and whatever is an outlier is considered another rope; final
% output is a nx2 matrix with angles and dist; assuming polar coordinates
function ropes = mergeDataPoints(filteredData)
    ropes = [];
    cluster = [filteredData(1,:)];
    [rows, ~] = size(filteredData);
    for i = 2:rows
        if and(and(...
                filteredData(i, 2) <= filteredData(i - 1, 2) + 0.005,...
                filteredData(i, 2) >= filteredData(i - 1, 2) - 0.005),and(...
                filteredData(i, 3) <= filteredData(i - 1, 3) + 3,...
                filteredData(i, 3) >= filteredData(i - 1, 3) - 3))
            cluster = [cluster; filteredData(i,:)];
        else
            ropes = [ropes; mean(cluster, 2) mean(cluster, 3)];
            cluster = [];
        end

    end
end
