#include "mex.h"
#include <stdio.h>
#include "libyolo.h"
#include "image.h"
#include "matrix.h"
#include <unistd.h>

static yolo_handle g_handle = NULL;

/* Init YOLO */
void yolomex_init(char *datacfg,char *cfgfile, char *weightfile, int initMode)
{
    /* check existence of files */
    if( access( datacfg, F_OK ) == -1 ) {mexErrMsgTxt("File not found. Initialzing YOLO failed.");}
    if( access( cfgfile, F_OK ) == -1 ) {mexErrMsgTxt("File not found. Initialzing YOLO failed.");}
    if( access( weightfile, F_OK ) == -1 ) {mexErrMsgTxt("File not found. Initialzing YOLO failed.");}

    /* init */
    g_handle = yolo_init(datacfg, cfgfile, weightfile, initMode);
    if (!g_handle){mexErrMsgTxt("Initialzing YOLO failed.");}
    return;
}

/* Cleanup YOLO */
void yolomex_cleanup()
{
    yolo_cleanup(g_handle);
    g_handle = NULL;
    return;
}

/* YOLO file-mode */
detection_info** yolomex_file(char *filename, float thresh, float hier_thresh, int* num)
{
    /* check init */
    if (!g_handle){mexErrMsgTxt("Run 'yolomex('init',datacfg,cfgfile,weightfile);' first.");}
    
     /* check existance of files */
    if( access( filename, F_OK ) == -1 ) {
        //printf("File %s\n not found", filename);
        mexErrMsgTxt("File not found. Run YOLO failed.");
    }

    *num = 0;
    detection_info **info = yolo_file(g_handle, filename, thresh, hier_thresh, num);

    if (info == NULL) {mexErrMsgTxt("Something went wrong in yolo_file C-function.");}
    return info;
}

/* YOLO image-mode */
detection_info** yolomex_detect(unsigned char *data, int w, int h, int c, float thresh, float hier_thresh, int* num)
{
    /* check init */
    if (!g_handle){mexErrMsgTxt("Run 'yolomex('init',datacfg,cfgfile,weightfile);' first.");}
    
    int i,j,k;
    image im = make_image(w, h, c);
    for(k = 0; k < c; ++k){
        for(j = 0; j < h; ++j){
            for(i = 0; i < w; ++i){
                int dst_index = i + w*j + w*h*k;
                int src_index = h*i + j + w*h*k;
                im.data[dst_index] = (float)data[src_index]/255.;
            }
        }
    }

    *num = 0;
    detection_info **info = yolo_detect(g_handle, im, thresh, hier_thresh, num);
    
    free_image(im);
    
    if (info == NULL) {mexErrMsgTxt("Something went wrong in yolo_detect C-function");}
    return info;
}

/* Result parsing function */
void infoToMatlabStruct(detection_info** info, int num, mxArray *plhs[])
{
    /* Create mxArray data structures to hold the data */
    /* to be assigned for the structure. */
    const char *fieldnames[6]; /* This will hold field names. */
    int i;
    /* Assign field names */
    for(i = 0; i<6; i++)
    fieldnames[i] = (char*)mxMalloc(20);
    memcpy(fieldnames[0],"class",sizeof("class"));
    memcpy(fieldnames[1],"left", sizeof("left"));
    memcpy(fieldnames[2],"right", sizeof("right"));
    memcpy(fieldnames[3],"top", sizeof("top"));
    memcpy(fieldnames[4],"bottom", sizeof("bottom"));
    memcpy(fieldnames[5],"prob", sizeof("prob"));
    /* Allocate memory for the structure */
    plhs[0] = mxCreateStructMatrix(1,num,6,fieldnames);
    /* Deallocate memory for the fieldnames */
    for(i = 0; i<6; i++)
    mxFree( fieldnames[i] );
    /* Assign the field values */
    for (i = 0; i < num; i++) {
        mxSetFieldByNumber(plhs[0],i,0, mxCreateString(info[i]->name));
        mxSetFieldByNumber(plhs[0],i,1, mxCreateDoubleScalar((double)info[i]->left));
        mxSetFieldByNumber(plhs[0],i,2, mxCreateDoubleScalar((double)info[i]->right));
        mxSetFieldByNumber(plhs[0],i,3, mxCreateDoubleScalar((double)info[i]->top));
        mxSetFieldByNumber(plhs[0],i,4, mxCreateDoubleScalar((double)info[i]->bottom));
        mxSetFieldByNumber(plhs[0],i,5, mxCreateDoubleScalar((double)info[i]->prob));
        free(info[i]);
    }
    free(info);
    return;
}

