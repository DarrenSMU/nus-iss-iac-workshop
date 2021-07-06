resource docker_image img_bear {
    name = "chukmunnlee/dov-bear:${var.img_bear_ver}"
}

resource docker_container cont_bear {
    count = length(var.bear_instances)
    name = "bear-${count.index}"
    image = docker_image.img_bear.latest
    ports {
        internal = 3000
    }
    env = [
        "INSTANCE_NAME=${var.bear_instances[count.index]}"
    ]
}

resource local_file nginx_conf {
    filename = "nginx.conf"
    content = templatefile("./nginx_conf.tpl", {
        ports = local.ext_ports
        ip = local.ip
    })
}


data "digitalocean_ssh_key" "my-key" {
    name = "terraform"
}

// create a droplet, ubuntu 20.04.x64, sgp1, s-1vcpu-1gb
// set the corresponding private key the above public key
// output the ipv4 address of the droplet
resource digitalocean_droplet nginx {
    name = "nginx"
    image = var.droplet_image
    size = var.droplet_size
    region = var.droplet_region

    ssh_keys = [ data.digitalocean_ssh_key.my-key.id ]

    connection {
        type = "ssh"
        user = "root"
        private_key = file(var.private_key)
        host = self.ipv4_address
    }

    // apt update -y
    // apt upgrade -y
    // apt install nginx -y
    provisioner remote-exec {
        inline = [
            "apt update -y", "apt upgrade -y",
            "apt install nginx -y",
            "systemctl enable nginx",
            "systemctl start nginx",
        ]
    }

    provisioner "file" {
        source      = "./nginx.conf"
        destination = "/etc/nginx/nginx.conf"
    }

    provisioner remote-exec {
        inline = [
            "/usr/sbin/nginx -s reload"
        ]
    }

    depends_on = [
        local_file.nginx_conf
    ]


    // generate the nginx.conf

    // copy the file to droplet /etc/nginx/nginx.conf

    // restart nginx
    // /usr/sbin/nginx -s reload
}

// local variables, not available outside of this 'module'
locals {
    // list comprehension
    ext_ports = [ for c in docker_container.cont_bear: "${c.ports[0].external}" ]
    ip = var.docker_ip
}

// generate artefacts
resource local_file external_ports {
    filename = "external_ports.txt"
    content = templatefile("./external_ports.txt.tpl", {
        ports = local.ext_ports
    })
}


// outputs
output image_name {
    description = "Container name"
    value = docker_container.cont_bear[*].name
}

output external_ports {
    value = docker_container.cont_bear[*].ports[0].external
}

output external_ports_v2 {
    value = local.ext_ports
}

output nginx_ipv4 {
    value = digitalocean_droplet.nginx.ipv4_address
}

