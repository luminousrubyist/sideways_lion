%% projection_output.m
% Generate output for a given flowline projection
% @param string fname the flowline
% @param handles the GUIDE handles object
% @return string output the output associated with the flowline
function output = projection_output(handles)
    lines = {};

    % Projections format
    lines{end+1} = 'fname seg_id chron ridge_side mean_dist std_dev_dist npicks';
    % Projections


    for i=1:length(handles.projections)
        proj = handles.projections{i};
        fname = proj.fname;
        seg_id = proj.seg_id;
        chron = proj.chron;
        ridge_side = proj.ridge_side;
        mean_dist = proj.mean_dist;
        std_dev = proj.std_dev;
        npicks = proj.npicks;

        str = sprintf('%s %d %f %s %f %f %d',fname,seg_id,chron,ridge_side,mean_dist,std_dev,npicks);
        lines{end+1} = str;
    end

    output = join(lines,sprintf('\n'));
end
