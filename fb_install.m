%% fb_install.m

% Get the user's Matlab directory
matlab_dir = userpath;
matlab_dir = matlab_dir(1:end-1);

%% Add packages to the Matlab path

%% Add fieldtrip-beamforming
cur_file = mfilename('fullpath');
[pkg_path,~,~] = fileparts(cur_file);
addpath(pkg_path);
addpath(fullfile(pkg_path,'configs'));
% TODO create config mat files? or save to git?

%% Add fieldtrip-beamforming external packages
% Add phasereset
addpath(fullfile(pkg_path,'external','phasereset'));

% Add PSOM
% dep_path = fullfile(matlab_dir,'psom-1.0.2');
% addpath(dep_path);

%% Add fieldtrip

% Add fieldtrip
% dep_path = fullfile(matlab_dir,'fieldtrip-20150127');
dep_path = fullfile(matlab_dir,'fieldtrip-20160128');
if ~exist(dep_path,'dir')
    error(['fb:' mfilename],...
        ['%s does not exist.\n'...
        'Please check the path to your fieldtrip installtion.\n'], dep_path);
end
addpath(dep_path);
ft_defaults

% Add private fieldtrip functions
% Copy the private functions into a new directory and make them not private
oldpath = fullfile(dep_path, 'private');
newpath = fullfile(dep_path, 'private_not');
copyfile(oldpath, newpath);
addpath(newpath);

% TODO wget anatomy data, or is it available in fieldtrip?

%clear all;