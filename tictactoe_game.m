function varargout = tictactoe_game(varargin)
% ��� �������� ���� ��� ����, ��� ����������� ��������� ������� �� ���� (
% ������ ���� - ��� �� ���� ���� ��� ��������, ��� ������������ �����������
% ��������: ������, ������� ��� �����. ������ ������ ��������� ������� �
% ���� ����. ����� ������ ���� ������, ������� ���� �����, ����� �������
% ��������� � ��������� ���� � ��������� � ������� ���� ��� ������ �������
% ������.

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
% ��� ������� ���������� ������ ���������� � ����� ��� ��������, ����� �� 9, �.� ����
% 3�3.  ����� � ���� ���������� ����������� ��������� � ������ ��������.
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
% ������ ������� ������� �������� � ���������� imgName �������� � ������
% ����, ������� �������� �� ������� ����.
% ����� 3 ��������: empty.png - ����� ����, zero.png - ������, tic.png -
% ��������
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
% ��������������� �������, ������� ���� ������ ���� ( � ������� ��� ���
% �������� ���� ������) � ������������ ��� ������ ( � - ������, � -
% �������). ��� ������� �������� � ���������� idxs, ������� ������� ����.
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
    if ~isempty(X) && sum(abs(handles.Parameters.isChecked)) == 0 % ���� ������ ���, �� �������� ������
        r = randi(length(X));
        X = X(r);
        Y = Y(r);
    elseif ~isempty(X) % �������� ������ ������ ���� � ���������� �����
        X = X(1); % ����� ���� �� ������������� ��������� � ������ ������ ���� �� ����������� ( �� ����� ����� �� ����������� ������)
        Y = Y(1);
    else
        X = 0;
        Y = 0;
    end
end

function [isWin, moveIdx] = checkWin(fieldMtx,idxs,handles,fromMove)
% ������� ��������� ���� ��� ���� � ������������ ������, ���� ���� 3 �
% �����. ����� - ���� �� ���� ������, �� ������ �� ����������. ��������
% ���� ��� ���� ����������, ���� ����� 1 ������. ����� ������������ ��
% ������ ���������. ����������� �������� ������ ��� ���������� � �������
% ��� ������. � ���������� �� ���� ������ ��������. �� ��������� ��������,
% ����� ����� �� ��������� ����� �����, ����� ���������� ������ �� ��� (
% ��� ����� �������� ���������). ���� ������ � ���, �� ������ ����� ��
% ���������, �.� ��������� ����� ������ ����������. 
    isWin = false; % ���������� �� ������
    moveIdx = 0; % ����� � ������� ���� ������� ���
    sumMtx = zeros(1,8); % ������� ���� �� ������ ( ������� � idxs)
    for ii = 1:8 % ���� �� ���� ������ �� idxs
        tmpSum = 0;
        for jj = 1:3 % �� ���� ����� � �����
            x = idxs{ii,jj}{1};
            y = idxs{ii,jj}{2};
            tmpSum = tmpSum + fieldMtx(x,y); % ��������� ����� �������� �����( 1 ��� �����, -1 ��� �������)
        end
        sumMtx(ii) = tmpSum; % � ����������� � ���������� sumMtx 
    end
    [maxSum, maxIdx] = max(sumMtx); % ��������� ������� �� ���� ����
    [minSum, minIdx] = min(sumMtx); % � �������� + �� ������� ������ ����������
    if (abs(maxSum) == 3 || abs(minSum) == 3) % ���� 3 - �� ���� �� ������� �������
        handles.Parameters.isWin = true; % �������������� ������
        isWin = true;
        if mod(handles.Parameters.counter,2) == 0 % ���� �� ������ ����
           
            if handles.Parameters.firstMove == 0 % � ����� ��� ��������, �� ������� ����� 1
               % ����������� ���������� ����� �� 1 � ������ �������
               % ���������� � ���� �����
               handles.Parameters.pl1Wins = handles.Parameters.pl1Wins + 1; 
               handles.text3.String{1} = [handles.Parameters.pl1Name,': ',num2str(handles.Parameters.pl1Wins)];
               handles.text2.String{1} = ['Pobedil ',handles.Parameters.pl1Name,'!'];
            else % ����� ����� 2 � ����������
               handles.Parameters.pl2Wins = handles.Parameters.pl2Wins + 1;
               handles.text4.String{1} = [handles.Parameters.pl2Name,': ',num2str(handles.Parameters.pl2Wins)];
               handles.text2.String{1} = ['Pobedil ',handles.Parameters.pl2Name,'!'];
            end
        else % �� �� ����� ���� ��� �������� �������
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

        % ���� ��������� ����������� ������ ����, ������� ������ �������� 2
        % ( ���� �� �� 0)
        for ii = 1:9
            handles.Parameters.isChecked(ii) = 2;
        end
        % Update handles structure
        guidata(handles.figure1, handles);
    elseif sum(abs(handles.Parameters.isChecked)) == 9 % ���� �� ������, 
        % �� ��������� ������ �� ��� ���� - ����� �����
        handles.text2.String{1} = 'Pobedila druzhba!';
        handles.Parameters.isWin = true; % ������������ ����� ����
        isWin = true;
        % Update handles structure
        guidata(handles.figure1, handles);
    elseif fromMove == false % ����� ������ ��� �����������, ���� ����� �������� �� ������
        % ����� �� �������, ������� ������ ��� ���������� ( ��� ����� ����
        % fromNode)
        if sum(abs(handles.Parameters.isChecked)) == 0 % ���� ��������� ����� ������
            moveIdx = randi(8); % �� ����� ������, ��� ��������
        else
            if abs(maxSum) > abs(minSum) % ���� � ������ ��� 2 ������, �� ���� �������� ���
                moveIdx = maxIdx;
                while sum(handles.Parameters.usedIdx == moveIdx) ~= 0
                    % ���� � �����, ���� �� �������� ��������� ����
                    sumMtx(moveIdx) = -10; % ���������� �������� ������������ �������� � �����, ����� �� ����� ���
                    [~, moveIdx] = max(sumMtx);
                end
            else
                moveIdx = minIdx; % ����� ���� ����������� �������� ���� �������, ���� ������ ����,
                % ������� �������� ��� ������� ����� �����
                while sum(handles.Parameters.usedIdx == moveIdx) ~= 0
                    sumMtx(moveIdx) = 10;
                    [~, moveIdx] = min(sumMtx);
                end
            end
        end
        
    end
end

function makeMove(handles, idxs, eventdata)
% �������, ������� ��������������� "������ ���", �.� ������ ���� �
% ���������, ����������� �� ������� ����
    moveX = 0; % ���������� ����� ����
    moveY = 0;
    fieldMtx = reshape(handles.Parameters.isChecked, [3,3]).'; % ���������� ������ 1�9 � ���� 3�3 ��� �������� ���������
    if mod(handles.Parameters.counter,2) == handles.Parameters.firstMove
        fieldMtx = -fieldMtx; % ���� ������ ����� �����, �� ����������� ����, ����� �� �������� ��� :))
    end
    
    while moveX+moveY == 0 && handles.Parameters.isWin == false % � ����� ���� �� ������ ������ ��� ���� ����
        [handles.Parameters.isWin, moveIdx] = checkWin(fieldMtx,idxs,handles,false); % ��������� ������� ���� ��� �������� ������ � ��
        [moveX,moveY] = searchIdx(moveIdx, fieldMtx, idxs,handles); % �� ������� ���� ����� ������ �������
        if moveX + moveY == 0 % ��������� ��� ��������� ����������� �����
            handles.Parameters.usedIdx = [handles.Parameters.usedIdx moveIdx];
        end
    end
    if handles.Parameters.isWin == false % ���� ��� �� ������ ( ����� �����������)
        delay = randi(handles.Parameters.maxDelay)-1; % ��������� ��������, ��� �� ��������� ������
        if delay >= 1 % �������� ��������� �� 0 �� maxDelay-1
            uiwait(handles.figure1,delay);
        end
        % ������ ���
        axesNum = (moveX-1)*3 + moveY; % ���������� ������ �� ���� � ��������( ����, (2,2) -> 5)
        axesObj = getAxes(axesNum,handles); % ��������, ����, ������� ���� �������� �� ������� �������
        if mod(handles.Parameters.counter,2) == 0 % ������ ��� ( ������� � ���� �������� � ��������� ��������)
            handles.Parameters.isChecked(axesNum) = -1;
            showImg('zero.png',axesObj,handles.figure1,axesNum); % �������
        else
            handles.Parameters.isChecked(axesNum) = 1;
            showImg('tic.png',axesObj,handles.figure1,axesNum); % ��� ���������
        end
        % Update handles structure
        guidata(handles.figure1, handles); % ��������� ���������
        fieldMtx = reshape(handles.Parameters.isChecked, [3,3]).'; % ��������� �� ���������� �� ������
        [handles.Parameters.isWin, ~] = checkWin(fieldMtx,idxs,handles,true); % ����� ����
        if handles.Parameters.isWin == false % ���� ���, �� �������� � "������"
            gameEngine(handles.figure1,handles,true);
        else
            uiwait(handles.figure1); % ���� ��, �� ���� �������� ������
        end
    end
