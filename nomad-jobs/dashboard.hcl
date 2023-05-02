job "bofa-demo-dashboard" {
    datacenters = ["dc1"]
    
    type = "service"
    
    group "dashboard" {
        network {
            mode = "bridge"

            port "http" {
                static = 3100
                to     = 3100
            }
        }
        service {
            name = "bofa-demo-dashboard"
            port = "http"

            connect {
                sidecar_service {
                    proxy {
                        upstreams {
                            destination_name = "bofa-demo-mongodb"
                            local_bind_port  = 27017
                        }
                    }
                }
            }
        }

        task "wait-for-mongodb" {
            driver = "docker"

            config {
                image = "mongo:latest"

                entrypoint = ["/bin/sh"]

                command = "-c"

                args = [
                    "while ! mongo --host 127.0.0.1 --port 27017 --eval 'db.adminCommand(\"ping\")' --quiet >/dev/null 2>&1; do sleep 5; done"
                ]
            }
        }

        task "dashboard" {
            driver = "docker"

            lifecycle {
                hook = "poststart"
                sidecar = false
            }
            vault {
                policies = ["demo"]
                change_mode   = "restart"
            }
            template {
                data = <<EOH
MONGOKU_DEFAULT_HOST={{ with secret "mongodb/creds/demo" }}{{ .Data.username }}:{{ .Data.password }}{{ end }}@127.0.0.1:27017
EOH
                destination = "secrets/mongoku.env"
                env         = true
            }

            config {
                image = "huggingface/mongoku:latest"
            }
        }
    }
}