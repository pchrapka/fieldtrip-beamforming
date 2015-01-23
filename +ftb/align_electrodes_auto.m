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
cfgin.elec_file = cfg.files.elec;
cfgin.mri_file = cfg.files.mri_mat;
cfgin.outputfile = cfg.files.elec_aligned;
ftb.align_electrodes(cfgin);

%% Visualization - check alignment
figure;
cfgin = [];
cfgin.headmodel_file = cfg.files.mri_headmodel;
cfgin.elec_file = cfg.files.elec_aligned;
vis_check_alignment(cfgin);

%% Interactive alignment
prompt = 'How''s it looking? Need manual alignment? (Y/n)';
response = input(prompt, 's');
if isequal(response, 'Y')
    % Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
    cfgin = [];
    cfgin.type = 'interactive';
    cfgin.headmodel_file = cfg.files.mri_headmodel;
    cfgin.elec_file = cfg.files.elec_aligned;
    cfgin.outputfile = cfg.files.elec_aligned;
    ftb.align_electrodes(cfgin);
end

%% Visualization - check alignment
figure;
cfgin = [];
cfgin.headmodel_file = cfg.files.mri_headmodel;
cfgin.elec_file = cfg.files.elec_aligned;
vis_check_alignment(cfgin);

end