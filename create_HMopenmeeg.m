%% create_HMopenmeeg

% Processing options
cfg = [];
cfg.ft_volumesegment.output = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.method = 'projectmesh';
cfg.ft_prepare_mesh.tissue = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.numvertices = [2000, 2000, 1000]; 
% NOTE [3000, 2000, 1000] gives me an error: Mesh is self intersecting
cfg.ft_prepare_headmodel.method = 'openmeeg';
cfg.stage.headmodel = 'HMopenmeeg';
% MRI data
cfg.mri_data = fullfile('anatomy','Subject01','Subject01.mri');

%% Create head model
cfg = ftb.create_headmodel(cfg);