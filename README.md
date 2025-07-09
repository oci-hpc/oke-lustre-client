# oke-lustre-client-daemonset

This repository documents the steps required to setup Lustre Client on Oracle Kubernetes Engine (OKE) worker nodes using a Kubernetes DaemonSet. This method allows you to meet the prerequisites to mount Lustre File System on OKE worker nodes.

## Prerequisites
1. Create a [Lustre Managed File System](https://docs.oracle.com/en-us/iaas/Content/lustre/file-system-create.htm).
2. Ensure there is [connectivity](https://docs.oracle.com/en-us/iaas/Content/lustre/security-rules.htm) between the OKE worker nodes and the Lustre Managed File System.
3. Create [self-managed OKE worker nodes](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingubuntubasedworkernodes.htm) running Ubuntu 22.04.

## Installation Instructions

### Preparing the DaemonSet docker image

1. **Creating the docker image**

    ```bash
    docker build -t <your-docker-repo>/ubuntu-curl-jq:latest .
    ```

2. **Push the docker image to your docker repository**

    ```bash
    docker push <your-docker-repo>/ubuntu-curl-jq:latest
    ```
### Helm Installation

### Manual Installation

1. **Enable the helm repo**

    ```bash
    helm repo add oke-lustre-client https://oci-hpc.github.io/oke-lustre-client/
    helm repo update oke-lustre-client
    ```
2. ** `values.yaml`**

3. Install the lustre client using the helm chart

    ```bash
    helm upgrade --install lustre-client-installer oke-lustre-client/lustre-client-installer \
    --set daemonset.initContainer.image=<your-docker-repo>/ubuntu-curl-jq:latest
    ```

#### Preparing the DaemonSet manifest

1. **Update the `daemonset.yaml` file**

    Update the following values in the `daemonset.yaml` file for your environment:
    - `image`: The Docker image you created in the previous step. (line 214)

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

## Terraform code to create Ubuntu Node Pool

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