% plot_dipole_simulation
% Script to plot the concentric sphere model along with the electrodes

config_dir = 'config';
head_model_dir = 'head-model';

% Load electrodes
elec_file = fullfile(config_dir, 'standard_1020.elc');
elec = ft_read_sens(elec_file);

% Load volume conductor
data_file = fullfile(head_model_dir, 'dipole_sim.mat');
data_in = load(data_file);
raw = data_in.data;
clear data_in;

cfg = [];
% cfg.elec = elec;
% cfg.viewmode = 'component';
% ft_databrowser(cfg, raw);
avg = ft_timelockanalysis([], raw);
ft_databrowser(cfg, avg);