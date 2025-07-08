resource "oci_containerengine_node_pool" "lustre_np" {
    #Required
    cluster_id = var.cluster_ocid
    compartment_id = var.compartment_id
    name = var.nodepool_name
    node_shape = var.node_shape
    kubernetes_version = var.kubernetes_version
    
    node_config_details {
        #Required
        placement_configs {
            #Required
            availability_domain = var.availability_domain
            subnet_id = var.subnet_id

        }
        size = 1

        node_pool_pod_network_option_details {
            #Required
            cni_type = var.cni_type
        }
        nsg_ids = var.workers_nsg_ids
    }

    node_metadata = {
        "user_data" : data.cloudinit_config.workers.rendered
        "ssh_authorized_keys": var.ssh_authorized_keys
    }
    node_shape_config {

        #Optional
        memory_in_gbs = var.memory_in_gbs
        ocpus = var.ocpus
    }
    node_source_details {
        #Required
        image_id = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaapo2tbf6sp2hyi3z4rij4agultcrzsazl3sfkiwif55fpi3bl4ucq"
        source_type = "IMAGE"
        #Optional
        boot_volume_size_in_gbs = 200
    }
    ssh_public_key = var.ssh_authorized_keys
}

data "oci_containerengine_cluster" "test_cluster" {
    #Required
    cluster_id = var.cluster_ocid

    should_include_oidc_config_file = false
}

locals{
    ssh_authorized_keys = var.ssh_authorized_keys
    runcmd_bootstrap = format(
    "curl -sL -o /var/run/oke-ubuntu-cloud-init.sh https://raw.githubusercontent.com/oracle-quickstart/oci-hpc-oke/refs/heads/main/files/oke-ubuntu-cloud-init.sh && (bash /var/run/oke-ubuntu-cloud-init.sh '%v' '%v' || echo 'Error bootstrapping OKE' >&2)",
    var.kubernetes_version, false,
    ) 
    
    cluster_ca_cert = yamldecode(data.oci_containerengine_cluster_kube_config.test_cluster_kube_config.content).clusters[0].cluster.certificate-authority-data
    cluster_apiserver = split(":", data.oci_containerengine_cluster.test_cluster.endpoints[0].private_endpoint)[0]
}

data "oci_containerengine_cluster_kube_config" "test_cluster_kube_config" {
    #Required
    cluster_id = var.cluster_ocid
}
