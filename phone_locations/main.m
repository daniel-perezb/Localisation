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


%% Adjust Markers: Set Master Station as Origin Without Changing Orientation

% Get the master station's location
master_location = Markers1(master).location;

% Subtract the master location from all marker locations
% Only translation is applied to maintain the original axes alignment.
for i = 1:length(Markers1)
    Markers1(i).location = Markers1(i).location - master_location;
end

%% Plot Merged Markers
% plot_markers(Markers1, master);
%% Location of humans taking pictures of AR markers

% Variables
folder_name = 'data/Extracted_Images';
files = dir(fullfile(folder_name, '*.jpg'));
files = files(~[files.isdir]);

camParamMatFilePath = "./data/calibration/cameraParamsIp14Pro.mat";
markerSizeMM = 180; % Ar tag marker size in mm

% Marker index based on images taken
Marker_Image = [2, 4, 2, 4, 2, 4];

% Initialise variables
markerPositions = zeros(size(files, 1), 3);
markerOrientations = zeros(3, 3, size(files, 1));
cameraPositions = zeros(size(files, 1), 3);
cameraOrientations = zeros(3, 3, size(files, 1));
angles = zeros(size(files, 1),3);
timestamp = cell(size(files, 1)-1, 1);
new_marker_num = zeros(size(files, 1),1);
final_angles = zeros(size(files, 1),1);
final_distances = zeros(size(files, 1),1);
Initial = eye(3);
change_axes = 1;

% Scale factor for visualizing the axes
axisLength = 0.2;

people = struct('location', {}, 'orientation', {});

for i = 1:size(files,1)
    % Error with 5 photo
    if i==5
        continue
    end
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

    % Store copy for rotation later
    original_pose = pose.A;

    % Adjust pose by rotating about 'y' axis
    pose.A = rotate_pose(pose.A, -90, 'x');

    % Extract and convert translation vector and rotation matrix
    translationVector = pose.A(1:3, 4) * 0.001; % Convert mm to meters
    translationVector = [translationVector(3), translationVector(2), -translationVector(1)];
    rotationMatrix = pose.A(1:3, 1:3);
 

    % Calculate the translation from origin to marker in photo
    Origin_translation =  Markers1(Marker_Image(i)).location - translationVector;
    marker_location = Markers1(Marker_Image(i)).location;

    % Apply transformation to the camera location
    Transformed_Point =  Origin_translation + [0,0,0] ;
    cameraPositions(i,:) = Transformed_Point(1:3);
    cameraOrientations(:, :, i) = eye(3);
    cameraOrientations(:, :, i) = [cameraOrientations(:,3), cameraOrientations(:,1), cameraOrientations(:,2)];
    
    % final_angles(i) = norm(cameraPositions(i,:) - Markers1(Marker_Image(i)).location); 

    % Find rotation on x axis
    R_AB = original_pose(1:3, 1:3) * eye(3);
    eulerAngle = rotm2eul(R_AB, 'XYZ');
    angles(i,:) = rad2deg(eulerAngle);

    % Angle difference in degrees
    theta_rad = deg2rad(180 - abs(angles(i,1)));
    theta_rad = -theta_rad;
    
    % Rotation matrix
    Rx = [cos(theta_rad), -sin(theta_rad), 0;
             sin(theta_rad), cos(theta_rad), 0;
             0, 0, 1];
    
    cameraPositions(i,:) = (Rx * (cameraPositions(i,:)' - marker_location') + marker_location')';
    cameraOrientations(:, :, i) = Rx * eye(3);
        
    final_angles(i) = rad2deg(theta_rad);
    final_distances(i) = norm(cameraPositions(i,:) - marker_location);

    % Store modified marker position and orientation
    people(end+1).location = cameraPositions(i,:);
    people(end).orientation = cameraOrientations(:, :, i);

end

% Plot location of people and markers at the end
plot_markers_people(Markers1, master, people);

%% Save info from images
% out_file = 'data/Test_10-04-24/cameras.csv'; % Output file
% save_camera_location(people, Markers1, out_file, new_marker_num,timestamp)