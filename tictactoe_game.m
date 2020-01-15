function varargout = tictactoe_game(varargin)
% Это основное поле для игры, тут реализуется обработка нажатий на поля (
% каждое поле - это по сути поле для графиков, где отображается необходимая
% картинка: пустая, крестик или нолик. Логику вывода реализуют функции в
% коде ниже. Можно начать игру заново, ведется счет побед, можно вывести
% результат в текстовый файл и вернуться в главное меню для выбора другого
% режима.

    % TICTACTOE_GAME MATLAB code for tictactoe_game.fig
    %      TICTACTOE_GAME, by itself, creates a new TICTACTOE_GAME or raises the existing
    %      singleton*.
    %
    %      H = TICTACTOE_GAME returns the handle to a new TICTACTOE_GAME or the handle to
    %      the existing singleton*.
    %
    %      TICTACTOE_GAME('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in TICTACTOE_GAME.M with the given input arguments.
    %
    %      TICTACTOE_GAME('Property','Value',...) creates a new TICTACTOE_GAME or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before tictactoe_game_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to tictactoe_game_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help tictactoe_game

    % Last Modified by GUIDE v2.5 09-Jan-2020 17:43:34

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @tictactoe_game_OpeningFcn, ...
                       'gui_OutputFcn',  @tictactoe_game_OutputFcn, ...
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

function axesObj = getAxes(axesNum,handles)
% Эта функция возвращает нужную переменную с полем для картинки, всего их 9, т.к игра
% 3х3.  Затем с этой переменной выполняются обращения к другим функциям.
    switch axesNum
        case 1
            axesObj = handles.axes1;
        case 2
            axesObj = handles.axes2;
        case 3
            axesObj = handles.axes3;
        case 4
            axesObj = handles.axes4;
        case 5
            axesObj = handles.axes5;
        case 6
            axesObj = handles.axes6;
        case 7
            axesObj = handles.axes7;
        case 8
            axesObj = handles.axes8;
        case 9
            axesObj = handles.axes9;
        otherwise
            axesObj = handles.axes1;
    end
end

function showImg(imgName,axesObj,handFig1,axesNum)
% Данная функция выводит заданную в переменной imgName картинку в нужное
% поле, которое получено из функции выше.
% Всего 3 картинки: empty.png - белое поле, zero.png - нолики, tic.png -
% крестики
    questImgMap(256,:) = get(handFig1, 'Color');
    img = imread(imgName);
    img = image(img, 'Parent', axesObj);
    axesObj.Children.ButtonDownFcn = @(hObject,eventdata)tictactoe_game('axes_ButtonDownFcn',hObject,eventdata,guidata(hObject),axesObj,axesNum);
    set(handFig1, 'Colormap', questImgMap);
    set(axesObj, ...
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(img,'XData'), ...
    'YLim'   , get(img,'YData')  ...
    );
end

function [X,Y] = searchIdx(moveIdx, fieldMtx, idxs,handles)
% Вспомогательная функция, которая ищет пустое поле ( в котором еще нет
% крестика либо нолика) и возвращается его индекс ( х - строка, у -
% столбец). Все индексы хранятся в переменной idxs, которая описана ниже.
    X = [];
    Y = [];
    for jj = 1:3
        x = idxs{moveIdx,jj}{1};
        y = idxs{moveIdx,jj}{2};
        if fieldMtx(x,y) == 0
            X = [X x];
            Y = [Y y];
        end
    end
    if ~isempty(X) && sum(abs(handles.Parameters.isChecked)) == 0 % если первый ход, то выбираем наугад
        r = randi(length(X));
        X = X(r);
        Y = Y(r);
    elseif ~isempty(X) % выбираем первое пустое поле в подходящей линии
        X = X(1); % можно было бы анализировать несколько и искать пустое поле на пересечении ( но тогда опять же неинтересно играть)
        Y = Y(1);
    else
        X = 0;
        Y = 0;
    end
end

function [isWin, moveIdx] = checkWin(fieldMtx,idxs,handles,fromMove)
% Функция проверяет поле для игры и констатирует победу, если есть 3 в
% линию. Ничью - если всё поле занято, но победа не достигнута. Выбирает
% поле для хода компьютера, если режим 1 игрока. Выбор производится по
% методу минимакса. Вычисляется максимум пользы для компьютера и минимум
% для игрока. В приоритете не дать игроку выиграть. Но случаются ситуации,
% когда суммы по отдельным полям равны, тогда выбирается первое из них (
% тут можно обыграть компьютер). Если учесть и это, то играть будет не
% интересно, т.к компьютер будет всегда выигрывать. 
    isWin = false; % достигнута ли победа
    moveIdx = 0; % линия в которой надо сделать ход
    sumMtx = zeros(1,8); % матрица сумм по линиям ( описано в idxs)
    for ii = 1:8 % цикл по всем линиям из idxs
        tmpSum = 0;
        for jj = 1:3 % по всем полям в линии
            x = idxs{ii,jj}{1};
            y = idxs{ii,jj}{2};
            tmpSum = tmpSum + fieldMtx(x,y); % считается сумма значений полей( 1 для крест, -1 для ноликов)
        end
        sumMtx(ii) = tmpSum; % и сохраняется в переменную sumMtx 
    end
    [maxSum, maxIdx] = max(sumMtx); % находится минимум из всех сумм
    [minSum, minIdx] = min(sumMtx); % и максимум + их позиции данной переменной
    if (abs(maxSum) == 3 || abs(minSum) == 3) % если 3 - то один из игроков выиграл
        handles.Parameters.isWin = true; % констатируется победа
        isWin = true;
        if mod(handles.Parameters.counter,2) == 0 % если на четном ходе
           
            if handles.Parameters.firstMove == 0 % и игрок был ноликами, то выиграл игрок 1
               % увеличиваем количество побед на 1 и дальше выводим
               % информацию в поля формы
               handles.Parameters.pl1Wins = handles.Parameters.pl1Wins + 1; 
               handles.text3.String{1} = [handles.Parameters.pl1Name,': ',num2str(handles.Parameters.pl1Wins)];
               handles.text2.String{1} = ['Pobedil ',handles.Parameters.pl1Name,'!'];
            else % иначе игрок 2 и аналогично
               handles.Parameters.pl2Wins = handles.Parameters.pl2Wins + 1;
               handles.text4.String{1} = [handles.Parameters.pl2Name,': ',num2str(handles.Parameters.pl2Wins)];
               handles.text2.String{1} = ['Pobedil ',handles.Parameters.pl2Name,'!'];
            end
        else % то же самое если был нечетный счетчик
            if handles.Parameters.firstMove == 1
               handles.Parameters.pl1Wins = handles.Parameters.pl1Wins + 1;
               handles.text3.String{1} = [handles.Parameters.pl1Name,': ',num2str(handles.Parameters.pl1Wins)];
               handles.text2.String{1} = ['Pobedil ',handles.Parameters.pl1Name,'!'];
            else
               handles.Parameters.pl2Wins = handles.Parameters.pl2Wins + 1;
               handles.text4.String{1} = [handles.Parameters.pl2Name,': ',num2str(handles.Parameters.pl2Wins)];
               handles.text2.String{1} = ['Pobedil ',handles.Parameters.pl2Name,'!'];
            end
        end

        % надо отключить возможность менять поля, поэтому ставим значения 2
        % ( лишь бы не 0)
        for ii = 1:9
            handles.Parameters.isChecked(ii) = 2;
        end
        % Update handles structure
        guidata(handles.figure1, handles);
    elseif sum(abs(handles.Parameters.isChecked)) == 9 % если не победа, 
        % то проверяем заняты ли все поля - тогда ничья
        handles.text2.String{1} = 'Pobedila druzhba!';
        handles.Parameters.isWin = true; % констатируем конец игры
        isWin = true;
        % Update handles structure
        guidata(handles.figure1, handles);
    elseif fromMove == false % иначе делаем ход компьютером, если вызов проверки не вызван
        % одной из функций, которая делает ход компьютера ( для этого флаг
        % fromNode)
        if sum(abs(handles.Parameters.isChecked)) == 0 % если компьютер ходит первый
            moveIdx = randi(8); % то ходим наугад, для интереса
        else
            if abs(maxSum) > abs(minSum) % если у игрока уже 2 подряд, то надо помешать ему
                moveIdx = maxIdx;
                while sum(handles.Parameters.usedIdx == moveIdx) ~= 0
                    % ищем в цикле, пока не найдется свободное поле
                    sumMtx(moveIdx) = -10; % выставляем заведомо неподходящее значение в сумму, чтобы не брать его
                    [~, moveIdx] = max(sumMtx);
                end
            else
                moveIdx = minIdx; % иначе надо максимально улучшить свою позицию, ищем пустое поле,
                % которое позволит это сделать лучше всего
                while sum(handles.Parameters.usedIdx == moveIdx) ~= 0
                    sumMtx(moveIdx) = 10;
                    [~, moveIdx] = min(sumMtx);
                end
            end
        end
        
    end
end

function makeMove(handles, idxs, eventdata)
% функция, которая непосредственно "делает ход", т.е меняет поле с
% индексами, полученными из функции выше
    moveX = 0; % изначально пишем нули
    moveY = 0;
    fieldMtx = reshape(handles.Parameters.isChecked, [3,3]).'; % превращаем строку 1х9 в поле 3х3 для удобства обработки
    if mod(handles.Parameters.counter,2) == handles.Parameters.firstMove
        fieldMtx = -fieldMtx; % если первым ходил игрок, то инвертируем поле, чтобы не помогать ему :))
    end
    
    while moveX+moveY == 0 && handles.Parameters.isWin == false % в цикле пока не найдем нужное для хода поле
        [handles.Parameters.isWin, moveIdx] = checkWin(fieldMtx,idxs,handles,false); % запускаем функцию выше для проверки победы и тд
        [moveX,moveY] = searchIdx(moveIdx, fieldMtx, idxs,handles); % из функции выше берем нужные индексы
        if moveX + moveY == 0 % обновляем уже полностью заполненные линии
            handles.Parameters.usedIdx = [handles.Parameters.usedIdx moveIdx];
        end
    end
    if handles.Parameters.isWin == false % если еще не победа ( иначе бесмысленно)
        delay = randi(handles.Parameters.maxDelay)-1; % имитируем задержку, как бы компьютер думает
        if delay >= 1 % задержка случайная от 0 до maxDelay-1
            uiwait(handles.figure1,delay);
        end
        % делаем ход
        axesNum = (moveX-1)*3 + moveY; % превращаем индекс из поля в линейный( напр, (2,2) -> 5)
        axesObj = getAxes(axesNum,handles); % картинка, поле, которое надо поменять по данному индексу
        if mod(handles.Parameters.counter,2) == 0 % делаем ход ( заносим в поле значение и обновляем картинку)
            handles.Parameters.isChecked(axesNum) = -1;
            showImg('zero.png',axesObj,handles.figure1,axesNum); % ноликом
        else
            handles.Parameters.isChecked(axesNum) = 1;
            showImg('tic.png',axesObj,handles.figure1,axesNum); % или крестиком
        end
        % Update handles structure
        guidata(handles.figure1, handles); % обновляем структуру
        fieldMtx = reshape(handles.Parameters.isChecked, [3,3]).'; % проверяем не достигнута ли победа
        [handles.Parameters.isWin, ~] = checkWin(fieldMtx,idxs,handles,true); % после хода
        if handles.Parameters.isWin == false % если нет, то передаем в "движок"
            gameEngine(handles.figure1,handles,true);
        else
            uiwait(handles.figure1); % если да, то ждем дейтсвий игрока
        end
    end
