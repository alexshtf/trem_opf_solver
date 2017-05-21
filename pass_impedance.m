function res = pass_impedance(curve, Z)

w = curve.vs;
s = curve.ss;

w_tilde = abs(w - Z * conj(s) ./ w);
s_tilde = s - Z * (s .* conj(s)) ./ w.^2;

res = node_curves.from_points(w_tilde, real(s_tilde), imag(s_tilde));
