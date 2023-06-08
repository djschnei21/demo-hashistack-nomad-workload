source "virtualbox-ovf" "demo" {
    source_path         = "input/ubuntu.ova"
    checksum            = "md5:eb5889ae0ad07cb4b2ee3a54025135db"
    headless            = true
    communicator        = "ssh"
    ssh_username        = "packer"
    ssh_password        = "packer"
    shutdown_command    = "echo 'packer' | sudo -S shutdown -P now"
    output_directory    = "output/"
    output_filename     = "packer-demo"
}

source "vsphere-iso" "demo" {
    vcenter_server      = "vcenter.example.com"
    insecure_connection = true

    datacenter          = "Datacenter1"
    cluster             = "Cluster1"
    datastore           = "Datastore1"
    network             = "VM Network"
    vm_name             = "packer-demo"
    guest_os_type       = "ubuntu64Guest"

    iso_urls            = ["http://example.com/ubuntu.iso"]
    iso_checksum        = "md5:eb5889ae0ad07cb4b2ee3a54025135db"

    ssh_username        = "packer"
    ssh_password        = "packer"

    shutdown_command    = "echo 'packer' | sudo -S shutdown -P now"

    convert_to_template = true
}

build {
    sources = ["sources.virtualbox-ovf.demo"]
    provisioner "shell" {
        inline = [
            "DEBIAN_FRONTEND=noninteractive",
            "sudo apt-get update",
            "sudo apt-get upgrade -y",
            "sudo apt-get clean",
            "sudo apt-get install gnupg -y",
            "curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor",
            "echo \"deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse\" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list",
            "sudo apt-get update",
            "sudo apt-get install -y mongodb-org",
            "sudo systemctl start mongod",
            "sudo systemctl enable mongod",
            "until mongosh  --shell --quiet --eval \"print('waited for connection')\"; do sleep 1; done",
            "mongosh --shell --quiet --eval \"db.getSiblingDB('admin').createUser({user: 'admin', pwd: 'password', roles: [{role:'root', db:'admin'}]})\"",
            "sudo sed -i 's|127\\.0\\.0\\.1|0.0.0.0|g' /etc/mongod.conf"
        ]
    }
    post-processor "shell-local" {
        inline = [
            "scp output/*.vmdk node4:~/ubuntu.vmdk",
        ]
    }
}