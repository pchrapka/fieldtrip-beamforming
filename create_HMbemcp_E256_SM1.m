%% create_HMbemcp_E256_SM1.m
% Simulate sources using the HMbemcp and E256 head model

k = 1;
dip(k).pos = [-25 0 50];
dip(k).mom = dip(k).pos/norm(dip(k).pos);
k = k+1;
dip(k).pos = [0 -80 50];
dip(k).mom = dip(k).pos/norm(dip(k).pos);

trials = 100;
fsample = 250; %Hz
triallength = 4*256/fsample;

% Signal configuration
cfgsig = [];
cfgsig.fsample = fsample;
cfgsig.ntrials = trials;
cfgsig.triallength = triallength;
cfgsig.type = 'erp';
cfgsig.amp = 1;
cfgsig.freq = 10;
cfgsig.pos = 120;
cfgsig.jitter = 5;

% Interference configuration
cfgint = [];
cfgint.fsample = fsample;
cfgint.ntrials = trials;
cfgint.triallength = triallength;
cfgint.type = 'erp';
cfgint.amp = 1;
cfgint.freq = 10;
cfgint.pos = 120;
cfgint.jitter = 5;
cfgint.pos = 124;

cfg = [];
cfg.force = false;
cfg.stage.headmodel = 'HMbemcp';
cfg.stage.electrodes = 'E256';
cfg.stage.dipolesim = 'SM1snr0';

cfg.snr = 0;

cfg.signal.ft_dipolesignal = cfgsig;
cfg.signal.ft_dipolesimulation.dip.pos = [dip(1).pos]; % in cm?
cfg.signal.ft_dipolesimulation.dip.mom = [dip(1).mom]';
% cfg.signal.ft_dipolesimulation.dip.signal = signal;
% cfg.ft_dipolesimulation.dip.frequency = 10; % Hz
% cfg.ft_dipolesimulation.dip.phase = 0;
% cfg.ft_dipolesimulation.dip.amplitude = 1;
% cfg.signal.ft_dipolesimulation.ntrials = 100;
% cfg.signal.ft_dipolesimulation.fsample = fsample; % Hz
% cfg.ft_dipolesimulation.triallength = 4*256/fsample;% in seconds
% cfg.ft_dipolesimulation.relnoise = 0; % TODO no idea what kind of units, %? db?

cfg.interference.ft_dipolesignal = cfgint;
cfg.interference.ft_dipolesimulation.dip.pos = [dip(2).pos]; % in cm?
cfg.interference.ft_dipolesimulation.dip.mom = [dip(2).mom]';
% cfg.interference.ft_dipolesimulation.dip.signal = interference;

cfg.noise.fsample = fsample;
cfg.noise.ntrials = trials;
cfg.noise.triallength = triallength;
cfg.noise.power = 1;
% Create noise from output of ft_dipolesimulation, copy struct and fill it
% in with noise

cfg = ftb.create_dipolesim(cfg);

% create noise
% create signal
% create interference
% adjust snr interference relative to noise
% adjust snr signal relative to noise
% what about multiple sources that make up the signal?