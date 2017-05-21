function merged = merge_curves(N, curves, s, Vbounds)   
    [vmin, vmax] = common_volt_range(curves, Vbounds);
    mv = volt_curve(N, vmin, vmax);
    if isnan(s)
        ms = 0;
    else
        ms = s;
    end
    
    for i = 1:numel(curves)
        ms = ms + node_curves.sample_powers_for_volts(curves{i}, mv);
    end
    
    merged = struct('vs', mv, 'ss', ms);
end

function [vmin, vmax] = common_volt_range(curves, Vbounds)
    lbs = cellfun(@(c) node_curves.min_volt(c), curves);
    ubs = cellfun(@(c) node_curves.max_volt(c), curves);
    vmin = max(lbs);
    vmax = min(ubs);
    
    vmin = max(vmin, min(Vbounds));
    vmax = min(vmax, max(Vbounds));

    if vmax - vmin < 1E-6
        error('Infeasible problem. vmax - vmin = %f', vmax - vmin);
    end
end

