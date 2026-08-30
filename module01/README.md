# JHU Production AI - Module 01:

In this module we are setting up our Azure Virtual Machine and VSCode to enable us to complete the upcoming projects for this semester!

## Prerequisites

Before starting this module, ensure you have the following installed on your local machine:

- **[Visual Studio Code](https://code.visualstudio.com/)** - Code editor for development and remote SSH access, with the **Remote - SSH** extension (`ms-vscode-remote.remote-ssh`)
- **[Terraform](https://developer.hashicorp.com/terraform/install)** - Infrastructure as Code tool for deploying Azure resources (version 1.9.0 or newer)
- **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)** - Command-line tool for authenticating and managing Azure resources
- **[Git](https://git-scm.com/downloads)** - to clone this repository

You also need an **SSH key pair**. The VM is key-only, password login is disabled, and
`terraform apply` will not run without a public key to install:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/azure_lab -C "jhu-ai-lab"
```

That gives you `~/.ssh/azure_lab` (your private key, which never leaves your machine) and
`~/.ssh/azure_lab.pub` (the public half, which Terraform installs on the VM). Keep the
default path unless you change `sshPublicKeyPath` in your variables file to match.

## Your Azure Subscription

Terraform deploys into whichever Azure subscription you point it at, and it has no default.
Before you deploy anything you have to fill in the `studentSubscriptionId` parameter in
[`VirtualMachine/terraform/student.tfvars.json`](./VirtualMachine/terraform/student.tfvars.json),
which ships with a placeholder:

```json
"studentSubscriptionId": "REPLACE-WITH-YOUR-SUBSCRIPTION-ID",
```

<!--
TODO(instructor): this points at the rapid-ai-class Canvas course - course 135509,
Module 0, page slug `azure-subscription` (page id 3444190). Repoint it at the 604
course's own Module 0 subscription page once that course exists. Also confirm the
135509 page is actually published before students are sent here: as of 2026-08-29
every item in that Module 0 was still unpublished, so this link 404s for students
until the module is released.

IMPORTANT: that page names the RAPIDAI subscription (JH-WSE-CLASS-EP-RAPIDAI,
8738094a-...). This course deploys into JH-WSE-CLASS-EP-PRODUCTIONAI
(454f8f24-fd11-4fa7-8e95-8b0d80c25bb9, per `az account list` on 2026-08-30). Until
the 604 page exists, a student following this link deploys into the wrong course's
subscription. Do not publish this README to 604 students with the link as it stands.
-->

**The subscription name and ID for this course are on the Azure Subscription page in
Module 0 on Canvas:**

<https://jhu.instructure.com/courses/135509/pages/azure-subscription>

Copy the subscription ID from that page into `student.tfvars.json`, then confirm your Azure
CLI is pointed at the same subscription before you run Terraform:

```bash
az login
az account show --output table                     # which subscription am I in?
az account list --output table                     # which ones can I see?
az account set --subscription <SUBSCRIPTION-ID>    # switch to the course subscription
```

Running `terraform apply` against the wrong subscription is the expensive kind of mistake:
the resources land somewhere nobody is watching, and they keep billing after you have
forgotten they exist.

While you have `student.tfvars.json` open, replace `example` with your own name in every
resource name. The subscription is shared with the whole class, so resource names have to be
unique within it and it has to be obvious which resources are yours.

## Topics

This module contains the following topics that are recommended to be completed in the following order:

1. [Deploy Virtual Machine](./docs/VirtualMachine.md)
2. [Setup VSCode](./docs/VSCodeSetup.md)
3. [Optional: Open WebUI and Ollama](./docs/OpenWebUI.md)
