function bnd = monotonic_seq(x)
% Computes indices which are endpoints of strictly monotonic sub-sequences 
% within the given vector.
%
% Usage:
%   bnd = monotonic_seq(x)
%
% Inputs:
%   x
%       Must be a row or a column numeric vector
% Outputs:
%   bnd
%       A vector whose last element is numel(x) and denotes the endpoints of 
%       monotonic sub-sequences within x. If k = numel(bnd), then x(1:bnd(1)),
%       x((1 + bnd(1)):bnd(2)), ..., x((1 + bnd(k-1)):bnd(k)) are all strictly
%       monotonic.
        
ind = (diff(x) > 0) - (diff(x) < 0);
if any(ind == 0)
    error('The given vector must not consist of equal consecutive elements');
end

if isrow(ind)   
    bnd = [1 + find(diff(ind)), numel(x)];
else
    bnd = [1 + find(diff(ind)); numel(x)];
end