# We collected 3 rosbags on 07 April, and successfully processed the map and trajectory.

# We provide the aligned map from lidar, aligned trajectory from lidar, aligned survey results, and the rotation and translation from the lidar to the survey.

# The survey data has the antenna 8 as base station.


results_map_trajectory/
├──── results_2025_04_07-11_20_03
│   ├──── aligned_map_....ply                          % aligned lidar map
│   ├──── aligned_trajectory_....csv                   % aligned lidar trajectory
│   ├──── R_and_t_....csv                              % rotation and translation from lidar to survey
├──── results_2025_04_07-11_39_04
│   ├──── aligned_map_....ply                          % aligned lidar map
│   ├──── aligned_trajectory_....csv                   % aligned lidar trajectory
│   ├──── R_and_t_....csv                              % rotation and translation from lidar to survey
├──── results_2025_04_07-12_00_34
│   ├──── aligned_map_....ply                          % aligned lidar map
│   ├──── aligned_trajectory_....csv                   % aligned lidar trajectory
│   ├──── R_and_t_....csv                              % rotation and translation from lidar to survey
├──── aligned_survey_results.csv                       % this the survey results with all respect to 8 as base station
├──── README.md                                        % readme file
...
