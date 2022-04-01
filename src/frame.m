classdef Frame < handle
    
    properties
        posX = 0;
		posY = 0;
		eleDimX = 0;
		eleDimY = 0;
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

		% loads the data into proper format; time is in ____; angle is in
		% degrees; distance is in mm; amplitude is in ____
		function raw_data = loadData(obj, excel_file_name)
            data = readtable(excel_file_name);
            columnNames = upper(data.Properties.VariableNames);

            % Finding Time Values
            timeLocation = strfind(columnNames, 'TIME');
            timeLocation = find(~cellfun(@isempty,timeLocation));
            time = data(:,timeLocation);
            time = table2array(time);
            time = str2double(time);
            length = size(time,1);
            
            % Finding Amplitude Values
%             amplitudeLocation = strfind(columnNames, 'AMPLITUTE');
%             amplitudeLocation = find(~cellfun(@isempty,amplitudeLocation));
%             amplitude = data(:,amplitudeLocation);
%             amplitude = table2array(amplitude);
%             amplitude = str2double(amplitude);
            
            % Finding Distance and Angle Values; Then convert to x and y
            distanceLocation = strfind(columnNames, 'DISTANCE');
            distanceLocation = find(~cellfun(@isempty,distanceLocation));
			angleLocation = strfind(columnNames, 'ANGLE');
            angleLocation = find(~cellfun(@isempty,angleLocation));
			distance = data(:,angleLocation);
			distance = table2array(distance);
            distance = str2double(distance);
			angle = data(:,angleLocation);
            angle = table2array(angle);
            angle = str2double(angle);
			[rows, ~] = size(angleLocation);
			x = [];
			y = [];
			for i = 1:rows
				xt = distance(i) * cosd(angle(i));
        		yt = distance(i) * sind(angle(i));
				transCoord = [0, -1, obj.posX; 1, 0, obj.posY; 0, 0, 1] * [xt; yt; 1];
				x = [x; transCoord(1)];
				y = [y; transCoord(2)];
			end
            
            % Combine Values to Matrix [time, angle, distance, amplitude]
			raw_data = zeros(length,4);
			raw_data(:,1) = time;
			raw_data(:,2) = x;
			raw_data(:,3) = y;
% 			raw_data(:,4) = amplitude;
            
            clear data timeLocation amplitudeLocation distanceLocation angleLocation; 
            clear columnNames time distance angle amplitude;
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
				if and(isCorner, and(ITS_RAW(i, 2) < 360, and(ITS_RAW(i, 2) >= 270, ITS_RAW(i, 3) > 0 )))
					if and(ITS_RAW(i, 2) <= obj.eleDimX - obj.posX, and(ITS_RAW(i, 2) >= 0 - obj.posX, and(ITS_RAW(i, 3) <= obj.eleDimY - obj.posY, ITS_RAW(i, 3) >= 0 - obj.posY)))
						filteredDataDimensions = [filteredDataDimensions; ITS_RAW(i, :)];
					end
				elseif ITS_RAW(i, 3) > 0
					if and(ITS_RAW(i, 2) <= obj.eleDimX - obj.posX, and(ITS_RAW(i, 2) >= 0 - obj.posX, and(ITS_RAW(i, 3) <= obj.eleDimY - obj.posY, ITS_RAW(i, 3) >= 0 - obj.posY)))
						filteredDataDimensions = [filteredDataDimensions; ITS_RAW(i, :)];
					end
				end
				i
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
				i
            end
        end
        
		% super basic plotter; just enter the filtered data and it plots in
		% cartesian
		function justPlotPls(obj, data)
			[rows, ~] = size(data);
			hold on
			for i = 1:rows
				plot(data(i, 2), data(i, 3), 'o')
				i
			end
			hold off
		end

	end
end