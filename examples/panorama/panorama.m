%SURFmex example function
%   Petter Strandmark 2008
%   petter.strandmark@gmail,com  
function BigImage = panorama(files,output)
    %Default files if none are given
    if nargin <= 0
        files = {'a.jpg','b.jpg','c.jpg','d.jpg'};
    end

    %Preallocate cell arrays
    frames = cell(length(files),1);
    descr  = cell(length(files),1);
    I      = cell(length(files),1);
    for i = 1:length(files)
        %Read file
        I{i} = imread(files{i});
        %Calculate SURF descriptor
        tic
        [frames{i} descr{i} sign{i}] = surfpoints(rgb2gray(I{i}));
        timetaken = toc;
        I{i} = double(I{i})/255;
        disp(sprintf('Time taken to create %d points: %.2f seconds',size(frames{i},2),timetaken));
    end
       
    %Number of colors
    ncolors = size(I{1},3);

    xmin = 1;
    xmax = size(I{1},2);
    ymin = 1;
    ymax = size(I{1},1);
    
    H  = cell(length(files),1);
    for image = 2:length(files)
        
        %Find SURF matches
        tic
        matches = surfmatch(descr{1},sign{1},descr{image},sign{image});
        disp(sprintf('Time taken to match: %.4f', toc));
        
        Po = frames{1}(:,matches(1,:));
        Pt = frames{image}(:,matches(2,:));
        Po = [Po;ones(1,size(Po,2))];
        Pt = [Pt;ones(1,size(Pt,2))];

        %Transformation from first image to the coordinate
        %system of the current image
        H{image} = estimate_projective_ransac(Po,Pt,4);   
        
        gridxmin = 1;
        gridxmax = size(I{image},2);
        gridymin = 1;
        gridymax = size(I{image},1);
        [gridX gridY] = meshgrid(gridxmin:gridxmax,gridymin:gridymax);
        
        %Transform the coordinates back to the coordinate system
        %of the first image
        transformedgrid = H{image} \ [gridX(:)';gridY(:)';ones(1,numel(gridX))];
        objgridX = transformedgrid(1,:) ./ transformedgrid(3,:);
        objgridY = transformedgrid(2,:) ./ transformedgrid(3,:);
        
        %Update the maximum and minimum coordinates
        xmax=max(max(objgridX),xmax);
        ymax=max(max(objgridY),ymax);
        xmin=min(min(objgridX),xmin);
        ymin=min(min(objgridY),ymin);        
    end
    xmin = floor(xmin);
    xmax = ceil(xmax);
    ymin = floor(ymin);
    ymax = ceil(ymax);
    
    fprintf('Panorama computed, generating large image...\n');
    
    %Now that we know the dimensions, create the big
    %image 
    BigImage = NaN*zeros( ymax-ymin+1, xmax-xmin+1, ncolors);
    BigImage( -ymin+2:-ymin+size(I{1},1)+1, ...
              -xmin+2:-xmin+size(I{1},2)+1,:) = I{1};
    
    %The grid of the big image
    [biggridX, biggridY] = meshgrid(xmin:xmax,ymin:ymax);
    gridsize = size(biggridX);

    for image = 2:length(files)    
        %Transform the coordinates from the big image to the
        %coordinate system of the current image
        transformedgrid = H{image} * [biggridX(:)';biggridY(:)';ones(1,numel(biggridX))];
        objgridX = transformedgrid(1,:) ./ transformedgrid(3,:);
        objgridY = transformedgrid(2,:) ./ transformedgrid(3,:);
        
        for color = 1:ncolors
            %Calculate the values of the current image at these 
            %locations
            TransImage = interp2(I{image}(:,:,color),objgridX,objgridY);
            TransImage = reshape(TransImage,gridsize);

            %Add these values to the big image
            for i = 1:size(BigImage,1)
                for j = 1:size(BigImage,2)         
                    % isnan(BigImage(i,j)) && 
                    if  ~isnan(TransImage(i,j))
                        BigImage(i,j,color) = TransImage(i,j);
                    end
                end
            end 
        end
        
        %Create a frame
        frame = [1 1 size(I{image},2) size(I{image},2);
        size(I{image},1) 1 1 size(I{image},1)];
        transformedframe = H{image} \ [frame; ones(1,4)];
        transformedframe(1,:) = transformedframe(1,:) ./ transformedframe(3,:)  -  xmin + 1;
        transformedframe(2,:) = transformedframe(2,:) ./ transformedframe(3,:)  -  ymin + 1;
        iframe{image}      = transformedframe(1:2,:);
    end
    

    
    

    if nargout == 0
        for image = 1:length(files) 
            subplot(5,3,image);
            imshow(I{image});
        end

        subplot(5,3,[7 8 9 10 11 12 13 14 15]);

        imshow(BigImage);
        hold on

        for image = 2:length(files)
            plot(iframe{image}(1,[1:4 1]),iframe{image}(2,[1:4 1]),'r-','LineWidth',1);
		end
    end
    
    if nargin > 1
        imwrite(BigImage,output);
    end
end