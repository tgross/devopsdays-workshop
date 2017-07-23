job "workshop-<TODO>" {

  datacenters = ["dc1"]

  type = "service"

  constraint = {
    attribute = "${attr.kernel.version}"
    operator = ">="
    value = "4.0.0"
  }

  # A group is the Nomad equivalent of a Kubernetes "pod": a collection
  # of tasks that should be co-located on the same host.
  group "workshop" {

    count = 1

    task "app" {

      # we're going to deploy a Docker container that's been
      # previously built (this is the image in the app/ directory)
      driver = "docker"
      config {
        image = "0x74696d/devopsdays-workshop"
        network_mode = "host"
      }

      # The service block tells Nomad how to register this service
      # with Consul for service discovery and monitoring.
      service {
        name = "workshop"
        port = "HTTP"
        check {
          type     = "http"
          path     = "/"
          interval = "5s"
          timeout  = "2s"
        }
      }

      # Set environment variables which will be
      # available to the job when it runs.
      env {
        "OAUTH_TOKEN" = "<TODO>" # TODO: fill this in
        "ACCOUNT" = "<TODO>"     # TODO: fill this in
      }

      # Specify the maximum resources required to run the job,
      # include CPU, memory, and bandwidth.
      resources {
        cpu    = 500 # MHz
        memory = 128 # MB

        network {
          mbits = 100

          # dynamic port assignment named "http".
          # this will expose the environment variables
          # NOMAD_IP_HTTP and NOMAD_PORT_HTTP
          # which our application will use
          port "HTTP" {}
        }
      }
    }
  }
}
