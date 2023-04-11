# Last Stop 

Welcome to the Last Stop for all of your LLM prompts

## Last Stop benefits the individual and the organization

<br />

- __Deploy within minutes__ (individuals & organizations benefit!)
    - Check out our installation notes below, it only takes a few minutes to get going!
- __Cheaper usage of ChatGPT__ (individuals & organizations benefit!)
    - Why pay $20 a month when you can pay per service request, host it yourself at fractions of the cost*! (*Naturally, this depends on the usage of the individual, but most will likely save money and gain security.)
- __Data Loss Prevention__ (DLP)
    - Organizations benefit from maintaining their own instance of ChatGPT on their servers
    - Allow your employees to access ChatGPT without bringing their own accounts
    - Monitor for potential DLP (emails, names, code, etc), sanitize the requests, block the requests, or anything in between
- __Build a company corpus__
    - A corpus is a collection of data, such as the prompts and the responses
    - Share prompts among the team so nobody has to search the same thing twice!
    - Provides better results and quicker results, as well as faster knowledge shares
- __Gain insights__ into common prompts and train your employees based on the commonalities
- __API Security__
    - ChatGPT has heightened security for their APIs that includes an "Opt-in" selection for your data to be shared. [Don't be the product, use the APIs!!](https://help.openai.com/en/articles/7039943-data-usage-for-consumer-services-faq)

 <br />

__The best benefit of all? This is intended to run entirely in your own network or on your own device!__

<br />

## Our mission

<br />

Last Stop's mission is to provide accessibility and security to the individual and to the organization. Second to that is providing a quality experience with all LLMs in one location - query one or query them all (as more APIs are released of course).

<br />

![Example image of LLM functionality](assets/example.png)

<br />

## Why we started this

<br />

Countries and organizations are banning ChatGPT altogether, but we believe that there is a happy medium. New innovation should not be stifled but encouraged safely, and that's exactly what we're here to empower.

Don't be like these examples:

- [11% of data that employees paste in ChatGPT contains sensitive data](https://www.csoonline.com/article/3691115/sharing-sensitive-business-data-with-chatgpt-could-be-risky.html)
- [Samsung Proprietary Information Leak](https://mashable.com/article/samsung-chatgpt-leak-details)

<br />

Have more questions? Reach out to us in some of the following places:
- [Join our Discord](https://discord.gg/J8S4SYBqsq)
- [Circulate - Contact Us](https://www.circulate.dev/contact)
- [Kai Herrera](https://www.linkedin.com/in/kai-herrera/)
- [Dustin Buschman](https://www.linkedin.com/in/dbuschman/)

<br />

## How to deploy on your local machine

<br />

1. In order to deploy for the first time you must have the following dependencies:
    - [An API Key for ChatGPT](https://platform.openai.com/overview)
        - If you want us to retrieve and manage the API Key on your behalf, let us know! 
    - Docker ([Rancher](https://rancherdesktop.io/) or [Docker Desktop](https://docs.docker.com/desktop/))
1. Add your OpenAI API Key to the lib/docker-compose.yml file, at `OPENAI_APIKEY=` 
1. In /lib, run `docker compose up --build` to spin up the environment 
1. Navigate to localhost:8080 to begin using the UI

<br />

## How to deploy to the cloud

<br />

Coming soon - starting with AWS. If you would like to see more cloud configurations just let us know.

<br />

## Current Status & Roadmap

<br />

Immediate concerns:
```
- Responsive web design
- Build infrastructure as code to deploy to cloud
```

We plan to:
```
- Build in-network ML solutions for DLP detection
    - e.g. token classification for names, email, code, etc
- Build in-network ML solutions for data sanitization
- Provide a data store for organizations to build knowledge bases
- Provide an API layer for organizations to leverage for internal usage
- Continue to build a quality Open Source UI experience
- Build a mobile experience
- Much more - feel free to create an issue
```

<br />

## FAQ:

<br />

Can I use GPT-4?
```
Yes, but first you must apply to the waitlist at `platform.openai.com`. It is not generally available yet.
```

Can I use Bard or Anthropic?
```
We have applied to participate in their APIs to begin building for these LLMs. We look forward to the market of models, and will be supporting more as they get released.
```

