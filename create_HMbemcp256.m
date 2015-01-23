%% Set up vars

% Processing options
cfg = [];
cfg.ft_volumesegment.output = {'brain','skull','scalp'};
cfg.ft_prepare_headmodel.method = 'bemcp';
cfg.name.headmodel = 'HMbemcp256';
% MRI data
cfg.mri_data = fullfile('anatomy','Subject01','Subject01.mri');

%% Create head model
cfg = ftb.create_headmodel(cfg);

%% Set up electrodes
cfg.files.elec_orig = 'GSN-HydroCel-256.sfp';
% TODO Copy electrode file to current project?
cfg = ftb.align_electrodes_auto(cfg);