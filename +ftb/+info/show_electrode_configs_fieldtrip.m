%% show_electrode_configs_fieldtrip
%
% Plots the default fieldtrip electrodes

fieldtrip_dir = 'C:\Users\Phil\Documents\MATLAB\fieldtrip-20131016\';
if ~exist(fieldtrip_dir,'dir')
   error('fbt:fieldtrip_show_electrode_configs',...
       'update the fieldtrip directory variable');
end

% Get the list of electrode configurations
dirlist  = dir(fullfile(fieldtrip_dir,'template','electrode','*')); 
filename = {dirlist(~[dirlist.isdir]).name}';

% Plot each sensor array
for i=1:length(filename)
    if ~isequal(filename{i},'README')
        elec = ft_read_sens(filename{i});
        figure
        ft_plot_sens(elec);
        title(filename{i});
        grid on
        rotate3d
    end
end