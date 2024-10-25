clear;
close all;

%% User-defined Variables
filename1 = 'data/Test_23-10-24/UTS_test2.csv';  % Path to first CSV file
n_markers1 = 5;                            % Number of markers in the first file

% Output file name
out_file = 'data/Test_10-04-24/people_locations.csv'; % Output file

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
% plot_markers(Markers1, master);
%% Location of humans taking pictures of AR markers

% Variables
folder_name = 'data/GT_station_23-10-24';
files = dir(fullfile(folder_name, '*.jpg'));
files = files(~[files.isdir]);

camParamMatFilePath = "./data/calibration/cameraParamsIp14Pro.mat";
markerSizeMM = 180; % Ar tag marker size in mm

% Marker index based on images taken
Marker_Image = [5, 1];

% close all
% Initialize an empty struct array for storing people locations and orientations
people = struct('location', {}, 'orientation', {});

for i = 1:length(files)
    
    % Get the pose of the marker in the image
    arTagImagePath = fullfile(folder_name, files(i).name);
    [~, pose, ~, t] = getPose(arTagImagePath, camParamMatFilePath, markerSizeMM);

    % Skip if no marker is detected
    if isempty(pose)
        continue;
    end
    
    % Ensure translation is in meters
    pose.A(1:3,4) = pose.A(1:3,4) * 0.001;  % Convert from mm to meters if necessary
    
    % Pose of the marker in the camera frame
    T_marker_camera = pose.A;
    
    % Pose of the marker in the world frame
    T_marker_world = [Markers1(Marker_Image(i)).orientation, Markers1(Marker_Image(i)).location'; 0, 0, 0, 1];
    
    % Inverse between Marker and camera
    T_person = T_marker_world * inv(T_marker_camera);

    % Extract location and orientation
    people(end+1).location = T_person(1:3, 4);
    people(end).orientation = T_person(1:3, 1:3);
    
end

% Plot location of people and markers at the end
 plot_markers_people(Markers1, master, people);
%% Save info from images
out_file = 'data/Test_10-04-24/cameras.csv'; % Output file
save_camera_location(people, Markers1, out_file, new_marker_num,timestamp)