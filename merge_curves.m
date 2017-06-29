function merged = merge_curves(N, curves, s, Vbounds)   
    [vmin, vmax] = common_volt_range(curves, Vbounds);
    
    if vmax - vmin < 1E-6
        merged = [];
        return;
    end
    
    mv = volt_curve(N, vmin, vmax);
    if isnan(s)
        ms = 0;
    else
        ms = s;
    end
    
    for i = 1:numel(curves)
        ms = ms + curves{i}.sample_phi(mv);
    end
    
    merged = struct('vs', mv, 'ss', ms);
end

function [vmin, vmax] = common_volt_range(curves, Vbounds)
    lbs = cellfun(@(c) node_data.min_volt(c), curves);
    ubs = cellfun(@(c) node_data.max_volt(c), curves);
    vmin = max(lbs);
    vmax = min(ubs);
    
    vmin = max(vmin, min(Vbounds));
    vmax = min(vmax, max(Vbounds));
end

