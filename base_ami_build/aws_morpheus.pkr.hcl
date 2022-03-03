variable "morpheus_version" { default = "5.4.3-1" }

source "amazon-ebs" "morpheus_ubuntu20" {
    // skip_create_ami = true
    ami_name = "morpheus-${var.morpheus_version}-ubuntu20"
    ami_virtualization_type = "hvm"
    source_ami_filter {
        filters  = {
            architecture = "x86_64"
            virtualization-type = "hvm"
            name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"
        }
        owners = [ "099720109477" ]
        most_recent = true
    }
    instance_type = "t3.large"
    launch_block_device_mappings {
        device_name = "/dev/sda1"
        volume_size = 40
        volume_type = "gp3"
        delete_on_termination = true
    }
    ssh_username = "ubuntu"
}

build {
    sources = [
        "source.amazon-ebs.morpheus_ubuntu20"
    ]
    provisioner "file" {
        source = "../scripts/morpheus_setup.sh"
        destination = "/home/ubuntu/morpheus_setup.sh"
    }
    provisioner "file" {
        source = "../scripts/morpheus_install.sh"
        destination = "/tmp/morpheus_install.sh"
    }
    provisioner "shell" {
        inline = [
            "curl -q -o /home/ubuntu/morpheus.deb https://downloads.morpheusdata.com/files/morpheus-appliance_${var.morpheus_version}_amd64.deb",
            "sudo dpkg -i /home/ubuntu/morpheus.deb",
            "rm -f /home/ubuntu/morpheus.deb",
            "sudo mv /home/ubuntu/morpheus_setup.sh /var/lib/cloud/scripts/per-instance/morpheus_setup.sh",
            "sudo chmod +x /var/lib/cloud/scripts/per-instance/morpheus_setup.sh",
            "sudo bash /tmp/morpheus_install.sh"
        ]
    }
}