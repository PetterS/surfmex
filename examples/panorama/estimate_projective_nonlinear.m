%SURFmex example function
%   Petter Strandmark 2008
%   petter.strandmark@gmail,com  
function Hend = estimate_projective_nonlinear(Po,Pt,H)

    h0 = [H(1,1); H(1,2); H(1,3);
          H(2,1); H(2,2); H(2,3);
          H(3,1); H(3,2); H(3,3);];
    
    errstart = errorfunc(h0,Po,Pt);
	%Required Optimization Toolbox
	%Do not run this function if unavailable, example will still work
    [h errend] = fminsearch( @(h) errorfunc(h,Po,Pt), h0);
    
    disp(sprintf('Error from %.2f to %.2f',errstart,errend));
    
    %Return H
    Hend = [h(1) h(2) h(3);
            h(4) h(5) h(6);
            h(7) h(8) h(9)];
end

function error = errorfunc(h,P1,P2)
    H = [h(1) h(2) h(3);
         h(4) h(5) h(6);
         h(7) h(8) h(9)];
    error = 0;
    for k = 1:size(P1,2)
        vp = H*P1(:,k);
        xp = vp(1)/vp(3);
        yp = vp(2)/vp(3);
        xpreal = P2(1,k)/P2(3,k);
        ypreal = P2(2,k)/P2(3,k);
        error = error + (xp-xpreal).^2 + (yp-ypreal).^2;
    end
end