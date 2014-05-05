function options = surfoptions
%SURFOPTIONS Default options for SURF interest point calculation
%
%  OPTIONS = SURFOPTIONS returns a structure with fields initialized to
%  default values.
%
%  Parameters are directly passed into OpenCV. If not present,
%  OpenCV's default vaules are used.
%
%   See also SURFPOINTS.
%
%   Copyright 2010 Petter Strandmark
%   petter.strandmark@gmail.com



    options.nOctaveLayers    = 2;
    options.nOctaves  = 4;
    
    %Response treshold
    options.hessianThreshold = 500;
    
    %If the extended flag is turned on, SURF 128 is used
    options.extended        = 0;
end
