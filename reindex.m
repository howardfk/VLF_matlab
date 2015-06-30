load THtimes_-1.600e+04.mat
TH_re(910).total = 0;
for i = 1:length(thresholdtimes)
	if mod(i,2) == 0
		TH_re(i).total = thresholdtimes(i-1).total
		TH_re(i).timelist = thresholdtimes(i-1).timelist
		TH_re(i).start = thresholdtimes(i-1).start
		TH_re(i).date = thresholdtimes(i-1).date
		TH_re(i).firstevent = thresholdtimes(i-1).firstevent
		TH_re(i).lastevent = thresholdtimes(i-1).lastevent
	else
		TH_re(i).total = thresholdtimes(i+1).total
		TH_re(i).timelist = thresholdtimes(i+1).timelist
		TH_re(i).start = thresholdtimes(i+1).start
		TH_re(i).date = thresholdtimes(i+1).date
		TH_re(i).firstevent = thresholdtimes(i+1).firstevent
		TH_re(i).lastevent = thresholdtimes(i+1).lastevent 
	end
end
save('THtimes_reindex.mat','TH_re')
