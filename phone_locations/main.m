clear;
close all;

%% User-defined Variables
filename1 = 'data/Test_23-10-24/UTS_test.csv';  % Path to first CSV file
n_markers1 = 5;                            % Number of markers in the first file

% Output file name
out_file = 'data/Test_10-04-24/station_locations.csv'; % Output file

% Master terminal
master = 1; % This terminal will work as the origin [0,0,0]

%% Read and Process Markers from First File
[Points1, Markers1] = readMarkers(filename1, n_markers1);

%% Compute Distances and Transforms for First Set of Markers
[points_2_centre1, points_2_master1] = calculate_transforms(Markers1, master);
% plot_markers(Markers1, master);
%% Adjust Markers: Set Master Station as Origin Without Changing Orientation

% Get the master station's location and orientation
master_location = Markers1(master).location;
master_orientation = Markers1(master).orientation;

% Adjust each marker's position and orientation
for i = 1:length(Markers1)
    % Adjust positions (include rotation)
    Markers1(i).location = master_orientation' * (Markers1(i).location - master_location)';
    Markers1(i).location = Markers1(i).location';  % Transpose back to row vector
    
    % Adjust orientations
    Markers1(i).orientation = master_orientation' * Markers1(i).orientation;
end
%% Plot Markers with master as origin
plot_markers(Markers1, master);
% Invert Z axis for easier visualisation
set(gca, 'ZDir','reverse')
hold off
drawnow
%% Location of humans taking pictures of AR markers

% Variables
folder_name = 'data/GT_station_23-10-24';
files = dir(fullfile(folder_name, '*.jpg'));
files = files(~[files.isdir]);

camParamMatFilePath = "./data/calibration/cameraParamsIp14Pro.mat";
markerSizeMM = 180; % Ar tag marker size in mm

% Marker index based on images taken
Marker_Image = [5, 2];

% Scale factor for visualizing the axes
axisLength = 0.2;

people = struct('location', {}, 'orientation', {});

for i = 1:size(files,1)
  
    % Get pose of the marker in image
    arTagImagePath = fullfile(folder_name, files(i).name);
    [~, pose, ~, t] = getPose(arTagImagePath, camParamMatFilePath, markerSizeMM);

    % Skip if no marker is detected
    if isempty(pose)
        continue;
    end

    % Add values to arrays
    timestamp{i} = t;
    new_marker_num(i) = Marker_Image(i);

    % Pose matrix from AR tag detection (marker to camera)
    T_C_M = pose.A;
    T_C_M(1:3, 4) = T_C_M(1:3, 4) * 0.001; % Convert mm to meters

    % Compute inverse to get camera pose relative to marker (T_M_C)
    T_M_C = inv(T_C_M);

    % Define the adjustment matrix T_adj to align coordinate systems
    % Adjust this matrix according to your coordinate system differences
    T_adj = [1  0  0  0;
             0  0 -1  0;
             0  1  0  0;
             0  0  0  1];

    % Apply the adjustment
    T_M_C_adj = T_adj * T_M_C;

    % Get marker pose in world coordinates (T_W_M)
    R_W_M = Markers1(Marker_Image(i)).orientation;
    t_W_M = Markers1(Marker_Image(i)).location';
    T_W_M = [R_W_M, t_W_M; 0 0 0 1];

    % Compute camera pose in world coordinates (T_W_C)
    T_W_C = T_W_M * T_M_C_adj;

    % Extract camera position and orientation
    cameraPositions(i,:) = T_W_C(1:3, 4)';
    cameraOrientations(:, :, i) = T_W_C(1:3, 1:3);

    % Store modified camera position and orientation
    people(end+1).location = cameraPositions(i,:);
    people(end).orientation = cameraOrientations(:, :, i);
end
% Plot location of people and markers at the end
plot_markers_people(Markers1, master, people);
set(gca, 'ZDir','reverse')
%% Save info from images
% out_file = 'data/Test_10-04-24/cameras.csv'; % Output file
% save_camera_location(people, Markers1, out_file, new_marker_num,timestamp)