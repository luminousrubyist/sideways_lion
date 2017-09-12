%% projection_output.m
% Generate output for a given flowline projection
% @param string fname the flowline
% @param handles the GUIDE handles object
% @return string output the output associated with the flowline
function output = projection_output(fname,handles)
    flow = handles.flow(fname);
    lines = {};
    lines{end+1} = 'fname seg_id';
    flow_str = sprintf('%s %d',fname,flow.seg_id);
    lines{end+1} = flow_str;

    % Projections format
    lines{end+1} = 'chron ridge_side mean_dist std_dev_dist npicks';
    % Projections


    for i=1:length(flow.projections)
        proj = flow.projections{i};
        chron = proj.chron;
        ridge_side = proj.ridge_side;
        mean_dist = proj.mean_dist;
        std_dev = proj.std_dev;
        npicks = proj.npicks;

        str = sprintf('%f %s %f %f %d',chron,ridge_side,mean_dist,std_dev,npicks);
        lines{end+1} = str;
    end

    output = join(lines,sprintf('\n'));
end
