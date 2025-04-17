% Clear workspace and load data
clear; clc;
close all;

% --- Step 1: Load the point cloud ---
ptCloud = pcread('data/results_map_trajectory/results_2025_04_07-11_39_04/lidar/map_2025_04_07-11_39_04.pcd');

% --- Step 2: Load the trajectory ---
% Read the CSV into a table
T = readtable('data/results_map_trajectory/results_2025_04_07-11_39_04/lidar/trajectory_2025_04_07-11_39_04.csv');

% Extract position (Nx3) and quaternion (Nx4) matrices
positions = [T.PosX, T.PosY, T.PosZ];
quaternions = [T.QuatX, T.QuatY, T.QuatZ, T.QuatW];

% --- Step 2: Load the survey ---
survey_result = readtable('../base_stations_location/data/Test_13-03-25/metro_antenna_results_new_new_iden.csv');
survey_position = [survey_result.location_1, survey_result.location_2, survey_result.location_3];
survey_orientation = survey_result.orientation;
load('../base_stations_location/data/Test_13-03-25/Markers1_base8.mat')

% --- Step 3: Visualize both ---
figure;
hold on;
pcshow(ptCloud, 'MarkerSize', 50);
plot3(positions(:,1), positions(:,2), positions(:,3), 'r-', 'LineWidth', 2);  % Plot trajectory
plot3(survey_position(:,1), survey_position(:,2), survey_position(:,3), 'r*', 'LineWidth', 2);  % Plot survey
axis on;

% Example: 4 points in each set
Q = [survey_position(3,:); survey_position(4,:); survey_position(11,:); survey_position(10,:)];       % target (after some R & t)
P = [-5.7162 -7.1458 1.6067; -7.2162 -6.1236 1.2185; -18.6184 -21.8428 8.6432; -19.6964 -21.0639 8.4768];       % source 

[R, t] = rigid_transform(P, Q);

% To verify:
P_transformed = (R * P')' + repmat(t', size(P,1), 1);
disp(norm(Q - P_transformed))  % should be close to 0

transformedPoints = (R * ptCloud.Location')' + t';
ptCloudTransformed = pointCloud(transformedPoints);

[positions1, quaternions1] = transformTrajectory(positions, quaternions, R, t);

% Visualize
figure;
hold on;
pcshow(ptCloudTransformed, 'MarkerSize', 50);
plot3(positions1(:,1), positions1(:,2), positions1(:,3), 'r-', 'LineWidth', 2);  % Plot transformed trajectory
plot3(survey_position(:,1), survey_position(:,2), survey_position(:,3), 'r*', 'LineWidth', 2);  % Plot survey

plot_markers1(Markers1, 8);
axis on;
axis equal

% Update position columns
T.PosX = positions1(:,1);
T.PosY = positions1(:,2);
T.PosZ = positions1(:,3);

% Update quaternion columns
T.QuatX = quaternions1(:,1);
T.QuatY = quaternions1(:,2);
T.QuatZ = quaternions1(:,3);
T.QuatW = quaternions1(:,4);

writetable(T, 'data/results_map_trajectory/results_2025_04_07-11_39_04/aligned_trajectory_2025_04_07-11_39_04.csv');
pcwrite(ptCloudTransformed, 'data/results_map_trajectory/results_2025_04_07-11_39_04/aligned_map_2025_04_07-11_39_04.ply', 'Encoding', 'ascii');

%figure
if 0
points = [survey_result(:,1), survey_result(:,2), survey_result(:,3)];

% Create red color [255, 0, 0] for each point
numPoints = size(points, 1);
redColor = repmat(uint8([255, 0, 0]), numPoints, 1);  % Nx3

% Create point cloud with color
ptCloudd = pointCloud(points, 'Color', redColor);

% Save to PLY file (ASCII or binary)
pcwrite(ptCloudd, 'output_survey_points.ply', 'Encoding', 'ascii');
pcwrite(ptCloud, 'output_map_points.ply', 'Encoding', 'ascii');  % or 'binary'

% Labels and appearance
title('Point Cloud with Trajectory');
%xlabel('X'); ylabel('Y'); zlabel('Z');
%legend('Point Cloud', 'Trajectory Path', 'Trajectory Points');
grid on;
axis equal;
view(3);
end
