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

It asks two questions:

```
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```

**Set a passphrase.** The private key is the only credential for a VM whose SSH port faces
the internet. If your laptop is lost or the file is copied, the passphrase is what stops
whoever has it from logging in as you. Pick something you can type from memory; it is not
recoverable, and losing it means generating a new key pair and re-deploying.

Pressing Enter twice for an empty passphrase also works, and the deployment does not care
either way. You are trading the protection above for never being prompted.

With a passphrase, SSH asks for it every time it uses the key, and VS Code Remote - SSH
connects several times per session. Load the key into `ssh-agent` once per login and it
stops asking:

```bash
# macOS / Linux
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/azure_lab
```

```powershell
# Windows, in PowerShell (one-time setup, then ssh-add on each login)
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add $HOME\.ssh\azure_lab
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
NOTE(instructor): both Azure Subscription pages exist but were unpublished as of
2026-08-31 (604: course 135329, page id 3447899; 704: course 135509, page id 3444190),
so the links below 404 for students until each course's Module 0 is released.

INSTRUCTOR SETUP, once per subscription, before any student deploys: register the
resource providers. providers.tf sets resource_provider_registrations = "none", so
Terraform will not do it and students cannot (needs subscription-level rights).
  az provider register --namespace Microsoft.Network  --subscription <id>
  az provider register --namespace Microsoft.Compute  --subscription <id>
  az provider register --namespace Microsoft.Storage  --subscription <id>
Skipping this fails every deployment with 409 MissingSubscriptionRegistration.
Status: 8738094a (RAPIDAI) not yet (first apply hit the 409 on 2026-08-30).
        454f8f24 (PRODUCTIONAI) not yet. Update these lines when each is done.
-->

**The subscription name and ID for your course are on the Azure Subscription page in
Module 0 on Canvas.** This repository serves two courses that deploy into two different
subscriptions, so use the page for the course you are enrolled in:

| Your course | Subscription page | Subscription name |
|---|---|---|
| EN.705.604 (Production AI) | <https://jhu.instructure.com/courses/135329/pages/azure-subscription> | `JH-WSE-CLASS-EP-PRODUCTIONAI` |
| EN.705.704 (Rapid AI Systems) | <https://jhu.instructure.com/courses/135509/pages/azure-subscription> | `JH-WSE-CLASS-EP-RAPIDAI` |

Copy the subscription ID from your course's page into `student.tfvars.json`, then confirm
your Azure CLI is pointed at the same subscription before you run Terraform. The
subscription name from `az account show` must match the name in the table for your course:

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

## What Comes Installed on the VM

You install nothing by hand. At first boot the VM runs
[`VirtualMachine/scripts/custom_data.sh`](./VirtualMachine/scripts/custom_data.sh), which
installs the toolchain for the whole semester - that script is the source of truth, and
this section is the readable summary of it.

**The install runs in the background for 15-25 minutes after `terraform apply` finishes.**
A VM that looks empty right after deployment is still provisioning. Check it from a
terminal on the VM:

```bash
cloud-init status --wait               # blocks until provisioning is done
cat /var/log/provision-summary.txt     # every line should read OK
```

### System tools

| Tool | Used from |
|---|---|
| `git`, `unzip`, `jq`, `build-essential`, `tmux`, `htop`, `vim` | Module 01 |
| `python3.12` (alongside the system Python 3.10, which is deliberately left alone) | Module 01 |
| `az` - Azure CLI | Module 01 |
| `func` - Azure Functions Core Tools 4 | Azure Functions work |
| `docker` with the buildx and compose plugins | Module 08 |
| `kubectl`, `helm`, `terraform` | Module 09 |
| `node` 22 via nvm, installed in your home directory | tooling |
| `claude` - Claude Code CLI, in `~/.local/bin` | AI-assisted development, all modules |

### Python environment

A virtual environment at `~/ai-dev`, built on Python 3.12, **activated automatically on
login** - your prompt shows `(ai-dev)`. It contains:

- **AI clients:** `anthropic`, `openai`
- **Frameworks (CPU builds - the course subscription has no GPU SKUs):** `torch`,
  `torchvision`, `torchaudio`, `tensorflow-cpu`, `scikit-learn`
- **Hugging Face:** `transformers`, `datasets`, `huggingface_hub`, `accelerate`, `peft`,
  `tokenizers`, `evaluate`
- **LangChain:** `langchain`, `langchain-anthropic`, `langchain-openai`, `langchain-community`
- **Data science:** `numpy`, `pandas`, `scipy`, `matplotlib`, `seaborn`, `plotly`,
  `jupyter`, `ipykernel`, `ipywidgets`
- **MLOps:** `mlflow`, `wandb`, `dvc`
- **Azure SDKs:** `azure-identity`, `azure-mgmt-compute`, `azure-storage-blob`
- **Utilities:** `python-dotenv`, `tqdm`, `rich`, `httpx`, `requests`, `pydantic`

### What the provisioning leaves behind

| File on the VM | What it is |
|---|---|
| `/var/log/provision-summary.txt` | Self-check: one `OK`/`FAIL` line per tool and package, then a final `RESULT:` line |
| `~/requirements.txt` | `pip freeze` of the exact environment you were handed |
| `/var/log/cloud-init-output.log` | The full install log, for troubleshooting |

Two things that only take effect on your **next** login after provisioning finishes:
running `docker` without `sudo`, and the `(ai-dev)` prompt if you were logged in during the
install. If either is missing, log out and back in before assuming something failed.

**Not installed:** your API keys and your Claude sign-in. Keys are yours; put them in a
`.env` file that git ignores, and never commit them. For Claude Code, run `claude` once on
the VM and log in with your own account.

## Topics

This module contains the following topics that are recommended to be completed in the following order:

1. [Deploy Virtual Machine](./docs/VirtualMachine.md)
2. [Setup VSCode](./docs/VSCodeSetup.md)
3. [Optional: Open WebUI and Ollama](./docs/OpenWebUI.md)
