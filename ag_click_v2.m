pathname = 'Clicks/'
path_id= [pathname 'clicks*.mat'];
listing = dir(path_id);
num_files=length(listing);

train(num_files).number = num_files

for l=1:num_files
    filename = strcat(listing(l).name);
    load([pathname filename]);
    l
    filename
    train(l).number = l;
    train(l).UT = UT;
    train(l).cfile = cfile;
    train(l).click_shape = click_shape;
    train(l).click_train = click_train;
    train(l).pow_shape = pow_shape;
    train(l).pow_train = pow_train;
    train(l).quality = quality;

%Calculating new properties
%period(n) = time between n and n+1
    for i = 1:length(click_train)-1
        period(i) = click_train(i+1,1) - click_train(i,1);
    end
    duration_train = click_train(length(click_train),1) - click_train(1,1)

    train(l).period = period;
    train(l).duration_train = duration_train;
    clear click_train
end

save('click_data_train_v2','train');
clear
