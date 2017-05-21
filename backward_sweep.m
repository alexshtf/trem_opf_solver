function [voltages_matrix, powers_matrix, currents_matrix] = ...
        backward_sweep(m, curves, G, root, Z)
    bfs_edges = bfsearch(G, root, 'edgetonew');
    
    n = numnodes(G);
    rv = curves.data{root}.vs;
    
    voltages_matrix = zeros(m, n);
    voltages_matrix(:, 1) = transpose(linspace(min(rv), max(rv), m));
        
    for edge = transpose(bfs_edges) 
        src = edge(1);
        dst = edge(2);
        
        src_volts = voltages_matrix(:, src);
        inj_powers = curves.sample_node_powers_for_volts(dst, abs(src_volts));
        dst_volts = src_volts + conj(inj_powers) * Z(src, dst) ./ conj(src_volts);
        voltages_matrix(:, dst) = dst_volts;
    end
    
    voltages_matrix = transpose(voltages_matrix);
    currents_matrix = compute_admittance(Z) * voltages_matrix;
    powers_matrix = voltages_matrix .* conj(currents_matrix);
end