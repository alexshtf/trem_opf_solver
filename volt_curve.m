function vs = volt_curve(N, vmin, vmax)
%vs = (vmin^(-2) + linspace(0, 1, N) .* (vmax^(-2) - vmin^(-2))).^(-1/2);
%vs = vmin + (1 - linspace(0, 1, N)).^8 * (vmax - vmin);
vs = linspace(vmin, vmax, N);