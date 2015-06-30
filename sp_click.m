function varargout = sp_click(varargin)
%SP_CLICK M-file for sp_click.fig
%      SP_CLICK, by itself, creates a new SP_CLICK or raises the existing
%      singleton*.
%
%      H = SP_CLICK returns the handle to a new SP_CLICK or the handle to
%      the existing singleton*.
%
%      SP_CLICK('Property','Value',...) creates a new SP_CLICK using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to sp_click_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SP_CLICK('CALLBACK') and SP_CLICK('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SP_CLICK.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%                             
% See also: GUIDE, GUIDATA, GUIHANDLES  
                                         
% Edit the above text to modify the response to help sp_click

% Last Modified by GUIDE v2.5 14-Jun-2015 15:12:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sp_click_OpeningFcn, ...
                   'gui_OutputFcn',  @sp_click_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


%TODO - Add a flag for itnersting events filename = [whtever '_int']
%       ???rename xy to click_shape (nx2 matrix)
%       implment the append method, making sure to read orignal varibles and resave
%           -figure out how to remeber most recent file to append
%       Add date time  (same as file name) as var

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [currentfile] = correctfilename(start_datetime)
global pathname;

mint = str2num(datestr(start_datetime,'MM'));

if mint < 30
    mint = '00';
elseif mint > 29.999
    mint = '30';
else
	error('something wrong with selecting the filename');
end

dataid = strcat(pathname,['SP' datestr(start_datetime,'yymmddHH') mint '*.mat']);

try
    nameid = dir(dataid);
    currentfile = nameid.name;
catch
    error('Looks like maybe your DATA file is missing form the /Data/ Folder');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bb, F, T, P, df, dt] = setupVLF(pathname, filename, offsetSec, duration)
bb = vlfExtractBB( pathname, filename, offsetSec, offsetSec + duration);

% Spectrogram parameters, can be adjusted
nfft = 4096;
window = 2048;
noverlap = window/2;

bb.data = bb.data - mean(bb.data);
[~,F,T,P] = spectrogram( bb.data, window, noverlap, nfft, bb.Fs );
P = 10*log10(abs(P));
F = F/1e3;

df = bb.Fs/nfft;
dt = (window-noverlap)/bb.Fs;


% --- Executes just before sp_click is made visible.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sp_click_OpeningFcn(hObject, eventdata, handles, varargin)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
global pathname;        %Current path for data
global duration;        %The duration that will be FFT by spectra code
global TH_times;        %List of times loaded form the threshold program
global quality;         %#ok<NUSED>
%Sets the defult values for the quality and save radio buttons 
quality = 1;

%Loading data and usful vars
load('THtimes_reindex.mat');
load('saveplace','i','offsetSec');

TH_times = TH_re;
duration = str2num(get( handles.duration, 'String')); %#ok<*ST2NM>
pathname = 'Data/';

[i, offsetSec, filename] = check_file(i, offsetSec);
disp(i)
save('saveplace','i','offsetSec','-append')

% Choose default command line output for sp_click
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes sp_click wait for user response (see UIRESUME)
% uiwait(handles.guifig);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = sp_click_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function offsetMin_Callback(hObject, eventdata, handles)
% hObject    handle to offsetMin (see GCBO)

% Hints: get(hObject,'String') returns contents of offsetMin as text
%        str2double(get(hObject,'String')) returns contents of offsetMin as a double

% --- Executes during object creation, after setting all properties.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function offsetMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offsetMin (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function duration_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of duration as text
%        str2double(get(hObject,'String')) returns contents of duration as a double
% --- Executes during object creation, after setting all properties.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function duration_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%   makedate_TH %%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [datetime] = makedate_TH(TH_date, TH_time)
datetime = datevec(['2014', TH_date,TH_time ],'yyyymmddHHMM');

%%%%%%%%%%%%%%%%%%%%%%%   make_ctime (Currenttime) %%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [time] = make_ctime(whichhalf, offsetSec, tempdate_s) %date_ref, offsetSec)
offsetDays = offsetSec * 0.0000115741;

