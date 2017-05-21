function Y = compute_admittance(Z)
% Compute the Y matrix
m=length(Z);
Y=sparse(m,m);
for k=1:m
    for l=k+1:m
        if (Z(k,l)~=0)
            Y(k,l)=1/Z(k,l);
        end
    end
end
Y=Y+Y.';
Y=diag(sum(Y))-Y;

end