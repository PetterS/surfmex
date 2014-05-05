%SURFmex example function
%   Petter Strandmark 2008
%   petter.strandmark@gmail,com  
function cost = projective_distance2(P,Q)
    cost = zeros(1,size(P,2));
    P(1,:) = P(1,:)./P(3,:);
    P(2,:) = P(2,:)./P(3,:);
    Q(1,:) = Q(1,:)./Q(3,:);
    Q(2,:) = Q(2,:)./Q(3,:);
    P = P(1:2,:);
    Q = Q(1:2,:);
    cost = sum( (P - Q).^2 ); 
end