%% create_HMbemcp256_L10mm.m
% Compute the leadfield using the HMbemcp256 head model. The lead field is
% on a uniform grid with 10mm spacing

cfg = [];
cfg.name.headmodel = 'HMbemcp256';
cfg.name.leadfield = 'L10mm';
cfg.ft_prepare_leadfield.grid.resolution = 10;
cfg.ft_prepare_leadfield.grid.unit = 'mm';

cfg = ftb.create_leadfield(cfg);