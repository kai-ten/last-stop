# Last Stop 

Last Stop is the final place your prompt resides before sending your data to the black box. Last Stop is a DLP solution that to mitigate data loss before prompts get sent to Large Language Models (LLMs) like OpenAI's ChatGPT, Google's Bard (coming soon), and more. Last Stop also allows you gain insights into the use-cases that your organization is sending to LLMs, so that you can increase the experiences of using these tools as an organization. 

With each prompt, the data being monitored is checked for code, PII, sensitive organization data, and whatever else you'd like to define as a flag or key metric. Any findings in the data can result in blocking the message, can result in sanitizing the data prior to being submitted, or can result in being stored to a Vector database to build a company corpus. Once the data has been validated and cleaned (if necessary), the request will be forwarded to the LLM.

<br />

__The best part? This is intended to run entirely in your own cloud!__

<br />

![Example image of LLM functionality](assets/example.png)

<br />

Make the most of these LLMs by leveraging them all in one application all while staying safe from DLP. After all, it is estimated that [11% of data that employees paste in ChatGPT contains sensitive data](https://www.csoonline.com/article/3691115/sharing-sensitive-business-data-with-chatgpt-could-be-risky.html).

Have more questions? Reach out to us in some of the following places:
- [Circulate - Contact Us](https://www.circulate.dev/contact)
- [Kai Herrera](https://www.linkedin.com/in/kai-herrera/)
- [Dustin Buschman](https://www.linkedin.com/in/dbuschman/)

<br />

## How to deploy for the first time

1. In order to deploy for the first time you must have the following dependencies:
    - [An API Key for ChatGPT](https://platform.openai.com/overview) (yes, having this is better than employees signing in on their behalf)
        - If you want us to retrieve and manage the API Key on your behalf, let us know! 
    - Docker ([Rancher(https://rancherdesktop.io/)] or [Docker Desktop](https://docs.docker.com/desktop/))
    - [aws-cli](https://aws.amazon.com/cli/)
    - [Golang 1.20](https://go.dev/doc/install)
    - [Node v18.x](https://nodejs.org/en)
    - [Terraform](https://developer.hashicorp.com/terraform/downloads?ajs_aid=bf5b0ec0-8e9f-4b0c-9e0b-1879f52fa26c&product_intent=terraform)
        - [tfenv](https://github.com/tfutils/tfenv) if you have MacOS / Linux is even better
    - [make](https://www.gnu.org/software/make/)

    Want to see an easier deployment process? Let us know! 

1. Once your machine is configured, take a look at the terraform.example.tfvars file.
    - VPC
        - If you already have one, input the IDs here
        - If you want a new one created, use the example settings
    - IP Addresses
        - We support IPv4 and IPv6, just add the proper IP ranges for your network.
        - If you need a different pattern, just let us know

1. Change the file name from `terraform.example.tfvars` to `terraform.tfvars`
    - This is ignored in .gitignore. If you want to check this into your PRIVATE repo, then comment out the `terraform.tfvars` line in .gitignore.

1. You are now ready to run the following:
    ```
    make init
    ```

    This will initialize a remote backend, and install everything using the Terraform workspace "default". This means that if you change workspace, you will also be able to change the environment that you are deploying. It's worth noting that if you expect to deploy across AWS accounts, the remote state will be different in each account unless you connect the accounts via IAM. Let us know if this is something you would like to see.

1. After your project has initialize, you __MUST__ store your API Key in the Secret that was created in Secrets Manager. Replace the entire string value with your API Key that you created on [OpenAI's Platform](https://platform.openai.com/overview).

1. You are now ready to use the website! Check out Cloudfront to get your website endpoint. If you would like to see some Route53 configuration, let us know! 

As you have read, we want you to let us know about anything you want or need. Please reach out for any reasons - you can find us above this section.

<br />

## Deploying new changes

Assuming you have initially deployed...

1. If you would like to see your changes before you apply, run the following:
    ```
    make plan
    ```

1. Any subsequent changes will now only require you to run the following:

    ```
    make apply
    ```

1. If you want to delete the project, run the following:
    ```
    make delete
    ```

<br />

## Current Status & Roadmap

We currently...
```
    - Support AWS only
    - Require building from source
    - Host in Cloudfront behind a WAF
```

We plan to... (these plans will be adjusted based on user interest!)
```
- Support more cloud providers
- Host ML in-network for DLP detection
- Provide an easier deployment process
- Much more - but the above are the big 3! 
```
