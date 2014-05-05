%Estimates projective transformation
%  [Pt;1] = lambda*H*[Po;1]
%SURFmex example function
%   Petter Strandmark 2008
%   petter.strandmark@gmail,com  
function [H inliers Ofinal] = estimate_projective_ransac(Po,Pt,O)
    dist_thresh = 3;
    imax = 200;

    nmatch = size(Po,2);
    
    if nmatch == 0
        H = eye(3);
        inliers = [];
        Ofinal = 0;
        return
    end
   

    sbest = -inf;
    Obest = 0;
    for iter = 1:imax
        %Choose random points
        rperm = randperm(nmatch);
        nmin = O;
        index = rperm(1:min(nmin,nmatch));
        %Estimate
        H = estimate_model(O,Po(:,index),Pt(:,index));
        
        %How many inliers?
        Pot = H*Po;
        dist2 = projective_distance2(Pot,Pt);
        inliers = find(dist2 <= dist_thresh);
        numinliers = length(inliers);
        
        %Score of this transformation
        s = numinliers;

    
        %If we found a better one, save
        if s >= sbest
            bestinliers = inliers;
            Obest = O;
            sbest = s;
            Hbest = H;
        end
        
        
        
%         disp(sprintf('i=%2d O=%d inliers=%d',iter,O,numinliers));
    end
    
    if Obest==0
        %Only happens in extremely degenerate cases
        H = eye(3);
        Ofinal = 0;
        inliers = [];
        return
    end
    

    %This is a matter of interest
    Ofinal = Obest;%min(length(bestinliers), 3);
    disp(sprintf('Final model: %d inliers',length(bestinliers)));
    
    %Estimate the transformation from the consensus
    %model and points
    if Ofinal < 4
        H = estimate_model(Ofinal,Po(:,bestinliers),Pt(:,bestinliers));
        %H = Hbest;
    elseif Ofinal == 4
        H = estimate_projective_nonlinear(Po(:,bestinliers),Pt(:,bestinliers),Hbest);
    end
    inliers = bestinliers;
end


function [H failed] = estimate_model(type, Po, Pt)
    if type < 4
        Po(1,:) = Po(1,:)./Po(3,:);
        Po(2,:) = Po(2,:)./Po(3,:);
        Pt(1,:) = Pt(1,:)./Pt(3,:);
        Pt(2,:) = Pt(2,:)./Pt(3,:);
    end
    
    if type == 1
        [M t failed] = estimate_affine1(Po,Pt);
        H = [M t;0 0 1];
    elseif type == 2
        [M t failed] = estimate_affine2(Po,Pt);
        H = [M t;0 0 1];
    elseif type == 3
        [M t failed] = estimate_affine3(Po,Pt);
        H = [M t;0 0 1];
    elseif type == 4
        H = estimate_projective4point(Po,Pt);
        failed = 0;
    end
end


function [M t failed] = estimate_affine1(Po,Pt)
    M = eye(2);
    t = mean(Pt - Po,2);
    t = t(1:2);
    failed = 0;
end

function [M t failed] = estimate_affine2(Po,Pt)
    nmatch = size(Po,2);
    A = zeros(2*nmatch,4);
    b = zeros(2*nmatch,1);
    for i = 1:nmatch
        x = Po(1,i);
        y = Po(2,i);
        u = Pt(1,i);
        v = Pt(2,i);
        A(2*i-1:2*i,:) = [x -y 1 0;y x 0 1];
        b(2*i-1:2*i) = [u;v];
    end
    if rank(A)<2
        M = zeros(2);
        t = [0;0];
        failed = 1;
        return
    end
    X = A\b;
    M = [X(1) -X(2);X(2) X(1)];
    t = [X(3); X(4)];
    failed = 0;
end

function [M t failed] = estimate_affine3(Po,Pt)
    nmatch = size(Po,2);
    A = zeros(2*nmatch,6);
    b = zeros(2*nmatch,1);
    for m = 1:nmatch
        x = Po(1,m);
        y = Po(2,m);
        u = Pt(1,m);
        v = Pt(2,m);
        A(2*m-1:2*m,:) = [x y 0 0 1 0; 0 0 x y 0 1];
        b(2*m-1:2*m)   = [u; v];
    end
    %Solve AX = b
    if 1/cond(A)<1e-16
        %Cannot estimate
        M = zeros(2);
        t = [0;0];
        failed = 1;
    else
        X = A\b;
        M = [X(1) X(2);X(3) X(4)];
        t = [X(5); X(6)];
        failed = 0;
    end
end

function m = choosefrom(Mlist)
    m = Mlist(round(length(Mlist)*rand + 0.5));
end