%SURFPOINTS Calculate SURF interest points
%
%  [POINTS, DESCR]             = SURFPOINTS(I)
%  [POINTS, DESCR]             = SURFPOINTS(I, OPTIONS)
%  [POINTS, DESCR, SIGN]       = SURFPOINTS(...)
%  [POINTS, DESCR, SIGN, INFO] = SURFPOINTS(...)
%
%
%   [POINTS, DESCR] = SURFPOINTS(I) takes an image I and returns the
%   locations of the N points of interest in the 2-by-N matrix POINTS,
%   where each column corresponds to one point of interest. The descriptors
%   are returned in the D-by-N matrx DESCR, where D varies depending on
%   what type of descriptors are calculated (default is 64).
%
%   [POINTS, DESCR] = SURFPOINTS(I, OPTIONS) calculates interest points
%   with addtional options. OPTIONS is a struct with the following possible
%   fields (passed into OpenCV):
%       
%       nOctaveLayers    : Layers within an octave(default 2)
%       nOctaves         : Number of octaves (default 4)
%       hessianThreshold : Higher values gives fewer points (default 500)
%       extended         : If set to 1, 128-dimensional SURF is used
%                          (default 0)
%   An omitted field will be assigned the default value 
%
%   [POINTS, DESCR, SIGN] = SURFPOINTS(...) puts the sign of the laplacian
%   into the 1-by-N matrix SIGN. This can be used for faster matching.
%
%   [POINTS, DESCR, SIGN INFO] = SURFPOINTS(...) puts extra information in
%   the 4-by-N matrix INFO. The columns of INFO corresponds to each
%   interest point.
%           INFO(1,:)  detected scales of the interest points
%           INFO(2,:)  strength of the interest points
%           INFO(3,:)  orientation of the interest points
%
%   See also SURFOPTIONS, SURFMATCH.
%
%   Reference: Herbert Bay, Tinne Tuytelaars and Luc Van Gool "SURF: 
%   Speeded Up Robust Features", Proceedings of the 9th European Conference
%   on Computer Vision, Springer LNCS volume 3951, part 1, pp 404--417, 
%   2006 
%
%   Copyright 2010 Petter Strandmark
%   petter.strandmark@gmail.com