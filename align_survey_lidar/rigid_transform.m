function [R, t] = rigid_transform(P, Q)
    % Ensure P and Q are Nx3
    assert(all(size(P) == size(Q)));
    N = size(P, 1);

    % 1. Compute centroids
    centroid_P = mean(P, 1);
    centroid_Q = mean(Q, 1);

    % 2. Center the points
    P_centered = P - centroid_P;
    Q_centered = Q - centroid_Q;

    % 3. Compute covariance matrix
    H = P_centered' * Q_centered;

    % 4. SVD
    [U, ~, V] = svd(H);

    % 5. Compute rotation
    R = V * U';

    % Reflection case: fix improper rotation
    if det(R) < 0
        V(:,3) = -V(:,3);
        R = V * U';
    end

    % 6. Compute translation
    t = centroid_Q' - R * centroid_P';
end
