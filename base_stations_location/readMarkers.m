function [Points, Markers] = readMarkers(filename, n_markers)

    % This function finds the orientation and centre in 3D space of a set 4
    % points sorrounding a AR tag
    % It expects as input a filename and number of markers in the file.
    % It returns Cnetroid and Orientation of a set 4 of markers
    
    
    % CSV expect as input 
    % 1st Column num of marker
    % 2nd Column x location
    % 3rd Column y location
    % 4th Column z location
    
    data = readtable(filename, 'FileType', 'text', 'VariableNamingRule', 'preserve', 'Delimiter', ',');
    
    % Initialize an array for centroids and orientation matrices
    Markers = struct('location', {}, 'orientation', {});

    allPoints = table2array(data(:,2:end));
    
    % Swap X and Y (i.e., column 1 with column 2) due to the survey data is
    % like that, we need to fix it
    allPoints = allPoints(:, [2 1 3]);

    pairs = [14,5,1;13,3,1;14,12,2;15,8,2];
    allPointsRot = svd_points(allPoints,pairs);

    % Original point if axes are different to the ones specified
    % Otherwise change to original_point = [0,0,0];
    original_point = allPointsRot(end,:);
    Points = zeros(1, 3);

    for i = 1:4:(n_markers*4)
        points = zeros(4, 3); % To store the X, Y, Z of the 4 midpoints
    
        % Reformat and store the data for the four points
        for j = 0:3
            % Reformat each row's data to extract [x, y, z] coordinates
            point = allPointsRot(i+j,:);
            points(j+1, :) = point - original_point;
            Points(end+1, :) = point - original_point;
        end
    
        % This has to be changed if only 3 points are detected
        centroid = mean(points, 1); % Calculate centroid of the points
    
        % Compute vectors for orientation
        v1 = points(4, :) - points(2, :); % X coordinante from point 1 to 3
        v3 = points(3, :) - points(1, :); % Z coordinante from point 2 to 4
        v2 = cross(v1, v3); % Y coordinante Cross product to get the third orthogonal vector
    
        % Normalize vectors to make them unit vectors
        v1 = v1 / norm(v1);
        v2 = v2 / norm(v2);
        v3 = v3 / norm(v3);
    
        % Orientation matrix [v1; v2; v3] as rows
        orientation = [v1; v2; v3];
    
        % Define the rotation matrix for a degree clockwise around the z-axis
        Rz_0 = [1, 0, 0; 
                     0,1, 0; 
                     0, 0, 1];
        
        % Rz_90 = [0, -1, 0; 
        %                1, 0, 0; 
        %                0, 0, 1];

         % Rz_180 = [-1, 0, 0; 
         %               0,-1, 0; 
         %               0, 0, 1];

        % Apply the rotation
        orientation1 = Rz_0 * orientation;
        
        % Store computed centroid and orientation in the Markers struct
        Markers(end+1).location = centroid;
        Markers(end).orientation = orientation1;
    end
        Points(1,:) = [];
end