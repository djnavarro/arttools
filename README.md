
# arttools

<!-- badges: start -->
<!-- badges: end -->

This is a personal package used to help with my generative art workflows. 

## Structure of an art repository

Core insight: there are *four* distinct products:

1. The source code (and other inputs) for the generative art system
2. The raw output created by the generative art system
3. The processed/curated images and accompanying manifest file
4. The gallery page on the generative art site displaying the images

Each of these has a different home!

1. Source code lives on GitHub, one repo per system
2. Raw output is ephemeral: it exists only locally
3. Processed images live as a "folder" in the public GCS Bucket
4. Gallery page is in the art site repo and hotlinks to images


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

To do:
 
- There should be a `Makefile` that handles the build step, and *only* the build step. It's there to manage the `series-subdivision` (or whatever) folder, *after* we've done the manual curation step and chosen which image files should be published

### The manifest file

A csv file containing the following fields:

- `path`: path to the image file (e.g., `"800/subdivision_012_22490.png"`)
- `resolution`: the image resolution in pixels (if not square, use the largest dimension)
- `series`: the system name (e.g., `"subdivision"`)
- `sys_id`: the system version string (e.g, `"012"`)
- `img_id`: the image identifier, usually just the seed (e.g. `"22490"`)
- `format`: the file extension (e.g., `"png"`)
- `date`: the publication date in YYYY-MM-DD format (e.g. `"2023-06-02"`)

To do:

- Manifests should also have a `manifest_version` field so that if I later change the manifest format the reader can work out how to handle the manifest by inspecting that field

### System name changes

It's grossly typical that we choose a new name at the end of the process. Solution to this is to make it "superficial only". That is:

- Don't rename source files
- Don't rename the system ids etc within source files
- Don't rename the output file

But we:

- Do rename the repository on github (e.g., from `series-rectangles` to `series-subdivision`)
- Do rename the gallery folder (again, e.g., from `series-rectangles` to `series-subdivision`)
- Use the new name in the `_gallery.csv` file

It's not ideal, but it minimises mess, and ultimately ensures that the thing that gets published uses the correct name on the art website and on github. It also has the nice property of preserving redirects on github.

### Publishing images to cloud storage

- Optional, but desirable: move (or copy) the gallery folder to the `~/Bucket/djnavarro-art` folder. Gallery folders properly belong to the object store rather than the git repo, so we might as well have that reflected locally!
- To publish a gallery folder, copy it to the `djnavarro-art` bucket on google cloud storage using the `series-upload.sh` script. For instance:

  ```
  ./series-upload.sh series-subdivision
  ```
  
  The actual script:

  ```
  #! /bin/bash
  FOLDER=$1;
  gcloud storage cp $FOLDER gs://djnavarro-art --recursive --project generative-art-389407
  ```

### Updating the website




