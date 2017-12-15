#ifndef LIBYOLO_H
#define LIBYOLO_H
#include "image.h"

typedef void* yolo_handle;

typedef struct { char name[32]; int left; int right; int top; int bottom; float prob; } detection_info;

yolo_handle yolo_init(char *datacfg, char *cfgfile, char *weightfile, int initMode);
void yolo_cleanup(yolo_handle handle);
detection_info **yolo_detect(yolo_handle handle, image im, float thresh, float hier_thresh, int *num);
detection_info **yolo_file(yolo_handle handle, char *filename, float thresh, float hier_thresh, int *num);

#endif // LIBYOLO_H