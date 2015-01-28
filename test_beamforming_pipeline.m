%% beamforming_pipeline.m

clear all;
clc;
close all;

pipeline_run = true;
pipeline_visu = false;

% pipeline_run = false;
% pipeline_visu = true;

config_dir = 'config';
head_model_dir = 'head-model';

elec_file = fullfile(config_dir, 'standard_1020.elc');
vol_file = fullfile(head_model_dir, 'concentric_sphere_vol.mat');

%% Configure pipeline stages
k = 1;

% Add concentric sphere volume conductor stage
job(k).name = 'concentric_sphere_vol';
job(k).brick = 'ftb.bricks.prepare_concentricsphere_vol';
job(k).in.elec = elec_file;
job(k).out.vol = vol_file;
opt = [];
opt.conductivity = [1 1/80 1]; % skin skull brain
opt.r = [1 0.92 0.88];
job(k).opt = opt;
k = k + 1;

% Add leadfield stage
job(k).name = 'concentric_sphere_leadfield';
job(k).brick = 'ftb.bricks.prepare_concentricsphere_leadfield';
job(k).in.elec = elec_file;
job(k).in.vol = vol_file;
job(k).out.leadfield = fullfile(head_model_dir,...
    'concentric_sphere_leadfield.mat');
opt = [];
opt.prepare_leadfield.grid.resolution = 1;
opt.prepare_leadfield.grid.unit = 'cm';
job(k).opt = opt;
k = k + 1;

% Add dipole simulation
job(k).name = 'dipole_simulation';
job(k).brick = 'ftb.bricks.create_dipole_simulation';
job(k).in.elec = elec_file;
job(k).in.vol = vol_file;
job(k).out.data = fullfile(head_model_dir,...
    'dipole_sim.mat');
opt = [];
opt.dipole_simulation.dip.pos = [0 -80 14]/10; % in cm?
opt.dipole_simulation.dip.mom = [1 1 1]';
opt.dipole_simulation.dip.frequency = 10; % Hz
opt.dipole_simulation.dip.phase = 0;
opt.dipole_simulation.dip.amplitude = 1;
opt.dipole_simulation.ntrials = 100;
opt.dipole_simulation.triallength = 1;% in seconds
opt.dipole_simulation.fsample = 220; % Hz
opt.dipole_simulation.relnoise = 0.4; % TODO no idea what kind of units, %? db?
job(k).opt = opt;
k = k + 1;

% Add timelock analysis
job(k).name = 'timelock_analysis';
job(k).brick = 'ftb.bricks.analysis_timelock';
job(k).in.data = job(k-1).out.data;
job(k).out.timelock = fullfile(head_model_dir,...
    'dipole_sim_timelock.mat');
opt = [];
opt.timelock_analysis.covariancewindow = 'all';
opt.timelock_analysis.covariance = 'yes';
opt.timelock_analysis.removemean = 'no';
job(k).opt = opt;
k = k + 1;

% Add sourceanalysis
job(k).name = 'source_analysis';
job(k).brick = 'ftb.bricks.analysis_source';
job(k).in.timelock = job(k-1).out.timelock;
job(k).in.elec = elec_file;
job(k).in.vol = vol_file;
job(k).in.leadfield = job(k-3).out.leadfield;
job(k).out.sourceanalysis = fullfile(head_model_dir,...
    'dipole_sim_sourceanalysis.mat');
opt = [];
opt.source_analysis.method = 'lcmv';
opt.source_analysis.lcmv.keepmom = 'yes';
job(k).opt = opt;
k = k + 1;

%% Add jobs to pipeline

pipeline = struct();
pipeline = ftb.util.add_jobs(pipeline, job);

%% Visualize the pipeline
% Double check that dependencies are correct
if pipeline_visu
    psom_visu_dependencies(pipeline);
end

%% Run the pipeline
opt_pipe.path_logs = [pwd filesep 'output' filesep 'logs'];
opt_pipe.mode = 'session';
% opt_pipe.restart = {'dipole_simulation'};
% % NOTE background mode doesn't seem to work
% % opt_pipe.max_queued = 2;
if pipeline_run
    psom_run_pipeline(pipeline, opt_pipe);
end
% 
% %% View logs
% % psom_pipeline_visu('C:\Users\Phil\My
% % Projects\rtms-wavelets-2\output\logs\','log',a1_1_gmfa)