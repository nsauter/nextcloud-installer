nextcloud-installer
=============

By [@nsauter](https://github.com/nsauter).

This nextcloud installer was written in order to make it very easy for everyone to have their own and private cloud. You dont need to take care of anything. Besides your working DNS to the desired IP.

* * *

What you need:

* A DNS Name which points to your servers ip address.
* Any server which can be reached from the internet.
* A clean Ubuntu or Debian installation.
* This installer..

Additional Infos
----------------

This installer turns a fresh Ubuntu or Debian machine into a working nextcloud server (latest version) by installing and configuring all needed components including a SSL/TLS certificate.

The main components installed are:

* [apache](https://httpd.apache.org/) Webserver with various PHP Modules.
* [Nextcloud](https://nextcloud.com/) Open-Source Cloud.

Secured by:

* [LetsEncrypt](https://letsencrypt.org/de/about/)

For more information on how we handle your privacy, see the [security details page](security.md).

Installation
------------

This installer will make your nextcloud data dir `/data`Â. I recommend tomount thisÂ as own partitin. If this directory is not mounted it will be generate.

1. Install git:

    ```bash
    $ sudo apt update -y && apt install git -y
    ```

2. Clone this repository:

    ```bash
    $ git clone https://github.com/nsauter/nextcloud-installer.git
    $ cd nextcloud-installer
    ```

3. Begin the installation:

    ```bash
    $ sudo ./install.sh
    ```

4. Enter the requested infos:

    ```
    Please enter your e-mail address: admins_mail@demo.org
    Please enter your servers FQDN (e.g. nexcloud.mydomain.net): nextcloud.demo.org
    ```

5. Watch the installer doing the its thing:

    ```
    Updating OS...
    Installing needed packages...
    Generating passwords...
    Preparing database...
    Generating PHP settings...
    Downloading & installing latest nextcloud version...
    Generating Nextcloud datadir and getting permissions right...
    Generating apache configuration...
    Generating SSl/TLS certificate...

    ###################### FINISHED INSTALLATION ######################

    Now connect to "https://nextcloud.demo.org" to finish installation.
    
    Nextcloud Data Dir:             /data
    Nextcloud Database User:        nextcloud
    Nextcloud Database Password:    Deity-Heyday*Witch
    
    Database Root Password:         beefy!Bounty!nosy
    
    ATTENTION: Make sure to store those passwords in a safe location.
    
    ###################################################################
    ```

