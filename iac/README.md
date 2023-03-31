# Deploying the Infrastructure

The infrastructure is intended to be a single command deployment. 
Use terraform workspaces, if you don't create a new workspace it will deploy to "default"

<br />

## Requirements
- [make](https://www.gnu.org/software/make/manual/make.html)
- Docker (Rancher Desktop or Docker Desktop)
- Terraform v1.4.2+ (recommend tfenv if using MacOS / Linux)
- Golang v1.20

<br />

## Steps for your first deployment

1. Deploy the infastructure.

    ```
    make init
    ```

    This will create a remote backend in the environment you are signed into in your CLI. This will also deploy a project using the "default" Terraform Workspace. Feel free to change this workspace depending on how you manage your AWS environments

1. Go to Secrets Manager, select "/last-stop-default/openapi/api_key", and store your OpenAPI API Key

1. Submit a prompt! 

<br />

## Steps for updates & maintenance

To plan any changes to your infrastructure.

```
make plan
```

To deploy the changes you made. Note that -auto-approve is set, so if you would rather review your deployment one more time then go to the Makefile and remove that line.

```
make apply
```




