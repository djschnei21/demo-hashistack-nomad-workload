resource "nomad_job" "mongodb" {
  jobspec = file("${path.module}/nomad-jobs/mongodb.hcl")
}

resource "null_resource" "wait_for_db" {
  depends_on = [nomad_job.mongodb]

  provisioner "local-exec" {
    command = "sleep 5 && bash wait-for-nomad-job.sh ${nomad_job.mongodb.id}"
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
    name                 = "mongodb-on-nomad"
    username             = "admin"
    password             = "password"
    connection_url       = "mongodb://{{username}}:{{password}}@demo-mongodb.service.consul:27017/admin?tls=false"
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
    command = "curl --header \"X-Vault-Token: ${var.vault_token}\" --request POST ${var.vault_addr}/v1/${vault_database_secrets_mount.mongodb.path}/rotate-root/mongodb-on-nomad"
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
 jobspec = file("${path.module}/nomad-jobs/mongodb-vmdk.hcl")
}