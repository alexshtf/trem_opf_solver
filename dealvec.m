function varargout = dealvec(X)
    C = num2cell(X);
    [varargout{1:numel(C)}] = C{:};  
end