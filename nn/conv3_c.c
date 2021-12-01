#include "mex.h"
#include "matrix.h"
#include "math.h"

// nn_spatialConvolutionMap(y, weight, dH, dW, dT)

void conv3D(float *pfY, float *pfWeight, long dH, long dW, long dT, 
        long h, long w, long t, long kH, long kW, long kT,     float* pfYout) {    
    
    
    long h_out = (long) floor( (h - kH)/ dH) + 1;
    long w_out = (long) floor( (w - kW) /dW) + 1;
    long t_out = (long) floor( (t - kT) /dT) + 1;
    
//  y_out1 = zeros(h_out, w_out, nOutputPlanes);    
//    pfYout = (float***) mxCalloc(h_out * w_out * nOutputPlanes);
    
    long i,j,k,  q,r,s;
    long kW_x_kH = kW*kH;
    long kW_x_kH_x_kT = kW*kH*kT;
//    long kW_x_kH_x_nInputPlanes = kW*kH*nInputPlanes;
    long h_x_w = h * w;
            
    float weight_conv_input;

        

    // assume nOutputPlanes = 1
  //  for (k = 0; k < nOutputPlanes; k++) {      // go through all output positions
        
     
    // assume nInputPlanes = 1
   //     for (l = 0; l < nInputPlanes; l++) {

            for (i = 0; i < h_out; i++) {      // go through all output positions
                for (j = 0; j < w_out; j++) {
                    for (k = 0; k < t_out; k++) {

                    
                        // y_out(:,:,k) = bias(k) ;    
                        //if (l==0) {  // only add bias once:
                        //    pfYout[i + j*h_out + k*h_out*w_out] = pfBias[k];
                        //}

                        // weight_conv_input = weight_conv_input + weight(s,t, k,l) * y( dH*(i-1)+s, dW*(j-1)+t, l );
                        weight_conv_input = 0;
                        for (q = 0; q < kH; q++) {  // convolution 
                            for (r = 0; r < kW; r++) {
                                for (s = 0; s < kT; s++) {
                                
                                    weight_conv_input +=    pfWeight[q + r*kH + s*kW_x_kH ] * 
                                                            pfY[ (dW*i)+q + (dH*j+r)*h  +  (dT*k + s)*h_x_w       ];
                                    
                                }
                            }
                        }


                        pfYout[i + j*h_out + k*h_out*w_out] += weight_conv_input;
                    }  

                    
                }

            }
      //  }       
    //}
    
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
    float *pfY, *pfWeight;
    
    // OUTPUT:
    float *pfYout;
    mwSize ndims_out, *dims_out;
    
    // Local:    
    const mxArray * pArg;
    // mwSize nrowsX,ncolsX, nrowsY1, ncolsY1, nrowsY2, ncolsY2;

        
    //long Nx, nshift, Nvecs, Ny;
    long h, w, t,  kH, kW, kT,  dH, dW, dT,   h_out, w_out, t_out;
        
    
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
    h = (long) mxGetM(pArg);
    w = (long) mxGetSize(pArg, 2);
    t = (long) mxGetSize(pArg, 3);
    
    //nInputPlanes_y = (long) mxGetSize(pArg, 3);
    
    //mexPrintf("Size Y = %d x %d x %d\n", mxGetSize(pArg, 1), mxGetSize(pArg, 2), mxGetSize(pArg, 3));

            
    /// ------------------- Weight ----------
    pArg = prhs[1];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) ) { 
            mexErrMsgTxt("Input 2(Weight) must be a noncomplex single matrix.");
    }
    
    pfWeight = (float*) mxGetData(pArg);
    kH = (long) mxGetM(pArg);
    kW = mxGetSize(pArg, 2); 
    kT = mxGetSize(pArg, 3);
    //nInputPlanes = mxGetSize(pArg, 3);
    //nOutputPlanes = mxGetSize(pArg, 4);
    

    //mexPrintf("Size Weight = %d x %d x %d\n", kH, kW, nOutputPlanes);
    //mexPrintf("Size Weight = %d x %d x %d\n", mxGetSize(pArg, 1), mxGetSize(pArg, 2), mxGetSize(pArg, 3));

    /// ------------------- dH ----------
    pArg = prhs[2];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) || (mxGetNumberOfElements(pArg) > 1) ) { 
        mexErrMsgTxt("Input 3 (dH) must be a noncomplex single scalar.");
    }
    dH = (long) mxGetScalar(pArg);
    
    /// ------------------- dW ----------
    pArg = prhs[3];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) || (mxGetNumberOfElements(pArg) > 1) ) { 
        mexErrMsgTxt("Input 4 (dW) must be a noncomplex single scalar.");
    }
    dW = (long) mxGetScalar(pArg);
        
    
    /// ------------------- dT ----------
    pArg = prhs[4];
	if(!mxIsNumeric(pArg) || !mxIsSingle(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) || (mxGetNumberOfElements(pArg) > 1) ) { 
        mexErrMsgTxt("Input 5 (dT) must be a noncomplex single scalar.");
    }
    dT = (long) mxGetScalar(pArg);
    
    
    h_out = (long) floor( (h - kH)/ dH) + 1;
    w_out = (long) floor( (w - kW)/ dW) + 1;
    t_out = (long) floor( (t - kT)/ dT) + 1;
    //mexPrintf("h, w, kH, kW, dH, dW = %d, %d, %d, %d, %d, %d\n", h, w, kH, kW, dH, dW);
    
//  y_out1 = zeros(h_out, w_out, nOutputPlanes);    
//    pfYout = (float***) mxCalloc(h_out * w_out * nOutputPlanes);
    
    /// ------------------- Yout (OUTPUT)----------        
    ndims_out = 3;
    dims_out = (mwSize*) mxCalloc(ndims_out, sizeof(mwSize));
    dims_out[0] = (mwSize) h_out;
    dims_out[1] = (mwSize) w_out;
    dims_out[2] = (mwSize) t_out;
            
    //mexPrintf("Creating output ... \n");
    //mexPrintf("Size Yout (before) (a) = %d x %d x %d\n", h_out, w_out, nOutputPlanes);
    //mexPrintf("Size Yout (before) (b) = %d x %d x %d\n", dims_out[0], dims_out[1], dims_out[2]);
        
    
    plhs[0] = mxCreateNumericArray(ndims_out, dims_out,
         mxSINGLE_CLASS, mxREAL);
    pfYout = (float*) mxGetData(plhs[0]);

    //mexPrintf("Size Yout = %d x %d x %d\n", mxGetSize(plhs[0], 1), mxGetSize(plhs[0], 2), mxGetSize(plhs[0], 3));

            
    conv3D(pfY, pfWeight, dH, dW, dT, 
        h, w, t, kH, kW, kT,   pfYout);


}

