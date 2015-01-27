function vis_headmodel_elements(cfg)
%   cfg.elements
%       cell array of head model elements to be plotted: 
%           'electrodes', 'volume', 'leadfield'
%       TODO Add dipole
%   cfg.stage
%       struct of short names for each pipeline stage
%
%   See also ftb.get_stage

for i=1:length(cfg.elements)
    switch cfg.elements{i}
        case 'volume'
            hold on;
            
            % Load data
            cfghm = ftb.load_config(cfg.stage.headmodel);
            vol = ftb.util.loadvar(cfghm.files.mri_headmodel);
            
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
            
        case 'electrodes'
            hold on;
            
            % Load data
            cfghm = ftb.load_config(cfg.stage.electrodes);
            elec = ftb.util.loadvar(cfghm.files.elec_aligned);
            
            % Plot electrodes
            ft_plot_sens(elec,...
                'style', 'sk',...
                'coil', true);
            %'coil', false,...
            %'label', 'label');
            
        case 'leadfield'
            hold on;
            
            % Load data
            cfghm = ftb.load_config(cfg.stage.leadfield);
            leadfield = ftb.util.loadvar(cfghm.files.leadfield);
            
            % Plot inside points
            plot3(...
                leadfield.pos(leadfield.inside,1),...
                leadfield.pos(leadfield.inside,2),...
                leadfield.pos(leadfield.inside,3), 'k.');
            
        otherwise
            error(['fb:' mfilename],...
                'unknown element %s', cfg.elements);
    end
end

end

