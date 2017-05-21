function voltages_matrix = compute_complex_voltages(bfs, Z, S, abs_volt, gen_set, q_gen)
    num_instances = size(abs_volt, 2);
    num_nodes = size(abs_volt, 1);
    num_edges = size(bfs, 1);

    % compute injected powers from leaves to generator
    injected_power = inf(num_edges, num_instances);
    node_powers = zeros(num_nodes, num_instances);
    node_powers(~isnan(S), :) = repmat(S(~isnan(S)), [1, num_instances]);
    node_powers(gen_set, :) = real(node_powers(gen_set, :)) + 1i * q_gen;
    for i = flip(1:num_edges)
        a = bfs(i, 1);
        b = bfs(i, 2);
        
        vb = abs_volt(b, :);
        sb = node_powers(b, :);
        
        [p_ba, q_ba, ~] = forward_imp(real(sb), imag(sb), vb, Z(b, a));
        injected_power(i, :) = p_ba + 1i * q_ba;
        node_powers(a, :) = node_powers(a, :) + injected_power(i, :);
    end
    
    % compute voltages from generator to leaves
    injected_power = -injected_power; % reverse edge order - reverse sign of injected power
    voltages_matrix = inf(size(abs_volt));
    voltages_matrix(1, :) = abs_volt(1, :); % generator is slack - has zero angle
    for i = 1:num_edges
        a = bfs(i, 1);
        b = bfs(i, 2);
        
        s_ab = injected_power(i, :);
        z_ab = Z(a, b);
        va = voltages_matrix(a, :);
        voltages_matrix(b, :) = va - z_ab * conj(s_ab) ./ conj(va);
    end
end