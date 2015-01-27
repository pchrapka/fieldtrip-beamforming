%% create_HMbemcp_E256_Llinx10mm.m
% Compute the leadfield using the HMbemcp256 head model. The lead field is
% on a linear grid in the x direction with 10mm spacing

cfg = [];
cfg.stage.headmodel = 'HMbemcp';
cfg.stage.electrodes = 'E256';
cfg.stage.leadfield = 'Llinx10mm';
cfg.ft_prepare_leadfield.grid.xgrid = -100:1:100;
cfg.ft_prepare_leadfield.grid.ygrid = 0;
cfg.ft_prepare_leadfield.grid.zgrid = 10;
% cfg.ft_prepare_leadfield.grid.resolution = 10;
cfg.ft_prepare_leadfield.grid.unit = 'mm';

cfg = ftb.create_leadfield(cfg);