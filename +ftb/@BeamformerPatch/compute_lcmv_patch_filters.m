function source = compute_lcmv_patch_filters(...
    data, leadfield, patch_model, varargin)
%COMPUTE_LCMV_PATCH_FILTERS computes filters for an LCMV beamformer that
%operates on patches instead of point sources
%   [source] = COMPUTE_LCMV_PATCH_FILTERS(data, leadfield, patch_model, ...)
%   computes filters for an LCMV beamformer that operates on patches
%   instead of point sources. This is useful for coarse beamforming.
%
%   TODO add reference Limpiti2006
%
%   Input
%   -----
%   data (struct)
%       timelocked EEG data, output of ft_timelockanalysis
%   leadfield (struct)
%       leadfields, output of ft_prepare_leadfield
%   patch_model (ftb.PatchModel)
%       patch model object, output of ftb.PatchModel
%
%   Parameters
%   ----------
%   fixedori (default = true)
%       fixed moment orientation, chooses the moment that maximizes the
%       power of the beamformer
%
%       NOTE fixedori = false is not implemented
%   mode (default = 'all')
%       mode of operation, chooses how many grid points are set for the
%       beamforming step
%       all - all points inside a patch are selected and contain the patch
%       filter (useful for plotting)
%       single - one point inside a patch is selected and contains the
%       patch filter (useful for saving memory)
%   
%   Output
%   ------
%   source (struct)
%       struct containing spatial filters and patch ables
%   source.inside (cell array)
%       index specifying which grid points are to be evaluated
%   source.filters (cell array)
%       beamforming filter for each point in the leadfield grid, to be
%       specified as precomputed filters in ft_sourceanalysis
%   source.patch_labels (cell array)
%       anatomical label for each point in the leadfield grid


p = inputParser;
addRequired(p,'data',@isstruct);
addRequired(p,'leadfield',@isstruct);
addRequired(p,'patch_model',@(x) isa(x,'ftb.PatchModel'));
addParameter(p,'fixedori',true,@islogical);
addParameter(p,'mode','all',@(x) any(validatestring(x,{'all','single'})));
% add options
parse(p,data,leadfield,patch_model,varargin{:});

% allocate mem
source = [];
source.filters = cell(size(leadfield.leadfield));
source.patch_labels = cell(size(leadfield.leadfield));
source.inside = false(size(leadfield.inside));
source.patch_centroid = zeros(length(leadfield.inside),3);

% NOTE when supplying ft_sourceanalysis with filters, i can only specify
% one per grid point, not per trial, so this function can only operate on a
% single covariance

% check number of covariance repetitions
ndims_cov = length(size(data.cov));
if ndims_cov == 3
    ntrials = size(data.cov,1);
    if ntrials == 1
        data.cov = squeeze(data.cov);
    end
else
    ntrials = 1;
end

if ntrials > 1
    error('can only precompute filters with one cov, use singletrial option in BeamformerPatch');
end

fprintf('computing filters...\n');
% computer filter for each patch
for i=1:length(patch_model.patches)
    fprintf('computing filter for patch %d\n',i);

    if isempty(patch_model.patches{i}.U)
        filter = zeros(1,size(data.cov,1));
    else
        % get the patch basis
        Uk = patch_model.patches{i}.U;
        
        Yk = Uk'*pinv(data.cov)*Uk;
        
        % check what to do about unknown moment
        if p.Results.fixedori
            % if the moment orientation is unknown, maximize the power
            % ordered from smallest to largest
            [V,D] = eig(Yk);
            d = diag(D);
            [~,idx] = sort(d(:),1,'ascend');
            % select the eigenvector corresponding to the smallest eigenvalue
            vk = V(:,idx(1));
            
            % compute patch filter weights
            filter = pinv(vk'*Yk*vk)*pinv(data.cov)*Uk*vk;
            filter = filter';
        else
            % NOTE Not sure what to do if it's not true
            % You're limited to j moments
            % They're not x,y,z anymore because we changed the basis
            error('are you sure about this?');
            
            % compute patch filter weights
            filter = pinv(Yk)*Uk'*pinv(data.cov);
        end
        
    end
    
    switch p.Results.mode
        case 'all'
            % set patch filter at each point in patch
            [source.filters{patch_model.patches{i}.inside}] = deal(filter);
            % NOTE Redundant, but it keeps everything else in Fieldtrip working
            % as normal
            
            % save patch label for each point
            [source.patch_labels{patch_model.patches{i}.inside}] = deal(patch_model.patches{i}.name);
            
            % save centroid
            nverts = sum(pathces(i).inside);
            source.patch_centroid(patch_model.patches{i}.inside,:) = ...
                repmat(patch_model.patches{i}.centroid,nverts,1);
            
        case 'single'
            idx = find(patch_model.patches{i}.inside == 1, 1, 'first');
            
            if ~isempty(idx)
                % set patch filter at one point in patch
                source.filters{idx} = filter;
                
                % save patch label for each point
                source.patch_labels{idx} = patch_model.patches{i}.name;
                
                % save point location
                source.inside(idx) = true;
                
                % save centroid
                source.patch_centroid(idx,:) = patch_model.patches{i}.centroid;
            end
    end
    
end

switch p.Results.mode
    case 'all'
        % set empty filters to zero
        
        % check which filters are empty
        grid_empty = cellfun('isempty',source.filters);
        % select those that are inside only
        grid_empty = grid_empty' & leadfield.inside;
        % create a filter with zeros
        filter = zeros(size(filter));
        [source.filters{grid_empty}] = deal(filter);
        
        % check which labels are empty
        grid_empty = cellfun('isempty',source.patch_labels);
        [source.patch_labels{grid_empty}] = deal('');
        
        source.inside = leadfield.inside;
    case 'single'
        % inside points with empty filters should be ignored
end

end