end

function gameEngine(hObject,handles,fromMove)
% ������� - "������ ����". ������ �������� �������� - ����������� ����� �
% ������ �������� �� ������, �������� ����������� �������.
    fieldMtx = reshape(handles.Parameters.isChecked, [3,3]).';
    idxs = {... % ������� ����� �� ������� ��������� ����� � ����� ���� ��������
    {1,3} {2,2} {3,1}; % �������� ���������
    {1,1} {2,1} {3,1}; % 1 ������� ����
    {1,2} {2,2} {3,2}; % 2 �������
    {1,3} {2,3} {3,3}; % 3 �������
    {1,1} {2,2} {3,3}; % ������� ���������
    {3,1} {3,2} {3,3}; % 3 ������
    {2,1} {2,2} {2,3}; % 2 ������
    {1,1} {1,2} {1,3}}; % 1 ������
    [handles.Parameters.isWin, ~] = checkWin(fieldMtx,idxs,handles,true); % �������� ������/�����
    if handles.Parameters.isWin == false % ���� ���, ��
        if handles.Parameters.isFirst == false
            handles.Parameters.counter = handles.Parameters.counter + 1; % �������� ���
        end
        handles.Parameters.isFirst = false;
        if mod(handles.Parameters.counter,2) == handles.Parameters.firstMove
            handles.text2.String{1} = handles.Parameters.textPl1; % ������� �� �����, ��� ������ �����
        else
            handles.text2.String{1} = handles.Parameters.textPl2; % ������ ����� ��� ������
        end
        % Update handles structure
        guidata(hObject, handles);

        if (mod(handles.Parameters.counter,2) ~= handles.Parameters.firstMove &&...
                handles.Parameters.playersNum == 1 && fromMove == false)

           makeMove(handles,idxs,0); % ���� ����� � 1 ������� � ������ ������ �� � ������� ����
           % � ������ �� ��� ������ ������, �� �������� ��� ����������
        end
    else
        uiwait(handles.figure1); % ���� ����� ����, �� ������� �������� ������������
    end