if whichhalf == 0
    time = datenum(tempdate_s) + offsetDays;
elseif whichhalf ==1
	time = datenum(tempdate_s) + offsetDays + 0.0104167; %15min in days
else
    error('whichhalf is not 1 or 0')
end

time = datevec(time);

%%%%%%%%%%%%%%%%%%%%%%%   check_file   %%%%%%%%%%%%%%%%%%%%%%% 
%Checks if and how to increment to the next location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [returni,offsetSec,filename] = check_file(i,offsetSec)
disp('calling check_file func')
global TH_times;
while i < 910
    if TH_times(i).total < 4000 %skpping events with less than 40 sec trigger time
        i = i + 1;
    else
		if mod(i,2)==0
			if offsetSec == 0
                offsetSec = 900 + TH_times(i).firstevent;
            elseif offsetSec > 1800
                i = i + 1
                offsetSec = 0;
                save('saveplace','i','offsetSec','-append')
                disp('INCREMENT i BY 1 for EVEN INDEX')
            else
                load('saveplace','offsetSec')
            end
		else
			if TH_times(i+1).total < 4000 %skipping events with less than 40 sec
                if offsetSec == 0
                    offsetSec = TH_times(i).firstevent;
                    lasteventtime = TH_times(i).lastevent;
                elseif offsetSec > 1800
                    i = i + 2
                    offsetSec = 0;
                    save('saveplace','i','offsetSec','-append')
                    disp('INCREMENT i BY 2 for odd INDEX')
                else
                    load('saveplace','offsetSec')
                end
            else
                if offsetSec == 0
                    offsetSec = TH_times(i).firstevent;
                    lasteventtime = 900 + TH_times(i+1).lastevent;
                 elseif offsetSec > 1800
                    i = i + 2
                    offsetSec = 0;
                    save('saveplace','i','offsetSec','-append')
                    disp('INCREMENT i BY 1 for oddindex but yes second half')
                else
                    load('saveplace','offsetSec')
                end
			end
        end
		save('saveplace','i','offsetSec','-append')
        returni = i;
        [filename] = make_filename(i);
        i = 1000;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%   check_time %%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [] = check_time(indexi, currenttime , firsteventtime, lasteventtime)


% --- Executes on button press in selectFile.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selectFile_Callback(hObject, eventdata, handles)

global pathname TH_times;
load('saveplace','i', 'offsetSec')
[i, offsetSec, filename] = check_file(i, offsetSec);
[filename] = make_filename(i);

%%%% Start basic code
duration = str2num(get( handles.duration, 'String'));

minP = -20;
maxP = 12;
set( handles.minP, 'String', num2str(minP));
set( handles.maxP, 'String', num2str(maxP));
filename
offsetSec

%load data
disp('loading data for select file button')
load('saveplace','i','offsetSec')
disp(i)
disp(offsetSec)
[bb, F, T, P, df, dt] = setupVLF(pathname, filename, offsetSec, duration);
% CREATE FIGURE AND AXIS OBJECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figWidth = 8;
figHeight = 3;
h_fig = findobj('Tag', 'plotfig');
if ( isempty( h_fig ) )
	h_fig = figure;
	colormap('jet');
	set( h_fig, 'PaperPositionMode', 'auto', ... 
		'Units', 'inches', 'Tag', 'plotfig');
	figpos = [ 1 4 figWidth figHeight ];
	set(h_fig, 'position', figpos );
else
	figure(h_fig);
	clf;
end;

h_ax = subplot(1,1,1);
h_im = imagesc(T, F, P, [minP maxP]);
axis xy;
hold on;
colorbar;
ylim([0.3 40]);

