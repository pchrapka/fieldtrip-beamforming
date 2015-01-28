% plot_source_analysis

config_dir = 'config';
head_model_dir = 'head-model';

% % Load electrodes
% elec_file = fullfile(config_dir, 'standard_1020.elc');
% elec = ft_read_sens(elec_file);

% % Load volume conductor
% data_file = fullfile(head_model_dir, 'dipole_sim.mat');
% data_in = load(data_file);
% raw = data_in.data;
% clear data_in;

% Load source analysis
source_file = fullfile(head_model_dir, 'dipole_sim_sourceanalysis.mat');
data_in = load(source_file);
sourceanalysis = data_in.sourceanalysis;
clear data_in;


cfg              = [];
cfg.funparameter = 'avg.pow';
cfg.method       = 'ortho'; % 'slice', 'surface'
% cfg.location     = 'max';
source1 = rmfield(sourceanalysis,'time');
ft_sourceplot(cfg, source1);

% cfg = [];
% % cfg.elec = elec;
% % cfg.viewmode = 'component';
% % ft_databrowser(cfg, raw);
% avg = ft_timelockanalysis([], raw);
% ft_databrowser(cfg, avg);

% Surface plot
cfg              = [];
cfg.funparameter = 'avg.pow';
cfg.method       = 'surface'; % 'slice', 'surface'
% cfg.location     = 'max';
source1 = rmfield(source,'time');
ft_sourceplot(cfg, source1);
ft_sourceplot(cfg, source_int_norm);

% Ortho plot
cfg              = [];
cfg.funparameter = 'avg.pow';
cfg.method       = 'ortho'; % 'slice', 'surface'
cfg.location     = 'max';
source1 = rmfield(source,'time');
ft_sourceplot(cfg, source1);
ft_sourceplot(cfg, source_int);

% Slice plot
cfg              = [];
cfg.funparameter = 'avg.pow';
cfg.maskparamter = cfg.funparameter;
cfg.method       = 'slice'; % 'slice', 'surface'
% cfg.location     = 'max';
source1 = rmfield(source,'time');
ft_sourceplot(cfg, source1);
ft_sourceplot(cfg, source_int);