  
data digitalocean_ssh_key ssh_key {
    name = "terraform"
}

resource digitalocean_droplet nginx {
    name = "nginx"
    image = var.droplet_image
    size = var.droplet_size
    region = var.droplet_region

    ssh_keys = [ data.digitalocean_ssh_key.ssh_key.id ]

    // automatically trust the remote host
    provisioner local-exec {
        command = "ssh-keyscan -H ${self.ipv4_address} >> ~/.ssh/known_hosts"
    }
}

output nginx_ipv4 {
    value = digitalocean_droplet.nginx.ipv4_address
}