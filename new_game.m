function varargout = new_game(varargin)
% Инициализация интерфейса, создается автоматически при помощи guide.
% Это основное окно для начала игры, можно выбрать режим 2 игрока или 1
% игрок - игра с компьютером, который играет по минимаксу.
% NEW_GAME MATLAB code for new_game.fig
%      NEW_GAME, by itself, creates a new NEW_GAME or raises the existing
%      singleton*.
%
%      H = NEW_GAME returns the handle to a new NEW_GAME or the handle to
%      the existing singleton*.
%
%      NEW_GAME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEW_GAME.M with the given input arguments.
%
%      NEW_GAME('Property','Value',...) creates a new NEW_GAME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before new_game_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to new_game_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help new_game

% Last Modified by GUIDE v2.5 08-Jan-2020 20:20:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @new_game_OpeningFcn, ...
                   'gui_OutputFcn',  @new_game_OutputFcn, ...
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


% --- Executes just before new_game is made visible.
% Функция выполняется при открытии программы, также создана автоматически,
% но добавлен код в тело функции
function new_game_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to new_game (see VARARGIN)

% Choose default command line output for new_game
handles.output = hObject;

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

% Создание структуры с параметрами, её будем передавать при помощи 
% переменной со всеми свойствами handles
Parameters = struct();
Parameters.inifilename = 'tictoe.ini'; % файл инициализации
Parameters.inifile = fopen(Parameters.inifilename); % считываем файл инициализации
while ~feof(Parameters.inifile) % в цикле построчно читаем с файла, если находим нужный параметр,
    fline = fgetl(Parameters.inifile); % то сохраняем его в структуру
    if (strfind(fline,'playersNum = ')) % 1 игрок по умолчанию
        Parameters.playersNum = str2num(fline(strfind(fline,'playersNum = ')+13:end));
    end
    if (strfind(fline,'counter = '))
    % счетчик для контроля процесса игры(четные - ходят нолики, нечетные значения - крестики
        Parameters.counter = str2num(fline(strfind(fline,'counter = ')+10:end));
    end                              
    if (strfind(fline,'isChecked = ')) % строка 1х9, в которой хранятся ходы ( поле игры)
        Parameters.isChecked = str2num(fline(strfind(fline,'isChecked = ')+12:end));
    end
    if (strfind(fline,'isFirst = ')) 
    % переменная для контроля первого хода компьютера, чтобы не
    % увеличивался счетчик, т.к заранее инициализируется
        Parameters.isFirst = str2num(fline(strfind(fline,'isFirst = ')+10:end));
    end
    if (strfind(fline,'isWin = ')) % 1 - кто-то выиграл или ничья, 0 - игра продолжается
        Parameters.isWin = str2num(fline(strfind(fline,'isWin = ')+8:end));
    end
    if (strfind(fline,'usedIdx = ')) % полностью заполненные строки, столбцы и диагонали
        Parameters.usedIdx = str2num(fline(strfind(fline,'usedIdx = ')+10:end));
    end
    if (strfind(fline,'maxDelay = ')) % задержка для имитации того, что компьютер думает
        % (на самом деле он может не оставить игроку шансов :)) )
        Parameters.maxDelay = str2num(fline(strfind(fline,'maxDelay = ')+11:end));
    end
    if (strfind(fline,'pl1Wins = ')) % счетчик количества побед игрока 1
        Parameters.pl1Wins = str2num(fline(strfind(fline,'pl1Wins = ')+10:end));
    end
    if (strfind(fline,'pl2Wins = ')) % счетчик количества побед игрока 2
        Parameters.pl2Wins = str2num(fline(strfind(fline,'pl2Wins = ')+10:end));
    end
end
handles.Parameters = Parameters; % сохраняем структуру в handles
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes new_game wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
% Функция выполняется при завершении работы окна для передачи переменных,
% тут передаем через handles
function varargout = new_game_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton1.
% Отклик на нажатие на кнопку выбора 1, тут ничего не происходит
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
% Отклик на нажатие на кнопку выбора 2, тут ничего не происходит
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in pushbutton1.
% Обработка нажатия на кнопку Начать игру
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% The figure can be deleted now
if get(handles.radiobutton1,'Value') == 1
    handles.Parameters.playersNum = 1; % сохраняем 1 или 2 игрока выбрано
else
    handles.Parameters.playersNum = 2;
end
delete(handles.figure1); % удаляем текущее окно
select_diag(handles.Parameters); % и вызываем следующее
