function align_electrodes(cfg)
% align_electrodes aligns electrodes, including all of the set up for each
% method type
%
%   Input
%   -----
%   cfg.elec_file
%       electrode location file
%   cfg.outputfile
%       output file name
%   cfg.type
%       type of alignment: 'fiducial', 'interactive'
%
%   'fiducial'
%   cfg.mri_file
%       MRI file for head model, either '.mri' or matlab file containing
%       output from ft_read_mri
%
%   'interactive'
%   cfg.headmodel_file

% Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg

% Load electrodes
elec = ftb.util.loadvar(cfg.elec_file);

switch cfg.type
    
    case 'fiducial'
        %% Fiducial alignment
        
        % Load MRI data
        [~,~,ext] = fileparts(cfg.mri_file);
        if isequal(ext, '.mat')
            mri = ftb.util.loadvar(cfg.mri_file);
        else
            mri = ft_read_mri(cfg.mri_file);
        end
        
        % Get landmark coordinates
        nas=mri.hdr.fiducial.mri.nas;
        lpa=mri.hdr.fiducial.mri.lpa;
        rpa=mri.hdr.fiducial.mri.rpa;
        
        transm=mri.transform;
        
        nas=warp_apply(transm,nas, 'homogenous');
        lpa=warp_apply(transm,lpa, 'homogenous');
        rpa=warp_apply(transm,rpa, 'homogenous');
        
        % create a structure similar to a template set of electrodes
        fid.chanpos       = [nas; lpa; rpa];       % ctf-coordinates of fiducials
        fid.label         = {'FidNz','FidT9','FidT10'};    % same labels as in elec
        fid.unit          = 'mm';                  % same units as mri
        
        % Alignment
        cfgin               = [];
        cfgin.method        = 'fiducial';
        cfgin.template      = fid;                   % see above
        cfgin.elec          = elec;
        cfgin.fiducial      = {'FidNz','FidT9','FidT10'};  % labels of fiducials in fid and in elec
        elec_aligned      = ft_electroderealign(cfgin);
        
    case 'interactive'
        %% Interactive alignment
        
        vol = ftb.util.loadvar(cfg.headmodel_file);
        
        cfgin           = [];
        cfgin.method    = 'interactive';
        cfgin.elec      = elec;
        if isfield(vol, 'skin_surface')
            cfgin.headshape = vol.bnd(vol.skin_surface);
        else
            cfgin.headshape = vol.bnd(1);
        end
        elec_aligned  = ft_electroderealign(cfgin);
        
    otherwise
        error(['ftb:' mfilename],...
            'unknown type %s', cfg.type);
        
end

% Save
save(cfg.outputfile, 'elec_aligned');

end