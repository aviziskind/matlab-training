#include "mex.h"

void bestCircShift(double *pdX, double *pdY1, double *pdY2, long N, long Nvec, double* pdDX) {    
    
    long iVec, iShift, iBestShift, nAtMax, i, i1, i2, vec_offset ;
    double* pdShift_dots = mxCalloc(N, sizeof(double)); 
    double maxDot, dot_i;
    double NaN = mxGetNaN();
    double x_max, x1, delta_x, dx;
    
    double maxFrac = 0.9999;

    x1 = pdX[0];
    for (i=0;i<N;i++) {
        pdX[i] -= x1;
    }

    delta_x = (pdX[1]-pdX[0]);
    x_max = pdX[N-1] + delta_x;                
            
    for (iVec=0;iVec<Nvec;iVec++) {
        vec_offset = iVec*N;
                        
        maxDot = 0;
        for (iShift =0; iShift<N;iShift++) {
            dot_i = 0;            
            i1 = 0;

            // iShift = 0: y2 = [1 2 3 4 5 6 7 8]
            // iShift = 1: y2 = [2 3 4 5 6 7 8:1]
            // iShift = 2: y2 = [3 4 5 6 7 8:1 2]
            
            for (i2=iShift; i2<N; i1++,i2++) {
                dot_i += pdY1[i1+vec_offset]*pdY2[i2+vec_offset];
            }                    
            for (i2=0; i2<iShift ;i1++,i2++) {
                dot_i += pdY1[i1+vec_offset]*pdY2[i2+vec_offset];                
            }
            pdShift_dots[iShift] = dot_i;
            
            if (dot_i > maxDot) {
                maxDot = dot_i;
                iBestShift = iShift;
            }
        }

        // check whether max is unique
        nAtMax = 0;
        for (iShift =0; iShift<N;iShift++) {
            if (pdShift_dots[iShift] >= maxDot*maxFrac) {
                nAtMax++;            
            }
        }
        if (nAtMax > 1) {
            dx = NaN;
        } else {
            dx = pdX[iBestShift];       // dPhi = phis(ind_maxdot);
            if (dx > x_max/2) {         // if dPhi > x_max/2
                dx = x_max-dx;      //    dPhi = x_max-dPhi; 
            }            
        }        
        pdDX[iVec] = dx;                
        
    }
    
    
    mxFree(pdShift_dots);
}
    
    
            


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    
    // INPUT:
    double *pdX, *pdY1, *pdY2;
    
    // OUTPUT:
    double *pdDX;
    
    // Local:    
    const mxArray * pArg;
    mwSize nrowsX,ncolsX, nrowsY1, ncolsY1, nrowsY2, ncolsY2;

    long Nx, nshift, Nvecs, Ny;
        
    
    /* --------------- Check inputs ---------------------*/
    if (nrhs != 3)
        mexErrMsgTxt("3 inputs required");
    if (nlhs > 1)  
        mexErrMsgTxt("only one output allowed");
    
    /// ------------------- X ----------
	pArg = prhs[0];
    nrowsX = mxGetM(pArg); ncolsX = mxGetN(pArg);
	if (!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) )
            mexErrMsgTxt("Input 1 (V) must be a noncomplex matrix of doubles.");
	if ((ncolsX != 1) && (nrowsX != 1))
            mexErrMsgTxt("Input 1 (V) must be a vector");
    pdX  = mxGetPr(pArg);
    Nx = nrowsX*ncolsX;    

    /// ------------------- Y1 ----------
    pArg = prhs[1];
    nrowsY1 = mxGetM(pArg); ncolsY1 = mxGetN(pArg);
	if(!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) ) { 
            mexErrMsgTxt("Input 2 (Y1) must be a noncomplex double matrix.");
    }
    pdY1 = mxGetPr(prhs[1]);
    
    if ((nrowsY1 == 1) || (ncolsY1 == 1)) {
        Nvecs = 1;
        Ny = nrowsY1 * ncolsY1;
    } else {
        Ny = nrowsY1;
        Nvecs = ncolsY1;
    }
                
    if (Ny != Nx) {
        mexErrMsgTxt("Length of Y1 vectors must be the same as the length of X");
    }
        
    /// ------------------- Y2 ----------
    pArg = prhs[2];
    nrowsY2 = mxGetM(pArg); ncolsY2 = mxGetN(pArg);
	if(!mxIsNumeric(pArg) || !mxIsDouble(pArg) || mxIsEmpty(pArg) || mxIsComplex(pArg) ) { 
            mexErrMsgTxt("Input 3 (Y2) must be a noncomplex double matrix.");
    }
    if ((nrowsY1 != nrowsY2) || (ncolsY2 != ncolsY1)) {
        mexErrMsgTxt("Y1 and Y2 must be the same size");
    }
    pdY2 = mxGetPr(prhs[2]);
       
    
    

    /// ------------------- dX (OUTPUT)----------    
    plhs[0] = mxCreateDoubleMatrix(1, Nvecs, mxREAL);
    pdDX = mxGetPr(plhs[0]);

    bestCircShift(pdX, pdY1, pdY2, Nx, Nvecs, pdDX);    

}


//         [1 2 3 4 5 6 7 8] iShift = 0
//         [8:1 2 3 4 5 6 7] iShift = 1
//         [7 8:1 2 3 4 5 6] iShift = 2
//             for (i2=N-iShift; i2<N  ;i1++,i2++) {
//                 dot_i += pdY1[i1+vec_offset]*pdY2[i2+vec_offset];
//                 
//             }
//             for (i2=0; i2<N-iShift; i1++,i2++) {
//                 dot_i += pdY1[i1+vec_offset]*pdY2[i2+vec_offset];
//             }                    

//         [1 2 3 4 5 6 7 8]  iShift = 0
//         [2 3 4 5 6 7 8:1]  iShift = 1
//         [3 4 5 6 7 8:1 2]  iShift = 2
//             for (i2=iShift; i2<N; i1++,i2++) {
//                 dot_i += pdY1[i1+vec_offset]*pdY2[i2+vec_offset];
//             }                    
//             for (i2=0; i2<iShift ;i1++,i2++) {
//                 dot_i += pdY1[i1+vec_offset]*pdY2[i2+vec_offset];                
//             }
        
