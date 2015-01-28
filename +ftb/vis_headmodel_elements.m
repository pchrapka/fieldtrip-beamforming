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
            cfgtmp = ftb.get_stage(cfg, 'headmodel');
            cfghm = ftb.load_config(cfgtmp.stage.full);
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
            cfgtmp = ftb.get_stage(cfg, 'electrodes');
            cfghm = ftb.load_config(cfgtmp.stage.full);
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
            cfgtmp = ftb.get_stage(cfg, 'leadfield');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            leadfield = ftb.util.loadvar(cfghm.files.leadfield);
            
            % Plot inside points
            plot3(...
                leadfield.pos(leadfield.inside,1),...
                leadfield.pos(leadfield.inside,2),...
                leadfield.pos(leadfield.inside,3), 'k.');
            
        case 'dipole'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'dipolesim');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            
            signal_components = {'signal','interference'};
            
            for i=1:length(signal_components)
                component = signal_components{i};
                if ~isfield(cfghm, component)
                    % Skip if component not specified
                    continue;
                end
                
                dip = cfghm.(component).ft_dipolesimulation.dip;
                ft_plot_dipole(dip.pos, dip.mom,...
                    'diameter',5,...
                    'length', 10,...
                    'color', 'blue',...
                    'unit', 'mm');
            end
            
        otherwise
            error(['fb:' mfilename],...
                'unknown element %s', cfg.elements);
    end
end

end

