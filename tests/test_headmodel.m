%% test_pipeline_object

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

%% Stage 1
% Create a bemcp head model
% headmodel = 'HMS01bemcp';
% Create an openmeeg head model
% headmodel = 'HMopenmeeg';
% Most accurate according to: https://hal.inria.fr/hal-00776674/document

config_dir = fullfile('..','configs');

% MRI
params_mri = fullfile(config_dir, 'MRIS01.mat');
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = fullfile(config_dir, 'HMbemcp.mat');
hm = ftb.Headmodel(params_hm,'bemcp');

params_e = fullfile(config_dir, 'E128.mat');
e = ftb.Electrodes(params_e,'128');
e.force = true;

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