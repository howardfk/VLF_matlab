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

%resid_anlysis(fitcoff, click_shape);
%I want to creat 3 Resiues arrays
%   -residues comparing fits with the data it was made from
%   -residues comparing fits with nabering data
%   -residues comparing fits with random data
count = 0;
for k=2:datacount-2
    for p=1:2
        if time_dur(k)<0.18
            k=k+p;
        elseif time_dur(k+p)<0.18
            k=k+p;
        else %comparing residues of fit to near by data
            if (UT(k+p) - UT(k)) < 0.00038 %13 seconds
                k
                count = count+1;
                res = resid_anlysis(fitcoff(k,:), train(k+p).click_shape);
                dispr_ratio(count) = fitcoff(k,2)/fitcoff(k+p,2);
                mean_res_nab(count) = mean(res); %res_nab is the residues of the nabor
                std_res_nab(count) = std(res);   %res_nab is the residues of the nabor
            else
                resid = 'TOO FAR';
            end 
        end
    end
end



%comparing residues of fit to its own data
for i=1:datacount
    res = resid_anlysis(fitcoff(i,:),train(i).click_shape);
    mean_res_self(i) = mean(res); %res_nab is the residues of the nabor
    std_res_self(i) = std(res);   %res_nab is the residues of the nabor
end


%comparing residules of random fits to random data
%
k=1;
for i=1:datacount
    for j=1:datacount
        res = resid_anlysis(fitcoff(i,:), train(j).click_shape);
        mean_res_rand(k) = mean(res); %res_nab is the residues of the nabor
        std_res_rand(k) = std(res);   %res_nab is the residues of the nabor
        k=k+1;
    end
end

dispr = fitcoff(:,2);

l=randi([1,395]);
m=l+1;

%x = train(m).click_shape(:,1);
%y = train(m).click_shape(:,2);
%constent = fitcoff(m,3);
%xexam = linspace(min(x),max(x),50);
%yexam = fitcoff(l,2).*xexam.^2 + fitcoff(l,1).*xexam + fitcoff(l,3);
%yexam_shift = fitcoff(l,2).*xexam.^2 + fitcoff(l,1).*xexam + constent;


figure(1)
subplot(2,2,1)
bining =[-1 0:0.2:5 6]; 
histogram(mean_res_self,bining)
title('Risidules of data to its own fit')
xlabel('Residule mean (kHz)')
ylabel('Count')
subplot(2,2,2)
%bining = [-15 -5:0.25:8 15];
histogram(dispr_ratio, 10)
xlim([-10 10]);
title('Dispersive coff ratio between nabours')
xlabel('Ratio of nearby hiss x^2 coff (kHz/sec^2)')
ylabel('Count')
subplot(2,2,3)
binning = [-5 0:5:70 100]
histogram(mean_res_rand, binning)
xlim([0 100]);
title('Risidules of data to random fit')
xlabel('Residule mean (kHz)')
ylabel('Count')
subplot(2,2,4)
bining = [-50 -25:10:180 250]
hist(dispr, bining)
xlim([-50 180]);
title('Dispertion constent of fits')
xlabel('kHz/sec^2')
ylabel('count')
