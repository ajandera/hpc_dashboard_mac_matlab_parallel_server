#!/bin/bash
set -e

echo "=== Mac HPC Node Setup Script ==="

##############################################
# 1️⃣ Install Homebrew if missing
##############################################
if ! command -v brew >/dev/null 2>&1; then
    echo "[INFO] Installing Homebrew…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

##############################################
# 2️⃣ Install required tools/packages
##############################################
brew update
brew install \
    slurm \
    openssh \
    rsync \
    gnu-tar \
    tmux \
    htop \
    jq \
    python3

# GPU monitoring
brew install --cask gfxcardstatus || true

##############################################
# 3️⃣ Create SLURM folders
##############################################
sudo mkdir -p /opt/slurm /var/spool/slurmctld /var/spool/slurmd /var/log/slurm
sudo chown -R $USER:admin /opt/slurm /var/spool/slurm* /var/log/slurm

##############################################
# 4️⃣ Detect cores, RAM → generate slurm.conf
##############################################
CORES=$(sysctl -n hw.ncpu)
MEM_MB=$(($(sysctl -n hw.memsize) / 1024 / 1024))
NODE=$(scutil --get LocalHostName)

cat > /opt/slurm/slurm.conf <<EOF
ClusterName=MacCluster
SlurmctldHost=$NODE
NodeName=$NODE CPUs=$CORES RealMemory=$MEM_MB State=UNKNOWN
PartitionName=default Nodes=$NODE Default=YES MaxTime=INFINITE State=UP
EOF

##############################################
# 5️⃣ Set up environment modules (MATLAB fallback)
##############################################
mkdir -p /opt/modules/matlab
cat > /opt/modules/matlab/2025a.lua <<EOF
help([[
Adds MATLAB to PATH if installed locally
]])
prepend_path("PATH","/Applications/MATLAB_R2025a.app/bin")
EOF

##############################################
# 6️⃣ Common HPC folders + SSH convenience
##############################################
mkdir -p ~/mac-hpc/projects ~/mac-hpc/scratch ~/mac-hpc/results
chmod 755 ~/mac-hpc/

# Enable SSH login + host key cache
sudo systemsetup -setremotelogin on

##############################################
# 7️⃣ System services for SLURM (optional)
##############################################
echo "[INFO] Creating SLURM service launchd plist"

cat > ~/Library/LaunchAgents/org.slurmctld.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key> <string>org.slurmctld</string>
    <key>ProgramArguments</key>
    <array><string>/opt/homebrew/sbin/slurmctld</string></array>
    <key>RunAtLoad</key> <true/>
</dict>
</plist>
EOF

launchctl load ~/Library/LaunchAgents/org.slurmctld.plist || true

##############################################
# 8️⃣ MATLAB tests (if installed)
##############################################
if [ -d "/Applications/MATLAB_R2025a.app" ]; then
    echo "[OK] MATLAB detected."
else
    echo "[WARN] MATLAB not found… will run jobs in headless environment mode."
fi

echo "=== Setup Complete ==="
echo "Reboot recommended after first configuration"