ylabel('Freq, kHz');
xlabel(['Time, seconds after ' datestr(bb.UT, 'HH:MM:SS') ' UT']);
title(['Stanford VLF South Pole   ' datestr(bb.UT, 'dd mmm yyyy') ...
  '   \Deltaf = ' num2str(round(df)) ' Hz, \Deltat = ' ...
	    num2str(round(dt*1e3)) ' ms']);

handles.h_fig = h_fig;
handles.h_ax = h_ax;
handles.h_im = h_ax;
handles.x_points = [];
handles.y_points = [];
handles.Power = P; % size(P) = 2049 x 2928
handles.p_points = [];
handles.dt = dt;
handles.df = df;
handles.h_m = [];
handles.filename = filename;
handles.UT = bb.UT;
set(h_fig, 'Pointer', 'crosshair');
guidata( findobj('Tag', 'guifig'), handles );
guidata(hObject, handles);
set(h_fig, 'Pointer', 'crosshair');
set(h_im, 'ButtonDownFcn', @spMouseClick);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveClicks_Callback(hObject, eventdata, handles)
global quality offsetSec;
if( isempty( handles.x_points ) )
	return;
end;

UTstart = handles.UT + handles.x_points(1)/60/60/24;

cfile = handles.filename;
UT = handles.UT;

x_points = handles.x_points;
y_points = handles.y_points;
                           
yindex = floor(y_points./0.02440214738);
xindex = floor(x_points./handles.dt);

r_save_shape = get(handles.r_save_shape,'Value');
r_save_train = get(handles.r_save_train,'Value');

click_temp(:,1) = handles.x_points;
click_temp(:,2) = handles.y_points;

pow_temp = zeros(1,length(x_points));
for index = 1:length(x_points)
    pow_temp(index) = handles.Power(yindex(index),xindex(index));
end 

to_append = get(handles.checkbox_append, 'Value');

if to_append == 0
    %Don't append creat a new file
    filename = ['Clicks/' 'clicks_' datestr(UTstart, 'yyyymmdd_HHMMSS.FFF')];
    if r_save_shape == 1
        click_shape = click_temp;
        pow_shape = pow_temp;
        save([filename '.mat'],'cfile', 'UT', 'click_shape','pow_shape','quality');
        clear click_shape;
        disp(['Saved click shape in ' filename]);
    elseif r_save_train == 1
        click_train= click_temp;
        pow_train = pow_temp;
        save([filename '.mat'],'cfile', 'UT', 'click_train','pow_train','quality');
        clear click_train
        disp(['Saved click train in ' filename]);
    else
        error('ERROR with the radio save buttons!  Train or Shape?')
    end

    print(handles.h_fig, [filename '.png'], '-dpng'); 
    handles.lastfile = filename;
    handles.lastUT = handles.UT;
elseif to_append == 1
    disp(datestr(handles.lastUT))
    disp(datestr(handles.UT))
    time_offset = handles.UT - handles.lastUT
    time_offset = time_offset*24*3600

    filename = handles.lastfile;
    if r_save_shape == 1
        click_temp(:,1) = click_temp(:,1) + time_offset;
        click_shape = click_temp; %nx2 matrix  (:,1) = time , (:,2) = frequncy
        pow_shape = pow_temp;
        save([filename '.mat'],'click_shape','pow_shape','-append')
    elseif r_save_train ==1
        %load last file then add new data 
        load([filename '.mat'],'click_train','pow_train')
        if exist('click_train')==0
            click_train =[];
        end
        if exist('pow_train')==0
            pow_train = [];        %if 'click_train' not found then click_train=[] 
        end
        click_temp(:,1) = click_temp(:,1) + time_offset;
        click_train = [click_train; click_temp];
        pow_train = [pow_train pow_temp];
        save([filename '.mat'],'click_train','pow_train','-append')
    end
    print(handles.h_fig, [filename 'train' '.png'], '-dpng'); 
end
guidata(hObject,handles);
%end of function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clearClicks_Callback(hObject, eventdata, handles)
% hObject    handle to clearClicks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.x_points = [];
handles.y_points = [];
handles.p_points = [];

