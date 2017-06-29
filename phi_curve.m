classdef phi_curve
    properties
        vmin
        vmax
        ps
        qs
    end
    
    methods
        function obj = phi_curve(volts, ps, qs)
            if nargin == 0
                obj.vmin = -inf;
                obj.vmax = inf;
                obj.ps = [];
                obj.qs = [];
                return;
            end
            
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
           
            
            obj.vmin = min(volts);
            obj.vmax = max(volts);
            obj.ps = pfunc;
            obj.qs = qfunc;
        end
        
        function s = sample_phi(obj, v)
            p = fnval(obj.ps, v);
            q = fnval(obj.qs, v);
            s = p + 1i * q;  
        end
    end
end