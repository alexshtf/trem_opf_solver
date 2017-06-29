function [v_tilde, s_tilde] = pass_impedance(v, s, Z)

v_tilde = abs(v - Z * conj(s) ./ v);
s_tilde = s - Z * (s .* conj(s)) ./ v.^2;
