%SURFmex example function
%   Petter Strandmark 2008
%   petter.strandmark@gmail,com  
function [H] = estimate_projective4point(Po,Pt)

    %Linear estimation (first 4 points)
    A = zeros(2*4,9);
    for k = 1:size(Po,2)
        x =  Po(1,k)/Po(3,k);
        y =  Po(2,k)/Po(3,k);
        xp = Pt(1,k)/Pt(3,k);
        yp = Pt(2,k)/Pt(3,k);
        A(2*k-1:2*k,:) =[x y 1 0 0 0 -xp*x -xp*y -xp;
                         0 0 0 x y 1 -yp*x -yp*y -yp];
    end
    [U S V] = svd(A);
    h = V(:,end);

    %Return H
    H = [h(1) h(2) h(3);
         h(4) h(5) h(6);
         h(7) h(8) h(9)];
end

