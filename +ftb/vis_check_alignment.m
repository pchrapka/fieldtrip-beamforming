function vis_check_alignment(cfg)
%   cfg.files.elec_aligned
%   cfg.files.mri_headmodel

elec = ftb.util.loadvar(cfg.files.elec_aligned);
vol = ftb.util.loadvar(cfg.files.mri_headmodel);

% Plot the scalp
if isfield(vol, 'bnd')
    switch vol.type
        case 'bemcp'
            ft_plot_mesh(vol.bnd(3),...
                'edgecolor','none',...
                'facealpha',0.8,...
                'facecolor',[0.6 0.6 0.8]);
        case 'dipoli'
            ft_plot_mesh(vol.bnd(1),...
                'edgecolor','none',...
                'facealpha',0.8,...
                'facecolor',[0.6 0.6 0.8]);
        otherwise
            error('hm:vis_check_alignment',...
                'Which one is the scalp?');
    end
elseif isfield(vol, 'r')
    ft_plot_vol(vol,...
        'facecolor', 'none',...
        'faceindex', false,...
        'vertexindex', false);
end
    
hold on;

% Plot electrodes
ft_plot_sens(elec,...
    'style', 'sk',...
    'coil', true);  

end

