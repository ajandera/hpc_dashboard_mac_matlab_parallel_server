function jobId = Submit(sshClient, sharedPath, scriptPath, varargin)
% Submit a MATLAB script to SLURM via sbatch
p = inputParser();
addParameter(p,'cpus',4);
addParameter(p,'mem','8G');
addParameter(p,'time','24:00:00');
addParameter(p,'useGPU',false);
addParameter(p,'remoteBase','/home');
parse(p,varargin{:});
pr = p.Results;

[~,name,ext] = fileparts(scriptPath);
remoteProj = sprintf('%s/hpc_jobs', pr.remoteBase);

% Ensure remote dir
sshClient.exec(sprintf('mkdir -p %s', remoteProj));

% upload script
MacHPCClusterTools.SSH.SCP.put(sshClient, scriptPath, sprintf('%s/%s%s', remoteProj, name, ext));

% prepare sbatch
gpuLine = '';
if pr.useGPU, gpuLine = '#SBATCH --gres=gpu:1\n'; end
sharedExport = '';
if ~isempty(sharedPath), sharedExport = sprintf('export HPC_SHARED_PATH=%s\n', sharedPath); end

runCmd = sprintf('run(''%s'');', name);
sbatch = sprintf(['#!/bin/bash\n' ...
    '#SBATCH --job-name=%s\n' ...
    '#SBATCH --output=%s_%%j.out\n' ...
    '#SBATCH --time=%s\n' ...
    '#SBATCH --ntasks=1\n' ...
    '#SBATCH --cpus-per-task=%d\n' ...
    '#SBATCH --mem=%s\n' ...
    '%s' ...
    'module load matlab || true\n' ...
    'cd %s\n' ...
    '%s' ...
    'matlab -nodisplay -r "%s"\n'], name, name, pr.time, pr.cpus, pr.mem, gpuLine, remoteProj, sharedExport, runCmd);

tmp = [tempname '.sh'];
fid = fopen(tmp,'w'); fwrite(fid,sbatch); fclose(fid);

remoteSbatch = sprintf('%s/%s_job.sh', remoteProj, name);
MacHPCClusterTools.SSH.SCP.put(sshClient, tmp, remoteSbatch);
delete(tmp);

% submit
[status,out] = sshClient.exec(sprintf('sbatch %s', remoteSbatch));
if status~=0, error('sbatch failed: %s', out); end
tok = regexp(out, 'Submitted batch job (\d+)', 'tokens', 'once');
if ~isempty(tok), jobId = tok{1}; else jobId = ''; end
end