/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    char *method;
    /* used in detect */
    float* imageData;
    int numDimsImg;
    mwSize const * sizeImg=NULL;
    int w,h,c;

    if(nrhs == 0) {mexErrMsgTxt("First input should specify method");}

    /* Check method requested */
    if(strcmp(mxArrayToString(prhs[0]),"init")==0){
        /* Check variables */
        if(nrhs!=4){mexErrMsgTxt("Init parameters: string datacfg, string cfgfile, string weightfile");}
        if ( mxIsChar(prhs[1]) != 1 || mxIsChar(prhs[2]) != 1 || mxIsChar(prhs[3]) != 1){mexErrMsgTxt("Init parameters: string datacfg, string cfgfile, string weightfile");}
        
        /* copy the string data from prhs[1-3] into a C string */
        char *datacfg = mxArrayToString(prhs[1]);
        char *cfgfile = mxArrayToString(prhs[2]);
        char *weightfile = mxArrayToString(prhs[3]);

        yolomex_init(datacfg,cfgfile,weightfile,0);
    }
    else if(strcmp(mxArrayToString(prhs[0]),"init_name")==0){
        /* Check variables */
        if(nrhs!=4){mexErrMsgTxt("Init parameters: string namefile, string cfgfile, string weightfile");}
        if ( mxIsChar(prhs[1]) != 1 || mxIsChar(prhs[2]) != 1 || mxIsChar(prhs[3]) != 1){mexErrMsgTxt("Init parameters: string namefile, string cfgfile, string weightfile");}
        
        /* copy the string data from prhs[1-3] into a C string */
        char *datacfg = mxArrayToString(prhs[1]);
        char *cfgfile = mxArrayToString(prhs[2]);
        char *weightfile = mxArrayToString(prhs[3]);

        yolomex_init(datacfg,cfgfile,weightfile,1);
    }
    else if(strcmp(mxArrayToString(prhs[0]),"cleanup")==0){
        /* Check variables */
        if(nrhs != 1){mexErrMsgTxt("Cleanup does not require parameters.");}

        yolomex_cleanup();
    }
    else if(strcmp(mxArrayToString(prhs[0]),"file")==0){
        /* Check variables */
        if(nrhs != 4){mexErrMsgTxt("Test parameters: string filename, double thresh, double hier_thresh");}
        if(nlhs != 1) {mexErrMsgTxt("One output required for test method");}
        if ( mxIsChar(prhs[1]) != 1 || mxIsDouble(prhs[2]) != 1 || mxIsDouble(prhs[3]) != 1){mexErrMsgTxt("Test parameters: string filename, double thresh, double hier_thresh");}  /* copy the string data from prhs[1] into a C string */
       
        /* parse filename */
        char *filename = mxArrayToString(prhs[1]);
        /* get numeric parameters */
        float thresh = (float)mxGetScalar(prhs[2]);        
        float hier_thresh = (float)mxGetScalar(prhs[3]);  
        /* run */
        int num;      
        detection_info** info = yolomex_file(filename, thresh, hier_thresh, &num);

        /* copy result to a Matlab struct for returning */
        infoToMatlabStruct(info, num, plhs);
    }
    else if(strcmp(mxArrayToString(prhs[0]),"detect")==0){
        /* Check variables */
        if(nrhs != 4){mexErrMsgTxt("Detect parameters: uint8 matrix (image), double thresh, double hier_thresh");}
        if(nlhs != 1) {mexErrMsgTxt("One output required for detect method");}
        if ( mxIsUint8(prhs[1]) != 1 || mxIsDouble(prhs[2]) != 1 || mxIsDouble(prhs[3]) != 1){mexErrMsgTxt("Detect parameters: uint8 matrix (image), double thresh, double hier_thresh");}
       
        /* Get image */
        imageData = (unsigned char*)mxGetData(prhs[1]);        
        numDimsImg = mxGetNumberOfDimensions(prhs[1]);    
        sizeImg = mxGetDimensions(prhs[1]);

        if (numDimsImg != 3){mexErrMsgTxt("Image is not RGB (n x m x 3)");}

        h = sizeImg[0];
        w = sizeImg[1];
        c = sizeImg[2];
  
        /* get numeric parameters */
        float thresh = (float)mxGetScalar(prhs[2]);        
        float hier_thresh = (float)mxGetScalar(prhs[3]);  

        /* run */
        int num;      
        detection_info** info = yolomex_detect(imageData, w, h, c, thresh, hier_thresh, &num);

        /* copy result to a Matlab struct for returning */
        infoToMatlabStruct(info, num, plhs);
    }
    else {mexErrMsgTxt("First input should specify method");}
    return;    
}