function [vopt ,sopt, cost] = solve_tree(...
    f, Z, PQ, PV, ref, varargin)
% Solves the optimal power-flow problem on a restricted network with
% additional constraints, such as pmin/pmax constraints on the reference
% node.
%
%   [vopt, sopt, cost] = solve_tree(f, Z, bounds, PQ, PV, Name, Value, ...)
%
% Input arguments:
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
%   PQ
%       Defines the PQ constraints. Must be either empty, or a matrix 
%       of 4 columns, where each row contains the data of a PQ constraint. 
%       The columns have the following meaning:
%           1: Node index
%           2: Apparent power
%           3: Minimum voltage absolute value.
%           4: Maximum voltage absolute value.
%   PV
%       Defines the PV constraints. Must be either empty, or A matrix of
%       5 columns, where each row contains the data of a PV constraint. 
%       The columns have the following meaning:
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
% Optional arguments, given as Name, Value pairs:
%   'FeasibleDensity'
%       The sampling density of the feasible set. Higher value results in 
%       better approximation of results closer to optimality. Must be an integer
%       greater than 1. The default is 1000.
%   'CurveDensity'
%       The sampling density of intermediate curve functions. Higher values
%       result smaller deviations from feasibility. Must be an integer greater
%       than 3. The default is 250.
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

validateRequiredInput(f, Z, PQ, PV, ref);
[m, d] = parseOptionalInput(varargin{:});

[v, s, ~] = generate_list_tree(m, d, Z, PQ, PV, ref);

func = f(v, s);
[cost,ind] = min(func);
vopt = v(:, ind);
sopt = s(:, ind);

function validateRequiredInput(f, Z, PQ, PV, ref)

if ~isa(f, 'function_handle')
    error('Expected argument 1, f, to be a function handle');
end

if ~ismatrix(Z) || size(Z, 1) ~= size(Z, 2) || ~isnumeric(Z) || isempty(Z)
    error('Expected argument 2, Z, to be a non-empty, squared numeric matrix');
end

if ~isempty(PQ) && (~ismatrix(PQ) || ~isnumeric(PQ) || size(PQ, 2) ~= 4)
    error('Expected argument 3, PQ, to be either empty, or a 4-column numeric matrix');
end

if ~isempty(PV) && (~ismatrix(PV) || ~isnumeric(PV) || size(PV, 2) ~= 5)
    error('Expected argument 4, PV, to be either empty, or a 5-column numeric matrix');
end

if ~isvector(ref) || numel(ref) ~= 6 || ~isnumeric(ref)
    error('Expected argument 5, ref, to be a numeric vector with 6 elements.');
end

if any(PQ(:, 1) ~= floor(PQ(:, 1))) 
    error('Expected argument 3, PQ, to have column 1 consisting of integers (bus indices)');
end

if any(PV(:, 1) ~= floor(PV(:, 1)))
    error('Expected argument 4, PV, to have column 1 consisting of integers (bus indices)');
end

n = length(Z);
allidx = sort([1; PQ(:, 1); PV(:, 1)]);
if any(allidx' ~= 1:n)
    error('Any node, except node 1, must be either a PQ or a PV node');
end


function [m, d] = parseOptionalInput(varargin)

p = inputParser;
addParameter(p, 'FeasibleDensity', 1000, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', '>=', 2}));
addParameter(p, 'CurveDensity', 250, @(x) validateattributes(x, {'numeric'}, {'scalar', 'ingeger', '>=', 4}));
parse(p, varargin{:});

m = p.Results.FeasibleDensity;
d = p.Results.CurveDensity;
