% Calculate distance between point and the center of the flowline by travelling
% along it
%
% @param lat the input Latitude
% @param lon the input longitudes
% @param hanldess
% @return dist the distance

function dist = flow_distance(lat,lon,handles)
  fpid = closest_flowpoint(lat,lon,handles);
  flow = handles.flow(handles.fname);
  flat = flow.lat(fpid);
  flon = flow.lon(fpid);
  base_dist = distance(flat,flon,lat,lon);
  radius = flowpoint_radius(fpid,handles);
  direction = abs(radius) / radius;
  dist = base_dist * direction + radius;
end
