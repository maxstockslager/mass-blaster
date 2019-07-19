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

% Last Modified by GUIDE v2.5 23-May-2019 12:35:46

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


% --- Outputs from this function are returned to the command line.
function varargout = smr_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in calibration.
function calibration_Callback(hObject, eventdata, handles)
% hObject    handle to calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
detect_calibration_peaks

% --- Executes on button press in samples.
function samples_Callback(hObject, eventdata, handles)
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
batch_process_google_spreadsheet

% --- Executes on button press in checkmissing.
function checkmissing_Callback(hObject, eventdata, handles)
% hObject    handle to checkmissing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
check_for_unprocessed_files

% --- Executes on button press in processalldata.
function processalldata_Callback(hObject, eventdata, handles)
% hObject    handle to processalldata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
detect_calibration_peaks
batch_process_google_spreadsheet
check_for_unprocessed_files
