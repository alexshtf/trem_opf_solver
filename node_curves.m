classdef node_curves < handle
    properties
        data
        backup
    end
    
    methods(Static)
        function curve = from_points(volts, ps, qs)
            if numel(ps) ~= numel(volts)
                error('Invalid number of real powers');
            end
            if numel(qs) ~= numel(volts)
                error('Invalid number of reactive powers');
            end

            if ~(issorted(volts) || issorted(flip(volts)))
                error('Problem does not fit the algorithm. Volts are not monotonic');
            end
            
            func = csapi(volts, [ps; qs]); 
            pfunc = fncmb(func, [1 0]); % extract P-only function
            qfunc = fncmb(func, [0 1]); % extract Q-only function
            curve = struct(...
                'vmin', min(volts),...
                'vmax', max(volts),...
                'ps', pfunc,...
                'qs', qfunc);
        end
        
        function s = sample_powers_for_volts(curve, v)
            p = fnval(curve.ps, v);
            q = fnval(curve.qs, v);
            s = p + 1i * q;            
        end
        
        function lb = min_volt(curve)
            lb = curve.vmin;
        end
        
        function ub = max_volt(curve)
            ub = curve.vmax;
        end
    end
    methods
        function obj = node_curves(n)
            obj.data = cell(1, n);
            obj.backup = cell(1, n);
        end
        
        function s = sample_node_powers_for_volts(obj, n, v)
            s = node_curves.sample_powers_for_volts(obj.data{n}, v);
        end
    end
end
