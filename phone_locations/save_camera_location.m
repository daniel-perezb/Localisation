function save_camera_location(Camera, Markers, output_file, Marker_Array,timestamp)
% This function saves the location of different cameras to csv file

% It expects as struct with multiple parameters with multiple matrices
% matrices
% Camera.location = [x,y,z]
% Camera.orientation = 3x3 matrix
% Markers.location = [x,y,z]
% Marker_Array = [1 x size(Camera,2)] containing number of base stationimage was taken off
% output_file = name of the output file



% Adjust orientation and transform to master cells to output in a single
% cell
for i=1:size(Camera,2)
    
    % Obtain transformation between camera postion and marker
    T1 = [Camera(i).orientation, Camera(i).location'; 0, 0, 0, 1];
    T2 = [Markers(Marker_Array(i)).orientation, Markers(Marker_Array(i)).location'; 0, 0, 0, 1];
    
    % Calculate the transformation from T1 to T2
    T = inv(T1) * T2;

    % Adjust orientation info to one cell
    temp1 = mat2str(Camera(i).orientation,4);
    temp1 = strrep(temp1,' ',',');
    Camera(i).orientation = temp1;
    
    % Append the number of marker taken
    Camera(i).station_image = Marker_Array(i);

    % Adjust transformation info to one cell
    temp2 = mat2str(T,4);
    temp2 = strrep(temp2,' ', ',');
    Camera(i).transformation_to_marker = temp2;

    % Append timestamp of image taken
    Camera(i).timestamp = timestamp(i);

end

writetable(struct2table(Camera),output_file,"Delimiter",',');

end