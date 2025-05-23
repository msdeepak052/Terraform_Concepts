# 🔧 What Are Terraform Provisioners?

## ✅ Definition

Terraform **Provisioners** are special configuration blocks that execute scripts or commands on a local or remote machine as part of the resource lifecycle.

They’re like the “final touches” you apply after Terraform has built the infrastructure — like hiring a painter after a house is constructed.

---

## 🎯 Why Use Provisioners?

Imagine Terraform is a robot contractor that builds virtual machines, databases, networks, etc. But sometimes, after Terraform builds a VM, you still want to:

- Install software (`apt install nginx`)
- Configure files (`echo "Hello" > /var/www/index.html`)
- Run a shell script (`bash my_script.sh`)
- Copy files onto the VM

This is where **Provisioners** step in. They're a bridge between infrastructure-as-code and configuration management or bootstrapping.

---

## 🔨 Types of Provisioners

### 1. `remote-exec`
Runs commands on the remote machine (e.g., an EC2 instance).

### 2. `local-exec`
Runs commands on the machine where you're running Terraform (e.g., your laptop or CI/CD runner).

### 3. `file`
Copies files or directories from your machine to the remote instance.

---

## 🏭 Real-World Industry Example

Let’s say you're an engineer at a **fintech startup** that spins up **on-demand testing environments**. Each environment needs:

- A secure EC2 instance  
- NGINX installed  
- An app binary copied over  
- A config file with an API key injected  

You use Terraform to spin up the EC2 instance. Once the instance is up, you need to:

- Copy your app and config (`file`)
- Install NGINX (`remote-exec`)
- Print the IP locally (`local-exec`)

## ⚠️ Important Caveats: When NOT to Use Provisioners

Provisioners are like **duct tape** — handy in a pinch, but not meant for long-term structural work.

---

### 💡 Industry Best Practice

Avoid **Provisioners** if you can. Prefer **Immutable Infrastructure**.

**Instead, use:**

- `cloud-init` or startup scripts baked into AMIs  
- Configuration management tools like **Ansible**, **Chef**, or **Packer**  
- **User Data** in AWS:

  ```hcl
  user_data = file("init.sh")


## ❗ Terraform Provisioners Break the Declarative Model

Provisioners can be:

- **Flaky**
- **Non-idempotent**
- Cause Terraform to **hang** or **fail** during `destroy`

They **go against the declarative philosophy** of Terraform and should be used with caution.

## 🔄 Lifecycle Triggers

- Provisioners run **only after a resource is created**
- They run **before a resource is destroyed** **if** you explicitly specify `when = "destroy"`

### 🔧 Example:

```hcl
provisioner "remote-exec" {
  when = "destroy"
  inline = [
    "echo 'Cleaning up before destroy...'"
  ]
}
```

### ⚠️ Provisioner Limitations

- ⚠️ **Provisioners do not run** if the resource is already up-to-date.
- ❌ This makes them **unsuitable for configuration drift management**.
- ✅ Instead, use tools like **Ansible** or **Puppet** for better control and idempotency.

---

### 🔬 Summary

| Feature         | Purpose                                         |
|-----------------|-------------------------------------------------|
| `file`          | Copy files to a remote machine                  |
| `remote-exec`   | Run remote shell commands via SSH               |
| `local-exec`    | Run local shell commands on the Terraform host  |
| **Best Practice** | Use for quick bootstrapping only             |
| **Better Tools** | `cloud-init`, Ansible, Packer, pre-baked AMIs |

---

### 📦 Terraform Example
---

### 1.main.tf

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for security
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  provisioner "file" {
    source      = "my_app_binary"
    destination = "/home/ubuntu/my_app_binary"
  }

  provisioner "file" {
    source      = "config.json"
    destination = "/home/ubuntu/config.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "chmod +x /home/ubuntu/my_app_binary",
      "/home/ubuntu/my_app_binary --config /home/ubuntu/config.json &"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > latest_server_ip.txt"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  tags = {
    Name = "fintech-app-instance"
  }
}

```

## 2.variables.tf

```hcl

variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  default     = "ami-0e35ddab05955cf57"  # Ubuntu 18.04 in us-east-1
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
}

variable "private_key_path" {
  description = "Path to the private SSH key"
  type        = string
}

```

## 3. terraform.tfvars

```hcl

key_name         = "lappynewawss"
private_key_path = "/home/ubuntu/lappynewawss.pem"

```
## 4. outputs.tf

```hcl

output "instance_ip" {
  value = aws_instance.app_server.public_ip
  description = "Public IP of the EC2 instance"
}

```
## 5. config.json

```json

{
  "api_key": "your_api_key_here",
  "env": "testing"
}

```

## 6. my_app_binary

'''sh

Empty file along woth the other files

```





