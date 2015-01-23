function cfg = align_electrodes_auto(cfg)
% align_electrodes_auto automated alignment of electrodes. It aligns the
% fiducials first, then asks if more manual alignment is necessary.
%
%   Input
%   -----
%   cfg.elec_file
%       electrode location file
%   cfg.folder
%       output folder for head model data
%   cfg.files
%       output files from create_headmodel
%
%   Output
%   ------
%   cfg.files


cfg.files.elec = fullfile(cfg.folder, 'elec.mat');
cfg.files.elec_aligned = fullfile(cfg.folder, 'elec_aligned.mat');

%% Load electrode data
elec = ft_read_sens(cfg.elec_file);
% Ensure electrode coordinates are in mm
elec = ft_convert_units(elec, 'mm'); % should be the same unit as MRI
% Save
save(cfg.files.elec, 'elec');

%% Automatic alignment
% Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
cfgin = [];
cfgin.type = 'fiducial';
cfgin.files = cfg.files;
cfgin.outputfile = cfg.files.elec_aligned;
ftb.align_electrodes(cfgin);

%% Visualization - check alignment
h = figure;
cfgin = [];
cfgin.files = cfg.files;
ftb.vis_check_alignment(cfgin);

%% Interactive alignment
prompt = 'How''s it looking? Need manual alignment? (Y/n)';
response = input(prompt, 's');
if isequal(response, 'Y')
    close(h);
    % Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
    cfgin = [];
    cfgin.type = 'interactive';
    cfgin.files = cfg.files;
    cfgin.outputfile = cfg.files.elec_aligned;
    ftb.align_electrodes(cfgin);
end

%% Visualization - check alignment
h = figure;
cfgin = [];
cfgin.files = cfg.files;
ftb.vis_check_alignment(cfgin);

end