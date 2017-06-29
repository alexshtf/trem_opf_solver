function [voltages_matrix, powers_matrix, currents_matrix] = ...
        backward_sweep(m, node_data, G, root, Z)
    
    bfs_edges = bfsearch(G, root, 'edgetonew');
    bfs_tree = digraph(bfs_edges(:, 1), bfs_edges(:, 2));
    
    bfs_sources = bfs_edges(:, 1);
    bfs_sources(diff(bfs_sources) == 0) = [];

    n = numnodes(G);
    
    voltage_matrices = cell(1, node_data(root).num_curves());
    
    for ci = 1:numel(voltage_matrices)
        rv = node_data(root).curves{ci}.vs;
        voltages_matrix = zeros(m, n);
        voltages_matrix(:, root) = transpose(linspace(min(rv), max(rv), m));
        
        phi_index = inf(1, n);
        phi_index(root) = ci;

        for src = transpose(bfs_sources)
            sons = successors(bfs_tree, src);
            sonIndices = node_data(src).sonIndices(:, phi_index(src));
            for i = 1:numel(sons)
                dst = sons(i);
                phi_index(dst) = sonIndices(i);

                src_volts = voltages_matrix(:, src);
                phi = node_data(dst).sample_phi(...
                    phi_index(dst), abs(src_volts));                    
                dst_volts = src_volts + conj(phi) * Z(src, dst) ./ conj(src_volts);
                voltages_matrix(:, dst) = dst_volts;
            end
        end
        voltage_matrices{ci} = voltages_matrix;
    end
    
    voltages_matrix = vertcat(voltage_matrices{:});
    voltages_matrix = transpose(voltages_matrix);
    currents_matrix = compute_admittance(Z) * voltages_matrix;
    powers_matrix = voltages_matrix .* conj(currents_matrix);
end