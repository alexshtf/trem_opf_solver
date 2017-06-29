function forward_sweep(d, node_data_arr, G, root, Z, ctrs)
    bfs_edges = bfsearch(G, root, 'edgetonew');
    bfs_tree = digraph(bfs_edges(:, 1), bfs_edges(:, 2));
    forward_sweep_rec(root, root, d, node_data_arr, bfs_tree, Z, ctrs);
end

function forward_sweep_rec(root, j, d, node_data_arr, bfs_tree, Z, ctrs)
    is_leaf = outdegree(bfs_tree, j) == 0;
    if is_leaf
        node_data_arr(j).add_curve(1, ctrs.leaf_curve(j, d));
    else
        children = transpose(successors(bfs_tree, j));
        for k = children
            forward_sweep_rec(root, k, d, node_data_arr, bfs_tree, Z, ctrs);
            node_data_arr(k).pass_impedance(Z(j,k))
        end
        
        if j == root
            s = 0;
        else
            s = ctrs.s(j);
        end
        
        node_data_arr(j).merge_curves(...
            node_data_arr(children), d, s, ctrs.Vbounds(j));
    end
end
