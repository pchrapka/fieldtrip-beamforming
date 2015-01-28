debug = false;
%% Stage 1
% % Create a bemcp head model
create_HMbemcp % getting a matrix conditioning error

% Create an open
% create_HMopenmeeg
% Most accurate according to: https://hal.inria.fr/hal-00776674/document

%% Stage 2
% Create aligned electrodes
create_HMbemcp_E256

%% Stage 3
% Create leadfield
create_HMbemcp_E256_L10mm
% create_HMbemcp_E256_Llinx10mm
% create_HMbemcp_E256_Lliny10mm

%% Stage 4
% Create simulated data
create_HMbemcp_E256_SM1snr0

%% Stage 5
% Source localization
create_HMbemcp_E256_L10mm_SM1snr0_BF1
% create_HMbemcp_E256_L10mm_SM1_BF2