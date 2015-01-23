%% Set up vars
cfg = [];
cfg.ft_volumesegment.output = {'brain','skull','scalp'};
cfg.ft_prepare_headmodel.method = 'bemcp';

headmodel_dir = ['elec256_' method];
cfg.mri_data = fullfile('anatomy','Subject01','Subject01.mri');
cfg.folder = fullfile('output', 'stage1_headmodel', headmodel_dir);

%% Create head model
cfg = ftb.create_headmodel(cfg);

%% Set up electrodes
cfg.elec_file = 'GSN-HydroCel-256.sfp';
% TODO Copy electrode file to current project?
cfg = ftb.align_electrodes_auto(cfg);