# Instructor Notes


## Set up prototype

Create `./host/password.yml` with the following values:

```yml
student_password: xxxx
triton_cns_search_domain_private: xxxxxxxx.us-east-1.cns.joyent.com
oauth_token: xxxxxxxx
```

The `student_password` should come from the results of `$(mkpasswd --method=sha-512)`, and the `oauth_token` should be a GitHub OAuth token with no privileges (we need this to bypass rate limiting for unauthenticated requests to the GitHub API).

## Set up Consul

```
# stand up Consul cluster

cd ./instructor/consul
triton-compose -p workshop up -d
triton-compose -p workshop scale consul=3
```
