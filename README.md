# YOLOv2 for MatLab
YOLOv2 for Matlab is a fork of the Matlab MEX wrapper Yolomex by Ignacio Rocco with Matlab demos for LED control and people tracking.

![screenshot](https://raw.githubusercontent.com/kbitr/matlab-yolov2/master/screenshot.jpg)

- This is using the original darknet framework, so it's meant to run on Unix (OSX/Linux).
- openMP is not included into gcc in OSX - you can still use your own compiler.
- Don't be stupid and change paths, if you're using different versions!

# Install
## 0. Clone

```bash
git clone --recursive https://github.com/kbitr/matlab-yolov2
```

## 1. Edit Makefile
- Adjust CC path (OSX)
- CUDA: Set "GPU=1"
- openMP: Set "OPENMP=1"

```bash
make
```

## 2. Compile _yolomex_ (in Matlab)

#### CUDA:
```bash
mex -I./darknet/include/ -I./darknet/src CFLAGS='-Wall -Wfatal-errors -Wno-unused-result -fPIC' -L. -lyolo -L/usr/local/cuda/lib64 -lcudart -lcublas -lcurand yolomex.c
```
#### CPU:
```bash
mex -I./darknet/include/ -I./darknet/src/ -L. -lyolo yolomex.c
```

## 4. Run Demo
```bash
main*.m
```

# OSX's Clang can't compile openMP?
Well, yeah - just install LLVM.
```bash
brew install llvm
```
- The following overwrites the mex-compiler config for c-files!
- It's recommended to store the *clang_openmp_maci64.xml* in *~/Library/Application Support/MathWorks/MATLAB/R2017b*.
- Adjust path in the below command if necessary
```bash
mex -setup:'~/Library/Application Support/MathWorks/MATLAB/R2017b/clang_openmp_maci64.xml' C
```

# Your Matlab crashes when using CUDA?
That happens when your GPU is running out of memory, since Matlab isn't aware of the memory usage. You should reduce the in the _batch_ vaulue _.cfg_-file to a lower multiple of 32. (But other values work as well.)

By the way, for speeding up the detection you can reduce the _width_ and _height_.