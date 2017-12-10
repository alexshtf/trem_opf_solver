classdef pq_constraint
    properties
        s
        vmin
        vmax
    end
    methods
        function obj = pq_constraint(s, vmin, vmax)
            [obj.s, obj.vmin, obj.vmax] = deal(s, vmin, vmax);
        end
    end
end