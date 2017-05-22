# Optimal Power Flow solver for Restricted Radial Networks

This repository contains MATLAB code for the Optimal Power Flow problem on a special kind of networks, we call Restricted Radial Network, which has the following properties:

- The topology is a tree with non-zero edge impedances.
- Node 1 is the reference node.
- The leaves of the tree are  either PQ or PV constrained nodes with bounded intervals constraining voltage magnitude or reactive power.
- Internal nodes are PQ nodes, with arbitrary, possibly unbounded, intervals constraining voltage magnitude.

The precise definition is described in the paper [INSERT PAPER REFERENCE HERE]

## Usage example

The following short MATLAB code defines a power network, feeds it to our solver, and produces an optimal solution. It can be found in the `example.m` script.

```matlab
% Define the (symmetric) impedance matrix and network topology. A
% nonzero entry defines an edge and its impedance. A zero entry means
% there is no edge.
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

% Define objective function - real power at node 1 + stability at PQ nodes.
%    f(v, s) = Re(s_1) + ||v_3| - 1| + ||v_4| - 1|
% We must provide a function handle that applies the function above
% to every column of the given arguments.
f = @(v, s) real(s(1, :)) + abs(abs(v(3, :) - 1)) + abs(abs(v(4, :) - 1));

% Solve the OPF problem and produce the optimal voltages, powers and objective value.
[v, s, fval] = solve_tree(100, 100, f, Z, PQ, PV, ref)
```

Running the code above produces the following output:

```
v =

   1.0013 + 0.0000i
   1.0100 - 0.0014i
   0.9979 + 0.0022i
   0.9950 + 0.0012i
   1.0000 + 0.0073i


s =

   0.0083 + 2.8859i
   4.9000 + 1.6655i
  -5.0000 - 1.0000i
  -4.0000 - 0.2000i
   4.2000 - 3.3199i


fval =

    0.0165
```
