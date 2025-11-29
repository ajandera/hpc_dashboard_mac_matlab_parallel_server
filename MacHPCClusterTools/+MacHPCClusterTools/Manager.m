classdef Manager < handle
    % Manager - main entry point for MacHPCClusterTools
    properties
        SSH % SSH client object (MacHPCClusterTools.SSH.Client)
        SharedStorage = '/Users/Shared/HPC'
        Host char = ''
        User char = ''
        Key char = ''
        Port = 22
    end

    methods
        function obj = Manager(host, user, key, port)
            if nargin >= 1, obj.Host = host; end
            if nargin >= 2, obj.User = user; end
            if nargin >= 3, obj.Key = key; end
            if nargin >= 4, obj.Port = port; end
        end

        function connect(obj)
            % Create SSH client and connect
            obj.SSH = MacHPCClusterTools.SSH.Client(obj.Host, obj.User, obj.Key, obj.Port);
            obj.SSH.connect();
            fprintf('[Manager] Connected to %s@%s:%d\n', obj.User, obj.Host, obj.Port);
        end

        function disconnect(obj)
            if ~isempty(obj.SSH), obj.SSH.close(); obj.SSH = []; end
            fprintf('[Manager] Disconnected.\n');
        end

        function jobId = submit(obj, scriptPath, varargin)
            jobId = MacHPCClusterTools.Slurm.Submit(obj.SSH, obj.SharedStorage, scriptPath, varargin{:});
        end

        function s = status(obj, jobId)
            s = MacHPCClusterTools.Slurm.Status(obj.SSH, jobId);
        end

        function fetch(obj, jobId, dest)
            if nargin < 3, dest = pwd; end
            MacHPCClusterTools.Slurm.Logs(obj.SSH, obj.SharedStorage, jobId, dest);
        end

        function cancel(obj, jobId)
            MacHPCClusterTools.Slurm.Cancel(obj.SSH, jobId);
        end

        function hosts = discoverNodes(obj, timeout)
            if nargin < 2, timeout = 4; end
            hosts = MacHPCClusterTools.Network.discoverSSHHosts(timeout);
        end
    end
end
