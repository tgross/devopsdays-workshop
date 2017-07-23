# Increase log verbosity
log_level = "INFO"

# Setup data dir
data_dir = "/var/lib/nomad/data"

# Enable the client
client {
    enabled = true
    servers = ["nomad.svc.{{ triton_cns_search_domain_private }}:4647"]
}
