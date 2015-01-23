%% fb_install.m

%% Add dependencies to the Matlab path

% Get the user's Matlab directory
matlab_dir = userpath;
matlab_dir = matlab_dir(1:end-1);

% Add PSOM
dep_path = [matlab_dir filesep 'psom-1.0.2'];
addpath(dep_path);

% Add fieldtrip package to Matlab path
dep_path = [matlab_dir filesep 'fieldtrip-20140611'];
addpath(dep_path);
ft_defaults

% Add fieldtrip-beamforming
cur_file = mfilename('fullpath');
[dep_path,~,~] = fileparts(cur_file);
addpath(dep_path);
    
%% Create directories in current working directory
directories = {...
    fullfile('output','stage1_headmodel'),...
    fullfile('output','stage2_leadfield'),...
    fullfile('output','stage3_simulated_eeg'),...
    fullfile('output','stage4_source_loc'),...
    };
for i=1:length(directories)
    output_dir = directories{i};
    if ~exist(output_dir, 'dir');
        mkdir(output_dir);
    end
end
