job "bofa-demo-mongodb" {
    datacenters = ["dc1"]
    
    type = "service"

    group "mongodb" {
        network {
            mode = "bridge"
            port "http" {
                static = 27017
                to     = 27017
            }
        }

        service {
            name = "bofa-demo-mongodb"
            port = "27017"

            connect{
                sidecar_service {}
            }
        } 

        task "mongodb" {
            driver = "docker"

            config {
                image = "mongo:latest"
            }
            env {
                # This will immedietely be rotated be Vault
                MONGO_INITDB_ROOT_USERNAME = "admin"
                MONGO_INITDB_ROOT_PASSWORD = "password"
            }
        }
    }
}
