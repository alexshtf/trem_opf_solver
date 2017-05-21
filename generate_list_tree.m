function [voltages, powers, currents] ...
    = generate_list_tree(m, d, Z, PQ, PV, ref)

ctrs = constraints(PQ, PV, ref);
root = 1;
curves = node_curves(length(Z));
G = graph(compute_adjacency(Z));

forward_sweep(d, curves, G, root, Z, ctrs);
[voltages, powers, currents] = ...
    backward_sweep(m, curves, G, root, Z);

feasible = ctrs.feasible(voltages, powers);
voltages = voltages(:, feasible);
powers = powers(:, feasible);
currents = currents(:, feasible);

end