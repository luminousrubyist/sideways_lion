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

    % Last Modified by GUIDE v2.5 30-Aug-2017 14:23:20

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
end
