function s = Status(sshClient, jobId)
if nargin<2 || isempty(jobId), error('JobId required'); end
[status,out] = sshClient.exec(sprintf('squeue -j %s -o "%%i %%t %%M %%L %%j" -h', jobId));
if status~=0, s = sprintf('Error: %s', out); else s = strtrim(out); end
end
