clear;
close all;

%% User-defined Variables
filename1 = 'data/Test_10-04-24/LAB1.csv';  % Path to first CSV file
n_markers1 = 6;                            % Number of markers in the first file

filename2 = 'data/Test_10-04-24/LAB1B.csv'; % Path to second CSV file
n_markers2 = 2;                            % Number of markers in the second file

% Output file name
out_file = 'data/Test_10-04-24/station_locations.csv'; % Output file

% Master terminal
master = 2; % This terminal will work as the origin [0,0,0]

% Base station number that connects both scans
test_1_station = 2; % Station on the first scan
test_2_station = 1; % Station on the second scan

%% Read and Process Markers from First File
[Points1, Markers1] = readMarkers(filename1, n_markers1);

%% Compute Distances and Transforms for First Set of Markers
[points_2_centre1, points_2_master1] = calculate_transforms(Markers1, master);

%% Read and Process Markers from Second File
[Points2, Markers2] = readMarkers(filename2, n_markers2);

%% Compute Distances and Transforms for Second Set of Markers
[points_2_centre2, points_2_master2] = calculate_transforms(Markers2, test_2_station);

%% Calculate transform between both scans
test_1_points = Points1((test_1_station-1)*4 + 1:test_1_station*4,:);
test_2_points = Points2((test_2_station-1)*4 + 1:test_2_station*4,:);
[R,t] = rigid_transform_3D(test_2_points', test_1_points');
T_matrix = [R,t;0,0,0,1];

% Transform and Merge Marker Sets
Markers1(7:end) = [];

% Invert axis based on TT readings
% This is done for the second scan to match the axes of first scan
inv_x = 0;
inv_y = 0;
inv_z = 0;

for i = 1:n_markers2
    if i == test_2_station
        continue
    else
        C = [Markers2(i).orientation, Markers2(i).location'; 0, 0, 0, 1];
        Transformed_Points = T_matrix * C;
        Markers1(end + 1).location = Transformed_Points(1:3, 4)';
        Markers1(end).orientation = Transformed_Points(1:3, 1:3);

        if inv_x
            Markers1(end).orientation(:,1) = -Markers1(end).orientation(:,1);
        end
        if inv_y
            Markers1(end).orientation(:,2) = -Markers1(end).orientation(:,2);
        end
        if inv_z
            Markers1(end).orientation(:,3) = -Markers1(end).orientation(:,3);
        end
    end
end

% Plot the stations
plot_markers(Markers1, master);

%% Adjust Markers: Set Master Station as Origin Without Changing Orientation

% Get the master station's location
master_location = Markers1(master).location;

% Subtract the master location from all marker locations
% Only translation is applied to maintain the original axes alignment.
for i = 1:length(Markers1)
    Markers1(i).location = Markers1(i).location - master_location;
end

%% Plot Merged Markers
% Now the master station is at the origin, and axes remain aligned
plot_markers(Markers1, master);

%% Compute All Transforms to Master

for i = 1:length(Markers1)
    % Compute distance to master (now at origin)
    Markers1(i).distance_to_master = norm(Markers1(i).location);

    % The transformation matrix to master (since master is at origin and axes are aligned)
    Markers1(i).transformation_to_master = [Markers1(i).orientation, Markers1(i).location'; 0, 0, 0, 1];

    % Extract rotation matrix
    R = Markers1(i).orientation;

    % Calculate yaw (ψ) - rotation about the Z-axis
    Markers1(i).yaw = atan2(R(2,1), R(1,1));

    % Calculate pitch (θ) - rotation about the Y-axis
    Markers1(i).pitch = asin(-R(3,1));

    % Calculate roll (φ) - rotation about the X-axis
    Markers1(i).roll = atan2(R(3,2), R(3,3));
end

%% Write Output File (Optional)
% save_markers(Markers1, out_file)
