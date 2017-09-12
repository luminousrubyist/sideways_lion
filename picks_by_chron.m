% picks_by_chron.m
% Take picks as input, return only those with the chron and ridge side matching the
% chron and ridge side provided
% @param picks the picks
% @param chron the chron to filter by
% @param ridge_side the ridge side to choose

function p = picks_by_chron(picks,chron,ridge_side)
    s = struct();

    indices = intersect(find(picks.page_ck == chron),find(strcmp(picks.ridge_side,ridge_side)));
    s = struct();
    s.pid = picks.pid(indices);
    s.plat = picks.plat(indices);
    s.plon = picks.plon(indices);
    s.page_ck = picks.page_ck(indices);
    s.ridge_side = picks.ridge_side{indices};
    p = s;
end
