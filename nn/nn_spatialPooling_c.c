#include "mex.h"
#include "matrix.h"
#include "math.h"

#define max(a,b)            (((a) > (b)) ? (a) : (b))

// nn_spatialSubSampling(y, kH, kW, dH, dW, maxFlag)

void nn_spatialPooling(float *pfY, long kH, long kW, long dH, long dW, 
        long h, long w, long nPlanes, int doMaxPooling, float* pfYout) {    
    
    
    long h_out = floor( (h - kH)/ dH) + 1;
    long w_out = floor( (w - kW) /dW) + 1;
    
//  y_out1 = zeros(h_out, w_out, nPlanes);    
//    pfYout = (float***) mxCalloc(h_out * w_out * nPlanes);
    
//     h_idxs = arrayfun( @(i_start) i_start : i_start+kH-1,  1 : dH: h-kH+1, 'un', 0 );
//     w_idxs = arrayfun( @(j_start) j_start : j_start+kW-1,  1 : dW: w-kW+1, 'un', 0 );
    
    
    long i,j,k, offset, s, t;
//     long kW_x_kH = kW*kH;
//     long kW_x_kH_x_nPlanes = kW*kH*nPlanes;
    double maxVal, sumVals;
            
    float weight_conv_input;
    

    for (k = 0; k < nPlanes; k++) {
        for (i = 0; i < h_out; i++) {
            for (j = 0; j < w_out; j++) {

                if (doMaxPooling) {
                     maxVal = pfY[ dW*i + (dH*j)*h + k*h*w ];
                     for (s = 0; s < kH; s++) {  
                            for (t = 0; t < kW; t++) {                                
                                 maxVal = max(maxVal, pfY[ dW*i+s + (dH*j+t)*h + k*h*w ]);
                            }
                     }

                     pfYout[i + j*h_out + k*h_out*w_out] = maxVal;
                } else {
                     
                     sumVals = 0;
                     for (s = 0; s < kH; s++) {  
                            for (t = 0; t < kW; t++) {                                
                                 sumVals += pfY[ dW*i+s + (dH*j+t)*h + k*h*w ];
                            }
                     }
                     pfYout[i + j*h_out + k*h_out*w_out] = sumVals;

                }


            }
        }
    }
    
     
}
        

// nn_spatialConvolutionMap(y, bias, weight, dH, dW, connTable)

long mxGetSize( const mxArray * pm, int dim) {
    mwSize nDims = mxGetNumberOfDimensions(pm);
    
    if (nDims < dim) {
        return 1;
    } else {
        const mwSize* size = mxGetDimensions(pm);
        return size[dim-1];
    }
}

//int mxIsSingle( const mxArray *pm ) {
//    return mxIsClass(pm, "single");
//}


// nn_spatialSubSampling(y, kH, kW, dH, dW, maxFlag)
    
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    
    // INPUT:
    float *pfY;
    
    // OUTPUT:
    float *pfYout;
    mwSize ndims_out, *dims_out;
    
    // Local:    
    const mxArray * pArg;
    // mwSize nrowsX,ncolsX, nrowsY1, ncolsY1, nrowsY2, ncolsY2;

        
    //long Nx, nshift, Nvecs, Ny;
    long h, w, kH, kW, dH, dW, nPlanes, h_out, w_out;
    int doMaxPooling;
        
    
    /* --------------- Check inputs ---------------------*/
    if ((nrhs < 5) || (nrhs > 6))
        mexErrMsgTxt("5 or 6 inputs required");
    if (nlhs > 1)  
        mexErrMsgTxt("only one output allowed");
    
    /// ------------------- Y ----------
	pArg = prhs[0];    
	if (!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) )
            mexErrMsgTxt("Input 1 (Y) must be a noncomplex matrix of singles.");
        
    pfY  = (float*) mxGetData(prhs[0]);
    h = mxGetM(pArg);
    w = mxGetSize(pArg, 2);
    nPlanes = (long) mxGetSize(pArg, 3);

    
    /// ------------------- kH ----------
    pArg = prhs[1];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) || (mxGetNumberOfElements(pArg) > 1) ) { 
        mexErrMsgTxt("Input 2 (kH) must be a noncomplex single scalar.");
    }
    kH = (long) mxGetScalar(pArg);
    
    /// ------------------- kW ----------
    pArg = prhs[2];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) || (mxGetNumberOfElements(pArg) > 1) ) { 
        mexErrMsgTxt("Input 3 (kW) must be a noncomplex single scalar.");
    }
    kW = (long) mxGetScalar(pArg);

    
    
    /// ------------------- dH ----------
    pArg = prhs[3];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) || (mxGetNumberOfElements(pArg) > 1) ) { 
        mexErrMsgTxt("Input 4 (dH) must be a noncomplex single scalar.");
    }
    dH = (long) mxGetScalar(pArg);
    
    /// ------------------- dW ----------
    pArg = prhs[4];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) || (mxGetNumberOfElements(pArg) > 1) ) { 
        mexErrMsgTxt("Input 5 (dW) must be a noncomplex single scalar.");
    }
    dW = (long) mxGetScalar(pArg);


    /// ------------------- doMaxPooling ----------    
    doMaxPooling = (int) ( (nrhs == 6) && (!mxIsEmpty(prhs[5])) && ((int) mxGetScalar(prhs[5]) == 1) );
            
    
    h_out = floor( (h - kH)/ dH) + 1;
    w_out = floor( (w - kW)/ dW) + 1;
    //mexPrintf("h, w, kH, kW, dH, dW = %d, %d, %d, %d, %d, %d\n", h, w, kH, kW, dH, dW);
    
    
    /// ------------------- Yout (OUTPUT)----------        
    ndims_out = 3;
    dims_out = (mwSize*) mxCalloc(ndims_out, sizeof(mwSize));
    dims_out[0] = (mwSize) h_out;
    dims_out[1] = (mwSize) w_out;
    dims_out[2] = (mwSize) nPlanes;
            
    //mexPrintf("Creating output ... \n");
    //mexPrintf("Size Yout (before) (a) = %d x %d x %d\n", h_out, w_out, nPlanes);
    //mexPrintf("Size Yout (before) (b) = %d x %d x %d\n", dims_out[0], dims_out[1], dims_out[2]);
        
    
    plhs[0] = mxCreateNumericArray(ndims_out, dims_out,
         mxSINGLE_CLASS, mxREAL);
    pfYout = (float*) mxGetData(plhs[0]);

    //mexPrintf("Size Yout = %d x %d x %d\n", mxGetSize(plhs[0], 1), mxGetSize(plhs[0], 2), mxGetSize(plhs[0], 3));

    //return;
    nn_spatialPooling(pfY, kH, kW, dH, dW, 
        h, w, nPlanes, doMaxPooling, pfYout);
            

}

