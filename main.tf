# update your ~/.ssh/config based on the provisioned host

locals {
  cmd_prefix_remove = var.update_ssh_config_enable != "" ? (var.cmd == "addhost" ? "echo Ignoring remove command" : "") : "echo Ignoring remove cmd: "
  cmd_prefix_add    = var.update_ssh_config_enable != "" ? (var.cmd == "remove" ? "echo Ignoring add command" : "") : "echo Ignoring add cmd: "
  hostnames         = var.hostnames == "" ? "" : format("--hostname %s", var.hostnames)
  ports             = var.ports == "" ? "" : format("--port %s", var.ports)
  user              = var.user == "" ? "" : format("--username %s", var.user)
  id                = var.id == "" ? "" : format("--identity %s", var.id)
  strict            = var.strict == "" ? "" : "--addstrict"
  backup = var.use_backup == "" ? "" : format("--backup_file %s.backup.%s",
    var.ssh_config,
    var.backup_postfix)
  custom_kexalgorithms = var.kexalgorithms == "" ? "" : format("--kexalgorithms %s",
    var.kexalgorithms)
}

resource "null_resource" "ssh_config_add" {
  provisioner "local-exec" {
    command = format("%s./update_ssh_config.py --remove %s --addhost %s %s %s %s %s %s %s %s %s",
      local.cmd_prefix_add,
      var.shorthosts,
      var.shorthosts,
      local.hostnames,
      local.user,
      local.ports,
      local.id,
      local.strict,
      var.use_backup == "" ? "" : format("%s.%s", local.backup, "terraform"),
      local.custom_kexalgorithms,
      var.ssh_config
    )
    working_dir = path.module

  }

  triggers = {
    always_run = var.local_exec_trigger
  }
}
