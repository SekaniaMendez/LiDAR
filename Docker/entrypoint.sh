#!/bin/bash
set -e

# Source global environment
source /opt/ros/jazzy/setup.bash
if [ -f "/ros2_ws/install/setup.bash" ]; then
  source /ros2_ws/install/setup.bash
fi

# Define helper functions
resource() {
  echo "🔄 Reloading ROS 2 environment..."
  source /opt/ros/jazzy/setup.bash
  if [ -f "/ros2_ws/install/setup.bash" ]; then
    source /ros2_ws/install/setup.bash
  fi
  echo "✅ Environment reloaded!"
}

# Function for quick workspace rebuild
rebuild() {
  echo "🧱 Rebuilding workspace..."
  cd /ros2_ws
  colcon build --symlink-install
  resource
}

# Optional message
echo "✅ ROS 2 Jazzy ready at /ros2_ws"
echo "💡 Available helpers: resource, rebuild"

# Keep interactive shell with functions available
exec "$@"