end

function gameEngine(hObject,handles,fromMove)
% Функция - "движок игры". Меняет значения счетчика - очередность ходов и
% делает проверки на победу, вызывает необходимые функции.
    fieldMtx = reshape(handles.Parameters.isChecked, [3,3]).';
    idxs = {... % индексы линий по которым считаются суммы и может быть выигрышь
    {1,3} {2,2} {3,1}; % побочная диагональ
    {1,1} {2,1} {3,1}; % 1 столбец поля
    {1,2} {2,2} {3,2}; % 2 столбец
    {1,3} {2,3} {3,3}; % 3 столбец
    {1,1} {2,2} {3,3}; % главная диагональ
    {3,1} {3,2} {3,3}; % 3 строка
    {2,1} {2,2} {2,3}; % 2 строка
    {1,1} {1,2} {1,3}}; % 1 строка
    [handles.Parameters.isWin, ~] = checkWin(fieldMtx,idxs,handles,true); % проверка победы/ничьи
    if handles.Parameters.isWin == false % если нет, то
        if handles.Parameters.isFirst == false
            handles.Parameters.counter = handles.Parameters.counter + 1; % передаем ход
        end
        handles.Parameters.isFirst = false;
        if mod(handles.Parameters.counter,2) == handles.Parameters.firstMove
            handles.text2.String{1} = handles.Parameters.textPl1; % выводим на экран, кто сейчас ходит
        else
            handles.text2.String{1} = handles.Parameters.textPl2; % второй игрок или первый
        end
        % Update handles structure
        guidata(hObject, handles);

        if (mod(handles.Parameters.counter,2) ~= handles.Parameters.firstMove &&...
                handles.Parameters.playersNum == 1 && fromMove == false)

           makeMove(handles,idxs,0); % если режим с 1 игроком и движок вызван не с функции хода
           % и сейчас не ход самого игрока, то вызываем ход компьютера
        end
    else
        uiwait(handles.figure1); % если конец игры, то ожидаем действий пользователя
    end
