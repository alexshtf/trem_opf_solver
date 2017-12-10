classdef pv_constraint
    properties
        p
        v
        qmin
        qmax
    end
    methods
        function obj = pv_constraint(p, v, qmin, qmax)
            [obj.p, obj.v, obj.qmin, obj.qmax] = deal(p, v, qmin, qmax);
        end
    end
end