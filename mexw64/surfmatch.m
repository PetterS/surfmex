%SURFMATCH Computes matches between two sets of SURF interest points
%   
%   MATCHES = SURFMATCH(DESCR1, DESCR2)
%   MATCHES = SURFMATCH(DESCR1, SIGN1, DESCR2, SIGN2)
%   MATCHES = SURFMATCH(..., THRESH)
%
%   MATCHES = SURFMATCH(DESCR1, DESCR2) computes matches between the two 
%   sets of descriptors returned by SURFPOINTS. MATCHES is a 2-by-N matrix
%   where the first row are indices corresponding to columns in DESCR1 and
%   the second row corresponds to DESCR2.
%
%   MATCHES = SURFMATCH(DESCR1, SIGN1, DESCR2, SIGN2) also takes the sign
%   of the laplacian into account for faster matching.
%
%   MATCHES = SURFMATCH(..., THRESH) provides an additional threshold
%   parameter discussed in the reference. The default value is 0.7.
%
%   See also SURFPOINTS.
%
%   Reference: Herbert Bay, Tinne Tuytelaars and Luc Van Gool "SURF: 
%   Speeded Up Robust Features", Proceedings of the 9th European Conference
%   on Computer Vision, Springer LNCS volume 3951, part 1, pp 404--417, 
%   2006 
%
%   Copyright 2010 Petter Strandmark
%   petter.strandmark@gmail.com