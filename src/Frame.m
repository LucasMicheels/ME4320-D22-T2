classdef Frame < handle
    
    properties
        % user input properties (basically, properties that are based on
		% the build of the elevator/shaft
		posX = 0;                        % x position of the sensor origin relative to the elevator coordinate origin
		posY = 0;                        % y position of the sensor origin relative to the elevator coordinate origin
		eleDimX = 0;                     % width of the shaft
		eleDimY = 0;                     % length of the shaft
		expectedNumRopes = 0;            % expected number of ropes the sensor should see

		% properties related to tolerances of the program when doing
		% calculations
		axisPadding = 100;               % in mm
		clusterPadding = 20;             % in mm
		sensorRotationCorrection = -90;   % in degrees; positive is clockwise rotation
		wallFilteringPadding = 20;       % in mm
    end
    
    methods
		% object instantiation
		function obj = Frame()
		end

		% sets the user input properties of the frame
		function setFrame(obj, x, y, eleX, eleY, numRopes)
			obj.posX = x;
			obj.posY = y;
			obj.eleDimX = eleX;
			obj.eleDimY = eleY;
			obj.expectedNumRopes = numRopes;
		end

		% loads the data into proper format; x and y are
		% in mm; Combine Values to Matrix [x, y, time]
		function raw_data = loadData(obj, excel_file_name)
            data = readtable(excel_file_name);
            columnNames = upper(data.Properties.VariableNames);
            
            % Finding Distance and Angle Values; Then convert to x and y
            distanceLocation = strfind(columnNames, 'DISTANCE');
            distanceLocation = find(~cellfun(@isempty,distanceLocation));
			angleLocation = strfind(columnNames, 'ANGLE');
            angleLocation = find(~cellfun(@isempty,angleLocation));
			distance = data(:,distanceLocation);
			distance = table2array(distance);
            distance = str2double(distance);
			angle = data(:,angleLocation);
            angle = table2array(angle);
            angle = str2double(angle);
			[rows, ~] = size(angle);
			raw_data = zeros(size(angle,1), 3);
			sweep = 1;
			j = 1;
			for i = 1:rows
				if distance(i) >= 0
					xt = ((distance(i) + 18.863) / 1.0095) * cosd(angle(i));     % adds bias of the sensor
        			yt = ((distance(i) + 18.863) / 1.0095) * sind(angle(i));     % adds bias of the sensor
					transCoord = [cosd(obj.sensorRotationCorrection), sind(obj.sensorRotationCorrection), obj.posX; -sind(obj.sensorRotationCorrection), cosd(obj.sensorRotationCorrection), obj.posY; 0, 0, 1] * [xt; yt; 1];
                    if i > 1
						if and(angle(i - 1) > 350, angle(i) <= 10)        % sets which sweep a data point belongs to SET TO 350 WHEN DONE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            sweep = sweep + 1;
						end
					end
					raw_data(j, :) = [transCoord(1), transCoord(2), sweep];
					j = j + 1;
				else
					raw_data(j, :) = [];
				end
				disp(i/rows * 100 + "% data loaded")
			end
            
            clear data distanceLocation angleLocation; 
            clear columnNames distance angle;
		end
		
		% Loads the raw data without any transformations
		function raw_data = justloadrawData(obj, excel_file_name)
            data = readtable(excel_file_name);
            columnNames = upper(data.Properties.VariableNames);
            
            % Finding Distance and Angle Values; Then convert to x and y
            distanceLocation = strfind(columnNames, 'DISTANCE');
            distanceLocation = find(~cellfun(@isempty,distanceLocation));
			angleLocation = strfind(columnNames, 'ANGLE');
            angleLocation = find(~cellfun(@isempty,angleLocation));
			distance = data(:,distanceLocation);
			distance = table2array(distance);
            distance = str2double(distance);
			angle = data(:,angleLocation);
            angle = table2array(angle);
            angle = str2double(angle);
			[rows, ~] = size(angle);
			x = [];
			y = [];
			raw_data = [];
			sweep = 1;
			for i = 1:rows
				if distance(i) >= 0
					xt = distance(i) * cosd(angle(i));     % adds bias of the sensor
        			yt = distance(i) * sind(angle(i));     % adds bias of the sensor
					transCoord = [xt; yt; 1];
                    if i > 1
						if and(angle(i - 1) > 310, angle(i) <= 1)        % sets which sweep a data point belongs to SET TO 350 WHEN DONE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            sweep = sweep + 1;
						end
					end
					raw_data = [raw_data; transCoord(1), transCoord(2), sweep];
				end
			end
            
            clear data timeLocation distanceLocation angleLocation; 
            clear columnNames distance angle x y;
		end

		% assuming angle, distance, manually sets up raw data
		function raw_data = manualLoadData(obj, excel_file)
			data = readtable(excel_file);
			data = table2array(data);
			distance = data(2:end,2);
			angle = data(2:end,1);
			[rows, ~] = size(angle);
			x = [];
			y = [];
			raw_data = [];
			sweep = 1;
			for i = 1:rows
				if distance(i) >= 0
					xt = distance(i) * cosd(angle(i));     % adds bias of the sensor
        			yt = distance(i) * sind(angle(i));     % adds bias of the sensor
					transCoord = [cosd(obj.sensorRotationCorrection), sind(obj.sensorRotationCorrection), obj.posX; -sind(obj.sensorRotationCorrection), cosd(obj.sensorRotationCorrection), obj.posY; 0, 0, 1] * [xt; yt; 1];
                    if i > 1
						if and(angle(i - 1) > 310, angle(i) <= 1)        % sets which sweep a data point belongs to SET TO 350 WHEN DONE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            sweep = sweep + 1;
						end
					end
					raw_data = [raw_data; transCoord(1), transCoord(2), sweep];
				end
			end
		end

		% code to filter walls based on dimensions; rawData is
		% the raw data; the 
		% coordinate system is the first quadrant of the cartesian coordinate
		% system; function must be given data set starting in the frame
		% it's looking for; dataToRemove is the amount of data removed from
		% the rawData it was given
		function [filteredDataDimensions, dataToRemove] = wallFilteringDIMENSIONS(obj, rawData, frame)
			filteredDataDimensions = [];
			dataToRemove = 0;
			frameSeen = frame;
			while frameSeen == frame && size(rawData, 1) > 0  % will keep going through the loop until either it has seen all the data in a certain frame or if there are no more data to look through
				if and(rawData(1, 1) <= obj.eleDimX - obj.wallFilteringPadding, and(rawData(1, 1) >= 0 + obj.wallFilteringPadding, and(rawData(1, 2) <= obj.eleDimY - obj.wallFilteringPadding, rawData(1, 2) >= 0 + obj.wallFilteringPadding)))
					filteredDataDimensions = [filteredDataDimensions; rawData(1, :)];
					rawData(1,:) = [];
					dataToRemove = dataToRemove + 1;
				else
					rawData(1,:) = [];
					dataToRemove = dataToRemove + 1;
				end

				if size(rawData, 1) > 0
					frameSeen = rawData(1, 3);
				else
					frameSeen = -1;                              % flag to say its done
				end
			end
        end

        % Assuming format of column vectors of [time, angle, distance, amplitude]
        % Will take in filtered data (so only the ropes) and merge data points that
        % are close together; final output is a nx2 matrix as x and y
		function points = mergeDataPoints(obj, filteredData)
			potentialRopes = [];
			cluster = [filteredData(1,:)];
			rows = size(filteredData, 1);
			ropes = zeros(obj.expectedNumRopes,3);
			for i = 2:rows
                if obj.clusterPadding^2 >= (filteredData(i, 1) - filteredData(i - 1, 1))^2 + (filteredData(i, 2) - filteredData(i - 1, 2))^2 %#ok<ALIGN> 
                    cluster = [cluster; filteredData(i,:)];
				elseif size(cluster,1) > 1
						averages = mean(cluster);
						potentialRopes = [potentialRopes; averages(1), averages(2), size(cluster,1)];
						cluster = [filteredData(i,:)];
				else
					cluster = [filteredData(i,:)];
				end
			end
            for p = 1:size(potentialRopes, 1)    % checks each potential rope
                for r = 1:obj.expectedNumRopes   % checks each potential rope with the list of the top clusters (ropes list)
                    if potentialRopes(p,3) > ropes(r,3)  % looking to find/see if a potential rope has an entry that is better than one of the entries in the ropes list
                        for u = 1:obj.expectedNumRopes   % starts the process of moving down entries in the ropes list
							if obj.expectedNumRopes > 1 && ~(u == obj.expectedNumRopes)                     % check to see if only looking for top one entry or if moved all the entries in ropes down one
								ropes(obj.expectedNumRopes - u + 1,:) = ropes(obj.expectedNumRopes - u, :); % sets the current entry to the entry above it
								if u == obj.expectedNumRopes - r                                            % checking to see if it has moved down the entries below the target entry index
									break                                                                   % breaks out of loop so it doesn't move entries down that we don't want to move down
								end
							end
						end
						ropes(r, :) = potentialRopes(p,:);                                                  % sets the target entry in the ropes list to the entry from the potential ropes list
						break
                    end
				end
			end
			points = [ropes(:, 1), ropes(:, 2)];
		end
        
		% super basic plotter; just enter the filtered data and it plots in
		% cartesian; assuming input data has form [x, y, ...]
		function elevatorPlotter(obj, data, graphTitle)
			try
				if size(data, 1) < 10
					hold on
					x = data(:,1);
					y = data(:,2);
					c = 1;
					for i = 1:size(data, 1)
						switch c
							case 1
								plot(x(i),y(i), 'ob');
							case 2
								plot(x(i),y(i), 'or');
							case 3 
								plot(x(i),y(i), 'og');
							case 4
								plot(x(i),y(i), 'oy');
						end
						if c < 4
							c = c + 1;
						else
							c = 1;
						end
					end
					hold off
				else
					plot(data(:, 1), data(:, 2), 'o')
				end
				title("Graph of " + graphTitle)
				axis([-obj.axisPadding, obj.eleDimX + obj.axisPadding, -obj.axisPadding, obj.eleDimY + obj.axisPadding])
				xlabel("x (mm)") 
				ylabel("y (mm)")
			catch exception
				disp("no data or data input is unexpected")
			end
		end
	end
end
