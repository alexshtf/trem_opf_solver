classdef root_constraint
    properties
      vmin
      vmax
    end
    methods
        function obj = root_constraint(vmin, vmax)
            [obj.vmin, obj.vmax] = deal(vmin, vmax);
        end
    end
end