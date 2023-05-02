resource "nomad_job" "mongodb" {
  jobspec = file("${path.module}/nomad-jobs/mongodb.hcl")
}

resource "null_resource" "wait_for_db" {
  depends_on = [nomad_job.mongodb]

  provisioner "local-exec" {
    command = "bash wait-for-nomad-job.sh ${nomad_job.mongodb.id}"
  }
}

resource "vault_database_secrets_mount" "mongodb" {
  depends_on = [
    null_resource.wait_for_db
  ]
  lifecycle {
    ignore_changes = [
      mongodb[0].password
    ]
  }
  path = "mongodb"

  mongodb {
    name                 = "mongodb"
    username             = "admin"
    password             = "password"
    connection_url       = "mongodb://{{username}}:{{password}}@bofa-demo-mongodb.service.consul:27017/admin?tls=false"
    max_open_connections = 0
    allowed_roles = [
      "demo",
    ]
  }
}

resource "null_resource" "mongodb_root_rotation" {
  depends_on = [
    vault_database_secrets_mount.mongodb
  ]
  provisioner "local-exec" {
    command = "VAULT_ADDR=${var.vault_addr} VAULT_TOKEN=${var.vault_token} vault write -f ${vault_database_secrets_mount.mongodb.path}/rotate-root/mongodb"
  }
}

resource "vault_database_secret_backend_role" "mongodb" {
  name    = "demo"
  backend = vault_database_secrets_mount.mongodb.path
  db_name = vault_database_secrets_mount.mongodb.mongodb[0].name
  creation_statements = [
    "{\"db\": \"admin\",\"roles\": [{\"role\": \"root\"}]}"
  ]
}

resource "nomad_job" "dashboard" {
  depends_on = [
    vault_database_secret_backend_role.mongodb
  ]
  jobspec = file("${path.module}/nomad-jobs/dashboard.hcl")
}


// Optional Full KVM based VM Example
resource "nomad_job" "fullvm" {
  count = 0
  jobspec = file("${path.module}/nomad-jobs/vmdk.hcl")
}