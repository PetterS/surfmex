function make
    fprintf('Platform : %s\n', mexext);

    %Change this to OpenCV lib directory
    opencv_lib_dir = 'D:\Build\opencv-2013\install\x64\vc12\lib\';
	%Change this to OpenCV include directory
    opencv_include_dir = 'D:\Build\opencv-2013\install\include';
    
	mex('-outdir', mexext, 'surfmatch.cpp', ...
	    ['-I' opencv_include_dir]);
	disp('surfmatch OK')

    mex('-outdir', mexext, 'surfpoints.cpp', ...
		['-I' opencv_include_dir], ...
	    [opencv_lib_dir 'opencv_core300.lib'], ...
	    [opencv_lib_dir 'opencv_nonfree300.lib'], ...
		[opencv_lib_dir 'opencv_legacy300.lib']);
	disp('surfpoints OK')

    disp('Compilation OK');
end
