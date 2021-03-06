% Location of data files
pathname = 'Data/';
% Location to save plots
savepath = 'Plots/';

% Default colorscale, can be adjusted
maxP = 15;
minP = maxP-40; %orignal 40

% WHOLE MINUTES
sUT = datenum(2014, 08, 30, 01, 24, 00 );
eUT = datenum(2014, 08, 30, 01, 24, 00 );

% CREATE FIGURE AND AXIS OBJECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figWidth = 8;
figHeight = 3;
fig = findobj('Tag', 'sp');
if ( isempty( fig ) ) 
	fig = figure;
	colormap('jet');
	set( fig, 'PaperPositionMode', 'auto', 'Units', 'inches', 'Tag', 'sp');
	figpos = [ 1 2 figWidth figHeight ];
	set(fig, 'position', figpos );
else
	figure(fig);
	clf;
end;

%%%%%%%%%%%%%%%%%%%%%% Select files %%%%%%%%%%%%%%%%%%%%%%
%Times to play with: 8-30 00:36 (the weird one that did notwork)
%Inteince time: 8-30 00:44
%light time: 8-30 00:38 && 01:07
%Quite time: 8-30 01:24,  8-28 00:00 && 00:01

numMin = (eUT-sUT)*24*60+1;
UT = sUT;
for( k = 1:numMin )

	[y,m,d,h,mi,s] = datevec(UT);
	% Data files are half hour files
	% Determine if we want the 00 or the 30 file
	if( (mi+round(s)/60) < 30 )
		MM = '00';
		whichSec = mi*60+round(s);
	else
		MM = '30';
		whichSec = (mi-30)*60+round(s);
	end;

	% load data
	filename = ['SP' datestr( UT, 'yymmddHH' ) MM '00_000.mat'];
	bb = vlfExtractBB( pathname, filename, whichSec, whichSec+60);
    
	% Spectrogram parameters, can be adjusted
	nfft = 4096;
	window = 2048;
	noverlap = window/2;
    
	bb.data = bb.data - mean(bb.data);
	[S,F,T,P] = spectrogram( bb.data, window, noverlap, nfft, bb.Fs );
    %
    P = 10*log10(abs(P));
    %%%%%%%%%%%%%%%%%%%%%% Creat Spectral Density %%%%%%%%%%%%%%%%%%%%%%
    lowerfreq = 5000;
    upperfreq = 50000;
    lowerindex = floor(lowerfreq/24.4141);
    upperindex = floor(upperfreq/24.4141);
    SD = zeros(length(T));
    for i = 1:length(T)
        for j = lowerindex:upperindex %length(F)
            SD(i) = SD(i)+ P(j,i);
        end;
    end;
 
	%maxP = max(max(P));
	%minP = maxP - 40;

	df = bb.Fs/nfft;
	dt = (window-noverlap)/bb.Fs;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Average or not to average? %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        time = 0.0102 %set to 0.0102 to set number of averages not based on time
        avg = 100*time/0.0102; %set muliple to 1 to set the amount of time to average over
        SDavg = zeros(floor(length(SD)/avg));
        Tavg = zeros(floor(length(T)/avg));

        %Tavg(i) = T(1:58:length(T));
        for i=1:(floor(length(T)/avg))
            j = (i-1)*avg;
            SDavg(i) = mean(SD(1+j:avg+j));
            Tavg(i) = T(1+j);
        end;

        %%%%%%%%%%%%%%%%%%%%%% Graphing line plot of power spectral density %%%%%%%%%%%%%%%%%%%%%%
        clf;
        full_freq=0;
        axis xy;
        plot(Tavg,SDavg)
        ylim([-5*10^4, 0])
        ylabel('Spectral Densitt, Power/kHz?');
        xlabel(['Time, seconds after ' datestr(bb.UT, 'HH:MM') ' UT']);
        title(['Stanford VLF South Pole   ' datestr(bb.UT, 'dd mmm yyyy') ...
            '   \Deltaf = ' num2str(round(df)) ' Hz, \Deltat = ' ...
            num2str(round(dt*1e3)) ' ms']);
        if full_freq == 1
            printname = ['SDavg_' datestr(bb.UT, 'yyyymmdd_HHMM')];
        else
            printname = ['SDavg_' datestr(bb.UT, 'yyyymmdd_HHMM')];
        end;
        disp(printname)
        printfolder = [savepath datestr(bb.UT, 'yyyy_mm_dd/')];
        print('-dpng', [printfolder printname]);

        UT = UT + 1/24/60;
        %%%%%%%%%%%%%%%%%%%%%%% Avoid error where mi=59 and s=59.9
        [y,m,d,h,mi,s] = datevec(UT);
        s = round(s);
        UT = datenum(y,m,d,h,mi,s);
        

end;
	
