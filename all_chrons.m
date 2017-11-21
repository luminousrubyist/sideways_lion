%% all_chrons.m
% Return all possible unique chrons
% @param double lat Latitude
% @param double lon Longitude
% @param handles the application's handles object
% @return int pid the id of the closest pick
function chrons = all_chrons(handles)
    len = length(handles.picks.pid);
    
    % all page_ck / ridge_side pairs will be stored in this cell array
    % as JSON-serialized values.
    all = cell(len,1);
    options = struct('Compact', 1);
    for i=1:len
        ridge_side = handles.picks.ridge_side{i};
        chron = handles.picks.page_ck(i);
        % Save the data as a JSON string
        row = savejson('',{chron,ridge_side},options);
        all{i} = row;
    end
    
    % Eliminate all duplicates from this cell array
    result = unique(all);
    
    % Now, map back from JSON to MATLAB values
    for i=1:length(result)
        result{i} = loadjson(result{i});
    end
    
    % The result should be a cell array of cell arrays.
    % Each element cell array is a two-element vector with
    % the chron first and the ridge-side second
    chrons = result;
end
