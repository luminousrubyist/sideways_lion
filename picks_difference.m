% picks_difference
% takes picks as input, return only those not in the second parameter
% @param a the picks to begin with
% @param b the picks to remove

function p = picks_difference(a,b)

    ids = setdiff(a.pid,b.pid);
    indices = ismember(a.pid,ids);
    s = struct();
    s.pid = a.pid(indices);
    s.plat = a.plat(indices);
    s.plon = a.plon(indices);
    s.page_ck = a.page_ck(indices);
    s.ridge_side = a.ridge_side(indices);
    p = s;
end
