function [handles,F,T,P,df,dt] = vlfmake(handles, pathname,filename,offsetSec, duration)
% VLFMAKE Take vlf south pole data creat graph handles
%   Takes in (pathname, filename, offsetSec, duration) for
%   vlfextract
%   Takes in 
%   Returns the Frequancy, Time, Power, delta Freq, delta time
%   Spectragram is dropped from the FFT
offsetSec = str2num(get( handles.offsetMin, 'String'))*60;
duration = str2num(get( handles.duration, 'String'));


minP = -25;
maxP = 15;
set( handles.minP, 'String', num2str(minP));
set( handles.maxP, 'String', num2str(maxP));


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

%load data
bb = vlfExtractBB( pathname, filename, offsetSec, offsetSec+duration);

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

%%%%%%  Copy and pasted from sp_click

h_ax = subplot(1,1,1);
minP;
maxP;
h_im = imagesc(T, F, P, [minP maxP]);
axis xy;
hold on;
colorbar;
ylim([0.3 40]);

ylabel('Freq, kHz');
xlabel(['Time, seconds after ' datestr(bb.UT, 'HH:MM') ' UT']);
title(['Stanford VLF South Pole   ' datestr(bb.UT, 'dd mmm yyyy') ...
  '   \Deltaf = ' num2str(round(df)) ' Hz, \Deltat = ' ...
	    num2str(round(dt*1e3)) ' ms']);

handles.h_fig = h_fig;
handles.h_ax = h_ax;
handles.h_im = h_ax;
handles.x_points = [];
handles.y_points = [];
handles.p_points = [];
handles.h_m = [];
handles.filename = filename;
handles.UT = bb.UT;
guidata( findobj('Tag', 'guifig'), handles );

set(h_fig, 'Pointer', 'crosshair');
%set(h_im, 'ButtonDownFcn', @spMouseClick);

end