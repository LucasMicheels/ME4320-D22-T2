
i = 1;
while i < size(angle,1)
    if (angle(i, 1) > 180) | (angle(i, 1) < 0)
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