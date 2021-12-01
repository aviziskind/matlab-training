#include "mex.h"
#include "matrix.h"
#include "math.h"

// nn_spatialConvolutionMap(y, bias, weight, dH, dW, connTable)

void nn_spatialConvolution3D_no_bias(float *pfY, float *pfWeight, long dH, long dW, 
        long h, long w, long kH, long kW, long nInputPlanes, long nOutputPlanes,  float* pfYout) {    
    
    
    long h_out = floor( (h - kH)/ dH) + 1;
    long w_out = floor( (w - kW) /dW) + 1;
    
//  y_out1 = zeros(h_out, w_out, nOutputPlanes);    
//    pfYout = (float***) mxCalloc(h_out * w_out * nOutputPlanes);
    
    long i,j,k,l, offset, s, t;
    long kW_x_kH = kW*kH;
    long kW_x_kH_x_nInputPlanes = kW*kH*nInputPlanes;

            
    float weight_conv_input;
    float a,b;
    long count = 0;
            
    
    //for (conn_i = 0; conn_i < nConnections; conn_i++) {
        //l = (long) pfConnTable[2*conn_i]   -1;   // go through all input/output plane connections
        //k = (long) pfConnTable[2*conn_i+1] -1;

    for (k = 0; k < nOutputPlanes; k++) {      // go through all output positions
        
        
        for (l = 0; l < nInputPlanes; l++) {

            for (i = 0; i < h_out; i++) {      // go through all output positions
                for (j = 0; j < w_out; j++) {

                    // y_out(:,:,k) = bias(k) ;    
                    if (l==0) {  // only add bias once:
                        pfYout[i + j*h_out + k*h_out*w_out] = pfBias[k];
                    }
                    
                    // weight_conv_input = weight_conv_input + weight(s,t, k,l) * y( dH*(i-1)+s, dW*(j-1)+t, l );
                    weight_conv_input = 0;
                    for (s = 0; s < kH; s++) {  // convolution 
                        for (t = 0; t < kW; t++) {
                            weight_conv_input +=    pfWeight[s + t*kH + l* kW*kH + k * kW_x_kH_x_nInputPlanes] * 
                                                    pfY[ dW*i+s + (dH*j+t)*h + l*h*w ];
                        }
                    }

                    
                    
                    pfYout[i + j*h_out + k*h_out*w_out] += weight_conv_input;
  

                    
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


    
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    
    // INPUT:
    float *pfY, *pfBias, *pfWeight;
    
    // OUTPUT:
    float *pfYout;
    mwSize ndims_out, *dims_out;
    
    // Local:    
    const mxArray * pArg;
    // mwSize nrowsX,ncolsX, nrowsY1, ncolsY1, nrowsY2, ncolsY2;

        
    //long Nx, nshift, Nvecs, Ny;
    long h, w, kH, kW, dH, dW, nInputPlanes, nInputPlanes_y, h_out, w_out, nOutputPlanes;
    long nBias;
        
    
    /* --------------- Check inputs ---------------------*/
    if (nrhs != 5)
        mexErrMsgTxt("5 inputs required");
    if (nlhs > 1)  
        mexErrMsgTxt("only one output allowed");
    
    /// ------------------- Y ----------
	pArg = prhs[0];    
	if (!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) )
            mexErrMsgTxt("Input 1 (Y) must be a noncomplex matrix of singles.");
        
    pfY  = (float*) mxGetData(prhs[0]);
    h = mxGetM(pArg);
    w = mxGetSize(pArg, 2);
    nInputPlanes_y = (long) mxGetSize(pArg, 3);
    
    //mexPrintf("Size Y = %d x %d x %d\n", mxGetSize(pArg, 1), mxGetSize(pArg, 2), mxGetSize(pArg, 3));
    /// ------------------- Bias ----------
    pArg = prhs[1];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) ) { 
            mexErrMsgTxt("Input 2 (Bias) must be a noncomplex single matrix.");
    }
    
    pfBias = (float*) mxGetData(pArg);
    nBias = (long) mxGetNumberOfElements(pArg);

            
    /// ------------------- Weight ----------
    pArg = prhs[2];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) ) { 
            mexErrMsgTxt("Input 3 (Weight) must be a noncomplex single matrix.");
    }
    
    pfWeight = (float*) mxGetData(pArg);
    kH = mxGetM(pArg);
    kW = mxGetSize(pArg, 2); 
    nInputPlanes = mxGetSize(pArg, 3);
    nOutputPlanes = mxGetSize(pArg, 4);
    
    if (nInputPlanes_y  != nInputPlanes) {
        mexPrintf("number of input planes in weight mtx: %d. number of input planes in y : %d\n", nInputPlanes, nInputPlanes_y);
        mexErrMsgTxt("number of input planes in weight mtx must be the same as the number of input planes in y");
    }

    
    if (nBias != nOutputPlanes) {
        mexPrintf("number of elements in Bias : %d. size3 = %d\n", nBias, nOutputPlanes);
        mexErrMsgTxt("number of elements in Bias must be the same size of dimension 3 of weights");
    }
    //mexPrintf("Size Weight = %d x %d x %d\n", kH, kW, nOutputPlanes);
    //mexPrintf("Size Weight = %d x %d x %d\n", mxGetSize(pArg, 1), mxGetSize(pArg, 2), mxGetSize(pArg, 3));

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
        
    
    h_out = floor( (h - kH)/ dH) + 1;
    w_out = floor( (w - kW)/ dW) + 1;
    //mexPrintf("h, w, kH, kW, dH, dW = %d, %d, %d, %d, %d, %d\n", h, w, kH, kW, dH, dW);
    
//  y_out1 = zeros(h_out, w_out, nOutputPlanes);    
//    pfYout = (float***) mxCalloc(h_out * w_out * nOutputPlanes);
    
    /// ------------------- Yout (OUTPUT)----------        
    ndims_out = 3;
    dims_out = (mwSize*) mxCalloc(ndims_out, sizeof(mwSize));
    dims_out[0] = (mwSize) h_out;
    dims_out[1] = (mwSize) w_out;
    dims_out[2] = (mwSize) nOutputPlanes;
            
    //mexPrintf("Creating output ... \n");
    //mexPrintf("Size Yout (before) (a) = %d x %d x %d\n", h_out, w_out, nOutputPlanes);
    //mexPrintf("Size Yout (before) (b) = %d x %d x %d\n", dims_out[0], dims_out[1], dims_out[2]);
        
    
    plhs[0] = mxCreateNumericArray(ndims_out, dims_out,
         mxSINGLE_CLASS, mxREAL);
    pfYout = (float*) mxGetData(plhs[0]);

    //mexPrintf("Size Yout = %d x %d x %d\n", mxGetSize(plhs[0], 1), mxGetSize(plhs[0], 2), mxGetSize(plhs[0], 3));

            
    nn_spatialConvolution(pfY, pfBias, pfWeight, dH, dW, 
        h, w, kH, kW, nInputPlanes, nOutputPlanes, pfYout);


}