end

% --- Executes just before tictactoe_game is made visible.
% Функция выполняется при открытии формы с игрой, инициализируются
% переменные, полученные из предыдущих форм и осуществляется начальная
% подготовка поля к игре.
function tictactoe_game_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to tictactoe_game (see VARARGIN)

    % Choose default command line output for tictactoe_game
    handles.output = hObject;
    
    % Determine the position of the dialog - centered on the callback figure
    % if available, else, centered on the screen
    % по центру экрана выводим, также как и в предыдущих
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
    
    d_x = 1; % для всех 9 полей надо сначала поставить белые картинки
    d_y = 1;
    for ii = 1:9
        axesObj = getAxes(ii,handles);
        %set(axesObj,'ActivePositionProperty','outerposition');
        set(axesObj,'Position',[0.2+(d_x-1)*0.15 0.63-(d_y-1)*0.15 0.14 0.14]); % тут задаем координаты полей
        % чтобы было симметрично и красиво
        d_x = d_x + 1;
        if d_x > 3
            d_x = 1;
            d_y = d_y + 1;
        end
        showImg('empty.png',axesObj,handles.figure1,ii); % выводим пустое поле
    end
    set(handles.pushbutton1,'Position',[20 6 20 2]); % координаты кнопок задаем
    set(handles.pushbutton2,'Position',[42 6 14 2]); % слева направо 1 и 2:
    set(handles.pushbutton4,'Position',[60 6 14 2]); % координаты левого угла, 3 и 4 - размеры
    
    % Update handles structure
    guidata(hObject, handles);
    % Make the GUI modal
    %set(handles.figure1,'WindowStyle','modal')
    
    if size(varargin) > 0 % если на вход пришла структура, то обрабатываем данные с нее
        % и выводим в соответствующие поля
        handles.Parameters = varargin{1};
        if handles.Parameters.playersNum == 2 % текстовые формы
            handles.Parameters.textPl1 = ['Seichas hodit ',handles.Parameters.pl1Name,'!'];
            handles.Parameters.textPl2 = ['Seichas hodit ',handles.Parameters.pl2Name,'!'];
        else
            handles.Parameters.textPl1 = ['Seichas hodit ',handles.Parameters.pl1Name,'!'];
            handles.Parameters.textPl2 = 'Seichas hodit velikiy i uzhasniy iskusstvenniy intellekt!';
        end
        if handles.Parameters.playerOneCh == 'x' % если игрок выбрал крестики, то сохраняем единицу
            handles.Parameters.firstMove = 1;
            handles.text2.String{1} = handles.Parameters.textPl1;
        else
            handles.Parameters.firstMove = 0; % иначе 0 ( используется в "движке")
            handles.text2.String{1} = handles.Parameters.textPl2;
        end
        % выводим начальное количество побед
        handles.text3.String{1} = [handles.Parameters.pl1Name,': ',num2str(handles.Parameters.pl1Wins)];
        handles.text4.String{1} = [handles.Parameters.pl2Name,': ',num2str(handles.Parameters.pl2Wins)];
        % Update handles structure
        guidata(hObject, handles);
        % если игрок выбрал нолики и первым ходит комп, то вызываем функцию
        % для хода
        if (handles.Parameters.counter ~= handles.Parameters.firstMove &&...
            handles.Parameters.playersNum == 1)
            handles.Parameters.isFirst = true;
            gameEngine(handles.figure1,handles,false);
        end
    end

    % UIWAIT makes tictactoe_game wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = tictactoe_game_OutputFcn(hObject, eventdata, handles) 
