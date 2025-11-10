# Lustre Client Build instructions for OL8

## Build Lustre Client for Oracle Linux

1. Switch from UEK to RHCK

    Run the script below as `root`:

    ```
    #!/bin/bash 

    ## Switch to RHCK
    CURRENT_KERNEL="$(uname -r)"
    if [[ "${CURRENT_KERNEL}" =~ uek ]]; then
        echo "Switching to RHCK..."
        EXISTING_RHCK_IMAGE=$(grubby --info=ALL | grep -E "^kernel" | grep -v -E "(uek|rescue)"  | cut -d'=' -f2 | tail -n 1 | sed 's/"//g')
        if [[ -n "$EXISTING_RHCK_IMAGE" ]]; then
            grubby --set-default "$EXISTING_RHCK_IMAGE"
            echo "Setting $EXISTING_RHCK_IMAGE as default kernel."
        else
            echo "Installing RHCK kernel..."
            yum makecache
            yum install -y kernel
            RHCK_IMAGE=$(rpm -q --qf "%{VERSION}-%{RELEASE}.%{ARCH}\n" kernel | tail -n 1)
            RHCK_IMAGE="/boot/vmlinuz-${RHCK_VERSION}"
            if [[ -f "$RHCK_IMAGE" ]]; then
                grubby --set-default "$RHCK_IMAGE"
                echo "Setting $RHCK_IMAGE as default kernel."
            else
                echo "ERROR: RHCK kernel image $RHCK_IMAGE not found."
                exit 1
            fi
        fi
        echo "Cleaning up cloud-init state and rebooting for RHCK switch..."
        cloud-init clean --logs --reboot
        exit 0
    fi
    ```

2. Ensure build prerequisites are installed:

    ```
    release=$(cat /etc/os-release | grep ^VERSION= |cut -f2 -d\" |cut -f1 -d.)
    sudo dnf config-manager --set-enabled ol${release}_codeready_builder
    sudo dnf config-manager --enable ol${release}_developer_EPEL
    sudo yum-config-manager --enable ol${release}_developer
    sudo yum install git libtool patch pkgconfig libnl3-devel.x86_64 libblkid-devel libuuid-devel rpm-build kernel-rpm-macros kernel-devel kernel-abi-whitelists libmount libmount-devel libyaml-devel
    ```

3. Clone Lustre client repo:

    The repository below has the patch [LU-18644](https://github.com/lustre/lustre-release/commit/b4748cb4684f5b2594d127b29f3876f07bd077ee) backportd to 2.15.5.

    ```
    git clone https://github.com/robo-cap/lustre-release.git lustre-client
    cd lustre-client/
    git checkout tags/2.15.5-oci
    ```

4. Build the client RPMs:

    ```
    sudo sh autogen.sh
    ./configure --enable-client
    sudo make rpms
    sudo make dkms-rpm
    ```

5. Zip the files:

    ```
    tar -czf OL8-Lustre-client-dkms-2.15.tar.gz lustre-client-dkms-2.15.*.el8.noarch.rpm lustre-client-2.15.*.el8.x86_64.rpm
    ```

## Known issues:

- You may have to use a different client tag or import the patch above if you intend to build for different kernel versions.