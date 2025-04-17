clear;
clc
close all;

%% User-defined Variables
%filename1 = 'data/Test_23-10-24/UTS.csv';  % Path to first CSV file
%filename1 = 'data/Test_11-03-25/uts.csv';  % Path to first CSV file
%filename1 = 'data/Test_13-03-25/1-6.csv';  % Path to first CSV file
%filename1 = 'data/Test_13-03-25/7-12.csv';  % Path to first CSV file
filename1 = 'data/Test_13-03-25/metro_final.csv';  % Path to first CSV file
n_markers1 = 15;                            % Number of markers in the first file

% Output file name
out_file = 'data/Test_13-03-25/metro_antenna_results_new_new_iden.csv'; % Output file

% Master terminal
master = 8; % This terminal will work as the origin [0,0,0]

%% Read and Process Markers from First File
[Points1, Markers1] = readMarkers(filename1, n_markers1);

%% Compute Distances and Transforms for First Set of Markers
[points_2_centre1, points_2_master1] = calculate_transforms(Markers1, master);

%% Adjust Markers: Set Master Station as Origin Without Changing Orientation
for i = 1:length(Markers1)
    Markers1(i).orientation(1, :) = -Markers1(i).orientation(1, :);
end

% Get the master station's location and orientation
master_location = Markers1(master).location;
master_orientation = Markers1(master).orientation;

[U, ~, V] = svd(master_orientation);
master_orientation = U * V';  % This ensures an orthogonal rotation matrix
Markers1(master).orientation = master_orientation;

if 1 % apply the master location to all
for i = 1:length(Markers1)
    % Adjust positions (include rotation)
    Markers1(i).location = (Markers1(i).location - master_location)';
    Markers1(i).location = Markers1(i).location';  % Transpose back to row vector

    % Swap position
    %Markers1(i).location = Markers1(i).location([2 1 3]);

    % Swap orientation axes
    %Markers1(i).orientation = Markers1(i).orientation([2 1 3], [2 1 3]);
    
    % Adjust orientations
    Markers1(i).orientation = master_orientation' * Markers1(i).orientation;
end
end

%% Plot Merged Markers
plot_markers(Markers1, master);
hold on;
axis equal
set(gca, 'XDir','normal') 
set(gca, 'YDir','normal') 
set(gca, 'ZDir','normal') 

%% Compute roll, pith and yaw
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
 save_markers(Markers1, out_file)
