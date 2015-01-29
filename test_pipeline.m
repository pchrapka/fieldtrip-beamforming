debug = false;
stage = [];

%% Stage 1
% Create a bemcp head model
% headmodel = 'HMbemcp';
% Create an openmeeg head model
headmodel = 'HMopenmeeg';
% Most accurate according to: https://hal.inria.fr/hal-00776674/document

stage.headmodel = headmodel;
% Get the config
cfg = ftb.prepare_headmodel(stage);
% Create the model
cfg = ftb.create_headmodel(cfg);

%% Stage 2
% Create aligned electrodes
electrodes = 'E256';
stage.electrodes = electrodes;
% Get the config
cfg = ftb.prepare_electrodes(stage);
% Create the model
cfg = ftb.create_electrodes(cfg);

%% Stage 3
% Create leadfield
leadfield = 'L10mm';
% leadfield = 'Llinx10mm';
% leadfield = 'Lliny10mm';

stage.leadfield = leadfield;
% Get the config
cfg = ftb.prepare_leadfield(stage);
% Create the model
cfg = ftb.create_leadfield(cfg);

% check_leadfield(cfg);

%% Stage 4
% Create simulated data
% dipolesim = 'SM1snr0';
dipolesim = 'SS1snr0';

stage.dipolesim = dipolesim;
% Get the config
cfg = ftb.prepare_dipolesim(stage);
% Create the model
cfg = ftb.create_dipolesim(cfg);

% check_dipolesim(cfg);

%% Stage 5
% Source localization
beamformer = 'BF1';

stage.beamformer = beamformer;
% Get the config
cfg = ftb.prepare_sourceanalysis(stage);
% Create the model
cfg = ftb.create_sourceanalysis(cfg);

check_sourceanalysis(cfg);
