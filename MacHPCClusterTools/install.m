function install
% Install script for MacHPCClusterTools
rootDir = fileparts(mfilename("fullpath"));
addpath(genpath(rootDir));
savepath;
fprintf('[MacHPCClusterTools] Installed and paths saved.\n');
end
