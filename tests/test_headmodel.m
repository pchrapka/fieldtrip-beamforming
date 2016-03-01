%% test_pipeline_object

close all;

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

%% Create analysis step objects

config_dir = fullfile('..','configs');

% MRI
params_mri = fullfile(config_dir, 'MRIS01.mat');
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = fullfile(config_dir, 'HMbemcp.mat');
hm = ftb.Headmodel(params_hm,'bemcp');

params_e = fullfile(config_dir, 'E128.mat');
e = ftb.Electrodes(params_e,'128');
e.force = false;

params_lf = fullfile(config_dir, 'L5mm.mat');
lf = ftb.Leadfield(params_lf,'5mm');

%% Set up beamformer analysis
out_folder = 'output';
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

analysis = ftb.AnalysisBeamformer(out_folder);

%%
analysis.add(m);
analysis.init();
analysis.process();

%%
analysis.add(hm);
analysis.init();
analysis.process();
figure;
hm.plot({'brain','skull','scalp','fiducials'})

%%
analysis.add(e);
analysis.init();
analysis.process();

figure;
e.plot({'brain','skull','scalp','fiducials','electrodes-aligned','electrodes-labels'})

%%
analysis.add(lf);
analysis.init();
analysis.process();

figure;
lf.plot({'brain','skull','scalp','fiducials','leadfield'});