function [voltages, powers, currents] ...
    = generate_list_tree(m, d, Z, PQ, PV, ref, root)

ctrs = constraints(PQ, PV, ref);
node_data_arr = node_data.make_array(length(Z));
G = graph(compute_adjacency(Z));

forward_sweep(d, node_data_arr, G, root, Z, ctrs);
[voltages, powers, currents] = ...
    backward_sweep(m, node_data_arr, G, root, Z);

feasible = ctrs.feasible(voltages, powers);
voltages = voltages(:, feasible);
powers = powers(:, feasible);
currents = currents(:, feasible);

end