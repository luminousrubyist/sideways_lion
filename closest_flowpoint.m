% closest_flowpoint.m
%% closest_pick.m
% Get the id of the closest pick in the current flowline to the given lat/lon coordinates
% @param double lat Latitude
% @param double lon Longitude
% @
% @param handles the application's handles object
% @return int pid the id of the closest pick
function fid = closest_flowpoint(lat,lon,handles)
    flow = handles.flow(handles.fname);
    lat_vector = flow.lat;
    lon_vector = flow.lon;
    distances_to_mouse = hypot(lat - lat_vector, lon - lon_vector);
    [~,index] = min(abs(distances_to_mouse));
    fid = index;
end
