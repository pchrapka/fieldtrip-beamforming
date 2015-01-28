%% create_HMbemcp256_L10mm.m
% Compute the leadfield using the HMbemcp256 head model. The lead field is
% on a uniform grid with 10mm spacing

cfg = [];
cfg.stage.headmodel = 'HMbemcp';
cfg.stage.electrodes = 'E256';
cfg.stage.leadfield = 'L10mm';
cfg.ft_prepare_leadfield.grid.resolution = 10;
cfg.ft_prepare_leadfield.grid.unit = 'mm';

cfg = ftb.create_leadfield(cfg);

debug = false;
if debug
    cfgtmp = ftb.get_stage(cfg);
    cfglf = ftb.load_config(cfgtmp.stage.full);
    leadfield = ftb.util.loadvar(cfglf.files.leadfield);
    
    lf_inside = leadfield.leadfield(leadfield.inside);
    for i=1:length(lf_inside)
        result = sum(sum(isnan(lf_inside{i})));
        if result > 0
            fprintf('found nan %d\n', leadfield.inside(i));
        end
    end
end

if debug
    cfgin = [];
    cfgin.stage = cfg.stage;
    cfgin.elements = {'electrodes', 'volume', 'leadfield'};
    ftb.vis_headmodel_elements(cfgin);
end
