variable region {
    default = "eu-frankfurt-1"
}

variable kubernetes_version {
    default = "v1.32.1"
}

variable node_shape {
    default = "VM.Standard.E4.Flex"
}

variable nodepool_name {
    default = "ubuntu-np"
}

variable memory_in_gbs {
    default = 16
}

variable ocpus {
    default = 2
}
variable availability_domain {
    default = "GqIF:EU-FRANKFURT-1-AD-1"
}

variable cni_type {
    default = "FLANNEL_OVERLAY"
}

variable subnet_id {
    default = "ocid1.subnet.oc1.eu-frankfurt-1.aaaa......"
}

variable workers_nsg_ids {
    default = [""]
}

variable compartment_id {
    default = "ocid1.compartment.oc1..aaaaaaa...."
}

variable cluster_ocid {
    default = "ocid1.cluster.oc1.eu-frankfurt-1.aaaaa....."
}

variable ssh_authorized_keys {
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0..."
}

variable image_ocid {
    default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaa..."
}