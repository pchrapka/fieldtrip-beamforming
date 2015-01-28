%% create_HMbecmp_E256

%% Set up electrodes
cfg = [];
cfg.elec_orig = 'GSN-HydroCel-256.sfp';
cfg.stage.headmodel = 'HMbemcp';
cfg.stage.electrodes = 'E256';
% TODO Copy electrode file to current project?
cfg = ftb.create_electrodes(cfg);