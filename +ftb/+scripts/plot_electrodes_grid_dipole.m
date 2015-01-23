% plot_electrodes_grid_dipole
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

% Load leadfield grid
leadfield_file = fullfile(head_model_dir, 'concentric_sphere_leadfield.mat');
data_in = load(leadfield_file);
leadfield = data_in.leadfield;
clear data_in;

% Plot the cortex surface
util.plot_concentricsphere(vol, elec, [1]);

% Plot inside points
hold on;
leadfield = ft_convert_units(leadfield, 'mm');
plot3(...
    leadfield.pos(leadfield.inside,1),...
    leadfield.pos(leadfield.inside,2),...
    leadfield.pos(leadfield.inside,3), 'k.');

% Plot dipole
pos = [0 -80 14];
mom = [1 1 1];
ft_plot_dipole(pos, mom,...
    'diameter',5,...
    'length', 10,...
    'color', 'blue',...
    'unit', 'mm');

