classdef node_data < handle
    properties
        sonIndices
        curves
    end
    
    methods(Static)
        function arr = make_array(sz)
            arr(sz) = node_data();
        end
        
        function curves = decompose_phi_curves(volts, ps, qs)
            breaks = monotonic_seq(volts);
            curves = cell(1, numel(breaks));
            
            from = 1;
            for i = 1:numel(breaks)
                range = from:breaks(i);
                curves{i} = phi_curve(volts(range), ps(range), qs(range));
                from = breaks(i);
            end
        end
        
        function lb = min_volt(curve)
            lb = curve.vmin;
        end
        
        function ub = max_volt(curve)
            ub = curve.vmax;
        end
    end
    
    methods
        function pass_impedance(obj, Z)
            phi_curves = cell(1, obj.num_curves());
            phi_indices = cell(1, obj.num_curves());
            for i = 1:numel(phi_curves)
                curve = obj.curves{i};
                indices = obj.sonIndices(:, i);
                [v_tilde, s_tilde] = pass_impedance(curve.vs, curve.ss, Z);
                phi_curves{i} = node_data.decompose_phi_curves(...
                    v_tilde, real(s_tilde), imag(s_tilde));
                phi_indices{i} = repmat(indices, [1, numel(phi_curves{i})]);
            end
            obj.sonIndices = horzcat(phi_indices{:});
            obj.curves = horzcat(phi_curves{:});
        end
        
        function merge_curves(obj, children, d, constraint) 
            son_indices = cell(1, numel(children));
            for i = 1:numel(children)
                son_indices{i} = 1:(children(i).num_curves());
            end
            son_indices = combvec(son_indices{:});
             
            for i = 1:size(son_indices, 2)
                idx = son_indices(:, i);
                
                curves_to_merge = cell(1, numel(children));
                for j = 1:numel(children)
                    curves_to_merge{j} = children(j).curves{idx(j)};
                end
                
                merged = merge_curves(d, curves_to_merge, constraint);
                if isa(merged, 'struct')
                    obj.add_curve(idx, merged);
                end
            end
            
            if obj.num_curves() == 0
                error('Problem is infeasible');
            end
        end     
        
        function s = sample_phi(obj, idx, v)
            s = obj.curves{idx}.sample_phi(v);
        end
                  
        function n = num_curves(obj)
            n = numel(obj.curves);
        end
        
        function obj = node_data()
            obj.sonIndices = [];
            obj.curves = cell(0,0);
        end
        
        function add_curve(obj, indices, curve)
            obj.sonIndices(:, end+1) = indices(:);
            obj.curves{end+1} = curve;
        end
    end
end