import rosbag2_py
import csv
import sys
from rclpy.serialization import deserialize_message
from rosidl_runtime_py.utilities import get_message
import datetime

def unix_time_to_string(sec, nanosec):
    """Convert UNIX time to a human-readable string."""
    timestamp = sec + nanosec * 1e-9
    dt = datetime.datetime.fromtimestamp(timestamp)
    return dt.strftime('%Y-%m-%d %H:%M:%S.%f')

def main():
    if len(sys.argv) < 3:
        print("Usage: python extract_pose.py <bag_file_path> <pose_topic_name> [output_csv_file]")
        sys.exit(1)

    bag_file_path = sys.argv[1]
    pose_topic_name = sys.argv[2]
    output_csv_file = sys.argv[3] if len(sys.argv) > 3 else 'output.csv'

    clock_topic_name = '/clock'  # Assuming the clock topic is named '/clock'

    # Initialize storage and converter options
    storage_options = rosbag2_py.StorageOptions(uri=bag_file_path, storage_id='sqlite3')
    converter_options = rosbag2_py.ConverterOptions(
        input_serialization_format='cdr', output_serialization_format='cdr')

    # Open the bag file for reading
    reader = rosbag2_py.SequentialReader()
    reader.open(storage_options, converter_options)

    # Get all topics and types
    topic_types = reader.get_all_topics_and_types()
    type_dict = {topic.name: topic.type for topic in topic_types}

    # Check if the required topics exist
    if pose_topic_name not in type_dict:
        print(f"Error: Topic '{pose_topic_name}' not found in the bag file.")
        sys.exit(1)
    if clock_topic_name not in type_dict:
        print(f"Error: Topic '{clock_topic_name}' not found in the bag file.")
        sys.exit(1)

    # Get the message types for the topics
    pose_msg_type = get_message(type_dict[pose_topic_name])
    clock_msg_type = get_message(type_dict[clock_topic_name])

    # Initialize counter for non-zero pos.x values
    non_zero_posx_counter = 0

    # Initialize clock time
    clock_time_sec = None
    clock_time_nanosec = None

    # Open the CSV file for writing
    with open(output_csv_file, mode='w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        # Write CSV header
        csv_writer.writerow(['Timestamp', 'Ros_Timestamp', 'PosX', 'PosY', 'PosZ', 'QuatX', 'QuatY', 'QuatZ', 'QuatW'])

        while reader.has_next():
            topic, data, timestamp = reader.read_next()
            if topic == clock_topic_name:
                # Deserialize the clock message
                clock_msg = deserialize_message(data, clock_msg_type)
                # Update clock time
                clock_time_sec = clock_msg.clock.sec
                clock_time_nanosec = clock_msg.clock.nanosec
            elif topic == pose_topic_name:
                # Ensure clock time is available
                if clock_time_sec is None:
                    continue  # Skip pose messages until clock time is available

                # Deserialize the pose message
                msg = deserialize_message(data, pose_msg_type)
                pos = msg.pose.position
		
		# Start recording from the first non-zero frame
                if pos.x != 0:
                    non_zero_posx_counter += 1
                    if non_zero_posx_counter >= 2:
                        # Convert clock time to human-readable format
                        real_time_str = unix_time_to_string(clock_time_sec, clock_time_nanosec)
                        # Extract ROS timestamp (in seconds)
                        ros_time_sec = msg.header.stamp.sec + msg.header.stamp.nanosec * 1e-9
                        # Extract orientation
                        ori = msg.pose.orientation
                        # Write the data to CSV
                        csv_writer.writerow([
                            real_time_str,
                            ros_time_sec,
                            pos.x, pos.y, pos.z,
                            ori.x, ori.y, ori.z, ori.w
                        ])
                else:
                    continue  # Skip zero pos.x values

    print(f"Data successfully extracted to {output_csv_file}")

if __name__ == '__main__':
    main()

