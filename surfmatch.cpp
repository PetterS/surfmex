/*
 *
 * Petter Strandmark 2010
 *
 * Uses some code from Andrea Vedaldi's SIFT library
 *
 */
#include <cstdlib>
#include <stdexcept>
#include <iostream>
#include <sstream>
#include<cstdlib>
#include<cmath>
 using namespace std;
 
#include"mex.h"

#include "mexutils.h"
#include "cppmatrix.h"

struct Pair
{ 
	int k1; 
	int k2;
	double score;
};

void mexFunctionReal(int nout, mxArray *out[], 
                 int nin, const mxArray *in[])
{
	using namespace std;
    int K1, K2, ND;
    double thresh = 0.7 ;
    
    enum {MATCHES=0,D} ;
    int k;
    Pair *pairs_begin, *pairs_end, *pairs_iterator;                                                                        
    int k1, k2;
    
    if (nin < 2 || nin > 5) {
        mexErrMsgTxt("2,3,4 or 5 input arguments required");
    }

	matrix<float> mxdescr1;
	matrix<float> mxdescr2;
	matrix<signed char> mxsign1;
	matrix<signed char> mxsign2;
	
    if (nin == 2 || nin == 3) {
        mxdescr1.init(in[0]);
        mxdescr2.init(in[1]);
    } else {
        mxdescr1.init(in[0]);
        mxdescr2.init(in[2]);
        mxsign1.init(in[1]);
        mxsign2.init(in[3]);
    }
       
    ASSERT( mxdescr1.O == 1 && mxdescr2.O == 1);
	ASSERT( mxdescr1.M == mxdescr2.M );
    K1 = mxdescr1.N;
    K2 = mxdescr2.N;
    ND = mxdescr1.M;
	
	float* descr1 = mxdescr1.data;
	float* descr2 = mxdescr2.data;
	signed char* sign1 = mxsign1.data;
	signed char* sign2 = mxsign2.data;

    if (sign1) {
		ASSERT( mxsign1.numel() == K1 );
		ASSERT( mxsign2.numel() == K2 );
    }
    
	int THRESH = 0;
    if(nin == 3) {
        THRESH = 2;
    }
    else if (nin == 5) {
        THRESH = 4;
    }
    if (THRESH) {
        matrix<double> mxthresh(in[THRESH]);
		ASSERT(mxthresh.numel() == 1);
        thresh = mxthresh(0);
    }
 
 
  /* ------------------------------------------------------------------
  **                                                         Do the job
  ** --------------------------------------------------------------- */ 
  
    pairs_begin = (Pair*) mxMalloc(sizeof(Pair) * (K1+K2)) ;
    pairs_iterator = pairs_begin ;

    float* d1 = descr1;
    for(k1 = 0 ; k1 < K1 ; ++k1, d1 += ND ) {                        
                                                                        
      float best = mxGetInf();                                     
      float second_best = mxGetInf();                               
      int bestk = -1 ;                                                  
                                                                        
      /* For each point P2[k2] in the second image... */
      float* d2 = descr2;
      for(k2 =  0 ; k2 < K2 ; ++k2, d2 += ND) {                      
        if (!sign1 || (sign1[k1] == sign2[k2])) {
            int bin ;                                                       
            float acc = 0 ;                                         
            for(bin = 0 ; bin < ND ; ++bin) {                               
              float delta = d1[bin] - d2[bin];                              
              acc += delta*delta;                                          
            }                                                               

            /* Filter the best and second best matching point. */           
            if(acc < best) {                                                
              second_best = best ;                                          
              best = acc ;                                                  
              bestk = k2 ;                                                  
            } else if(acc < second_best) {                                  
              second_best = acc ;                                           
            }                        
        }
      }                                                                 
                                                                        
                                                                        
      /* Lowe's method: accept the match only if unique. */             
      if( (float) best <= thresh * (float) second_best &&               
         bestk != -1) {                                                 
        pairs_iterator->k1 = k1 ;                                       
        pairs_iterator->k2 = bestk ;                                    
        pairs_iterator->score = second_best / best ;                    
        pairs_iterator++ ;                                              
      }                                                                 
    }                                                                   
                                                                        
    /* ---------------------------------------------------------------
     *                                                        Finalize
     * ------------------------------------------------------------ */
   
	pairs_end = pairs_iterator ;
	double* D_pt = 0;

	matrix<unsigned int> mxout(2, pairs_end-pairs_begin);
	out[MATCHES] = mxout;
	unsigned int* M_pt = mxout.data;
		
	if(nout > 1) {
		matrix<double> mxoutD(1,pairs_end-pairs_begin);
		out[D] = mxoutD;
		D_pt = mxoutD.data;
	}

	for(pairs_iterator = pairs_begin ; 
		pairs_iterator < pairs_end  ; 
		++pairs_iterator) {
		
		*M_pt++ = pairs_iterator->k1 + 1 ;
		*M_pt++ = pairs_iterator->k2 + 1 ;
		if(nout > 1) {
			*D_pt++ = pairs_iterator->score ;
		}
	}

    mxFree(pairs_begin) ;
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
	catch (exception& e) {
		mexErrMsgTxt(e.what());
	}
	catch (...) {
		mexErrMsgTxt("Unknown exception");
	}
}
