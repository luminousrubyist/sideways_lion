% flowpoint_radius.m
% calculate the distance between a flowpoint and the center
function dist = flowpoint_radius(fid,handles)
    flow = handles.flow(handles.fname);
    dist = fpr(fid,flow);
end

% Recursive helper function to calculate distance
function dist = fpr(fid,flow)
    cid = flow.center_id;
    if fid == cid
        dist = 0;
    else
        % The increment, the direction in which we will iterate
        inc = abs(cid - fid) / (cid - fid);
        next = fid + inc;
        lat1 = flow.lat(fid);
        lon1 = flow.lon(fid);
        lat2 = flow.lat(next);
        lon2 = flow.lat(next);
        dist = (distance(lat1,lon1,lat2,lon2) * inc * -1) + fpr(next,flow);
    end
end
