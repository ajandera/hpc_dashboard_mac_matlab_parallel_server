function Cancel(sshClient, jobId)
if nargin<2 || isempty(jobId), error('JobId required'); end
[status,out] = sshClient.exec(sprintf('scancel %s', jobId));
if status~=0, error('scancel failed: %s', out); end
end
