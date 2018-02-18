## Data

This is the most important section. This directory contains all of the data files that are used to generate the configurations used to build and maintain Cepheus.

## Structure of Directory
The files that are *not* in .gitignore but which are found here are the files that are common to all environments.

Common Directory:

YAML Data Files
1. centos.yaml
2. common.yaml
3. rhel.yaml
4. ubuntu.yaml

Other files found here are:
1. This README.md
2. sample_git_credentials_file - This is an example of what a git credentials file should look like.

All other files are generated files originate from templates and are not tracked by Git in your repo.
