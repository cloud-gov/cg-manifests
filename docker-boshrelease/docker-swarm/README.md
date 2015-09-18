# cf-docker-swarm-broker

This is a set of scripts to support quickly creating a swarm broker deployment.

## Prerequisites

1. A current [docker-boshrelease](https://github.com/cf-platform-eng/docker-boshrelease) release. If you don't have this, you must complete [Upload the BOSH Release](https://github.com/cf-platform-eng/docker-boshrelease#upload-the-bosh-release) in order to deploy.

## Usage

1. Create a copy of `secrets_example.yml`.

		cp secrets_example.yml secrets.yml

1. Customize `secrets.yml` to suite your environment by updating the **Deployment Meta** and **General Cloud Foundry Environment Secrets** sections. The **Deployment Specific** section will be generated from the supplied **Deployment Meta** information.

1. Optionally add more service offerings and service plans to to `plans.yml` using the included `redis28` service and `standard` plan as an example. The [docker-boshrelease](https://github.com/cf-platform-eng/docker-boshrelease/blob/master/examples/docker-swarm-broker-aws.yml) repo has a large number of ready-to-run plans.

1. Generate unique secret keys for the deployment with `randomize.sh`.

		randomize -s secrets.yml

1. Generate the final manifest with `generate.sh`.

		generate.sh -s secrets.yml -p plans.yml > cf-docker-swarm-broker-PROJECT.yml

1. Deploy.

		bosh deploy cf-docker-swarm-broker-PROJECT.yml

1. Print strings to create or update the broker.

		generate.sh -s secrets_example.yml -p plans.yml -b

		Create a broker:

		cf create-service-broker \
		  DEPLOYMENT_NAME containers-EZCWFZKv 2IYCgKMrZzHfjh9ZfnCl7hHbo9lR1RIfxOoI4F0jbZcJLq5v \
		  https://DEPLOYMENT_NAME.ENVIRONMENT_DOMAIN

		Update a broker:

		cf update-service-broker \
		  DEPLOYMENT_NAME containers-EZCWFZKv 2IYCgKMrZzHfjh9ZfnCl7hHbo9lR1RIfxOoI4F0jbZcJLq5v \
		  https://DEPLOYMENT_NAME.ENVIRONMENT_DOMAIN

## Todo

- More verbose procedure.
- Details on adding plans.
- Explanation of deployment defaults.
- Secret storage.
