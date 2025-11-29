function Logs(sshClient, sharedPath, jobId, dest)
if nargin<4, dest = pwd; end
remoteProj = sprintf('%s/hpc_jobs', '/home');
% try job out
[~,out] = sshClient.exec(sprintf('ls %s/*%s* 2>/dev/null || true', remoteProj, jobId));
if ~isempty(strtrim(out))
    files = strsplit(strtrim(out));
    for i=1:numel(files)
        rf = files{i};
        [~,name,ext] = fileparts(rf);
        local = fullfile(dest, [name ext]);
        try
            MacHPCClusterTools.SSH.SCP.get(sshClient, rf, local);
        catch
            warning('Failed to fetch %s', rf);
        end
    end
end
% try shared outputs
if ~isempty(sharedPath)
    [status,out2] = sshClient.exec(sprintf('ls %s/outputs | grep %s || true', sharedPath, jobId));
    if status==0 && ~isempty(strtrim(out2))
        items = strsplit(strtrim(out2), '\n');
        for i=1:numel(items)
            fn = strtrim(items{i});
            if isempty(fn), continue; end
            remoteFile = sprintf('%s/outputs/%s', sharedPath, fn);
            localFile = fullfile(dest, fn);
            try
                MacHPCClusterTools.SSH.SCP.get(sshClient, remoteFile, localFile);
            catch
                warning('Failed to fetch shared file %s', remoteFile);
            end
        end
    end
end
end
