%% fb_install.m

%% Add dependencies to the Matlab path

% Get the user's Matlab directory
matlab_dir = userpath;
matlab_dir = matlab_dir(1:end-1);

% Add PSOM
dep_path = fullfile(matlab_dir,'psom-1.0.2');
addpath(dep_path);

% Add fieldtrip package to Matlab path
% dep_path = fullfile(matlab_dir,'fieldtrip-20140611');
dep_path = fullfile(matlab_dir,'fieldtrip-20150127');
addpath(dep_path);
ft_defaults

% Add private fieldtrip functions
% Copy the private functions into a new directory and make them private
oldpath = fullfile(dep_path, 'private');
newpath = fullfile(dep_path, 'private_not');
copyfile(oldpath, newpath);
addpath(newpath);

% Add phasereset package to Matlab path
dep_path = fullfile(matlab_dir,'phasereset');
addpath(dep_path);

% Add fieldtrip-beamforming
cur_file = mfilename('fullpath');
[dep_path,~,~] = fileparts(cur_file);
addpath(dep_path);

% TODO wget anatomy data, or is it available in fieldtrip?