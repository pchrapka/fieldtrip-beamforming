function check_leadfield(cfg)

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
    cfgin.elements = {'electrodes', 'scalp', 'leadfield'};
    ftb.vis_headmodel_elements(cfgin);
end

end