function adjusted_pose = rotate_pose(pose_matrix, target_angle_deg, reference_matrix, axis)
    % Extract rotation matrix and translation vector from pose matrix
    rotationMatrix = pose_matrix(1:3, 1:3);
    translationVector = pose_matrix(1:3, 4);

    % Extract the rotation and translation from the reference matrix
    referenceRotation = reference_matrix(1:3, 1:3);
    referenceTranslation = reference_matrix(1:3, 4);

    % Define rotation axis based on the reference matrix orientation
    if axis == 'x'
        rotation_axis = referenceRotation(:, 1);  % X axis of reference matrix
    elseif axis == 'y'
        rotation_axis = referenceRotation(:, 2);  % Y axis of reference matrix
    elseif axis == 'z'
        rotation_axis = referenceRotation(:, 3);  % Z axis of reference matrix
    else
        error("Incorrect axis. Please select 'x', 'y', or 'z'.")
    end

    % Normalize the rotation axis to ensure it's a unit vector
    rotation_axis = rotation_axis / norm(rotation_axis);

    % Convert target angle to radians
    theta_rad = deg2rad(target_angle_deg);

    % Compute the rotation matrix around the given axis using Rodrigues' rotation formula
    K = [0, -rotation_axis(3), rotation_axis(2);
         rotation_axis(3), 0, -rotation_axis(1);
         -rotation_axis(2), rotation_axis(1), 0];

    R = eye(3) + sin(theta_rad) * K + (1 - cos(theta_rad)) * (K * K);

    % Move the pose to the reference point's frame (translate relative to the reference)
    translationRelative = translationVector - referenceTranslation;

    % Apply the rotation to both the orientation and the relative translation
    new_orientation = R * rotationMatrix;
    updated_translation = R * translationRelative;

    % Move the pose back to the original frame (translate back)
    updated_translation = updated_translation + referenceTranslation;

    % Construct the new pose matrix with the updated orientation and location
    adjusted_pose = eye(4);
    adjusted_pose(1:3, 1:3) = new_orientation;
    adjusted_pose(1:3, 4) = updated_translation;
end
