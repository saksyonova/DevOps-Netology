terraform {
  required_providers { 
    yandex = { 
      source = "yandex-cloud/yandex" 
    } 
  } 
  required_version = ">= 0.13" 
} 

provider "yandex" { 
  token     = "" 
  cloud_id  = "b1glptti2hjffghqmm9n" 
  folder_id = "b1g0rt8dea8afd5hqpnr" 
  zone      = "ru-central1-a" 
} 

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  network_id     = resource.yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = "ru-central1-a"
}

locals {
  instance = {
  stage = 1
  prod = 2
  }
}

resource "yandex_compute_instance" "vm-count" {
  name = "vm-${count.index}-${terraform.workspace}"
  
  lifecycle {
    create_before_destroy = true
  }

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  count = local.instance[terraform.workspace]
}

locals {
  id = toset([
    "1",
    "2",
  ])
}

resource "yandex_compute_instance" "vm-foreach" {
  for_each = local.id
  name = "vm-${each.key}-${terraform.workspace}"
  
  lifecycle {
    create_before_destroy = true
  }

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }
}
