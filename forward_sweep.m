function forward_sweep(d, curves, G, root, Z, ctrs)
    bfs_edges = bfsearch(G, root, 'edgetonew');
    bfs_tree = digraph(bfs_edges(:, 1), bfs_edges(:, 2));
    forward_sweep_rec(root, d, curves, bfs_tree, Z, ctrs);
end

function forward_sweep_rec(j, d, curves, bfs_tree, Z, ctrs)
    is_leaf = outdegree(bfs_tree, j) == 0;
    if is_leaf
        curves.data{j} = ctrs.leaf_curve(j, d);
    else
        children = transpose(successors(bfs_tree, j));
        for k = children
            forward_sweep_rec(k, d, curves, bfs_tree, Z, ctrs);
            curves.backup{k} = curves.data{k};
            curves.data{k} = pass_impedance(curves.data{k}, Z(j, k));
        end
        
        if j == 1
            s = 0;
        else
            s = ctrs.s(j);
        end
        curves.data{j} = merge_curves(...
            d, curves.data(children), s, ctrs.Vbounds(j));
    end
end
