# fieldtrip-beamforming

High level EEG beamforming pipeline with built in depedency checks

## install

Clone the repo
```bash
cd projects
git clone https://github.com/pchrapka/fieldtrip-beamforming.git
```

### dependencies

This project is built on top of [fieldtrip](http://www.fieldtriptoolbox.org/). Follow [these instructions](http://www.fieldtriptoolbox.org/download) on how to download and install fieldtrip.

#### OpenMEEG

This is optional. Only go through with this if you plan on using OpenMEEG.

Install OpenMEEG, open a terminal and run
   ```
   ./install.sh
   ```
   This will install OpenMEEG in /home/user/Documents/MATLAB/openmeeg. You will also need to modify your .bashrc
   
   TODO Add link to fieldtrip instructions

### setup

Open up MATLAB
```matlab
cd projects/fieldtrip-beamforming
fb_install
fb_make_configs
```

`fb_install` will throw up an error until you specify the path to your fieldtrip package

TODO i should make this easier

## demo

Once you've gone through the install steps. Run the following in MATLAB
```matlab
fb_demo
```

## data

### Default anatomical data

The default [anatomical data](ftp://ftp.fieldtriptoolbox.org/pub/fieldtrip/tutorial/Subject01.zip) can be downloaded from the fieldtrip website. Download the file to /pathtoproject/myproject/anatomy. Unzip the file.

