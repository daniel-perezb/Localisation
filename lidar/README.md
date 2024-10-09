# LiDAR Mapping and Path Computation
This project creates a 3D map from LiDAR scans and computes the path taken by a person during the scan. The project is implemented using ROS 2 and runs on Ubuntu 22.04. It uses the direct_lidar_inertial_odometry package for processing the LiDAR data and outputs the path in a CSV file format. Follow the steps below to set up and run the project.

### Prerequisites

System Requirements:

    Ubuntu 22.04
    ROS 2 Humble

### Dependencies

To ensure the project works correctly, make sure the following Python libraries are installed:
    
    pip3 install pandas numpy 

For installation of the direct lidar reconstruciton map please follow the instructions on the following link using 'feature/ros2' branch: 
    
    https://github.com/vectr-ucla/direct_lidar_inertial_odometry/tree/feature/ros2

## Running the Code

### 1. Start the LiDAR Inertial Odometry
Open the first terminal and run the direct_lidar_inertial_odometry launch file:

    ros2 launch direct_lidar_inertial_odometry dlio.launch.py rviz:=true pointcloud_topic:=/ouster/points imu_topic:=/ouster/imu
This will start the LiDAR mapping system and open RViz for visualizing the point clouds and path.

### 2. Record the Key Data in a New Bag
Open a second terminal and record the required topics into a new ROS 2 bag:

    ros2 bag record -o bag_name dlio/odom_node/pose

#### 3. Play the Recorded Bag File
Open a third terminal and play back the previously recorded bag file, ensuring to use --clock to enable the correct synchronization:
    
    ros2 bag play bag_name.db3 --clock

### 4. Save the Output Map
Before closing the RViz session, save the generated map in a separate terminal:
    
    ros2 service call /save_pcd direct_lidar_inertial_odometry/srv/SavePCD "{'leaf_size': .05, 'save_path': '~/path'}"
This will save the point cloud map to the specified directory.

### 5. Extract the Path from the Bag File
After recording the necessary data, extract the person's path from the ROS 2 bag file. Use the provided Python script to convert the bag file data into CSV format:
    
    python3 rosbag_2_csv.py input_bag /dlio/odom_node/pose output_name
This will generate a CSV file containing multiple columns with the x, y, and z coordinates of the person along with their orientation.