%% closest_pick.m
% Get the id of the closest pick in the current flowline to the given lat/lon coordinates
% @param double lat Latitude
% @param double lon Longitude
% @
% @param handles the application's handles object
% @return int pid the id of the closest pick
function pid = closest_pick(lat,lon,handles)
    picks = handles.picks;
    plat_vector = picks.plat;
    plon_vector = picks.plon;
    distances_to_mouse = hypot(lat - plat_vector, lon - plon_vector);
    [~,index] = min(abs(distances_to_mouse));
    pid = handles.picks.pid(index);
end
