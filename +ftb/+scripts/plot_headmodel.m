% plot_headmodel
% Script to plot the concentric sphere model along with the electrodes

config_dir = 'config';
head_model_dir = 'head-model';

% Load electrodes
elec_file = fullfile(config_dir, 'standard_1020.elc');
elec = ft_read_sens(elec_file);

% Load volume conductor
vol_file = fullfile(head_model_dir, 'concentric_sphere_vol.mat');
data_in = load(vol_file);
vol = data_in.vol;
clear data_in;

util.plot_concentricsphere(vol, elec);