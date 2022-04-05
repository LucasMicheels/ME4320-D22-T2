classdef Frame < handle
    
    properties
        posX = 0;
		posY = 0;
		eleDimX = 0;
		eleDimY = 0;
		axisPadding = 100;               % in mm
		clusterPadding = 1.5;            % in mm
		sensorRotationCorrection = -90;  % in degrees
		wallFilteringPadding = 30;       % in mm
    end
    
    methods
		%object instantiation
		function obj = Frame()
		end

		function setPosition(obj, x, y, eleX, eleY)
			obj.posX = x;
			obj.posY = y;
			obj.eleDimX = eleX;
			obj.eleDimY = eleY;
		end

		% loads the data into proper format; x and y are
		% in mm; Combine Values to Matrix [x, y, time]
		function raw_data = loadData(obj, excel_file_name)
            data = readtable(excel_file_name);
            columnNames = upper(data.Properties.VariableNames);

            % Finding Time Values
            timeLocation = strfind(columnNames, 'TIME');
            timeLocation = find(~cellfun(@isempty,timeLocation));
            time = data(:,timeLocation);
            time = table2array(time);
            time = str2double(time);
            
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
			for i = 1:rows
				if distance(i) >= 0
					xt = ((distance(i) + 18.863) / 1.0095) * cosd(angle(i));     % added bias of the sensor
        			yt = ((distance(i) + 18.863) / 1.0095) * sind(angle(i));     % added bias of the sensor
					transCoord = [cosd(obj.sensorRotationCorrection), sind(obj.sensorRotationCorrection), obj.posX; -sind(obj.sensorRotationCorrection), cosd(obj.sensorRotationCorrection), obj.posY; 0, 0, 1] * [xt; yt; 1];
					raw_data = [raw_data; transCoord(1), transCoord(2), time(i)];
				end
			end
            
            clear data timeLocation distanceLocation angleLocation; 
            clear columnNames time distance angle x y;
		end

		% Brendyn's code to filter walls based on dimensions; RAWMEAT is
		% the raw data; MaxX is the width of the shaft; MaxY is the length
		% of the shaft; posX is the x position of the sensor origin
		% relative to the coordinate origin; posY is the y position of the 
		% sensor origin relative to the coordinate origin; isCorner is a 
		% boolean that if true the function will only look in a 90 degree
		% field of view from the origin; the coordinate system is the first
		% quadrant of the cartesian coordinate system
		function filteredDataDimensions = wallFilteringDIMENSIONS(obj, ITS_RAW, isCorner)
			[rows, ~] = size(ITS_RAW);
			filteredDataDimensions = [];
			for i = 1:rows
				if and(isCorner, and(ITS_RAW(i, 1) <= obj.eleDimX, and(ITS_RAW(i, 1) >= obj.posX, and(ITS_RAW(i, 2) <= obj.eleDimY, ITS_RAW(i, 2) >= obj.posY))))
					if and(ITS_RAW(i, 1) <= obj.eleDimX - obj.wallFilteringPadding, and(ITS_RAW(i, 1) >= 0 + obj.wallFilteringPadding, and(ITS_RAW(i, 2) <= obj.eleDimY - obj.wallFilteringPadding, ITS_RAW(i, 2) >= 0 + obj.wallFilteringPadding)))
						filteredDataDimensions = [filteredDataDimensions; ITS_RAW(i, :)];
					end
				else
					if and(ITS_RAW(i, 1) <= obj.eleDimX - obj.wallFilteringPadding, and(ITS_RAW(i, 1) >= 0 + obj.wallFilteringPadding, and(ITS_RAW(i, 2) <= obj.eleDimY - obj.wallFilteringPadding, ITS_RAW(i, 2) >= 0 + obj.wallFilteringPadding)))
						filteredDataDimensions = [filteredDataDimensions; ITS_RAW(i, :)];
					end
				end
				disp(i/rows * 100 + "% complete")
			end
        end

        % Assuming format of column vectors of [time, angle, distance, amplitude]
        % Will take in filtered data (so only the ropes) and merge data points that
        % are close together; will need to do some brainstorming for edge cases;
        % maybe instead of just looking at the mean, we can make an imaginary
        % circle and whatever is an outlier is considered another rope; final
        % output is a nx2 matrix with angles and dist; assuming polar coordinates
        function ropes = mergeDataPoints(obj, filteredData)
            ropes = [];
            cluster = [filteredData(1,:)];
            [rows, ~] = size(filteredData);
            for i = 2:rows
                if obj.clusterPadding^2 <= (filteredData(i, 1) - filteredData(i - 1, 1))^2 + (filteredData(i, 2) - filteredData(i - 1, 2))^2
                    cluster = [cluster; filteredData(i,:)];
                else
                    ropes = [ropes; mean(cluster(:,1)), mean(cluster(:,2))];
                    cluster = [filteredData(i,:)];
                end
				disp(i/rows * 100 + "% complete")
            end
		end
        
		% super basic plotter; just enter the filtered data and it plots in
		% cartesian
		function justPlotPls(obj, data, graphTitle)
			try
				plot(data(:, 1), data(:, 2), 'o')
				title("Graph of " + graphTitle)
				axis([-obj.axisPadding, obj.eleDimX + obj.axisPadding, -obj.axisPadding, obj.eleDimY + obj.axisPadding])
				xlabel("x (mm)") 
				ylabel("y (mm)")
			catch exception
				disp("no data")
			end
		end
	end
end
