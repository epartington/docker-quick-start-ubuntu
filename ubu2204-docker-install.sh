#!/bin/bash

# This script automates the installation of Docker Engine (Community Edition)
# and Docker Compose on an Ubuntu system. It also performs the necessary
# post-installation step of adding the current user to the 'docker' group.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- [Step 1/5] Starting Docker installation... ---"
echo "Updating apt package index and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg

echo "--- [Step 2/5] Adding Docker's official GPG key... ---"
# Create the keyring directory
sudo install -m 0755 -d /etc/apt/keyrings
# Download and de-armor the GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# Set permissions
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "--- [Step 3/5] Setting up the Docker 'stable' repository... ---"
# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "--- [Step 4/5] Installing Docker Engine, CLI, and Compose... ---"
# Update apt-cache again with the new repo
sudo apt-get update
# Install the latest versions
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "--- [Step 5/5] Performing post-installation steps... ---"
echo "Adding current user ($USER) to the 'docker' group..."
# Create the docker group if it doesn't exist (usually does)
sudo groupadd docker || true
# Add the current user to the group
sudo usermod -aG docker $USER

echo ""
echo "=================================================================="
echo "✅ Docker installation complete!"
echo ""
echo "   IMPORTANT: You must log out and log back in"
echo "   for your new group membership to take effect."
echo ""
echo "After logging back in, you can verify the installation by running:"
echo "   docker run hello-world"
echo "=================================================================="
