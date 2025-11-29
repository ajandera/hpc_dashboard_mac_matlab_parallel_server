classdef Client < handle
    properties
        Host
        User
        Key
        Port = 22
    end
    methods
        function obj = Client(host, user, key, port)
            if nargin>=1, obj.Host = host; end
            if nargin>=2, obj.User = user; end
            if nargin>=3, obj.Key = key; end
            if nargin>=4, obj.Port = port; end
        end

        function connect(obj)
            % Test basic ssh connectivity using system ssh
            if isempty(obj.Host) || isempty(obj.User)
                error('Host and User must be set');
            end
            keyPart = '';
            if ~isempty(obj.Key), keyPart = sprintf('-i %s ', obj.Key); end
            cmd = sprintf('ssh -p %d %s %s@%s "echo CONNECT_OK"', obj.Port, keyPart, obj.User, obj.Host);
            [s,out] = system(cmd);
            if s~=0
                error('SSH connect failed: %s', out);
            end
        end

        function close(~)
            % no persistent connection
        end

        function [status,out] = exec(obj, cmd)
            keyPart = '';
            if ~isempty(obj.Key), keyPart = sprintf('-i %s ', obj.Key); end
            full = sprintf('ssh -p %d %s %s@%s "%s"', obj.Port, keyPart, obj.User, obj.Host, cmd);
            [status,out] = system(full);
        end
    end
end
