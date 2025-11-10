# Lustre Client Build instructions for Ubuntu 22.04

## Build Lustre Client for Ubuntu Jammy

1. Prepare the node:

    ```
    release=$(uname -r)
    sudo sudo apt-get install linux-image-${release}
    sudo apt-get install linux-headers-${release}
    sudo apt-get install linux-modules-${release}
    sudo update-grub

    ```

2. Install the prerequisites:

    ```
    sudo apt-get update
    sudo apt-get install -y libreadline-dev libpython3-dev libkrb5-dev libkeyutils-dev flex bison libmount-dev libtool make libnl-3-dev libnl-genl-3-dev libnl-3-dev pkg-config libnl-genl-3-dev libyaml-dev libtool libyaml-dev ed libreadline-dev  libncurses5-dev libncurses-dev flex gnupg libelf-dev gcc libssl-dev bc wget bzip2 build-essential udev kmod cpio debhelper  libssl-dev  rsync dpatch libsnmp-dev mpi-default-dev quilt swig module-assistant
    ```

3. Clone Lustre client repo:

    The repository below has the patch [LU-18644](https://github.com/lustre/lustre-release/commit/b4748cb4684f5b2594d127b29f3876f07bd077ee) backportd to 2.15.5.

    ```
    git clone https://github.com/robo-cap/lustre-release.git lustre-client
    cd lustre-client/
    git checkout tags/2.15.5-oci
    ```

4. Build the client PKGs:

    ```
    sudo sh autogen.sh
    ./configure --enable-client

    # Use sed to remove the reference to the kernel packages
    find debian -type f -name 'control' -exec sudo sed -Ei '
    s/(linux-headers-generic[[:space:]]*\|[[:space:]]*linux-headers-amd64[[:space:]]*\|[[:space:]]*linux-headers-arm64,)//g;
    s/(linux-image[[:space:]]*\|[[:space:]]*linux-image-amd64[[:space:]]*\|[[:space:]]*linux-image-arm64,)//g;
    s/(linux-headers-generic[[:space:]]*\|[[:space:]]*linux-headers-amd64,)//g;
    ' {} +

    sudo make debs

    sudo make dkms-debs
    ```


5. Tar the files:

    ```
    sudo tar -czf Ubuntu-Lustre-client-dkms-2.15.tar.gz debs/lustre-client-utils_2.15.*_amd64.deb debs/lustre-client-modules-dkms_2.15.*_amd64.deb
    ```

## Known issues:

- You may have to use a different client tag or import the patch above if you intend to build for different kernel versions.