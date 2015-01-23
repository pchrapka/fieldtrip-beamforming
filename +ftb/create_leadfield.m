function cfg = create_leadfield(cfg)
%
%   Input
%   -----
%   cfg.name.leadfield
%       lead field name
%   cfg.name.headmodel
%       head model name
%   cfg.folder
%       (optional, default = 'output/stage2_leadfield/name')
%       output folder for head model data
%   cfg.ft_prepare_leadfield
%       options for ft_prepare_leadfield, see ft_prepare_leadfield
%
%   Output
%   ------
%   cfg.files

cfg.name.full = [cfg.name.headmodel '_' cfg.name.leadfield];

% Set up default output folder
if ~isfield(cfg, 'folder') || isempty(cfg.folder)
    cfg.folder = fullfile('output', 'stage2_leadfield', cfg.name.full);
end

% Create the output folder
if ~exist(cfg.folder, 'dir')
    mkdir(cfg.folder);
end

%% Set up file names
cfg.files.leadfield = fullfile(cfg.folder, 'leadfield.mat');

%% Load head model config
cfghm = ftb.load_config(cfg.name.headmodel);

%% Compute leadfield

cfgin = cfg.ft_prepare_leadfield;
cfgin.elecfile = cfghm.files.elec_aligned;
cfgin.hdmfile = cfghm.files.mri_headmodel;
if ~exist(cfg.files.leadfield,'file')
    leadfield = ft_prepare_leadfield(cfgin);
    save(cfg.files.leadfield, 'leadfield');
else
    fprintf('%s: skipping ft_prepare_leadfield, already exists\n',mfilename);
end

%% Save the config file
ftb.save_config(cfg);

end