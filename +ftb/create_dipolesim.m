function cfg = create_dipolesim(cfg)
%
%   Input
%   -----
%   cfg.stage
%       struct of short names for each pipeline stage
%   cfg.stage.headmodel
%       head model name
%   cfg.stage.electrodes
%       electrode configuration name
%   cfg.stage.dipolesim
%       dipole simulation name
%
%   cfg.folder
%       (optional, default = 'output/stage[number]_dipolesim/name')
%       output folder for simulation data
%   cfg.ft_dipolesimulation
%       options for ft_dipolesimulation, see ft_dipolesimulation
%
%   cfg.force
%       force recomputation, default = false
%
%   Output
%   ------
%   cfg.files

if ~isfield(cfg, 'force'), cfg.force = false; end

% Populate the stage information
cfg = ftb.get_stage(cfg);

% Set up the output folder
cfg = ftb.setup_folder(cfg);

%% Load head model config
cfghm = ftb.load_config(cfg.stage.headmodel);
cfgelec = ftb.load_config(cfg.stage.electrodes);

%% Set up file names
cfg.files.dipolesim_signal = fullfile(cfg.folder, 'dipolesim_signal.mat');
cfg.files.dipolesim_interference = fullfile(cfg.folder, 'dipolesim_interference.mat');
cfg.files.dipolesim_noise = fullfile(cfg.folder, 'dipolesim_noise.mat');

cfg.files.dipole_signal = fullfile(cfg.folder, 'dipole_signal.mat');
cfg.files.dipole_interference = fullfile(cfg.folder, 'dipole_interference.mat');

%% Create the dipole signals
if isfield(cfg.signal, 'ft_dipolesignal')
    if ~exist(cfg.files.dipole_signal) || cfg.force
        signal = ft_dipolesignal(cfg.signal.ft_dipolesignal);
        save(cfg.files.dipole_signal, 'signal');
    else
        fprintf('%s: skipping ft_dipolesignal for signal, already exists\n',mfilename);
    end
end

if isfield(cfg.interference, 'ft_dipolesignal')
    if ~exist(cfg.files.dipole_interference) || cfg.force
        interference = ft_dipolesignal(cfg.interference.ft_dipolesignal);
        save(cfg.files.dipole_interference, 'interference');
    else
        fprintf('%s: skipping ft_dipolesignal for interference, already exists\n',mfilename);
    end
end

%% Simulate the dipoles

if ~exist(cfg.files.dipolesim_signal,'file') || cfg.force
    cfgin = cfg.signal.ft_dipolesimulation;
    cfgin.elecfile = cfgelec.files.elec_aligned;
    cfgin.hdmfile = cfghm.files.mri_headmodel;
    % Set up the dipole signal if it exists
    if isfield(cfg.signal, 'ft_dipolesignal')
        if exist('signal', 'var')
            cfgin.dip.signal = signal;
        else
            signal = ftb.util.loadvar(cfg.file.dipole_signal);
            cfgin.dip.signal = signal;
        end
    end
    dipolesim_signal = ft_dipolesimulation(cfgin);
    save(cfg.files.dipolesim_signal, 'dipolesim_signal');
else
    fprintf('%s: skipping ft_dipolesimulation for signal, already exists\n',mfilename);
end

if ~exist(cfg.files.dipolesim_interference,'file') || cfg.force
    cfgin = cfg.interference.ft_dipolesimulation;
    cfgin.elecfile = cfgelec.files.elec_aligned;
    cfgin.hdmfile = cfghm.files.mri_headmodel;
    % Set up the dipole signal if it exists
    if isfield(cfg.interference, 'ft_dipolesignal')
        if exist('interference', 'var')
            cfgin.dip.signal = interference;
        else
            interference = ftb.util.loadvar(cfg.file.dipole_interference);
            cfgin.dip.signal = interference;
        end
    end
    dipolesim_interference = ft_dipolesimulation(cfgin);
    save(cfg.files.dipolesim_interference, 'dipolesim_interference');
else
    fprintf('%s: skipping ft_dipolesimulation for interference, already exists\n',mfilename);
end

%% Simulate the noise
if ~exist(cfg.files.dipolesim_noise,'file') || cfg.force
    cfgin = cfg.noise;
    cfgin.elecfile = cfgelec.files.elec_aligned;
    cfgin.hdmfile = cfghm.files.mri_headmodel;
    dipolesim_noise = ft_dipolesimulationnoise(cfgin);
    save(cfg.files.dipolesim_noise, 'dipolesim_noise');
else
    fprintf('%s: skipping ft_dipolesimulation for signal, already exists\n',mfilename);
end

%% Average the data

%% Adjust signal and interference snr relative to the noise

%% Save the config file
ftb.save_config(cfg);

end