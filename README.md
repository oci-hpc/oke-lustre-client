# oke-lustre-client-daemonset

This repository documents the steps required to setup Lustre Client on Oracle Kubernetes Engine (OKE) worker nodes using a Kubernetes DaemonSet. This method allows you to meet the prerequisites to mount Lustre File System on OKE worker nodes.

## Prerequisites
1. Create a [Lustre Managed File System](https://docs.oracle.com/en-us/iaas/Content/lustre/file-system-create.htm).
2. Ensure there is [connectivity](https://docs.oracle.com/en-us/iaas/Content/lustre/security-rules.htm) between the OKE worker nodes and the Lustre Managed File System.
3. Worker nodes are running Ubuntu 22.04 or OL8 (with [RHCK](https://blogs.oracle.com/linux/post/changing-the-default-kernel-in-oracle-linux-its-as-simple-as-1-2-3) enabled).

Sample OKE cloud-init that can be used to enable RHCK on OL8:

```bash
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

## Default cloud-init for OKE

curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
bash /var/run/oke-init.sh
```

## Installation Instructions

### Preparing the DaemonSet docker image (Optional)

1. **Creating the docker image**

    ```bash
    docker build -t <your-docker-repo>/ubuntu-curl-jq:latest .
    ```

2. **Push the docker image to your docker repository**

    ```bash
    docker push <your-docker-repo>/ubuntu-curl-jq:latest
    ```

### Helm Installation

1. **Enable the helm repo**

    ```bash
    helm repo add oke-lustre-client https://oci-hpc.github.io/oke-lustre-client/
    helm repo update oke-lustre-client
    ```

2. Install the lustre client using the helm chart

    ```bash
    helm upgrade --install lustre-client-installer oke-lustre-client/lustre-client-installer
    ```

    You can override the daemonset contaimer image using the command:

    ```bash
    helm upgrade --install lustre-client-installer oke-lustre-client/lustre-client-installer --set daemonset.initContainer.image=<your-docker-repo>/ubuntu-curl-jq:latest
    ```
### Manual Installation

#### Installing the lustre client

1. **Apply the daemonset manifest**

    ```bash
    kubectl apply -f daemonset.yaml
    ```

2. **Check the Pod Logs**

    To check the pod logs, run the command:

    ```bash
    kubectl logs -n kube-system -l job=lustre-client-installer --all-containers --prefix=true --timestamps
    ```

## Verify installation

1. **Update the IP address in the `lustre-pv.yaml` file** 

    Update the IP address with the IP address of your Lustre server. (line 15)

2. **Apply the PersistentVolume manifest**

    ```bash
    kubectl apply -f lustre-pv.yaml
    ```

3. **Apply the sample pvc and deployment manifest**

    ```bash
    kubectl apply -f deployment-example.yaml
    ```

4. **Check the status of the pods**

    ```bash
    kubectl describe pod -l app=sample-deployment
    ```

## Clean-up the resources

To cleanup the Kubernetes resources, execute the following commands:

```bash
kubectl delete -f deployment-example.yaml
kubectl delete -f lustre-pv.yaml
kubectl delete -f daemonset.yaml
```

## Terraform code to create a Node Pool in OKE (configured with Flannel CNI)

1. **Import an Ubuntu Image as a Custom Image**

Import an Ubuntu Image as a Custom Image from [here](https://github.com/oracle-quickstart/oci-hpc-oke/blob/main/README.md#images-to-use) or create a Ubuntu 22.04 [custom image](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/managingcustomimages.htm) using one of [these](https://docs.oracle.com/en-us/iaas/images/ubuntu-2204/) as a base image.

2. **Update the values in the `terraform-deployment/terraform.auto.tfvars` file**

3. **Execute the terraform commands**

    ```bash
    terraform init
    terraform apply
    ```

4. **Clean-up resources**

    ```bash
    terraform destroy --auto-approve
    ```

## Build your own Lustre Client

1. [Instructions to build lustre-client for Ubuntu 22.04](guides/build-lustre-client-ubuntu-jammy.md)
2. [Instructions to build lustre-client for Oracle Linux 8](guides/build-lustre-client-ol.md)