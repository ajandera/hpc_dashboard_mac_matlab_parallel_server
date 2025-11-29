function MacHPCClusterDashboard
% Simple UIFigure dashboard for MacHPCClusterTools
fig = uifigure('Name','MacHPCClusterTools Dashboard','Position',[100 100 800 600]);
lbl = uilabel(fig,'Position',[20 560 400 24],'Text','MacHPCClusterTools - simple dashboard');
btnDiscover = uibutton(fig,'push','Text','Discover Nodes','Position',[20 520 120 30], 'ButtonPushedFcn', @(btn,event) onDiscover(btn));
btnConnect = uibutton(fig,'push','Text','Connect','Position',[160 520 120 30], 'ButtonPushedFcn', @(btn,event) onConnect(btn));
btnSubmit = uibutton(fig,'push','Text','Submit Script','Position',[300 520 120 30], 'ButtonPushedFcn', @(btn,event) onSubmit(btn));
txtLog = uitextarea(fig,'Position',[20 20 760 480],'Editable','off');

    function onDiscover(~)
        append('Discovering nodes...');
        hosts = MacHPCClusterTools.Network.discoverSSHHosts(4);
        if isempty(hosts)
            append('No hosts found.');
            return;
        end
        for k=1:numel(hosts)
            append(sprintf('Found: %s -> %s:%d', hosts(k).name, hosts(k).hostname, hosts(k).port));
        end
        assignin('base','MHC_hosts',hosts);
    end

    function onConnect(~)
        try
            hosts = evalin('base','MHC_hosts;');
        catch
            append('No discovered hosts in workspace. Please run Discover.');
            return;
        end
        if isempty(hosts), append('No hosts to connect.'); return; end
        h = hosts(1);
        append(sprintf('Connecting to %s...', h.hostname));
        mgr = MacHPCClusterTools.Manager(h.hostname,'youruser','~/.ssh/id_rsa', h.port);
        try
            mgr.connect();
            assignin('base','MHC_mgr',mgr);
            append('Connected and manager stored in workspace variable MHC_mgr.');
        catch ME
            append(['Connect failed: ' ME.message]);
        end
    end

    function onSubmit(~)
        try
            mgr = evalin('base','MHC_mgr;');
        catch
            append('No manager in workspace. Connect first.');
            return;
        end
        [file, path] = uigetfile('*.m','Select MATLAB script to submit');
        if isequal(file,0), append('No file chosen'); return; end
        fp = fullfile(path,file);
        append(sprintf('Submitting %s...', fp));
        try
            jobId = mgr.submit(fp,'cpus',2,'mem','4G','time','01:00:00');
            append(sprintf('Submitted job %s', jobId));
            assignin('base','MHC_lastjob',jobId);
        catch ME
            append(['Submit failed: ' ME.message]);
        end
    end

    function append(txt)
        txtLog.Value = [txtLog.Value; {sprintf('[%s] %s', datestr(now,'HH:MM:SS'), txt)}];
    end
end
