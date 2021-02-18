# NASA
**This is RTL implement of single-core npu**
## SingleCore NPU Architecture

<img src="/img/NPU_Architecture.jpg" height="50%" width="50%">

Then we implement our paper——NASA based on NPU( Not finished, need to improve).
 
## Version-1
The Architecture of the first version as below:

<img src="/img/Architecture.jpg" height="50%" width="50%">

We adopt mesh structure for PE array, and use NoC to connect them.
However, we find it is difficult to schedule operation (`CONV` 、`FC`、`POOLING`). 
Also it's unecessary to use complicated NoC. 
***
## Version-2
So we inspired by [Cambricon-F](https://ieeexplore.ieee.org/abstract/document/8980346) and [TETRIS-TANGRAM](https://github.com/stanford-mast/nn_dataflow#chen16), 
proposed new Architecture(as below) and Schedule scheme. Also, we change the single NPU's Architecture, combine `WB` `IOB` `BiasB` as one Buffer.  

<img src="/img/NewArchitecture.jpg" height="50%" width="50%">