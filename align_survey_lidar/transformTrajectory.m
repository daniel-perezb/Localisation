function [positions_out, quaternions_out] = transformTrajectory(positions_in, quaternions_in, R, t)
% TRANSFORMTRAJECTORY Applies a rigid transform (R, t) to a trajectory
% 
% INPUTS:
%   positions_in   - Nx3 matrix of positions [x y z]
%   quaternions_in - Nx4 matrix of quaternions in [x y z w] format
%   R              - 3x3 rotation matrix
%   t              - 3x1 translation vector
%
% OUTPUTS:
%   positions_out     - Nx3 transformed positions
%   quaternions_out   - Nx4 transformed quaternions (still in [x y z w] format)

    % Transform positions
    positions_out = (R * positions_in')' + t';

    % Transform quaternions
    N = size(quaternions_in, 1);
    quaternions_out = zeros(N, 4);

    for i = 1:N
        q_xyz_w = quaternions_in(i, :);                 % Input: [x y z w]
        q_wxyz = [q_xyz_w(4), q_xyz_w(1:3)];            % Reorder to [w x y z]

        R_local = quat2rotm(q_wxyz);                   % Convert to rotation matrix
        R_composed = R * R_local;                      % Apply global rotation
        q_wxyz_new = rotm2quat(R_composed);            % Back to quaternion
        quaternions_out(i, :) = [q_wxyz_new(2:4), q_wxyz_new(1)];  % Back to [x y z w]
    end
end
