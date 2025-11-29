classdef SCP
    methods(Static)
        function put(client, localPath, remotePath)
            keyPart = '';
            if ~isempty(client.Key), keyPart = sprintf('-i %s ', client.Key); end
            cmd = sprintf('scp -P %d %s %s %s@%s:%s', client.Port, keyPart, localPath, client.User, client.Host, remotePath);
            [s,o] = system(cmd);
            if s~=0, error('scp put failed: %s', o); end
        end

        function get(client, remotePath, localPath)
            keyPart = '';
            if ~isempty(client.Key), keyPart = sprintf('-i %s ', client.Key); end
            cmd = sprintf('scp -P %d %s %s@%s:%s %s', client.Port, keyPart, client.User, client.Host, remotePath, localPath);
            [s,o] = system(cmd);
            if s~=0, error('scp get failed: %s', o); end
        end
    end
end
