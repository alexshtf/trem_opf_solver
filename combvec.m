function c = combvec(varargin)
    grids = cell(size(varargin));
    [grids{:}] = ndgrid(varargin{:});
    grids = cellfun(@(grd) transpose(grd(:)), grids, 'UniformOutput', false);
    c = vertcat(grids{:});
end