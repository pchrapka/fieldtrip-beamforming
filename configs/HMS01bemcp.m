% HMS01bemcp

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
% Processing options
cfg.ft_volumesegment.output = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.method = 'projectmesh';
cfg.ft_prepare_mesh.tissue = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.numvertices = [2000, 1500, 1000];
cfg.ft_prepare_headmodel.method = 'bemcp';
% MRI data
cfg.mri_data = fullfile('anatomy','Subject01','Subject01.mri');

save('HMS01bemcp.mat','cfg');

cd(curdir);