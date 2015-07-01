%Funciont written for residual anlysis on continouse hissler data
%
%coff_1(j) = linear coffi  array j = 2
%coff_2(j) = squred polyfit array j = 3
%yinv_coff_1(j) = linear coffi  array j = 2
%yinv_coff_2(j) = squred polyfit array j = 3
%
%fitcoff nx3 matrix
%xypoints nx2 matrix
%chi_arr is a vector of chi/number_points for each fit
%1=first order
%2=seconed order
%3=first order inverse sqrt
%4=second order ivnerse sqrt
%
%Equation for save keeping later delate if forgoten
%resid = calc_residual(fitcoff(2),fitcoff(1),fitcoff(3), xypoints(:,1), xypoints(:,2));
function [coff_firstorder, coff_secondorder, resid1, resid2, chi_arr] = fit_anlysis(xypoints)
    [coff_1, coff_2, inv_coff_1, inv_coff_2, chi_arr, resid1, resid2] = fitdata(xypoints);
    % 1 is the linear
    % 2 is the linear inv sqrt
    coff_firstorder(1,:) = coff_1;
    coff_firstorder(2,:) = inv_coff_1;
    coff_secondorder(1,:) = coff_2;
    coff_secondorder(2,:) = inv_coff_2;
end

function [coff_1, coff_2, inv_coff_1, inv_coff_2, chi_arr, resid1, resid2] = fitdata(xypoints)
    yinv = (xypoints(:,2)).^(-0.5);
    y = xypoints(:,2);
    x = xypoints(:,1);

    coff_1 = polyfit(x,y,1);
    coff_2 =  polyfit(x,y,2);
    inv_coff_1 = polyfit(x,yinv,1);
    inv_coff_2 = polyfit(x,yinv,2);

    % residn gives you the nth order fit col-1 gives you 'regulre' values col-2 gives you inv sqrt y
    resid1(1,:) = y - polyval(coff_1,x); 
    resid1(2,:)= yinv - polyval(inv_coff_1,x); 
    resid2(1,:) = y - polyval(coff_2,x); 
    resid2(2,:) = yinv - polyval(inv_coff_2,x); 

    %Chi value for first order polyfit
    expt = polyval(coff_1,x);
    chi_arr(1) = chi_sq(y,expt);
    %Chi value for second order order polyfit
    expt = polyval(coff_2,x);
    chi_arr(2) = chi_sq(y,expt);
    %Chi value for first oder order order polyfit inverse sqrt function
    expt = polyval(inv_coff_1,x);
    chi_arr(3) = chi_sq(yinv,expt);
    %Chi value for first oder order order polyfit inverse sqrt function
    expt = polyval(inv_coff_2,x);
    chi_arr(4) = chi_sq(yinv,expt);
end

function [chi_norm] = chi_sq(obs,expt)
    if length(obs)~=length(expt)
        error('obsserved array not the same length as expected array for chi squared')
    else
        n = length(obs);
        resid = obs-expt;
        std_sq = (std(obs))^2;
        chi = (resid'*resid)/std_sq;
        chi_norm = chi/n;
    end
end
