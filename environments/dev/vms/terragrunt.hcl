

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../modules/vms"
}

dependency "networking" {
  config_path = "../networking"

  mock_outputs = {
    # networking_output = "mock"
    sg_id     = "some-sg-id"
    subnet_id = "some-subnet-id"
  }

  # mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
  vm_instances = include.root.inputs.vm_instances

  vm_ips = {
    vm-1_ip = include.root.inputs.ip_addr.vm-1_ip
    vm-2_ip = include.root.inputs.ip_addr.vm-2_ip
  }

  sg_id     = dependency.networking.outputs.sg_id
  subnet_id = dependency.networking.outputs.subnet_id
}