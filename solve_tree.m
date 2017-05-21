function [vopt ,sopt, cost] = solve_tree(...
    m, d, f, Z, PQ, PV, ref)
% Solves the optimal power-flow problem on a restricted network with
% additional constraints, such as pmin/pmax constraints on the reference
% node.
%
%   [vopt, sopt, cost] = solve_tree(m, d, f, Z, bounds, PQ, PV)
%
% Input arguments:
%   m
%       The sampling density of the feasible set. Higher value results in 
%       better approximation of the optimal solution. Must be a positive
%       integer.
%   d 
%       The sampling density of intermediate curve functions. Higher values
%       result in less constraint violation. Must be an integer greater than 3.
%   f
%       Objective function handle. The function must be callable 
%       as f(V, S) where V is a matrix of node voltages, and S is a matrix of
%       the same size of node apparent powers. For each i, V(:, i) and S(:, i) 
%       are a feasible solution of the given problem. The function should return
%       a vector of size(V, 1) elements, containing the objective value 
%       associated with each feasible pair in V and S.
%   Z
%       Edge impedance matrix and network topology. For a non-zero Z(i,j), the
%       value defines the impedance. If Z(i,j) is zero, it means that there is
%       no edge between i and j.
%   bounds
%       A matrix of size N x 6 with bounds on the voltage absolute value,
%       active power and reactive power for each node. Each row specifies
%       bound constraints associated with node i:
%         - Voltage absolute value is constrained to the interval
%           [bounds(i, 1), bounds(i, 2)]. The constraint is applied to the
%           PQ and the reference nodes. For PV nodes these bounds are
%           ignored.
%         - Active power is constrained to the interval [bounds(i, 3),
%           bounds(i, 4)]. The constraint is applied to PV and the
%           reference nodes. For PQ nodes these bounds are ignored.
%         - Reactive power is constrained to the interval [bounds(i, 4),
%           bounds(i, 5)]. The constraint is applied to PV and the
%           reference nodes. For PQ nodes these bounds are ignored.
%   PQ
%       A matrix of 4 columns, where each row contains the data of a PQ
%       constraint. The columns have the following meaning:
%           1: Node index
%           2: Apparent power
%           3: Minimum voltage absolute value.
%           4: Maximum voltage absolute value.
%   PV
%       A matrix of 5 columns, where each row contains the data of a PV
%       constraint. The columns have the following meaning:
%           1: Node index
%           2: Active power
%           3: Voltage absolute value
%           4: Minimum reactive power
%           5: Maximum reactive power
%   ref
%       A vector of size 6 with reference node constraints. The elements
%       have the following meaning:
%           1: Minimum voltage absolute value
%           2: Maximum voltage absolute value
%           3: Minimum active power
%           4: Maximum active power
%           5: Minimum reactive power
%           6: Maximum reactive power
%
%  Remarks:
%   - Node 1 is the reference node
%   - The network topology is a tree.
%   - Any node, except node 1, must be either a PQ node or a PV node. Thus,
%     its index must appear either in the first column of PQ or the PV 
%     table.
%   - Any PV node must be a leaf. The corresponding reactive power bounds
%     must be finite.
%   - For any leaf PQ node, the corresponding voltage absolute value bounds
%     must be finite.

[v, s, ~] = generate_list_tree(m, d, Z, PQ, PV, ref);

func = f(v, s);
[cost,ind] = min(func);
vopt = v(:, ind);
sopt = s(:, ind);
