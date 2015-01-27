%% Stage 1
% Create a bemcp head model
create_HMbemcp

%% Stage 2
% Create aligned electrodes
create_HMbemcp_E256

%% Stage 3
% Create leadfield
% create_HMbemcp_E256_L10mm
% create_HMbemcp_E256_Llinx10mm
create_HMbemcp_E256_Lliny10mm

cfgin = [];
cfgin.stage.headmodel = 'HMbemcp';
cfgin.stage.electrodes = 'E256';
cfgin.stage.leadfield = 'Lliny10mm';
cfgin.elements = {'electrodes', 'volume', 'leadfield'};
ftb.vis_headmodel_elements(cfgin);

%% Stage 4
% Create simulated data
% create_HMbemcp_E256_L10mm_SM1
% TODO Dependent on leadfield?

%% Stage 5
% Source localization
% create_HMbemcp_E256_L10mm_SM1_BF1
% create_HMbemcp_E256_L10mm_SM1_BF2