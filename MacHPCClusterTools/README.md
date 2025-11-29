# MacHPCClusterTools

This toolbox provides simple MATLAB helpers to submit jobs to a SLURM cluster from macOS,
discover nodes via Bonjour (dns-sd), and fetch outputs from a shared path.

Shared storage (configured): /Users/Shared/HPC

File structure:
- install.m / uninstall.m
- +MacHPCClusterTools/Manager.m
- +MacHPCClusterTools/+SSH/* (Client, SCP, Agent)
- +MacHPCClusterTools/+Slurm/* (Submit, Status, Cancel, Logs)
- +MacHPCClusterTools/+Network/* (discoverSSHHosts, resolveSSHService)
- app/MacHPCClusterDashboard.m (simple UIFigure dashboard)

Install:
1. Copy the `MacHPCClusterTools` folder to a MATLAB path location.
2. Run `install` in MATLAB.
3. Open dashboard: run `MacHPCClusterDashboard` in MATLAB command window.

