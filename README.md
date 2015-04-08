fieldtrip-beamforming
=====================
High level EEG beamforming pipeline with built in depedency checks

install
-------

Clone the repo
```
git clone https://github.com/pchrapka/fieldtrip-beamforming.git
```

### Optional

1. Install OpenMEEG, open a terminal and run
   ```
   ./install.sh
   ```
   This will install OpenMEEG in /home/user/Documents/MATLAB/openmeeg. You will also need to modify your .bashrc

dependencies
------------

This project is built on top of [fieldtrip](http://www.fieldtriptoolbox.org/). Follow [these instructions](http://www.fieldtriptoolbox.org/download) on how to download and install fieldtrip.

setup
-----

### Default anatomical data

The default [anatomical data](ftp://ftp.fieldtriptoolbox.org/pub/fieldtrip/tutorial/Subject01.zip) can be downloaded from the fieldtrip website. Download the file to /pathtoproject/myproject/anatomy. Unzip the file.

