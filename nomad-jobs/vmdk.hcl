job "bofa-demo-fullvm" {
    datacenters = ["dc1"]

    group "fullvm" {
        count = 1
        network {
            port "ssh" {}
        }
        service {
            name = "bofa-demo-fullvm-ssh"
            port = "ssh"
        }
        task "fullvm" {
            driver = "qemu"
            resources {
                memory  = 1024
                cpu     = 1024
            }
            config {
                image_path = "/opt/nomad/data/ubuntu.vmdk"
                accelerator = "kvm"
                args = [
                    "-device", 
                    "e1000,netdev=net0", 
                    "-netdev", 
                    "user,id=net0,hostfwd=tcp::${NOMAD_PORT_ssh}-:22"
                ]
            }
        }
    }
}