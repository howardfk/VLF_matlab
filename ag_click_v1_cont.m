pathname = 'Clicks/Continous/'
path_id= [pathname 'clicks*.mat'];
listing = dir(path_id);
num_files=length(listing);

train(num_files).number = num_files

for l=1:num_files
    filename = strcat(listing(l).name);
    load([pathname filename]);
    size(x)
    click_shape(:,1) = x;
    click_shape(:,2) = y;
    pow_shape = pow;

    train(l).UT = UT;
    train(l).cfile = cfile;
    train(l).click_shape = click_shape;
    train(l).pow_shape = pow_shape;
    train(l).quality = quality;
    clear click_shape
end

%Calculating new properties
%period(n) = time between n and n+1


save('click_agg_data_v1','train');
clear
