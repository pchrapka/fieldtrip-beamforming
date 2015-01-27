function cfg = create_headmodel(cfg)
%
%   Input
%   -----
%   cfg.mri_data
%       MRI file for head model
%   cfg.stage
%       struct of short names for each pipeline stage
%   cfg.stage.headmodel
%       head model name
%
%   cfg.folder
%       (optional, default = 'output/stage1_headmodel/shortname')
%       output folder for head model data
%   cfg.ft_volumesegment
%       options for ft_volumesegment, see ft_volumesegment
%   cfg.ft_prepare_headmodel
%       options for ft_prepare_headmodel, see ft_prepare_headmodel
%
%   Output
%   ------
%   cfg.files

if ~isfield(cfg, 'force'), cfg.force = false; end

% Populate the stage information
cfg = ftb.get_stage(cfg);

% Set up the output folder
cfg = ftb.setup_folder(cfg);

%% Set up file names
files = [];
files.mri = cfg.mri_data;

% MRI data specific
[mri_folder, mri_name, ~] = fileparts(cfg.mri_data);
files.mri_mat = fullfile(mri_folder, [mri_name '_mri.mat']);
files.mri_segmented = fullfile(mri_folder, [mri_name '_mri_segmented.mat']);

% Method specific
files.mri_headmodel = fullfile(...
    cfg.folder, ['mri_vol_' cfg.ft_prepare_headmodel.method '.mat']);

%% Segment the MRI

% Read the MRI
cfgin = [];
cfgin.inputfile = files.mri;
cfgin.outputfile = files.mri_mat;
if ~exist(cfgin.outputfile,'file')
    ft_read_mri_mat(cfg);
else
    fprintf('%s: skipping ft_read_mri_mat, already exists\n',mfilename);
end

% Segment the MRI data
cfgin = cfg.ft_volumesegment;
cfgin.inputfile = files.mri_mat;
cfgin.outputfile = files.mri_segmented;
if ~exist(cfgin.outputfile,'file')
    ft_volumesegment(cfg);
else
    fprintf('%s: skipping ft_volumesegment, already exists\n',mfilename);
end

%% Create the head model from the segmented data
cfgin = cfg.ft_prepare_headmodel;
cfgin.inputfile = files.mri_segmented;
cfgin.outputfile = files.mri_headmodel;
if ~exist(cfgin.outputfile, 'file')
    data = ftb.util.loadvar(files.mri_segmented);
    vol = ft_prepare_headmodel(cfgin, data);
    save(cfgin.outputfile, 'vol');
else
    fprintf('%s: skipping ft_prepare_headmodel, already exists\n',mfilename);
end

%% Copy file names to the config
cfg.files = files;

%% Save the config
ftb.save_config(cfg);

end