%Structure array 'train' has # values,  hisslers represents continouse clicks of individual hisslers
%   -number = arbritry counting number (not used)
%   -UT = universial time, days from 0-00-1900?  i think this is right but some arb date
%   cfile = original raw data file that this event was pulled from
%   click_shape = nx2 matrix    click_shape(n,1) = time seconds form UT
%   click_train= nx2 matrix    click_shape(n,2) = frequancy in kHz
%   pow_shape = 1xn matrix  pow_shape = power value for the nth click_shape (DOES NOT WORK for cont data, only for train data)
%   pow_train = 
%
%To pull data form a structured array the format is train(n).UT   this is the UT time for the nth hissler

data_in = 'click_data_train_v2.mat';
load(data_in);
datacount = length(train)
for i=1:datacount
    temp_click_shape = train(i).click_shape;
    x = temp_click_shape(:,1) - min(temp_click_shape(:,1));
    y = temp_click_shape(:,2);

    time_dur(i) = max(x) - min(x); %time_dur(n) = nth trains time durtion 
    bandwidth(i) = max(y) - min(y); %bandwith(n) = nth trains bandwidth
    UT(i) = train(i).UT;
end 

