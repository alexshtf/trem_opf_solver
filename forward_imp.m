function [p, q, v2_l] = forward_imp(i, j, v1, z) 


conj_I = (i + 1i*j) ./ v1;
I = conj(conj_I);
v2_l = v1 - I * z;
conj_S = I .* conj(v2_l);
p = real(conj_S);
q = -imag(conj_S);

% p=round(p*10)/10;
% q=round(q*10)/10;
% %v2_l=round(v2_l*10)/10;
% v2_l=sign(real(v2_l))*sqrt((round(abs(v2_l)*10)/10)^2-(round(imag(v2_l)*10)/10)^2)+1j*round(imag(v2_l)*10)/10;