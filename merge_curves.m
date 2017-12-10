function merged = merge_curves(N, curves, constr)   
    if isa(constr, 'pq_constraint')
        [vmin, vmax] = common_volt_range(curves, constr.vmin, constr.vmax);
    
        if vmax - vmin < 1E-6
            merged = [];
            return;
        end
    
        mv = volt_curve(N, vmin, vmax);
        ms = constr.s;
    elseif isa(constr, 'root_constraint')
        [vmin, vmax] = common_volt_range(curves, constr.vmin, constr.vmax);
    
        if vmax - vmin < 1E-6
            merged = [];
            return;
        end
    
        mv = volt_curve(N, vmin, vmax);
        ms = 0;
    elseif isa(constr, 'pv_constraint')
        [vmin, vmax] = common_volt_range(curves, -inf, inf);
        if (vmin > constr.v) || (constr.v > vmax)
            merged = [];
            return;
        end
        
        mv = ones(1, N) * constr.v;
        ms = constr.p + 1i * linspace(constr.qmin, constr.qmax, N);
    else
        error('BUG');
    end
    

    for i = 1:numel(curves)
        ms = ms + curves{i}.sample_phi(mv);
    end
    merged = struct('vs', mv, 'ss', ms);
end

function [vmin, vmax] = common_volt_range(curves, c_vmin, c_vmax)
    lbs = cellfun(@(c) node_data.min_volt(c), curves);
    ubs = cellfun(@(c) node_data.max_volt(c), curves);
    vmin = max(lbs);
    vmax = min(ubs);
    
    vmin = max(vmin, c_vmin);
    vmax = min(vmax, c_vmax);
end

