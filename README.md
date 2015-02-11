## 18F Cloud Foundry Bosh Deployment Manifest

This repo contains the source for the Bosh deployment manifest for the 18f
Cloud Foundry deployment.

### How to generate the final manifest:

1. Install `spiff`
1. Copy the secrets example to secrets file:
`cp manifests/cf-secrets-example.yml manifests/cf-secrets.yml`
1. Change all the variables in CAPS from `manifests/cf-secrets.yml` to proper values
1. Run `./generate_deployment_maifest > manifest.yml`

### How to deploy the manifest:

Wherever you have your bosh installation run:
1. `bosh deployment manifest.yml`
1. `bosh deploy`
