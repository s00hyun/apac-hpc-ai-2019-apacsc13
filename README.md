# apac-hpc-ai-2019-apacsc13

This repository contains the final source code and job scripts of **team GIST**, for [2019 APAC HPC/AI Competition](https://hpcadvisorycouncil.com/events/2019/APAC-AI-HPC/).

Only key codes are uploaded. Please check the whole files and run the job on the NSCC server.

## Login information

* Login ID: apacsc13

## Base code information

### 1) Framework
* Tensorflow (from [Tensorflow Benchmarks](https://github.com/tensorflow/benchmarks))
    * Version
        ```
        commit ID:  4828965154c424bc61a7ec361edb67bb267869f4
        commit date: Thu Apr 11 21:37:22 2019 -0700
        ```

    * File location on the server: 
        ```
        /home/users/industry/ai-hpc/apacsc13/benchmarks
        ```
* Horovod

### 2) Model
* ResNet-50

### 3) Dataset
* ImageNet 2012

    * File location on the server: 
        ```
        /scratch/users/industry/ai-hpc/apacsc13/ILSVRC2012
        ```

## Optimizations we made

## Results

### 1) Performances
* training
* computing

### 2) Improvements

### 3) Advantages

## Running the code

Go to 
```
final_code_loc
```
on server and run 
```
qsub final_code.pbs
```

## Authors

* **Jabin Koo** - *Team Leader* - [jbkoo@smartx.kr](jbkoo@smartx.kr)
* **JungSu Han** - *Team Member* - [jshan@smartx.kr](jshan@smartx.kr)
* **Soohyun Choi** - *Team Member* - [shchoi@smartx.kr](shchoi@smartx.kr)
* **Yujin hong** - *Team Member* - [hyj2508@smartx.kr](hyj2508@smartx.kr)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.