delete( handles.h_m );
handles.h_m = [];

guidata( findobj('Tag', 'guifig'), handles );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minP_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of minP as text
%        str2double(get(hObject,'String')) returns contents of minP as a double

% --- Executes during object creation, after setting all properties.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxP_Callback(hObject, eventdata, handles)
% hObject    handle to minP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minP as text
%        str2double(get(hObject,'String')) returns contents of minP as a double


% --- Executes during object creation, after setting all properties.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function spMouseClick(gcbo, eventdata);

handles = guidata( findobj('Tag', 'guifig') );

hh = get(gca, 'CurrentPoint');
x = hh(1,1);
y = hh(1,2);

axes( handles.h_ax )
h_m = plot( x,y, 'wo', 'MarkerFaceColor', 'w');

handles.x_points = [handles.x_points x];
handles.y_points = [handles.y_points y];
handles.h_m = [handles.h_m h_m];

guidata( findobj('Tag', 'guifig'), handles );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_Callback(hObject, eventdata, handles)

minP = str2num(get( handles.minP, 'String'));
maxP = str2num(get( handles.maxP, 'String'));

axes( handles.h_ax);
caxis([minP maxP]);

%%%%%%%%%%%%%% --- make_filename --- %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [currentfile] = make_filename(index)
global TH_times;
    %Update the filename
    TH_date = TH_times(index).date;
    TH_start = TH_times(index).start;
    tempdate_s = makedate_TH(TH_date,TH_start);
    [currentfile] = correctfilename(tempdate_s);

%%%%%%%%% --- Executes on button press in nextbotton.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nextbotton_Callback(hObject, eventdata, handles)
global offsetSec pathname duration TH_times;
load('saveplace','i','offsetSec')
[filename] = make_filename(i)

minP = str2num(get(handles.minP,'String'));%-20;
maxP = str2num(get(handles.maxP,'String'));%12;


if (offsetSec + 30) > 1800
	offsetSec = 1770
elseif offsetSec == 1770
    offsetSec = 2000
else
	offsetSec = offsetSec + 30
end

save('saveplace','offsetSec','-append')

try
    disp(i)
    [bb, F, T, P, df, dt] = setupVLF(pathname, filename, offsetSec, duration);
catch
    disp('CATCH')
    load('saveplace','i')
    [i, offsetSec, filename] = check_file(i,offsetSec);
    disp(i)
    disp(offsetSec)
    save('saveplace','i','offsetSec','-append')
    [i, offsetSec, filename] = check_file(i,offsetSec);
    disp(i)
    [bb, F, T, P, df, dt] = setupVLF(pathname, filename, offsetSec, duration);
end
%


% CREATE FIGURE AND AXIS OBJECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figWidth = 8;
figHeight = 3;
h_fig = findobj('Tag', 'plotfig');
if ( isempty( h_fig ) )
	h_fig = figure;
	colormap('jet');
	set( h_fig, 'PaperPositionMode', 'auto', ... 
		'Units', 'inches', 'Tag', 'plotfig');
	figpos = [ 1 4 figWidth figHeight ];
	set(h_fig, 'position', figpos );
else
	figure(h_fig);
	clf;
end;

h_ax = subplot(1,1,1);
h_im = imagesc(T, F, P, [minP maxP]);
axis xy;
hold on;
colorbar;
ylim([0.3 40]);

ylabel('Freq, kHz');%%%%%%%%%%%% Chancde HH:MM to HH:MM:SS
xlabel(['Time, seconds after ' datestr(bb.UT, 'HH:MM:SS') ' UT']);
title(['Stanford VLF South Pole   ' datestr(bb.UT, 'dd mmm yyyy') ...
  '   \Deltaf = ' num2str(round(df)) ' Hz, \Deltat = ' ...
	    num2str(round(dt*1e3)) ' ms']);

