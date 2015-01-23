function plot_concentricsphere(vol, elec, varargin)
%PLOT_CONCENTRICSPHERE plots the concentric sphere head model
%   PLOT_CONCENTRICSPHERE(VOL, ELEC, [SURFACE_INDEX])
%
%   vol     
%       volume conduction model, see ft_headmodel_concentricspheres
%   elec
%       sensor array, see ft_read_sens
%
%   surface_index
%       array of indices indicating which volume conductor surfaces to plot

if ~isfield(vol,'r')
    error('fbt:plot_concentricsphere',...
        'vol is not a concentric sphere head model');
end

colors = {'brain','white','skin'};
if nargin > 2
    idx = varargin{1};
else
    idx = 1:length(vol.r);
end
    
for i=idx
    vol_single = vol;
    vol_single.r = vol.r(i);
    ft_plot_vol(vol_single,...
        'facecolor', colors{i},...
        'facealpha', 0.2,...
        'faceindex', false,...
        'vertexindex', false);
end
    
% Plot electrodes
ft_plot_sens(elec,...
    'style', 'sk',...
    'coil', false,...
    'label', 'label');  

end