end

% --- Executes just before tictactoe_game is made visible.
% ������� ����������� ��� �������� ����� � �����, ����������������
% ����������, ���������� �� ���������� ���� � �������������� ���������
% ���������� ���� � ����.
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
    % �� ������ ������ �������, ����� ��� � � ����������
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
    
    d_x = 1; % ��� ���� 9 ����� ���� ������� ��������� ����� ��������
    d_y = 1;
    for ii = 1:9
        axesObj = getAxes(ii,handles);
        %set(axesObj,'ActivePositionProperty','outerposition');
        set(axesObj,'Position',[0.2+(d_x-1)*0.15 0.63-(d_y-1)*0.15 0.14 0.14]); % ��� ������ ���������� �����
        % ����� ���� ����������� � �������
        d_x = d_x + 1;
        if d_x > 3
            d_x = 1;
            d_y = d_y + 1;
        end
        showImg('empty.png',axesObj,handles.figure1,ii); % ������� ������ ����
    end
    set(handles.pushbutton1,'Position',[20 6 20 2]); % ���������� ������ ������
    set(handles.pushbutton2,'Position',[42 6 14 2]); % ����� ������� 1 � 2:
    set(handles.pushbutton4,'Position',[60 6 14 2]); % ���������� ������ ����, 3 � 4 - �������
    
    % Update handles structure
    guidata(hObject, handles);
    % Make the GUI modal
    %set(handles.figure1,'WindowStyle','modal')
    
    if size(varargin) > 0 % ���� �� ���� ������ ���������, �� ������������ ������ � ���
        % � ������� � ��������������� ����
        handles.Parameters = varargin{1};
        if handles.Parameters.playersNum == 2 % ��������� �����
            handles.Parameters.textPl1 = ['Seichas hodit ',handles.Parameters.pl1Name,'!'];
            handles.Parameters.textPl2 = ['Seichas hodit ',handles.Parameters.pl2Name,'!'];
        else
            handles.Parameters.textPl1 = ['Seichas hodit ',handles.Parameters.pl1Name,'!'];
            handles.Parameters.textPl2 = 'Seichas hodit velikiy i uzhasniy iskusstvenniy intellekt!';
        end
        if handles.Parameters.playerOneCh == 'x' % ���� ����� ������ ��������, �� ��������� �������
            handles.Parameters.firstMove = 1;
            handles.text2.String{1} = handles.Parameters.textPl1;
        else
            handles.Parameters.firstMove = 0; % ����� 0 ( ������������ � "������")
            handles.text2.String{1} = handles.Parameters.textPl2;
        end
        % ������� ��������� ���������� �����
        handles.text3.String{1} = [handles.Parameters.pl1Name,': ',num2str(handles.Parameters.pl1Wins)];
        handles.text4.String{1} = [handles.Parameters.pl2Name,': ',num2str(handles.Parameters.pl2Wins)];
        % Update handles structure
        guidata(hObject, handles);
        % ���� ����� ������ ������ � ������ ����� ����, �� �������� �������
        % ��� ����
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
% �����, ��� �� �����
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% ��������� ������ ���������� � ����. ��������� ���������� ����� � �������
% ���� � ������� � ����
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.figure1);
    fid = fopen('tictoe_output.txt', 'a+'); % ������� ���� ��� ������
    t = clock;
    if t(5) < 10 % ���� ������ ������ 10, �� ���� �������� 0 � ������
        minutes = ['0',num2str(t(5))];
    else
        minutes = num2str(t(5));
    end
    % �(4) ��� ����
    fprintf(fid, '%s', [date,' ',num2str(t(4)),':',minutes,' -> ',handles.Parameters.pl1Name,': ',num2str(handles.Parameters.pl1Wins),'  ']);
    fprintf(fid, '%s\n', [handles.Parameters.pl2Name,': ',num2str(handles.Parameters.pl2Wins),'  ']);
    fclose(fid);
    type('tictoe_output.txt'); 
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% ������� ���������� ����������  � ���� � ��������� ��������� ( ��������� �
% ����� .ini) � �������� ������� ��� �������� ������ �����
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
%     for ii = 1:9
%         axesObj = getAxes(ii,handles);
%         showImg('empty.png',axesObj,handles.figure1);
%     end
    uiresume(handles.figure1); % ���� ��������� ����� � �������� ����� ������ ��� �����
    handles.Parameters.inifile = fopen(handles.Parameters.inifilename);
    while ~feof(handles.Parameters.inifile) % ���������� new_game , ��������� ��������� � .ini
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
    tictactoe_game_OpeningFcn(handles.figure1, eventdata, handles, handles.Parameters); % �������� ������� ��� ��������
end

% --- Executes on mouse press over axes background.
function axes_ButtonDownFcn(hObject, eventdata, handles,axesObj,axesNum)
    % ������� ������������ ������� �� ���� �� �����, ����� ����� ����� �
    % ������� ����������� �������� + ��������� ����������
    % hObject    handle to axes1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if handles.Parameters.isChecked(axesNum) == 0 &&...
            (mod(handles.Parameters.counter,2) == handles.Parameters.firstMove ||...
            handles.Parameters.playersNum == 2)
        % ���� ���� ��� �� �������, ����� ����� � �� ��������� ���� ����� 2
        % �������
        if mod(handles.Parameters.counter,2) == 0 % ���� ��� �������
           showImg('zero.png',axesObj,handles.figure1,axesNum); % ������� �����
           handles.Parameters.isChecked(axesNum) = -1; % ��������� � ���� -1
        else
           showImg('tic.png',axesObj,handles.figure1,axesNum); % ����� ������� � 1
           handles.Parameters.isChecked(axesNum) = 1;
        end
        gameEngine(handles.figure1,handles,false); % �������� ������
    end
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% ������ ��� �������� � ������� ����
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_game(); % �������� ������� ����
delete(handles.figure1); % �������� ������� ����
end