handles.h_fig = h_fig;
handles.h_ax = h_ax;
handles.h_im = h_ax;
handles.x_points = [];
handles.y_points = [];
handles.p_points = [];
handles.Power = P;
handles.h_m = [];
handles.filename = filename;
handles.UT = bb.UT;
guidata( findobj('Tag', 'guifig'), handles );

set(h_fig, 'Pointer', 'crosshair');
set(h_im, 'ButtonDownFcn', @spMouseClick);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function smallnext_Callback(hObject, eventdata, handles)
% hObject    handle to smallnext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global offsetSec pathname duration TH_times;
load('saveplace','i','offsetSec')
[filename] = make_filename(i)

minP = str2num(get(handles.minP,'String'));%-20;
maxP = str2num(get(handles.maxP,'String'));%12;


if (offsetSec + 10) > 1800
	offsetSec = 1770
elseif offsetSec == 1770
    offsetSec = 2000
else
	offsetSec = offsetSec + 10
end

save('saveplace','offsetSec','-append')
disp('Saveing the new offset')
%load data
try
    disp(i)
    %NEED TO UP DATE THE FILENAME
    [bb, F, T, P, df, dt] = setupVLF(pathname, filename, offsetSec, duration);
catch
    load('saveplace','i')
	offsetSec = 0;
    [i, offsetSec, filename] = check_file(i,offsetSec);
    save('saveplace','i','offsetSec','-append')
    disp(i)
    [bb, F, T, P, df, dt] = setupVLF(pathname, filename, offsetSec, duration);
end

% CREATE FIGURE AND AXIS OBJECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figWidth = 8;
figHeight = 3;
h_fig = findobj('Tag', 'plotfig');
if ( isempty( h_fig ) )
	h_fig = figure;
	colormap('jet');
	set( h_fig, 'PaperPositionMode', 'auto', ... 
		'Units', 'inches', 'Tag', 'plotfig');
	figpos = [ 1 4 figWidth figHeight ];
	set(h_fig, 'position', figpos );
else
	figure(h_fig);
	clf;
end;

h_ax = subplot(1,1,1);
h_im = imagesc(T, F, P, [minP maxP]);
axis xy;
hold on;
colorbar;
ylim([0.3 40]);

ylabel('Freq, kHz');%%%%%%%%%%%% Chancde HH:MM to HH:MM:SS
xlabel(['Time, seconds after ' datestr(bb.UT, 'HH:MM:SS') ' UT']);
title(['Stanford VLF South Pole   ' datestr(bb.UT, 'dd mmm yyyy') ...
  '   \Deltaf = ' num2str(round(df)) ' Hz, \Deltat = ' ...
	    num2str(round(dt*1e3)) ' ms']);

handles.h_fig = h_fig;
handles.h_ax = h_ax;
handles.h_im = h_ax;
handles.x_points = [];
handles.y_points = [];
handles.p_points = [];
handles.Power = P;
handles.h_m = [];
handles.filename = filename;
handles.UT = bb.UT;
guidata( findobj('Tag', 'guifig'), handles );

set(h_fig, 'Pointer', 'crosshair');
set(h_im, 'ButtonDownFcn', @spMouseClick);
 

% --- Executes on button press in smallback.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function smallback_Callback(hObject, eventdata, handles)
% hObject    handle to smallback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global offsetSec pathname duration TH_times;
load('saveplace','i','offsetSec')
[filename] = make_filename(i)

minP = str2num(get(handles.minP,'String'));%-20;
maxP = str2num(get(handles.maxP,'String'));%12;
%set( handles.minP, 'String', num2str(minP));
%set( handles.maxP, 'String', num2str(maxP));

if (offsetSec - 10) < 0
	offsetSec = 0
else
	offsetSec = offsetSec - 10
end

save('saveplace','offsetSec','-append')
disp('Saveing the new offset')
%load data

disp(i)
%NEED TO UP DATE THE FILENAME
[bb, F, T, P, df, dt] = setupVLF(pathname, filename, offsetSec, duration);

