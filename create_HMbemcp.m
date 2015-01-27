%% Set up vars

% Processing options
cfg = [];
cfg.ft_volumesegment.output = {'brain','skull','scalp'};
cfg.ft_prepare_headmodel.method = 'bemcp';
cfg.stage.headmodel = 'HMbemcp';
% MRI data
cfg.mri_data = fullfile('anatomy','Subject01','Subject01.mri');

%% Create head model
cfg = ftb.create_headmodel(cfg);
