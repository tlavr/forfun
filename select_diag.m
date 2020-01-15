function varargout = select_diag(varargin)
% В данном окне можно задать имена игрока(или 2 игроков), а также выбрать
% чем играть - крестиками или ноликами. Первыми всегда ходят крестики!
% Далее вызывается основное поле для игры и туда передаются все переменные.
% SELECT_DIAG MATLAB code for select_diag.fig
%      SELECT_DIAG by itself, creates a new SELECT_DIAG or raises the
%      existing singleton*.
%
%      H = SELECT_DIAG returns the handle to a new SELECT_DIAG or the handle to
%      the existing singleton*.
%
%      SELECT_DIAG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_DIAG.M with the given input arguments.
%
%      SELECT_DIAG('Property','Value',...) creates a new SELECT_DIAG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_diag_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_diag_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_diag

% Last Modified by GUIDE v2.5 09-Jan-2020 17:15:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_diag_OpeningFcn, ...
                   'gui_OutputFcn',  @select_diag_OutputFcn, ...
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

% --- Executes just before select_diag is made visible.
function select_diag_OpeningFcn(hObject, eventdata, handles, varargin)
% Функция вызывается при открытии данной формы
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to select_diag (see VARARGIN)

% Choose default command line output for select_diag
handles.output = 'Yes';
% added code
% при условии, что на входе есть переменные, считываем их и дополняем
% структуру переменными, полученными из формы
if size(varargin) > 0
    handles.Parameters = varargin{1}; % получаем со входа структуру
    if handles.Parameters.playersNum == 1 % если один игрок
       handles.edit3.Enable = 'off'; % то отключаем второе поле для ввода имени
       handles.Parameters.pl1Name = 'Igrok 1'; % имена по умолчанию задаем
       handles.Parameters.pl2Name = 'Computer';
       % Update handles structure
       guidata(handles.figure1, handles); % обновляем структуру, чтобы она была доступна
                                          % с актуальными параметрами
    else
       handles.Parameters.pl1Name = 'Igrok 1'; % если два игрока, то имена такие
       handles.Parameters.pl2Name = 'Igrok 2';
       % Update handles structure
       guidata(handles.figure1, handles); % обновляем форму
    end
end

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3) % этот код нужен, если форма вызывается с параметрами имени, вопроса и тд
    % нами тут не используется
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
% Код ниже выводит выводит новое окно либо по центру предыдущего, либо по
% центру экрана
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
% считывается дефолтная для матлаба картинка с вопросиком
load dialogicons.mat

IconData=questIconData; % задается цвет фона
questIconMap(256,:) = get(handles.figure1, 'Color');
IconCMap=questIconMap;

Img=image(IconData, 'Parent', handles.axes1); % выводится картинка на основе axes1
set(handles.figure1, 'Colormap', IconCMap);

set(handles.axes1, ...% задаем параметры картинки
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(Img,'XData'), ...
    'YLim'   , get(Img,'YData')  ...
    );

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal') % не позволяет уйти с окна до ответа на вопрос

% UIWAIT makes select_diag wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
% вызывается при ответе на вопрос и закрытии окна, удаляем форму и вызывает
% основное поле для игры
function varargout = select_diag_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tictactoe_game(handles.Parameters);
% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.figure1);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% если выбраны крестики для игрока 1, обрабатываем кнопку
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');
handles.Parameters.playerOneCh = 'x'; % 1 игрок играет крестиками
handles.Parameters.playerTwoCh = 'o'; % второй игрок ноликами
% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% наоборот, 1 нолики, 2 крестики
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');
handles.Parameters.playerOneCh = 'o';
handles.Parameters.playerTwoCh = 'x';
% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject); % выполняет при закрытии крестиком
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over figure1 with no controls selected.
% выполняется при нажатии на Esc ( все равно, что нет)
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    



function edit1_Callback(hObject, eventdata, handles)
% поле для ввода имени, обрабатываем имя и меняем форму вопроса +
% запоминаем в структуре handles
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.Parameters.pl1Name = get(hObject,'String');
handles.text1.String = ['Пожалуйста, выберите, чем ',handles.Parameters.pl1Name,' будет играть?'];
% Update handles structure
guidata(handles.figure1, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% выполняется при создании поля для ввода, тут не нужно нам
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% поля для ввода для второго игрока
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
if handles.Parameters.playersNum == 2
    handles.Parameters.pl2Name = get(hObject,'String');
    % Update handles structure
    guidata(handles.figure1, handles);
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% аналогично при создании второго поля для ввода
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
