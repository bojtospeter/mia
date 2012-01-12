function [Files, dirpath] = uigetfiles2(arg, filter, startpath )
% [Files, dirpath]  = uigetfiles2( arg , filter, startpath )
% displays a dialog box to select a list of files from different folders.
% The selected files can be ordered inside the listbox using '/\' and '\/' buttons.
% The output a cell array of full names of selected files or [] if Cancel pushbutton clicked.
%
% Note 1: clicking OK button with no selected file returns {''}
% Note 2!: arg='Start' 

% Feel free to modify this file according to your needs !
% Fabrice.Pabois@ncl.ac.uk - University of Newcastle - 2000

if nargin == 0 
   arg='Start';
   filter='*.*';
   startpath = pwd;
elseif nargin == 2
    startpath = pwd;
elseif nargin == 3
   arg='Start';
   filter='*.*';
end

switch arg
case 'Start'
   h=LocalInit(filter,startpath);
   waitfor(h,'Selected','on');
   data = get(h,'UserData');
   Files = data.files';
   dirpath = data.directory;
   delete(h);
   
case 'ChangeDir'
   NewPath = uigetdir;
   if ~isempty(NewPath) | NewPath ~= 0
      cd(NewPath);
      set(findobj(gcbf,'Tag','CurrDir'),'String', NewPath);
      set(findobj(gcbf,'Tag','FileListLb'),'String', GetFiles(filter), 'Value',[]);
   end
   
case 'OK'
    FileListLb = findobj(gcbf,'Tag','FileListLb');
    NewSelection = get(FileListLb,'Value');
    if ~isempty(NewSelection)
        FileList = get(FileListLb,'String');
        %data.files = cellstr(get(findobj(gcf,'Tag','SelectionLb'),'String'));
        data.files = FileList(NewSelection);
        data.directory = [ get( findobj( gcf, 'Tag', 'CurrDir' ), 'String' ) filesep ];
        set(gcbf,'Selected','On', 'UserData', data );
    end
case 'Cancel'
   data = struct ( 'files', [], 'directory', [] );
   set(gcbf,'Selected','On','UserData',data);
   
end

% -------------------------------------------------------------------------------------------------------------------
function ListNames = GetFiles(filter)
% Here you could add your filters if you want to return certain types of files
if length(filter)==0
    filter='*.*';
end
DirRes = dir( filter );
if length(DirRes)==0
    ListNames='';
    return;
end
    
% Get the files + directories names
[ListNames{1:length(DirRes),1}] = deal(DirRes.name);

% Get directories only
[DirOnly{1:length(DirRes),1}] = deal(DirRes.isdir);

% Turn into logical vector and take complement to get indexes of files
FilesOnly = ~cat(1, DirOnly{:});
ListNames = ListNames(FilesOnly);

% -------------------------------------------------------------------------------------------------------------------
function Fig=LocalInit(filter,startpath)
% Dialog box
OldUnits=get(0,'Units');
set(0,'Units','pixels');
Pos=get(0,'ScreenSize');		% Get screen dimensions to centre dialog box
set(0,'Units',OldUnits);
Fig=figure('name','Select Files','NumberTitle','off','Resize','off','CloseRequestFcn','uigetfiles2(''Cancel'');', ...
   'WindowStyle','modal','MenuBar','none','units','pixels','Position',[Pos(3)/2-250 Pos(4)/2-150 480 350], ...
   'Color',get(0,'DefaultUIControlBackgroundColor'),'Tag','uigetfiles2');

uicontrol('Parent',Fig,'Style','frame','units','pixels','Position',[5 50 570 290]);

% Current folder
uicontrol('Parent',Fig,'Style','text','units','pixels','HorizontalAlignment','left','String','Current Folder:', ...
   'Position',[20 310 150 20]);
uicontrol('Parent',Fig,'Style','edit','units','pixels','BackgroundColor',[1 1 1],'HorizontalAlignment','left', ...
   'Enable','off','String',startpath,'Position',[20 290 350 24],'Tag','CurrDir');
uicontrol('Parent',Fig,'Style','pushbutton','units','pixels','String','...','Position',[420 290 50 24], ...
   'Tag','ChangeDir','Callback',['uigetfiles2(''ChangeDir'',''' filter  ''')' ]);


% Contents of the current folder
uicontrol('Parent',Fig,'Style','text','units','pixels','HorizontalAlignment','left','String','Files:','Position',[120 250 50 20]);
uicontrol('Parent',Fig,'Style','Listbox','units','pixels','BackgroundColor',[1 1 1],'Max',2, ...
   'String',GetFiles(filter), 'Position',[20 60 350 190],'Tag','FileListLb','Value',[]);

% % Current selection
% uicontrol('Parent',Fig,'Style','text','units','pixels','HorizontalAlignment','left','String','Selection:','Position',[370 250 70 20]);
% uicontrol('Parent',Fig,'Style','Listbox','units','pixels','BackgroundColor',[1 1 1],'Max',2, ...
%    'String','','Position',[270 60 240 190],'Tag','SelectionLb');

% Select-Remove pushbuttons
% uicontrol('Parent',Fig,'Style','pushbutton','units','pixels','String','Add','Position',[520 170 45 25],'CallBack','uigetfiles2(''AddFile'')');
% uicontrol('Parent',Fig,'Style','pushbutton','units','pixels','String','Remove','Position',[520 140 45 25],'CallBack','uigetfiles2(''RemFile'')');

% Shift up/down pushbuttons
% uicontrol('Parent',Fig,'Style','pushbutton','units','pixels','String','/\','Position',[520 100 45 25],'CallBack','uigetfiles2(''ShiftUp'')');
% uicontrol('Parent',Fig,'Style','pushbutton','units','pixels','String','\/','Position',[520 70 45 25],'CallBack','uigetfiles2(''ShiftDown'')');

% OK/Cancel Pushbuttons
uicontrol('Parent',Fig,'Style','pushbutton','units','pixels','String','OK','Position',[160 4 100 32], ...
    'CallBack','uigetfiles2(''OK'')','Tag','OKButton');
uicontrol('Parent',Fig,'Style','pushbutton','units','pixels','String','Cancel','Position',[270 4 100 32],'CallBack','uigetfiles2(''Cancel'')');
