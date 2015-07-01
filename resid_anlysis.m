%Funciont written for residual anlysis on continouse hissler data
%
%fitcoff(i,1) = linear coff  x
%fitcoff(i,2) = squred coff x^2
%fitcoff(n,3) = constent
%fitcoff nx3 matrix
%xypoints nx2 matrix
%
function [resid]=resid_anlysis(fitcoff, xypoints)
    xypoints(:,1) = xypoints(:,1) - min(xypoints(:,1));
    resid = calc_residual(fitcoff(2),fitcoff(1),fitcoff(3), xypoints(:,1), xypoints(:,2));
end

function [resid]=calc_residual(coffsq,cofflin, coffc,x,y)
    yfit = coffsq.*x.^2 + cofflin.*x + coffc;
    resid = sqrt((yfit - y).^2); %array of resid
end
