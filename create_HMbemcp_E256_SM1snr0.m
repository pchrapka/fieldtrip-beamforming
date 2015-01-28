%% create_HMbemcp_E256_SM1snr0.m
% Simulate sources using the HMbemcp and E256 head model

k = 1;
dip(k).pos = [-25 0 50];
dip(k).mom = dip(k).pos/norm(dip(k).pos);
k = k+1;
dip(k).pos = [0 -50 50];
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

snr = 0; % use the same snr for both signal and interference

cfg.signal.snr = snr;
cfg.signal.ft_dipolesignal = cfgsig;
cfg.signal.ft_dipolesimulation.dip.pos = [dip(1).pos]; % in cm?
cfg.signal.ft_dipolesimulation.dip.mom = [dip(1).mom]';
% cfg.signal.ft_dipolesimulation.dip.signal = signal;

cfg.interference.snr = snr;
cfg.interference.ft_dipolesignal = cfgint;
cfg.interference.ft_dipolesimulation.dip.pos = [dip(2).pos]; % in cm?
cfg.interference.ft_dipolesimulation.dip.mom = [dip(2).mom]';
% cfg.interference.ft_dipolesimulation.dip.signal = interference;

cfg.ft_dipolesimulationnoise.fsample = fsample;
cfg.ft_dipolesimulationnoise.ntrials = trials;
cfg.ft_dipolesimulationnoise.triallength = triallength;
cfg.ft_dipolesimulationnoise.power = 1;

cfg = ftb.create_dipolesim(cfg);

debug = false;
if debug
    cfgtmp = ftb.get_stage(cfg);
    cfghm = ftb.load_config(cfgtmp.stage.full);
    data = ftb.util.loadvar(cfghm.files.adjust_snr.all);
%     data = ftb.util.loadvar(cfghm.files.adjust_snr.signal);
%     data = ftb.util.loadvar(cfghm.files.adjust_snr.interference);
    ft_databrowser([], data);
end

if debug
    cfgin = [];
    cfgin.stage = cfg.stage;
    cfgin.elements = {'volume', 'dipole'};
    ftb.vis_headmodel_elements(cfgin);
end