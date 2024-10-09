Lidar Backpack User Manual 
UTS  
12/09/2024 
 

# Lidar Sensor 

The LiDAR backpack is equipped with an Ouster OS1-64 LiDAR sensor (Model Number: OS1-991942001092). The sensor requires a 24V power supply, which is provided by a voltage converter housed within the main circuit box. 

## Access Information 

    - Username: uts 

    - Password: admin1 

     

## Data Recording 

To record data, follow these steps: 

1. Double-click the “Record LiDAR” shortcut located on the desktop. 
2. This will run the script ouster_record.sh, located in the home directory. 
3. The program will automatically start recording, and the recorded data will be saved in the home directory with the filename format rosbag2_* where * is the date and time of the recording. 

    - The recording will generate two files: 

      - A *.db3 file (the rosbag data) 

      - A metadata file that includes session details. 

 

# Ouster code 

The code used for data recording is available in the following Git repository: 
https://github.com/ouster-lidar/ouster-ros/tree/ros2 

 
- Commit number: 2a0ef50f1dbe3f512321e809d6ca87391ce38f6e 

- Date: 3 June 2024 

Note: We have tested several newer commits, but they introduced errors. We recommend using this specific commit for consistency across devices. 

Starting the Ouster Lidar Recording 

To manually launch the Ouster LiDAR and begin recording, use the following command in the terminal: 

``` 

ros2 launch ouster_ros record.launch.xml        sensor_hostname:=os1-991942001092.local 

``` 

Alternatively, you can simply double-click the “Quick Launch” app located on the desktop to start recording without using the terminal. 

 

## Updated packages 

 

Modifications have been made to the repository to ensure compatibility between the LiDAR sensor and the direct_lidar processing code. 
 

The updated launch file is located at: 

- /home/ros2_ws/src/ouster-ros/ouster-ros/launch/record.composite.launch.xml 

 

Changes to the record.composite.launch.xml file ensure that the following topics are recorded: 

``` 

 /$(var ouster_ns)/imu 

 /$(var ouster_ns)/points 

``` 

This ensures both the IMU data and the point cloud data from the sensor are captured during recording. 

## Installation Instructions 

For detailed installation instructions on how the LiDAR and its components were set up (including ROS 2 and the desktop shortcuts), refer to the README.md file located in the home directory. This document includes step-by-step instructions for setting up the entire system. 

 

 
