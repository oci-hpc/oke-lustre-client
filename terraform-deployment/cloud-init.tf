data "cloudinit_config" "workers" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      growpart = {
        mode                     = "auto"
        devices                  = ["/"]
        ignore_growroot_disabled = false
      }
      resize_rootfs = true
      bootcmd = ["if [[ -f /usr/libexec/oci-growfs ]]; then /usr/libexec/oci-growfs -y; fi"]
    })
    filename   = "10-growpart.yml"
    merge_type = "list(append)+dict(no_replace,recurse_list)+str(append)"
  }

  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      write_files = [
        {
          content = local.cluster_apiserver,
          path    = "/etc/oke/oke-apiserver"
        },
        {
          encoding    = "b64",
          content     = local.cluster_ca_cert,
          owner       = "root:root",
          path        = "/etc/kubernetes/ca.crt",
          permissions = "0644",
        },
      ]
    })
    filename   = "50-oke-config.yml"
    merge_type = "list(append)+dict(no_replace,recurse_list)+str(append)"
  }

  part {    
    content_type = "text/cloud-config"
    content = jsonencode({
      runcmd  = [
        local.runcmd_bootstrap
      ]
    })
    filename   = "50-oke-runcmd.yml"
    merge_type = "list(append)+dict(no_replace,recurse_list)+str(append)"
  }
}