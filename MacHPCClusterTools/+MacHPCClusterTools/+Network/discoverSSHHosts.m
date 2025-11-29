function hosts = discoverSSHHosts(timeoutSeconds)
if nargin<1, timeoutSeconds = 4; end
hosts = struct('name',{},'regtype',{},'domain',{},'hostname',{},'port',{});
cmd = sprintf('dns-sd -B _ssh._tcp local');
% run browse for timeoutSeconds and capture output
[status,out] = system(sprintf('%s & sleep %d; kill %%1 >/dev/null 2>&1 || true', cmd, timeoutSeconds));
lines = strsplit(out, char(10));
services = {};
for i=1:numel(lines)
    line = strtrim(lines{i});
    if isempty(line), continue; end
    if ~isempty(regexp(line, '\b(Add|Add:|Add\))\b','once'))
        toks = regexp(line, '\s+', 'split');
        candidate = '';
        for t=1:numel(toks)
            tok = toks{t};
            if isempty(tok), continue; end
            if all(isstrprop(tok,'digit')), continue; end
            if length(tok)>length(candidate), candidate = tok; end
        end
        candidate = regexprep(candidate, '\.$','');
        if ~isempty(candidate), services{end+1} = candidate; end
    end
end
services = unique(services);
for i=1:numel(services)
    try
        info = MacHPCClusterTools.Network.resolveSSHService(services{i});
        hosts(end+1) = info; %#ok<AGROW>
    catch
    end
end
end
