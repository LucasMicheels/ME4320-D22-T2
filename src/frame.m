classdef Frame < handle
    
    properties
        
    end
    
    methods
		%object instantiation
		function obj = Frame()
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
            
            % Combine Values to Matrix [time, angle, distance, amplitude]
			raw_data = zeros(length,4);
			raw_data(:,1) = time;
			raw_data(:,2) = angle;
			raw_data(:,3) = distance;
			raw_data(:,4) = amplitude;
            
            clear data timeLocation amplitudeLocation distanceLocation angleLocation; 
            clear columnNames time distance angle amplitude;
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
        
            end
		end

		% filters walls based on dimensions; don't understand why it is
		% coded the way it is
		function filteredData = wallFiltering(obj, rawData)
			[rows, ~] = size(filteredData);
			for i = 1:rows
    			if (rawData(i, 2) > 180) | (rawData(i, 2) < 0)
        			if i == size(rawData,2)-1
            			angle = rawData(1:i-1, 2);
						distance = distance(1:i-1, 3);
            			amplitude = rawData(1:i-1, 4);
            			data = rawData(1:i-1, 1);
            			time = rawData(1:i-1, 1);
        			else
            			angle = cat(1, rawData(1:i-1, 2),angle(i+1:size(angle,1), 1));
            			amplitude = cat(1, amplitude(1:i-1, 1),amplitude(i+1:size(amplitude,1), 1));
            			data = cat(1, data(1:i-1, 1),data(i+1:size(data,1), 1));
            			distance = cat(1, distance(1:i-1, 1),distance(i+1:size(distance,1), 1));
            			time = cat(1, time(1:i-1, 1),time(i+1:size(time,1), 1));
        			end
        			i = i-1;
    			else
        			x = distance(i)*cos(angle(i));
        			y = distance(i)*sin(angle(i));
        			if (x > 0.98 & x < 1.02) | (y > 1.98 & y < 2.02)
            			if i == size(angle,1)-1
                			angle = angle(1:i-1, 1);
                			amplitude = amplitude(1:i-1, 1);
                			data = data(1:i-1, 1);
                			distance = distance(1:i-1, 1);
                			time = time(1:i-1, 1);
            			else
                			angle = cat(1, angle(1:i-1, 1),angle(i+1:size(angle,1), 1));
                			amplitude = cat(1, amplitude(1:i-1, 1),amplitude(i+1:size(amplitude,1), 1));
                			data = cat(1, data(1:i-1, 1),data(i+1:size(data,1), 1));
                			distance = cat(1, distance(1:i-1, 1),distance(i+1:size(distance,1), 1));
                			time = cat(1, time(1:i-1, 1),time(i+1:size(time,1), 1));
            			end
        			i = i-1;
        			end
    			end
			
    			i = i + 1;
			end
		end

		% Brendyn's code to filter walls based on dimensions; RAWMEAT is
		% the raw data; MaxX is the width of the shaft; MaxY is the length
		% of the shaft; posX is the x position of the sensor origin
		% relative to the coordinate origin; posY is the y position of the 
		% sensor origin relative to the coordinate origin; isCorner is a 
		% boolean that if true the function will only look in a 90 degree
		% field of view from the origin; the coordinate system is the first
		% quadrant of the cartesian coordinate system
		function filteredDataDimensions = wallFilteringDIMENSIONS(obj, ITS_RAW, MaxX, MaxY, posX, posY, isCorner)
			[rows, ~] = size(ITS_RAW);
			filteredDataDimensions = [];
			for i = 1:rows
				if and(isCorner, and(ITS_RAW(i, 2) < 360, and(ITS_RAW(i, 2) >= 270, ITS_RAW(i, 3) > 0 )))
					x = ITS_RAW(i, 3) * cosd(ITS_RAW(i, 2));
        			y = -ITS_RAW(i, 3) * sind(ITS_RAW(i, 2));
					if and(x <= MaxX, and(x >= 0, and(y <= MaxY, y >= 0)))
						filteredDataDimensions = [filteredDataDimensions; ITS_RAW(i, :)];
					end
				elseif ITS_RAW(i, 3) > 0
					x = ITS_RAW(i, 3) * cosd(ITS_RAW(i, 2));
        			y = -ITS_RAW(i, 3) * sind(ITS_RAW(i, 2));
					if and(x <= MaxX, and(x >= 0, and(y <= MaxY, y >= 0)))
						filteredDataDimensions = [filteredDataDimensions; ITS_RAW(i, :)];
					end
				end
			end
		end

		% super basic plotter; just enter the filtered data and it plots in
		% cartesian
		function justPlotPls(obj, data)
			[rows, ~] = size(data);
			hold on
			for i = 1:rows
				plot(data(i, 3) * cosd(data(i, 2)), data(i, 3) * sind(data(i, 2)), 'o')
			end
			hold off
		end

	 	

	end
end