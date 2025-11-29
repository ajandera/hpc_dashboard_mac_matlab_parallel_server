function uninstall
% Uninstall script for MacHPCClusterTools
rootDir = fileparts(mfilename("fullpath"));
rmpath(genpath(rootDir));
savepath;
fprintf('[MacHPCClusterTools] Uninstalled and paths removed.\n');
end
