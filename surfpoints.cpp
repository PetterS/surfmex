#include <cstdlib>
#include <stdexcept>
#include <iostream>
#include <sstream>
using namespace std;

#include <opencv/cv.h>

#include <opencv2/features2d/features2d.hpp>
#include <opencv2/nonfree/nonfree.hpp> 

using namespace cv;

//Define this macro if timing information should be calculated by startTime()--endTime()
//#define TIMING
//Prints the calculated timing information if defined
//#define PRINT_TIMING
#include "mextiming.h"

#include "mex.h"

#include "cppmatrix.h"



bool getOptionsField(const mxArray* mxoptions, int index, const char* name, double& value)
{
	const mxArray* mxfield   = mxGetFieldByNumber(mxoptions,0,index);
    const char*    fieldname = mxGetFieldNameByNumber(mxoptions,index);
    
    if (strcmp(fieldname,name)!=0) {
        return false;
    }
    
	if (mxfield != 0) {
		if  ( !mxIsNumeric(mxfield)  || 
			   mxGetNumberOfElements(mxoptions)!=1)
		{
			mexErrMsgTxt("SURFPOINTS: Invalid options field. Options must be scalars.");
			return false;
		}
		value = mxGetScalar(mxfield);
		return true;
	} else {
		return false;
	}
}

void mexFunctionReal(int			nlhs, 		/* number of expected outputs */
				 mxArray		*plhs[],	/* mxArray output pointer array */
				 int			nrhs, 		/* number of inputs */
				 const mxArray	*prhs[]		/* mxArray input pointer array */)
{
	using namespace std;
	
	cv::initModule_nonfree();

	if (nrhs < 1) {
		mexErrMsgTxt("Need arguments");
	}
	
	matrix<unsigned char> mximg(prhs[0]);
	ASSERT(mximg.O == 1);
	
	//
	// SURF Options
	//
	CvSURFParams params = cvSURFParams(500, 0);
	if (nrhs >= 2) {
		const mxArray* mxoptions = prhs[1];
		if (mxGetClassID(mxoptions)!=mxSTRUCT_CLASS) {
			mexErrMsgTxt("SURFMEX: Options must be provided as struct");
		}	
		if (mxGetNumberOfElements(mxoptions)!=1) {
			mexErrMsgTxt("SURFMEX: numel(options) ~= 1");
		}
		
		double value;
        
        int nfield = mxGetNumberOfFields(mxoptions);
        for (int field=0;field<nfield;++field) {
            if (getOptionsField(mxoptions,field,"nOctaveLayers",value)) {
                params.nOctaveLayers = int(value+0.5);
            }
            else if (getOptionsField(mxoptions,field,"nOctaves",value)) {
                params.nOctaves = int(value+0.5);
            }
            else if (getOptionsField(mxoptions,field,"hessianThreshold",value)) {
                params.hessianThreshold = value;
            }
            else if (getOptionsField(mxoptions,field,"extended",value)) {
                params.extended = value!=0;
            }
            else {
                char message[256];
                stringstream sout;
                sout << "Unknown field in options structure: \"" << mxGetFieldNameByNumber(mxoptions,field) << "\"";
                mexErrMsgTxt(sout.str().c_str());
            } 
        }
		
	}
	
	startTime();
	IplImage* img=cvCreateImage(cvSize(mximg.N,mximg.M),IPL_DEPTH_8U,1); 
	int height     = img->height;
	int width      = img->width;
	int step       = img->widthStep/sizeof(uchar);
	uchar* data    = (uchar *)img->imageData;

	for (int i=0;i<mximg.M;++i) {
		for (int j=0;j<mximg.N;++j) {
			data[i*step+j] = mximg(i,j);
		}
	}
	
	//Mat cvImg(mximg.N,mximg.M,CV_8UC1, mximg.data);
	/*IplImage iplimg = cvImg;
	IplImage* img = &iplimg;*/
	endTime("Converting image");
	
	CvMemStorage* storage = cvCreateMemStorage(0);
	CvSeq* keypoints;
	CvSeq* descriptors;
	cvExtractSURF( img, 0, &keypoints, &descriptors, storage, params );
	
	const int n = keypoints->total;
	const int length = (int)(descriptors->elem_size/sizeof(float));
	
	endTime("Extracting %d SURF features",n);
	
	
	/*
	vector<KeyPoint> keypoints_vec;
	SurfFeatureDetector surf;
	surf.detect(cvImg,keypoints_vec);
	
	const int n = keypoints_vec.size();
	const int length = 64;
	
	endTime("Extracting %d SURF features in the new way",n);
	*/
	
	
	matrix<double> mxpoints(2, n);
	matrix<float> mxdescr(length, n);
	matrix<signed char> mxsign(1, n);
	matrix<float> mxinfo(3, n);
	
	
	CvSeqReader reader, kreader;
	if (keypoints->total > 0) {
		cvStartReadSeq( keypoints, &kreader, 0 );
		cvStartReadSeq( descriptors, &reader, 0 );
		
		for(int i = 0; i < keypoints->total; i++ ) {
			const CvSURFPoint* kp = (const CvSURFPoint*)kreader.ptr;
			const float* mvec = (const float*)reader.ptr;
			CV_NEXT_SEQ_ELEM( kreader.seq->elem_size, kreader );
			CV_NEXT_SEQ_ELEM( reader.seq->elem_size, reader );
			
			mxpoints(0,i) = kp->pt.x;
			mxpoints(1,i) = kp->pt.y;
			
			mxsign(0,i) = kp->laplacian;
			
			mxinfo(0,i) = kp->size;
			mxinfo(1,i) = kp->hessian;
			mxinfo(2,i) = kp->dir;
			
			for (int j=0;j<length;++j) {
				mxdescr(j,i) = mvec[j];
			}
		}
	}
	
	
	if (nlhs >= 1) {
		plhs[0] = mxpoints;
	}
	if (nlhs >= 2) {
		plhs[1] = mxdescr;
	}
	if (nlhs >= 3) {
		plhs[2] = mxsign;
	}
	if (nlhs >= 4) {
		plhs[3] = mxinfo;
	}
	
	endTime("Writing output matrices");
	
	cvReleaseImage(&img);
	cvReleaseMemStorage(&storage);
	endTime("Releasing memory");
}


void mexFunction(int		nlhs, 		/* number of expected outputs */
                 mxArray	*plhs[],	/* mxArray output pointer array */
                 int		nrhs, 		/* number of inputs */
                 const mxArray	*prhs[]		/* mxArray input pointer array */)
{
	try {
		mexFunctionReal(nlhs,plhs,nrhs,prhs);
	}
	catch (bad_alloc& ) {
		mexErrMsgTxt("Out of memory");
	}
	catch (cv::Exception& e) {
		stringstream sout;
		sout << "Code     : " << e.code << endl;
		sout << "Error    : " << e.err  << endl;
		sout << "Function : " << e.func << endl;
		sout << "File     : " << e.file << endl;
		mexErrMsgTxt(sout.str().c_str());
	}
	catch (exception& e) {
		mexErrMsgTxt(e.what());
	}
	catch (...) {
		mexErrMsgTxt("Unknown exception");
	}
}
