% Define the two sets of points
first_set = [
    31.5204, 7.2688, -0.0151;
    31.5115, 7.3584, 0.0053;
    31.5242, 7.3798, -0.0832;
    31.5431, 7.2893, -0.1017
];

second_set = [
    -17.2535, 5.3354, 0.3949;
    -17.2838, 5.2491, 0.4151;
    -17.3092, 5.2357, 0.3266;
    -17.2885, 5.3251, 0.3068
];

% Compute centroids of both sets
centroid_first_set = mean(first_set);
centroid_second_set = mean(second_set);

% Compute the translation vector
translation_vector = centroid_first_set - centroid_second_set;

% Center the points by subtracting their respective centroids
first_set_centered = first_set - centroid_first_set;
second_set_centered = second_set - centroid_second_set;

% Compute the covariance matrix
H = second_set_centered' * first_set_centered;

% Perform Singular Value Decomposition (SVD)
[U, ~, V] = svd(H);

% Compute the rotation matrix
rotation_matrix = V * U';

% Ensure proper rotation (determinant should be +1)
if det(rotation_matrix) < 0
    V(:, end) = -V(:, end);
    rotation_matrix = V * U';
end

% Apply the rotation and translation to the second set
transformed_second_set = (second_set_centered * rotation_matrix') + centroid_first_set;

% Display the results
disp('Translation Vector:');
disp(translation_vector);
disp('Rotation Matrix:');
disp(rotation_matrix);
disp('Transformed Second Set (with translation and rotation):');
disp(transformed_second_set);
