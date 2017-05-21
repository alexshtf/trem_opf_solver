function adjacency = compute_adjacency(Z)
nonzeros = (Z~=0);
adjacency = triu(nonzeros,1)+tril(nonzeros,-1);
end