% CREATE FIGURE AND AXIS OBJECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figWidth = 8;
figHeight = 3;
h_fig = findobj('Tag', 'plotfig');
if ( isempty( h_fig ) )
	h_fig = figure;
	colormap('jet');
	set( h_fig, 'PaperPositionMode', 'auto', ... 
		'Units', 'inches', 'Tag', 'plotfig');
	figpos = [ 1 4 figWidth figHeight ];
	set(h_fig, 'position', figpos );
else
	figure(h_fig);
	clf;
end;

h_ax = subplot(1,1,1);
h_im = imagesc(T, F, P, [minP maxP]);
axis xy;
hold on;
colorbar;
ylim([0.3 40]);

ylabel('Freq, kHz');%%%%%%%%%%%% Chancde HH:MM to HH:MM:SS
xlabel(['Time, seconds after ' datestr(bb.UT, 'HH:MM:SS') ' UT']);
title(['Stanford VLF South Pole   ' datestr(bb.UT, 'dd mmm yyyy') ...
  '   \Deltaf = ' num2str(round(df)) ' Hz, \Deltat = ' ...
	    num2str(round(dt*1e3)) ' ms']);

handles.h_fig = h_fig;
handles.h_ax = h_ax;
handles.h_im = h_ax;
handles.x_points = [];
handles.y_points = [];
handles.p_points = [];
handles.Power = P;
handles.h_m = [];
handles.filename = filename;
handles.UT = bb.UT;
guidata( findobj('Tag', 'guifig'), handles );

set(h_fig, 'Pointer', 'crosshair');
set(h_im, 'ButtonDownFcn', @spMouseClick);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r_poor_Callback(hObject, eventdata, handles)

global quality;
quality = 1;
% Hint: get(hObject,'Value') returns toggle state of r_poor


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r_mod_Callback(hObject, eventdata, handles)
% hObject    handle to r_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global quality;
quality = 2;
% Hint: get(hObject,'Value') returns toggle state of r_mod


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r_exc_Callback(hObject, eventdata, handles)
% hObject    handle to r_exc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global quality;
quality = 3;
% Hint: get(hObject,'Value') returns toggle state of r_exc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_place_button_Callback(hObject, eventdata, handles)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global offsetSec placeholder; %#ok<NUSED>

i
offsetSec
save('saveplace.mat','i', 'offsetSec','-append')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function highc_button_Callback(hObject, eventdata, handles)
% hObject    handle to highc_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
minP = -4; %str2num(get( handles.minP, 'String'));
maxP = 22; %str2num(get( handles.maxP, 'String'));
set(handles.minP,'string', num2str(minP));
set(handles.maxP,'string', num2str(maxP));

axes( handles.h_ax);
caxis([minP maxP]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function medium_c_button_Callback(hObject, eventdata, handles)
% hObject    handle to medium_c_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
minP = -22; %str2num(get( handles.minP, 'String'));
maxP = 11; %str2num(get( handles.maxP, 'String'));
set(handles.minP,'string', num2str(minP));
set(handles.maxP,'string', num2str(maxP));

axes( handles.h_ax);
caxis([minP maxP]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function low_c_button_Callback(hObject, eventdata, handles)
% hObject    handle to low_c_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
minP = -22; %str2num(get( handles.minP, 'String'));
maxP = 33; %str2num(get( handles.maxP, 'String'));
set(handles.minP,'string', num2str(minP));
set(handles.maxP,'string', num2str(maxP));

axes( handles.h_ax);
caxis([minP maxP]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function highc_button_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to highc_button (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% keyPressed = eventdata.Key;
%  if strcmpi(keyPressed,'x')
%      % set focus to the button
%      uicontrol(handles.pushbutton1);
%      % call the callback
%      pushbutton1_Callback(handles.pushbutton1,[],handles);
%  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% New Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkbox_append_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_append (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_append
