% Define the impedance matrix and network topology
Zdef = [1, 2, 0.0017+0.0003i;  % Z12 
        1, 3, 0.0006+0.0001i;  % Z13
        3, 4, 0.0007+0.0003i;  % Z34
        3, 5, 0.0009+0.0005i]; % Z35
Z = sparse([Zdef(:, 1); Zdef(:, 2)], ...
           [Zdef(:, 2); Zdef(:, 1)], ...
           [Zdef(:, 3); Zdef(:, 3)]);

% Define PQ constraints. Each row is:
%   bus,  -p-iq, vmin, vmax       [consumed power is negative!]
PQ = [3,   -5-1i,  0.9, 1.1  ;
      4, -4-0.2i, 0.92, 1.06];

% Define PV constraints. Each row is:
%   bus,   p,  |v|, qmin, qmax
PV = [2, 4.9, 1.01,  -10, 10;
      5, 4.2,  1.0,   -5, 5];
      
% Define reference constraints: 
%    vmin, vmax, pmin, pmax, qmin, qmax      
ref = [0.93, 1.1, 0, 5, -10, 10];

% Define objective function. In each argument:
%    row = node, column = a feasible solution.
f = @(v, s) real(s(1, :)) + abs(abs(v(3, :) - 1)) + abs(abs(v(4, :) - 1));

% Solve the OPF problem and produce the optimal voltages, powers and objective value.
[v, s, fval] = solve_tree(f, Z, PQ, PV, ref)