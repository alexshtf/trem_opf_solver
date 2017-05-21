classdef constraints < handle
    properties
        PQ
        PV
        ref
    end
    
    properties(Access = private)
        PQi
        PVi
    end
    
    methods(Access = private)
        function t = pq_leaf_curve(obj, idx, d)
            S = obj.PQ(idx, 2);
            Vmin = obj.PQ(idx, 3);
            Vmax = obj.PQ(idx, 4);
            
            ts = linspace(0, 1, d);
    
            ps = real(S) * ones(size(ts));
            qs = imag(S) * ones(size(ts));    
            vs = volt_curve(d, Vmin, Vmax);
    
            t = struct('vs', vs, 'ss', ps + 1i * qs);            
        end
        
        function t = pv_leaf_curve(obj, idx, d)
            p = obj.PV(idx, 2);
            v = obj.PV(idx, 3);
            Qmin = obj.PV(idx, 4);
            Qmax = obj.PV(idx, 5);
            
            vs = v * ones(1, d);
            ps = p * ones(1, d);
            qs = linspace(Qmin, Qmax, d);
            t = struct('vs', vs, 'ss', ps + 1i * qs);
        end
    end
    
    methods
        function obj = constraints(PQ, PV, ref)
            if isempty(PQ)
                PQ = double.empty(0, 4);
            end
            if isempty(PV)
                PV = double.empty(0, 5);
            end
            n = max(max([PQ(:, 1); -inf]), max([PV(:, 1); -inf]));
            obj.ref = ref;
            obj.PQ = PQ;
            obj.PV = PV;
            [~, obj.PQi] = ismember(1:n, PQ(:, 1));
            [~, obj.PVi] = ismember(1:n, PV(:, 1));
        end
        
        function mask = feasible(obj, V, S)
            mask = true(1, size(V, 2));
            
            % reference feasibility mask
            pgen = real(S(1, :));
            qgen = imag(S(1, :));
            pmin = obj.ref(3);
            pmax = obj.ref(4);
            qmin = obj.ref(5);
            qmax = obj.ref(6);
            mask = mask & ...
                (pmin <= pgen) & (pgen <= pmax) & ...
                (qmin <= qgen) & (qgen <= qmax);
        end
        
        function t = leaf_curve(obj, j, d)
            if obj.PQi(j) > 0
                t = obj.pq_leaf_curve(obj.PQi(j), d);
            else
                t = obj.pv_leaf_curve(obj.PVi(j), d);
            end
        end
        
        function result = s(obj, j)
            pqi = obj.PQi(j);
            if pqi > 0
                result = obj.PQ(pqi, 2);
            else
                error('s constraint is defined only for PQ nodes');
            end
        end
        
        function res = Vbounds(obj, j)
            pqi = obj.PQi(j);
            if pqi > 0
                res = obj.PQ(pqi, 3:4);
            elseif j == 1
                res = obj.ref(1:2);
            else
                error('Vbounds can only be used with PQ or reference nodes');
            end
        end     
    end
end
