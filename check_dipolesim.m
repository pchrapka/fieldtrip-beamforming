function check_dipolesim(cfg)
debug = true;
if debug
    cfgtmp = ftb.get_stage(cfg, 'dipolesim');
    cfghm = ftb.load_config(cfgtmp.stage.full);
    data = ftb.util.loadvar(cfghm.files.ft_dipolesignal.signal);
    ft_databrowser([], data);
end

if debug
    cfgtmp = ftb.get_stage(cfg, 'dipolesim');
    cfghm = ftb.load_config(cfgtmp.stage.full);
    data = ftb.util.loadvar(cfghm.files.adjust_snr.all);
%     data = ftb.util.loadvar(cfghm.files.adjust_snr.signal);
%     data = ftb.util.loadvar(cfghm.files.adjust_snr.interference);
    ft_databrowser([], data);
end

if debug
    cfgin = [];
    cfgin.stage = cfg.stage;
    cfgin.elements = {'brain', 'dipole'};
    ftb.vis_headmodel_elements(cfgin);
end

end