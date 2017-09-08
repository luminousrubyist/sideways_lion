function varargout = lion(varargin)
    % LION MATLAB code for lion.fig
    %      LION, by itself, creates a new LION or raises the existing
    %      singleton*.
    %
    %      H = LION returns the handle to a new LION or the handle to
    %      the existing singleton*.
    %
    %      LION('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in LION.M with the given input arguments.
    %
    %      LION('Property','Value',...) creates a new LION or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before lion_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to lion_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help lion

    % Last Modified by GUIDE v2.5 08-Sep-2017 11:50:24

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @lion_OpeningFcn, ...
                       'gui_OutputFcn',  @lion_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

% --- Executes just before lion is made visible.
function lion_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to lion (see VARARGIN)

    addpath('freezeColors_v23_cbfreeze/freezeColors');
    warning('off','MATLAB:nargchk:deprecated');

    handles.files = struct();
    handles.files.ETOPO = 'data/etopo1_bed_c_f4.flt';
    handles.files.FLOWLINES = 'data/flowlines';
    handles.files.PICKS = 'data/GSFML.global.picks.gmt_output_latlonage';
    handles.files.SEGMENTS = 'data/segments_allspreadingrates_Feb172012';

    % ETOPO scaling
    handles.ETOPOLIM = [-5000 -2000];
    % Axes limits
    % pick ages in Mya
    handles.AGELIM  = [0 30];

    % Colors
    handles.JET = colormap('jet');
    handles.GRAYSCALE = colormap(flipud(colormap('gray')));

    % Load SEGMENTS
    handles.SEGMENTS = tdfread(handles.files.SEGMENTS, 'tab');
    handles.segments = handles.SEGMENTS;
    handles.segments.has_flowline = false(length(handles.segments.lat1),1);

    % Load flowlines --> files must start with 'flowline' and end with
    % an underscore followed by the flowline's segment id
    handles.flow = containers.Map;
    flowline_files = dir(fullfile(handles.files.FLOWLINES,'flowline*'));
    [nfiles,~] = size(flowline_files);
    for i = 1:nfiles
      fname = flowline_files(i).name;
      % Get a list of underscore-separated tokens in the filename, then reverse it
      tokens = flip(strsplit(fname,'_'));
      % The last token (first in the reversed list) is the segment id
      seg_id = str2num(tokens{1});
      handles.segments.has_flowline(seg_id) = true;

      fullname = fullfile(handles.files.FLOWLINES,fname);

      % Build xflow data
      flow = struct();
      flow.name = fname;
      flow.seg_id = seg_id;
      coords = load(fullname);

      % Interpret center of the flowline to be the first line of the file
      flow.center = coords(1,:);

      % Identify each end of flowline
      flow.first = coords(2,:);
      flow.last = coords(end,:);

      flow.lat = coords(:,1);
      flow.lon = coords(:,2);

      cid = intersect(find(flow.lat == flow.center(1) ),find(flow.lon == flow.center(2)));
      flow.center_id = cid(cid~=1);


      handles.flow(fname) = flow;
    end

    % Load picks
    picksformat = '%n %n %n';
    [plat, plon, page_ck] = textread(handles.files.PICKS,picksformat);

    handles.PLAT  = plat;
    handles.PLON = plon;
    handles.PAGE_CK = page_ck;

    handles.plat = plat;
    handles.plon = plon;
    handles.page_ck = page_ck;
    handles.pid = 1:length(plat);

    % Init plots
    handles.plots = struct();
    % Create an entry in the plots object for each axes
    all_axes = findobj(gcf,'type','axes');
    for i=1:length(all_axes)
      ax = all_axes(i);
      tag = ax.Tag;
      handles.plots.(tag) = struct();
    end

    % Draw map and ETOPO
    axes(handles.axes_main);

    handles = draw_map([-40 -20],[60 80],handles);
    set(handles.edit_minlat,'String',handles.plots.axes_main.latlim(1));
    set(handles.edit_maxlat,'String',handles.plots.axes_main.latlim(2));
    set(handles.edit_minlon,'String',handles.plots.axes_main.lonlim(1));
    set(handles.edit_maxlon,'String',handles.plots.axes_main.lonlim(2));
    handles = plot_segments(handles);

    % Output directory
    if ~ (7==exist('output','dir'))
      disp('Output directory not found, creating it');
      mkdir('output');
    end

    % Choose default command line output for lion
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes lion wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = lion_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% Draw a map on the current axes with parameters latlim and lonlim
function h = draw_map(latlim,lonlim,handles)
    ax = gca;
    tag = ax.Tag;
    cla(ax);

    % axes plots
    ap = handles.plots.(tag);

    if isfield(ap,'etopo')
      delete(ap.etopo);
      ap = rmfield(ap,'etopo');
    end

    worldmap(latlim,lonlim);
    ap.latlim = latlim;
    ap.lonlim = lonlim;

    % Load etopo
    [z,~] = etopo(handles.files.ETOPO,1,latlim,lonlim);

    ap.etopo = surfm(latlim,lonlim,z,z);

    % ETOPO axis
    colormap(ax,handles.GRAYSCALE);
    colorbar;
    caxis(handles.ETOPOLIM);
    hold on;

    freezeColors();

    % Store ap on the handles object
    handles.plots.(tag) = ap;

    h = handles;
end

function h = select_flowline(fname,handles)
    handles.fname = fname;
    flow = handles.flow(fname);
    seg_id = flow.seg_id;
    handles.seg_id = seg_id;
    nminlat = min(flow.lat) - 1;
    nmaxlat = max(flow.lat) + 1;
    nminlon = min(flow.lon) - 1;
    nmaxlon = max(flow.lon) + 1;

    set(handles.edit_minlat,'String',nminlat);
    set(handles.edit_maxlat,'String',nmaxlat);
    set(handles.edit_minlon,'String',nminlon);
    set(handles.edit_maxlon,'String',nmaxlon);

    latlim = [nminlat nmaxlat];
    lonlim = [nminlon nmaxlon];

    handles = draw_map(latlim,lonlim,handles);
    handles = plot_segments(handles);
    handles = plot_flowline(fname,handles);
    handles = plot_picks(handles);

    h = handles;
end

function h = highlight_picks(picks,handles)
    ax = gca;
    tag = ax.Tag;
    % axes plots
    ap = handles.plots.(tag);

    if(isfield(ap,'picks_highlight'))
        delete(ap.picks_highlight);
        ap = rmfield(ap,'picks_highlight');
    end

    ap.picks_highlight = plotm(handles.picks.plat(picks),handles.picks.plon(picks),'ro','MarkerSize',10,'MarkerFaceColor','red');
    hold on;
    handles.plots.(tag) = ap;
    h = handles;
end

function h = zoom_region(latlim,lonlim,handles)
  axes(handles.axes_right);
  handles = draw_map(latlim,lonlim,handles);
  handles = plot_picks(handles);

  handles = plot_flowline(handles.fname,handles);

  handles = plot_segments(handles);
  h = handles;
end

function h = plot_picks(handles)
  ax = gca;
  tag = ax.Tag;
  latlim = handles.plots.(tag).latlim;
  lonlim = handles.plots.(tag).lonlim;

  plat = handles.picks.plat;
  plon = handles.picks.plon;
  page_ck = handles.picks.page_ck;

  indices = find(plat < latlim(2) & plat > latlim(1) & plon < lonlim(2) & plon > lonlim(1));

  % axes plots
  ap = handles.plots.(tag);
  if isfield(ap,'picks')
      delete(ap.picks);
      ap = rmfield(ap,'picks');
  end
  if isfield(ap,'picks_whte')
      delete(ap.picks_whte);
      ap = rmfield(ap,'picks_whte');
  end

  ap.picks = scatterm(plat(indices),plon(indices),100,page_ck(indices),'diamond','MarkerFaceColor','flat','MarkerEdgeColor','flat');
  hold on;
  ap.picks_whte = scatterm(plat(indices),plon(indices),40,'wd');
  hold on;

  colormap(ax,'jet');
  colorbar;
  caxis(handles.AGELIM);
  hold on;

  handles.plots.(tag) = ap;

  h = handles;
end

function h = plot_segments(handles)
    ax = gca;
    tag = ax.Tag;

    % axes plots
    ap = handles.plots.(tag);
    if(isfield(ap,'segments'))
      delete(ap.segments);
      ap = rmfield(ap,'segments');
    end
    lat1 = handles.segments.lat1;
    lon1 = handles.segments.lon1;
    lat2 = handles.segments.lat2;
    lon2 = handles.segments.lon2;


    % Include in h only indices of segments whose start and ends points are
    % both within the viewing window
    indices = find(max([lat1 lat2],[],2)>=ap.latlim(1) & min([lat1 lat2],[],2)<=ap.latlim(2) & max([lon1 lon2],[],2)>=ap.lonlim(1) & min([lon1 lon2],[],2)<=ap.lonlim(2));
    lat1=lat1(indices);
    lat2=lat2(indices);
    lon1=lon1(indices);
    lon2=lon2(indices);
    for i = 1:length(lat1)
        ap.segments = plotm([lat1(i) lat2(i)],[lon1(i) lon2(i)],'r-','linewidth',4);
        hold on;
    end

    handles.plots.(tag) = ap;

    h= handles;
end

function h = plot_flowline(fname,handles)
    ax = gca;
    tag = ax.Tag;

    % axes plots
    ap = handles.plots.(tag);
    if(isfield(ap,fname))
        delete(ap.(fname));
        ap = rmfield(ap,fname);
    end

    flow = handles.flow(fname);
    ap.(fname) = plotm(flow.lat,flow.lon,'o','color',[0,0.5,1]);
    hold on;

    handles.plots.(tag) = ap;

    h = handles;
end

function edit_minlat_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_minlat (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit_minlat as text
    %        str2double(get(hObject,'String')) returns contents of edit_minlat as a double
end

% --- Executes during object creation, after setting all properties.
function edit_minlat_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_minlat (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function edit_maxlat_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_maxlat (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit_maxlat as text
    %        str2double(get(hObject,'String')) returns contents of edit_maxlat as a double
end

% --- Executes during object creation, after setting all properties.
function edit_maxlat_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_maxlat (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function edit_minlon_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_minlon (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit_minlon as text
    %        str2double(get(hObject,'String')) returns contents of edit_minlon as a double
end

% --- Executes during object creation, after setting all properties.
function edit_minlon_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_minlon (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function edit_maxlon_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_maxlon (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit_maxlon as text
    %        str2double(get(hObject,'String')) returns contents of edit_maxlon as a double
end

% --- Executes during object creation, after setting all properties.
function edit_maxlon_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_maxlon (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in pushbutton_scope_ok.
function pushbutton_scope_ok_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_scope_ok (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    minlat = str2double(get(handles.edit_minlat,'String'));
    maxlat = str2double(get(handles.edit_maxlat,'String'));
    minlon = str2double(get(handles.edit_minlon,'String'));
    maxlon = str2double(get(handles.edit_maxlon,'String'));

    % Draw map, plot picks
    handles = draw_map([minlat maxlat],[minlon maxlon],handles);
    handles = plot_picks(handles);

    guidata(hObject,handles);
end

% --- Executes on button press in pushbutton_choose_file.
function pushbutton_choose_file_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_choose_file (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [name,folder] = uigetfile('*.segment');
    filename = fullfile(folder,name);
    set(handles.edit_segment_file,'String',filename);
    guidata(hObject,handles);
end


function edit_segment_file_Callback(hObject, eventdata, handles)
    % hObject    handle to edit_segment_file (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit_segment_file as text
    %        str2double(get(hObject,'String')) returns contents of edit_segment_file as a double
end

% --- Executes during object creation, after setting all properties.
function edit_segment_file_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit_segment_file (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in pushbutton_flowfile_ok.
function pushbutton_flowfile_ok_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton_flowfile_ok (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    filename = get(handles.edit_segment_file,'String');
    fid = fopen(filename,'r');
    % First header line
    fgetl(fid);
    % {seg_id boundary}
    seg_info = textscan(fid,'%d %s');
    seg_id = seg_info{1};
    % Second header line
    fgetl(fid);
    % {pid plat plon page_ck ridge_side}
    picks_info = textscan(fid,'%d %f %f %f %s');
    picks = struct();
    picks.pid = picks_info{:,1};
    picks.plat = picks_info{:,2};
    picks.plon = picks_info{:,3};
    picks.page_ck = picks_info{:,4};
    picks.ridge_side = picks_info{:,5};
    handles.picks = picks;
    fclose(fid);
    fname = flowline_for(seg_id,handles);
    handles = select_flowline(fname,handles);
    guidata(hObject,handles);
end


function pushbutton_select_chron_Callback(hObject, eventdata, handles)
    fname = handles.fname;
    xflow = handles.flow(fname);
    seg_id = xflow.seg_id;
    [mlat mlon] = inputm(1);
    % Get id of closest pick
    pid = closest_pick(mlat,mlon,handles);

    set(handles.edit_chron,'String',handles.picks.page_ck(pid));
    set(handles.edit_ridge_side,'String',handles.picks.ridge_side(pid));

    guidata(hObject,handles);
end

function edit_chron_Callback(hObject, eventdata, handles)
end

function edit_chron_CreateFcn(hObject, eventdata, handles)

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function pushbutton_select_chron_ok_Callback(hObject, eventdata, handles)
    picks = handles.picks;
    chron = str2double(get(handles.edit_chron,'String'));
    ridge_side = get(handles.edit_ridge_side,'String');
    handles.picks.selected = intersect(find(picks.page_ck == chron),find(strcmp(picks.ridge_side,ridge_side)));
    handles = highlight_picks(handles.picks.selected,handles);


    nminlat = min(handles.picks.plat(handles.picks.selected)) - 0.1;
    nmaxlat = max(handles.picks.plat(handles.picks.selected)) + 0.1;
    nminlon = min(handles.picks.plon(handles.picks.selected)) - 0.1;
    nmaxlon = max(handles.picks.plon(handles.picks.selected)) + 0.1;

    handles = zoom_region([nminlat nmaxlat],[nminlon nmaxlon],handles);

    guidata(hObject,handles);
end


function edit_ridge_side_Callback(hObject, eventdata, handles)
end

function edit_ridge_side_CreateFcn(hObject, eventdata, handles)

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
