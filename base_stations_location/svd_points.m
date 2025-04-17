function allPointsRot = svd_points(allPoints,pairs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

all_Trans1 = [];
all_Trans2 = [];
all_Loca1 = [];
all_Loca2 = [];
for i =1:2:size(pairs,1)
     
    pair_idx_target = pairs(i,1);
    pair_idx_source = pairs(i,2);
    
    pair_idx_target1 = pairs(i+1,1);
    pair_idx_source1 = pairs(i+1,2);

    first_set = [allPoints((pair_idx_target-1)*4+1,:);
                     allPoints((pair_idx_target-1)*4+2,:);
                     allPoints((pair_idx_target-1)*4+3,:);
                     allPoints((pair_idx_target-1)*4+4,:);
                     allPoints((pair_idx_target1-1)*4+1,:);
                     allPoints((pair_idx_target1-1)*4+2,:);
                     allPoints((pair_idx_target1-1)*4+3,:);
                     allPoints((pair_idx_target1-1)*4+4,:);
                     ];

    second_set = [allPoints((pair_idx_source-1)*4+1,:);
                     allPoints((pair_idx_source-1)*4+2,:);
                     allPoints((pair_idx_source-1)*4+3,:);
                     allPoints((pair_idx_source-1)*4+4,:);
                     allPoints((pair_idx_source1-1)*4+1,:);
                     allPoints((pair_idx_source1-1)*4+2,:);
                     allPoints((pair_idx_source1-1)*4+3,:);
                     allPoints((pair_idx_source1-1)*4+4,:);
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
    transformed_second_set = ((second_set - centroid_second_set) * rotation_matrix') + translation_vector + centroid_second_set;
    
    % Display the results
    disp('Translation Vector:');
    disp(translation_vector);
    disp('centroid_first_set:');
    disp(centroid_first_set);
    disp('Rotation Matrix:');
    disp(rotation_matrix);
    
    disp('First Set:');
    disp(first_set);
    
    disp('Transformed Second Set (with translation and rotation):');
    disp(transformed_second_set);

    if pairs(i,end) ==1
    all_Trans1 = [all_Trans1; rotation_matrix];
    all_Loca1 = [all_Loca1; translation_vector; centroid_second_set];
    end

    if pairs(i,end) ==2
    all_Trans2 = [all_Trans2; rotation_matrix];
    all_Loca2 = [all_Loca2; translation_vector; centroid_second_set];
    end
end

% Trans1 = all_Trans1(1:3,:)*0.5 +all_Trans1(4:6,:)*0.5 ;
% Trans2 = all_Trans2(1:3,:)*0.5 +all_Trans2(4:6,:)*0.5 ;
% Loca1 = all_Loca1(1,:)*0.5 +all_Loca1(2,:)*0.5 ;
% Loca2 = all_Loca2(1,:)*0.5 +all_Loca2(2,:)*0.5 ;

% figure; hold on;
% plot3(allPoints(1:24,1),allPoints(1:24,2),allPoints(1:24,3),'r.');
% plot3(allPoints(25:48,1),allPoints(25:48,2),allPoints(25:48,3),'k.');
% plot3(allPoints(49:60,1),allPoints(49:60,2),allPoints(49:60,3),'b.');
% axis on;
% axis equal;

transformed_current_set = [];
for i = 1:6
    current_set = [allPoints((i-1)*4+1,:);
                     allPoints((i-1)*4+2,:);
                     allPoints((i-1)*4+3,:);
                     allPoints((i-1)*4+4,:);];
    
    % Compute centroids of both sets
    centroid_current_set = mean(current_set);
    
    % Center the points by subtracting their respective centroids
    current_set_centered = current_set - centroid_current_set;

    % Apply the rotation and translation to the second set
    transformed_current_set = [transformed_current_set; ((current_set - all_Loca1(2,:)) * all_Trans1') + all_Loca1(1,:) + all_Loca1(2,:)];
end

transformed_current_set2 = [];
for i = 7:12
    current_set = [allPoints((i-1)*4+1,:);
                     allPoints((i-1)*4+2,:);
                     allPoints((i-1)*4+3,:);
                     allPoints((i-1)*4+4,:);];
    
    % Compute centroids of both sets
    centroid_current_set = mean(current_set);
    
    % Center the points by subtracting their respective centroids
    current_set_centered = current_set - centroid_current_set;

    % Apply the rotation and translation to the second set
    %transformed_current_set2 = [transformed_current_set2; (current_set_centered * Trans2') + Loca2 + centroid_current_set];
    %transformed_current_set2 = [transformed_current_set2; (current_set_centered * all_Trans2') + all_Loca2 + centroid_current_set];
   transformed_current_set2 = [transformed_current_set2; ((current_set - all_Loca2(2,:)) * all_Trans2') + all_Loca2(1,:) + all_Loca2(2,:)];

end

transformed_current_set3 = [];
current_set1 = allPoints(60,:);
current_set2 = allPoints(61,:);
transformed_current_set3 = [transformed_current_set3; ((current_set1 - all_Loca1(2,:)) * all_Trans1') + all_Loca1(1,:) + all_Loca1(2,:)];
transformed_current_set3 = [transformed_current_set3; ((current_set2 - all_Loca2(2,:)) * all_Trans2') + all_Loca2(1,:) + all_Loca2(2,:)];
transformed_current_set3 = [transformed_current_set3; allPoints(62,:);];

figure; hold on;
plot3(transformed_current_set(:,1),transformed_current_set(:,2),transformed_current_set(:,3),'b.');
plot3(allPoints(49:60,1),allPoints(49:60,2),allPoints(49:60,3),'c.');
plot3(transformed_current_set2(:,1),transformed_current_set2(:,2),transformed_current_set2(:,3),'r.');
plot3(transformed_current_set3(:,1),transformed_current_set3(:,2),transformed_current_set3(:,3),'k*');
axis on;
axis equal;

allPointsRot = [transformed_current_set;transformed_current_set2;allPoints(49:60,:);transformed_current_set3;];
end