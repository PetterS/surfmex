%SURFmex example function
%   Petter Strandmark 2008
%   petter.strandmark@gmail,com  
clc
close all

%% Create images
I = rgb2gray(imread('peppers.png'));
I2 = double(I) + 15*randn(size(I));
I2 = max(0,I2);
I2 = min(255,I2);
I2 = uint8(I2);

%% Calculate interest points

clear options
options.extended = 1;

tic
[points descr sign info] = surfpoints(I, options);
disp(sprintf('Time taken to calculate %d points: %.5f seconds',size(points,2),toc));
[points2 descr2 sign2 info2] = surfpoints(I2, options);


%% Match
thresh = 0.7;
tic
matches = surfmatch(descr,sign, descr2,sign2, thresh);
disp(sprintf('Time taken to match points: %.3f seconds',toc));


%% Show
figure(1);
imshow(I);
hold on
figure(2)
imshow(I2);
hold on

figure(1);
plot(points(1,:), points(2,:), 'b+');
for i = 1:size(matches,2)
    %Distance between correspondences
    d = sum( (points(:,matches(1,i)) - points2(:,matches(2,i))).^2 );
    if d < 1
        %Inlier
        plot(points(1,matches(1,i)), points(2,matches(1,i)), 'g+');
        
        if rand < 0.1
            surfplot(points(:,matches(1,i)), info(:,matches(1,i)));
            figure(2);
            surfplot(points2(:,matches(2,i)), info2(:,matches(2,i)));
            figure(1);
        end
        
    else
        %Outlier
        plot(points(1,matches(1,i)), points(2,matches(1,i)), 'r+');
    end
end

figure(2);
plot(points(1,:), points(2,:), 'b+');
for i = 1:size(matches,2)
    %Distance between correspondences
    d = sum( (points(:,matches(1,i)) - points2(:,matches(2,i))).^2 );
    if d < 1
        %Inlier
        plot(points2(1,matches(2,i)), points2(2,matches(2,i)), 'g+');
    else
        %Outlier
        plot(points2(1,matches(2,i)), points2(2,matches(2,i)), 'r+');
    end
end