% выход, нам не нужен
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% обработка кнопки сохранения в файл. Сохраняет количество побед и текущую
% дату с матлаба в файл
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.figure1);
    fid = fopen('tictoe_output.txt', 'a+'); % открыли файл для записи
    t = clock;
    if t(5) < 10 % если минуты меньше 10, то надо добавить 0 в начале
        minutes = ['0',num2str(t(5))];
    else
        minutes = num2str(t(5));
    end
    % т(4) это часы
    fprintf(fid, '%s', [date,' ',num2str(t(4)),':',minutes,' -> ',handles.Parameters.pl1Name,': ',num2str(handles.Parameters.pl1Wins),'  ']);
    fprintf(fid, '%s\n', [handles.Parameters.pl2Name,': ',num2str(handles.Parameters.pl2Wins),'  ']);
    fclose(fid);
    type('tictoe_output.txt'); 
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% функция возвращает переменные  и поле к исходному состоянию ( считываем с
% файла .ini) и вызываем функцию при открытии данной формы
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
%     for ii = 1:9
%         axesObj = getAxes(ii,handles);
%         showImg('empty.png',axesObj,handles.figure1);
%     end
    uiresume(handles.figure1); % если отправили форму в ожидание после победы или ничьи
    handles.Parameters.inifile = fopen(handles.Parameters.inifilename);
    while ~feof(handles.Parameters.inifile) % аналогично new_game , считываем параметры с .ini
        fline = fgetl(handles.Parameters.inifile);
        if (strfind(fline,'counter = '))
            handles.Parameters.counter = str2num(fline(strfind(fline,'counter = ')+10:end));
        end
        if (strfind(fline,'isChecked = '))
            handles.Parameters.isChecked = str2num(fline(strfind(fline,'isChecked = ')+12:end));
        end
        if (strfind(fline,'isFirst = '))
            handles.Parameters.isFirst = str2num(fline(strfind(fline,'isFirst = ')+10:end));
        end
        if (strfind(fline,'isWin = '))
            handles.Parameters.isWin = str2num(fline(strfind(fline,'isWin = ')+8:end));
        end
        if (strfind(fline,'usedIdx = '))
            handles.Parameters.usedIdx = str2num(fline(strfind(fline,'usedIdx = ')+10:end));
        end
        if (strfind(fline,'maxDelay = '))
            handles.Parameters.maxDelay = str2num(fline(strfind(fline,'maxDelay = ')+11:end));
        end
    end
    % Update handles structure
    guidata(handles.figure1, handles);
    tictactoe_game_OpeningFcn(handles.figure1, eventdata, handles, handles.Parameters); % вызываем функцию при открытии
end

% --- Executes on mouse press over axes background.
function axes_ButtonDownFcn(hObject, eventdata, handles,axesObj,axesNum)
    % Функция обрабатывает нажатие на одно из полей, когда ходит игрок и
    % выводит необходимую картинку + обновляет переменные
    % hObject    handle to axes1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if handles.Parameters.isChecked(axesNum) == 0 &&...
            (mod(handles.Parameters.counter,2) == handles.Parameters.firstMove ||...
            handles.Parameters.playersNum == 2)
        % если поле еще не выбрано, ходит игрок а не компьютер либо режим 2
        % игроков
        if mod(handles.Parameters.counter,2) == 0 % если ход ноликов
           showImg('zero.png',axesObj,handles.figure1,axesNum); % выводим нолик
           handles.Parameters.isChecked(axesNum) = -1; % сохраняем в поле -1
        else
           showImg('tic.png',axesObj,handles.figure1,axesNum); % иначе крестик и 1
           handles.Parameters.isChecked(axesNum) = 1;
        end
        gameEngine(handles.figure1,handles,false); % вызываем движок
    end
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% кнопка для возврата в главное меню
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_game(); % вызываем главное меню
delete(handles.figure1); % удалаяем текущее окно
end
