function varargout = smr_gui(varargin)
% SMR_GUI MATLAB code for smr_gui.fig
%      SMR_GUI, by itself, creates a new SMR_GUI or raises the existing
%      singleton*.
%
%      H = SMR_GUI returns the handle to a new SMR_GUI or the handle to
%      the existing singleton*.
%
%      SMR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SMR_GUI.M with the given input arguments.
%
%      SMR_GUI('Property','Value',...) creates a new SMR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before smr_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to smr_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help smr_gui

% Last Modified by GUIDE v2.5 12-Sep-2019 10:41:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @smr_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @smr_gui_OutputFcn, ...
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


% --- Executes just before smr_gui is made visible.
function smr_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to smr_gui (see VARARGIN)

% Choose default command line output for smr_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes smr_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
system_names = get_system_names();

% update system names
set(handles.system_name_dropdown, 'String', system_names);

% update sheet name options
system_number = handles.system_name_dropdown.Value;
system_names = get_system_names();
system_name = system_names{system_number};
sheet_names = get_sheet_names(system_name);
set(handles.sheet_names_dropdown, 'String', sheet_names);
set(handles.sheet_names_dropdown, 'Value', 1);

% --- Outputs from this function are returned to the command line.
function varargout = smr_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ANALYZE_ALL_DATA.
function ANALYZE_ALL_DATA_Callback(hObject, eventdata, handles)
% hObject    handle to ANALYZE_ALL_DATA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system_number = handles.system_name_dropdown.Value;
system_names = get_system_names();
system_name = system_names{system_number};

sheet_names = get_sheet_names(system_name);
sheet_number = handles.sheet_names_dropdown.Value;
sheet_name = sheet_names{sheet_number};

SETTINGS = struct(...
    'system', system_name, ...
    'sheet', sheet_name, ...
    'reprocess_apply_calibration', handles.OVERWRITE_CALIBRATION.Value ...
);

detect_calibration_peaks(SETTINGS);
batch_process_google_spreadsheet(SETTINGS);


% --- Executes on selection change in system_name_dropdown.
function system_name_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to system_name_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns system_name_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from system_name_dropdown
% system_name = handles.
system_number = handles.system_name_dropdown.Value;
system_names = get_system_names();
system_name = system_names{system_number};
sheet_names = get_sheet_names(system_name);
set(handles.sheet_names_dropdown, 'String', sheet_names);
set(handles.sheet_names_dropdown, 'Value', 1);

% --- Executes during object creation, after setting all properties.
function system_name_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to system_name_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sheet_names_dropdown.
function sheet_names_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to sheet_names_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sheet_names_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sheet_names_dropdown


% --- Executes during object creation, after setting all properties.
function sheet_names_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sheet_names_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text2.
function text2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in OVERWRITE_CALIBRATION.
function OVERWRITE_CALIBRATION_Callback(hObject, eventdata, handles)
% hObject    handle to OVERWRITE_CALIBRATION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OVERWRITE_CALIBRATION
