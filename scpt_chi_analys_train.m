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

    %coff_1 2xn matrix: 1xn = reg first order, 2xn = 1/sqrt first order
    %coff_2 2xn matrix: 1xn = reg second order, 2xn = 1/sqrt firt odrer
    %residn gives you the nth order fit 
    %row-1 gives you 'regulre' values row-2 gives you inv sqrt y
    [coff_1, coff_2, resid1, resid2, chi_norm, r] = fit_anlysis(temp_click_shape);
    list_coff_1(i,:,:) = coff_1;
    list_coff_2(i,:,:) = coff_2;
    list_chi_norm(i,:) = chi_norm;
    list_r(i,:) = r;

    %Making residual graphs
    fig1 = figure(1)
    subplot(1,2,1)
    s1 = scatter(x,resid1(:,1),'x')
    hold on;
    s2 = scatter(x,resid2(:,1),'*')
    s3 = plot(x,zeros(length(x),1))
    title('Residule plots with first and second order fits')
    xlabel('time in seconds')
    ylabel('residule values in kHz')
    s1.MarkerEdgeColor = [0 0 1]
    s2.MarkerEdgeColor = [1 0 0]
    s3.MarkerEdgeColor = [0.5 0 0.1]
    hold off;

    subplot(1,2,2)
    s4= scatter(x,resid1(:,2),'x')
    hold on;
    s5 = scatter(x,resid2(:,2),'*')
    s6 = plot(x,zeros(length(x),1))
    title('Residule plots with 1/sqrt(freq) first and second order')
    xlabel('time in seconds')
    ylabel('residule values in 1/sqrt(kHz)')
    s4.MarkerEdgeColor = [0 0 1]
    s5.MarkerEdgeColor = [1 0 0]
    s6.MarkerEdgeColor = [0.5 0 0.1]
    hold off;
    path = 'Fits/'
    filename = ['risid_' num2str(i)]
    saveas(fig1,[path filename],'png')
    set(gcf,'Visible','off')

end 

test1 = list_chi_norm(:,1);
test2 = list_chi_norm(:,2); 
test3 = list_chi_norm(:,3); 
test4 = list_chi_norm(:,4); 

binning = [0:0.010:0.35]
fig1 = figure(2)
h1=histogram(test1,binning)
hold on
h2=histogram(test2,binning)
title('histogram of chi squred for each fit')
legend([h1 h2],'linear','second order')
xlabel('Ratio of Chi and number of points')
ylabel('count')
h1.FaceColor = [1 0 0]
h2.FaceColor = [1 1 0]

figure(3)
h3=histogram(test3,binning)
hold on
h4=histogram(test4,binning)
h3.FaceColor = [0 1 0]
h4.FaceColor = [0 0 1]

title('histogram of chi squred for each fit')
legend([h3 h4],'linear inverse sqrt','secondorder inverse sqrt')
xlabel('Ratio of Chi and number of points')
ylabel('count')

figure(4)
h5 = histogram(list_r(:,1))
title('first order fit to xy data')
