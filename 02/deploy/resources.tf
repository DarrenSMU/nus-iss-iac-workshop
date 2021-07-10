data digitalocean_ssh_key ssh_key {
    name = "terraform"
}

data digitalocean_image mynginx {
    name = var.droplet_image
}

resource digitalocean_droplet nginx {
    name = "nginx"
    image = data.digitalocean_image.mynginx.id
    size = var.droplet_size
    region = var.droplet_region

    ssh_keys = [ data.digitalocean_ssh_key.ssh_key.id ]
}

output nginx_ipv4 {
    value = digitalocean_droplet.nginx.ipv4_address
}