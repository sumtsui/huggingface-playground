#!/bin/bash

IMAGE_NAME="huggingface-play"
CONTAINER_NAME="huggingface-play"

# Function to prompt for yes/no confirmation
confirm() {
  while true; do
    read -p "$1 [y/n]: " yn
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo "Please answer yes or no." ;;
    esac
  done
}

# Check if the image exists
if [[ "$(docker images -q $IMAGE_NAME 2>/dev/null)" == "" ]]; then
  echo "Image not found. Building $IMAGE_NAME..."
  docker build -t $IMAGE_NAME .
else
  echo "Image $IMAGE_NAME already exists."
fi

# Check if the container is already running
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
  echo "Container $CONTAINER_NAME is already running."
  if confirm "Do you want to enter the existing container?"; then
    echo "Entering existing container..."
    docker exec -it $CONTAINER_NAME /bin/bash
    exit 0
  elif confirm "Do you want to stop the existing container and start a new one?"; then
    echo "Stopping existing container..."
    docker rm --force $CONTAINER_NAME
  else
    echo "Exiting without action."
    exit 0
  fi
elif [ "$(docker ps -aq -f status=exited -f name=$CONTAINER_NAME)" ]; then
  echo "Container exists but is not running."
  if confirm "Do you want to remove the existing container and start a new one?"; then
    echo "Removing existing container..."
    docker rm $CONTAINER_NAME
  else
    echo "Exiting without action."
    exit 0
  fi
fi

# Run the container
echo "Starting new container..."
docker run -d --name $CONTAINER_NAME \
  -p 7860:7860 \
  -v ./models:/home/user/app/models \
  -v ./main.py:/home/user/app/main.py \
  --platform linux/amd64 \
  $IMAGE_NAME

# Execute bash in the container
echo "Executing bash in the new container..."
docker exec -it $CONTAINER_NAME /bin/bash

echo "Script completed."
