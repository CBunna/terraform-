# Terraform Beginner Guide

A hands-on introduction to Terraform using the AWS EC2 example in this repository.

---

## What is Terraform?

Terraform is an **Infrastructure as Code (IaC)** tool by HashiCorp. It lets you define cloud resources (servers, networks, databases, etc.) in `.tf` files and manage them with simple commands.

**Core concept:** You describe *what* you want, Terraform figures out *how* to create or change it.

---

## Prerequisites

1. **Install Terraform** — [terraform.io/downloads](https://developer.hashicorp.com/terraform/downloads)
2. **Install AWS CLI** — [docs.aws.amazon.com/cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. **Configure AWS credentials**

```bash
aws configure
# Enter your: Access Key ID, Secret Access Key, Region, Output format
```

---

## Project Structure

```
iteration1/
├── main.tf          # Main configuration (provider + resources)
├── user_data.sh     # Startup script for the EC2 instance
├── .terraform/      # Downloaded providers (auto-generated, don't edit)
├── .terraform.lock.hcl  # Provider version lock file
├── terraform.tfstate    # Current state of your infrastructure
└── plan.tfplan          # Saved plan output
```

---

## Key Terraform Concepts

### 1. Provider
Tells Terraform which cloud/service to talk to and how.

```hcl
provider "aws" {
  region = "eu-central-1"
}
```

### 2. Resource
The actual infrastructure you want to create.

```hcl
resource "aws_instance" "apache_server" {
  ami           = "ami-096a4fdbcf530d8e0"  # Amazon Machine Image (OS image)
  instance_type = "t2.micro"               # Server size (free tier eligible)
  user_data     = file("user_data.sh")     # Script to run on first boot

  tags = {
    env = "dev"
  }
}
```

> **Resource syntax:** `resource "<TYPE>" "<NAME>" { ... }`
> The name `apache_server` is just a local label — it won't appear in AWS.

### 3. terraform block
Declares version requirements.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"   # Use any 6.x version
    }
  }
  required_version = ">= 1.2"  # Minimum Terraform CLI version
}
```

---

## The Core Workflow

```
Write .tf files  →  init  →  plan  →  apply  →  destroy
```

### Step 1: `terraform init`
Downloads the required providers and sets up the working directory.

```bash
terraform init
```

Run this once when you start, or after adding new providers.

---

### Step 2: `terraform plan`
Shows you what Terraform *will* do — without making any changes.

```bash
terraform plan

# Save the plan to a file (recommended)
terraform plan -out=plan.tfplan
```

Review the output carefully:
- `+` green = resource will be **created**
- `-` red = resource will be **destroyed**
- `~` yellow = resource will be **modified**

---

### Step 3: `terraform apply`
Creates or updates your infrastructure.

```bash
# Apply directly (will ask for confirmation)
terraform apply

# Apply a saved plan (no confirmation needed)
terraform apply plan.tfplan
```

Type `yes` when prompted, or use `-auto-approve` to skip.

---

### Step 4: `terraform destroy`
Tears down everything Terraform manages. **Use with caution.**

```bash
terraform destroy
```

---

## State File (`terraform.tfstate`)

Terraform keeps track of what it has created in `terraform.tfstate`.

- **Never delete it manually** — Terraform uses it to know what exists.
- **Never commit it to public git** — it may contain sensitive data (IPs, passwords).
- For teams, store state remotely (e.g., AWS S3 + DynamoDB).

Add to `.gitignore`:

```
*.tfstate
*.tfstate.backup
.terraform/
```

---

## Useful Commands

| Command | Description |
|---|---|
| `terraform init` | Initialize working directory |
| `terraform fmt` | Auto-format `.tf` files |
| `terraform validate` | Check for syntax errors |
| `terraform plan` | Preview changes |
| `terraform apply` | Apply changes |
| `terraform destroy` | Remove all managed resources |
| `terraform show` | Show current state |
| `terraform output` | Show output values |

---

## What This Example Does

The `iteration1/main.tf` in this repo:

1. Connects to AWS in the `eu-central-1` (Frankfurt) region
2. Creates a **t2.micro EC2 instance** (free tier) with Ubuntu
3. Runs `user_data.sh` on first boot, which installs **Apache2** web server

The result is a public web server running in AWS provisioned entirely from code.

---

## Common Errors

**`Error: No valid credential sources found`**
→ Run `aws configure` and set your credentials.

**`Error: Invalid AMI ID`**
→ AMI IDs are region-specific. Find the correct one in the AWS Console for your region.

**`Error: Error acquiring the state lock`**
→ Another `terraform apply` may be running, or a previous run crashed. Check for a `.terraform.tfstate.lock.info` file.


