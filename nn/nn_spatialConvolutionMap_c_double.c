#include "mex.h"
#include "matrix.h"
#include "math.h"

// nn_spatialConvolutionMap(y, bias, weight, dH, dW, connTable)

void nn_spatialConvolutionMap(double *pdY, double *pdBias, double *pdWeight, long dH, long dW, double* pdConnTable, 
        long h, long w, long kH, long kW, long nInputPlanes, long nOutputPlanes, long nConnections,    double* pdYout) {    
    
    
    long h_out = floor( (h - kH)/ dH) + 1;
    long w_out = floor( (w - kW) /dW) + 1;
    
//  y_out1 = zeros(h_out, w_out, nOutputPlanes);    
//    pdYout = (double***) mxCalloc(h_out * w_out * nOutputPlanes);
    
    long i,j,conn_i,k,l, offset, s, t;
    long kW_x_kH = kW*kH;
    long kW_x_kH_x_nInputPlanes = kW*kH*nInputPlanes;
            
    double weight_conv_input;
    
    for (conn_i = 0; conn_i < nConnections; conn_i++) {
        l = (long) pdConnTable[2*conn_i]   -1;   // go through all input/output plane connections
        k = (long) pdConnTable[2*conn_i+1] -1;

        for (i = 0; i < h_out; i++) {      // go through all output positions
            for (j = 0; j < w_out; j++) {
                     
                weight_conv_input = 0;
            
                for (s = 0; s < kH; s++) {  // convolution 
                    for (t = 0; t < kW; t++) {
                        // weight_conv_input = weight_conv_input + weight(s,t, k,l) * y( dH*(i-1)+s, dW*(j-1)+t, l );
                        weight_conv_input += pdWeight[s + t*kH + k* kW*kH + l * kW_x_kH_x_nInputPlanes] * 
                                             pdY[ dW*i+s + (dH*j+t)*h + l*h*w ];
                    }
                }
                
                // y_out(i,j,k) = y_out(i,j,k) + bias(k) + weight_conv_input;    
                pdYout[i + j*h_out + k*h_out*w_out] += pdBias[k] + weight_conv_input;
            
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

    
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    
    // INPUT:
    double *pdY, *pdBias, *pdWeight, *pdConnTable;
    
    // OUTPUT:
    double *pdYout;
    mwSize ndims_out, *dims_out;
    
    // Local:    
    const mxArray * pArg;
    // mwSize nrowsX,ncolsX, nrowsY1, ncolsY1, nrowsY2, ncolsY2;

        
    //long Nx, nshift, Nvecs, Ny;
    long h, w, kH, kW, dH, dW, nInputPlanes, h_out, w_out, nOutputPlanes, nConnections;
    long nBias;
        
    
    /* --------------- Check inputs ---------------------*/
    if (nrhs != 6)
        mexErrMsgTxt("6 inputs required");
    if (nlhs > 1)  
        mexErrMsgTxt("only one output allowed");
    
    /// ------------------- Y ----------
	pArg = prhs[0];    
	if (!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) )
            mexErrMsgTxt("Input 1 (Y) must be a noncomplex matrix of doubles.");
        
    pdY  = mxGetPr(prhs[0]);
    h = mxGetM(pArg);
    w = mxGetSize(pArg, 2);
    nInputPlanes = (long) mxGetSize(pArg, 3);
    
    //mexPrintf("Size Y = %d x %d x %d\n", mxGetSize(pArg, 1), mxGetSize(pArg, 2), mxGetSize(pArg, 3));
    /// ------------------- Bias ----------
    pArg = prhs[1];
	if(!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) ) { 
            mexErrMsgTxt("Input 2 (Bias) must be a noncomplex double matrix.");
    }
    
    pdBias = mxGetPr(pArg);
    nBias = (long) mxGetNumberOfElements(pArg);

            
    /// ------------------- Weight ----------
    pArg = prhs[2];
	if(!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) ) { 
            mexErrMsgTxt("Input 3 (Weight) must be a noncomplex double matrix.");
    }
    
    pdWeight = mxGetPr(pArg);
    kH = mxGetM(pArg);
    kW = mxGetSize(pArg, 2); 
    nOutputPlanes = mxGetSize(pArg, 3);
    nInputPlanes = mxGetSize(pArg, 2);
    
    if (nBias != nOutputPlanes) {
        mexPrintf("number of elements in Bias : %d. size3 = %d\n", nBias, nOutputPlanes);
        mexErrMsgTxt("number of elements in Bias must be the same size of dimension 3 of weights");
    }
    //mexPrintf("Size Weight = %d x %d x %d\n", kH, kW, nOutputPlanes);
    //mexPrintf("Size Weight = %d x %d x %d\n", mxGetSize(pArg, 1), mxGetSize(pArg, 2), mxGetSize(pArg, 3));

    /// ------------------- dH ----------
    pArg = prhs[3];
	if(!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) || (mxGetNumberOfElements(pArg) > 1) ) { 
        mexErrMsgTxt("Input 4 (dH) must be a noncomplex double scalar.");
    }
    dH = (long) mxGetScalar(pArg);
    
    /// ------------------- dW ----------
    pArg = prhs[4];
	if(!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) || (mxGetNumberOfElements(pArg) > 1) ) { 
        mexErrMsgTxt("Input 5 (dW) must be a noncomplex double scalar.");
    }
    dW = (long) mxGetScalar(pArg);

     /// ------------------- connTable ----------
    pArg = prhs[5];
	if(!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) ) { 
            mexErrMsgTxt("Input 6 (connTable) must be a noncomplex double matrix.");
    }
    
    pdConnTable = mxGetPr(pArg);
    nConnections = mxGetN(pArg);
        
    if ( mxGetM(pArg) != 2) {
        mexErrMsgTxt("connection table must have 2 rows");
    }
    
    h_out = floor( (h - kH)/ dH) + 1;
    w_out = floor( (w - kW)/ dW) + 1;
    mexPrintf("h, w, kH, kW, dH, dW = %d, %d, %d, %d, %d, %d\n", h, w, kH, kW, dH, dW);
    
//  y_out1 = zeros(h_out, w_out, nOutputPlanes);    
//    pdYout = (double***) mxCalloc(h_out * w_out * nOutputPlanes);
    
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
         mxDOUBLE_CLASS, mxREAL);
    pdYout = mxGetPr(plhs[0]);

    //mexPrintf("Size Yout = %d x %d x %d\n", mxGetSize(plhs[0], 1), mxGetSize(plhs[0], 2), mxGetSize(plhs[0], 3));

            
    nn_spatialConvolutionMap(pdY, pdBias, pdWeight, dH, dW, pdConnTable, 
        h, w, kH, kW, nInputPlanes, nOutputPlanes, nConnections, pdYout);


}

