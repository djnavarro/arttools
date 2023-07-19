
# arttools

<!-- badges: start -->
<!-- badges: end -->

This is a personal package used to help with my generative art workflows. 

## Structure of an art repository

The repository name should always be `series-[system identifier]`

Folder structure:

- Source code belongs to the `source` folder
- Output files belong to the `output` folder
- The `output` folder should have one sub-folder per system version 
- Build files belong to the `build` folder

File naming principles:

- Every system should have a "system id" string `sys_id` and "system version" string `sys_ver`
- Every output file should record the RNG `seed` used to produce it
- Output files should follow this naming convention:

  ```
  [system identifier]_[system version]_[output identifier].[file extension]
  ```

  At a minimum the output identifier should specify the seed, but it could be something more complicated depending on the nature of the system. As an example:
  
  ```
  subdivision_12_2249.png
  ```
  
Don't commit output files:

- The `output` folder should be listed in `.gitignore` and not committed
- A separate "gallery" folder, also called `series-[system identifier]` should be used to prepare the files that should be published. This is a manual curation process, copying a subset of generated images from the `output` folder to the gallery folder. 
- The gallery folder should also be listed in `.gitignore`.
- To publish the gallery folder, copy it to the `djnavarro-art` bucket on google cloud storage using the `series-upload.sh` script. For instance:

  ```
  ./series-upload.sh series-subdivision
  ```
  
  The actual script:

  ```
  #! /bin/bash
  FOLDER=$1;
  gcloud storage cp $FOLDER gs://djnavarro-art --recursive --project generative-art-389407
  ```


