# TemperCLI
Command Line tool installation for RHEL9.7 

The first step is creating a clone from the repository. You must have the necessary EPEL packages and the python3-serial installed before building the command line tool.
Here are the related commands for the EPEL package installation:

`sudo dnf install epel-release`

`sudo dnf install libusb-compat-0.1-devel`

OR you can do a manual installation by cloning the libusb repository:

`wget https://github.com/libusb/libusb-compat-0.1/releases/download/v0.1.8/libusb-compat-0.1.8.tar.bz2`


To install the python3-serial package, run 

`sudo dnf install python3-pyserial`

Next you can run the following:

`chmod +x temper_rhel9_install.sh`

`sudo ./temper_rhel9_install.sh`

`sudo cp temper_wrapper.sh /usr/local/bin/temper`

`sudo chmod +x /usr/local/bin/temper`

`sudo cp temper_hum_decoder.py /usr/local/bin/temper-decode`

`sudo chmod +x /usr/local/bin/temper-decode`

You should have the command line tools installed in the /usr/local/bin directory.
