% Project picks
% @param picks a struct of picks, with plat, plon, page_ck, and ridge_side properties
% @param handles the GUIDE handles object
% @return projection, the projection struct with chron, ridge_side, mean_dist, std_dev, and npicks properties.

function projection = project_picks(picks,handles)
    flow = handles.flow(handles.fname);
    avg_plat = mean(picks.plat);
    avg_plon = mean(picks.plon);
    fpid = closest_flowpoint(avg_plat,avg_plon,handles);
    prev = max(fpid-15,0);
    nxt = min(fpid + 15,length(flow.lat));

    % sample latitudes and longitudes
    slat = flow.lat(prev:nxt);
    slon = flow.lon(prev:nxt);

    % fit a line to the flowline
    fit = polyfit(slon,slat,1);
    % get slope and intercept
    m = fit(1);
    b = fit(2);
    fit_lon1 = slon(1) - 10;
    fit_lat1 = m * fit_lon1 + b;
    fit_lon2 = slon(1) + 10;
    fit_lat2 = m * fit_lon2 + b;

    m2 = -1/m;

    len = length(picks.plat);
    dists = zeros(len,1);

    % for each pick, calculate its projection


    proj_plat = zeros(len,1);
    proj_plon = zeros(len,1);

    for i=1:len
        plat = picks.plat(i);
        plon = picks.plon(i);
        lon1 = plon - 1;
        lon2 = plon + 1;
        lat1 = (lon1 - plon) * m2 + plat;
        lat2 = (lon2 - plon) * m2 + plat;

        [project_lon,project_lat] = polyxpoly([lon1 lon2],[lat1 lat2],[fit_lon1 fit_lon2],[fit_lat1 fit_lat2]);

        proj_plat(i) = project_lat;
        proj_plon(i) = project_lon;

        dist = flow_distance(project_lat,project_lon,handles);
        dists(i) = dist;
    end

    proj = struct();
    proj.picks = picks;
    proj.plat = proj_plat;
    proj.plon = proj_plon;
    proj.fname = flow.fname;
    proj.seg_id = flow.seg_id;
    proj.chron = picks.page_ck(1);
    proj.ridge_side = picks.ridge_side(1,:);
    proj.mean_dist = mean(dists);
    proj.std_dev = std(dists);
    proj.npicks = len;
    projection = proj;
end
