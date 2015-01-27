%% create_HMbemcp_E256_Lliny10mm.m
% Compute the leadfield using the HMbemcp256 head model. The lead field is
% on a linear grid in the y direction with 10mm spacing

cfg = [];
cfg.force = true;
cfg.stage.headmodel = 'HMbemcp';
cfg.stage.electrodes = 'E256';
cfg.stage.leadfield = 'Lliny10mm';
cfg.ft_prepare_leadfield.grid.xgrid = -25;
cfg.ft_prepare_leadfield.grid.ygrid = -100:10:100;
cfg.ft_prepare_leadfield.grid.zgrid = 50;
% cfg.ft_prepare_leadfield.grid.resolution = 10;
cfg.ft_prepare_leadfield.grid.unit = 'mm';

cfg = ftb.create_leadfield(cfg);