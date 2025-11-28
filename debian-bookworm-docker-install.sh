#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

echo "Starting Docker Installation for Debian Trixie (Raspberry Pi)..."

# 1. Update and Install Prerequisites
echo "Updating apt package index..."
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release iputils-ping dnsutils

# 2. Add Docker's Official GPG Key
echo "Adding Docker GPG key..."
mkdir -p /etc/apt/keyrings
rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Set Up the Repository
# NOTE: We force 'bookworm' (stable) here because 'trixie' (testing) 
# often lacks a dedicated release file in the official Docker repo.
echo "Setting up the Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Install Docker Engine
echo "Installing Docker Engine..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin

# 5. Enable and Start Docker
echo "Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

# 6. Post-Installation Steps (Group Configuration)
# Adds the user who called the script (via sudo) to the docker group
if [ -n "$SUDO_USER" ]; then
    echo "Adding user $SUDO_USER to the docker group..."
    usermod -aG docker "$SUDO_USER"
    echo "User $SUDO_USER added to docker group."
else
    echo "Script not run via sudo; skipping user group addition."
    echo "To run docker without sudo, run: usermod -aG docker your-username"
fi

# 7. Verification
echo "Verifying installation..."
docker --version
echo "Installation complete! You may need to log out and back in for group changes to take effect."
