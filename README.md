
# arttools

<!-- badges: start -->
<!-- badges: end -->

This is a personal package used to help with my generative art workflows. 

## Structure of an art repository

### Repository name

- Every system should have a "system id" string `sys_id` 
- The repository name should always be `series-[system identifier]`
- Example, if the system name is "subdivision" then the repo is:

  ```
  series-subdivision
  ```

### Folder structure

- Source code belongs to the `source` folder
- Output files belong to the `output` folder
- The `output` folder should have one sub-folder per system version 
- Build files belong to the `build` folder
- There should be a `LICENSE` file (probably CC-BY-4.0)

### Source versioning 

- From the beginning, assume that you'll iteratively modify the system. So, in addition to having a "system identifier" that provides a name for the system, there should be a "system version" string `sys_ver`. Use left-padded zeros, and number sequentially: `"001"`, `"002"`, etc. (I use three-digit strings here: I've never gone above 80 versions of a single system, so a three-digit code should be safe)
- Keep separate source files for each new version of the system, incrementing the version number every time you experiment with something new:

  ```
  subdivision_001.R
  subdivision_002.R
  subdivision_003.R
  etc.
  ```

### Seed choice

- Use five-digit numbers for the seeds. That should ensure that even in the most extravagant situation where we generate large numbers of output files, we can ensure that output files always sort in numerical seed order and have the same length. 

### Output file names

- Source files should write image files to the `output` directory
- Every output file should record the RNG `seed` used to produce it
- Output files should follow this naming convention:

  ```
  [system]_[version]_[seed].[file extension]
  ```

  As an example:
  
  ```
  subdivision_012_22490.png
  ```
  
### Ignored files

- The `output` folder should be listed in `.gitignore` and not committed
- A separate "gallery" folder, also called `series-[system identifier]` should be used to prepare the files that should be published. This will be a manual curation process, copying a subset of generated images from the `output` folder to the gallery folder. 
- The gallery folder should also be listed in `.gitignore`.

### Build files

- `build_previews.R`: generates smaller-resolution preview images
- `build_manifest.R`: writes the manifest.csv file to the gallery folder

### The manifest file

A csv file containing the following fields:

- `path`: path to the image file (e.g., `"800/subdivision_012_22490.png"`)
- `resolution`: the image resolution in pixels (if not square, use the largest dimension)
- `series`: the system name (e.g., `"subdivision"`)
- `sys_id`: the system version string (e.g, `"012"`)
- `img_id`: the image identifier, usually just the seed (e.g. `"22490"`)
- `format`: the file extension (e.g., `"png"`)
- `date`: the publication date in YYYY-MM-DD format (e.g. `"2023-06-02"`)

### Publishing process

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


