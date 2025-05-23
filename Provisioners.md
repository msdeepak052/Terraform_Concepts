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

---

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

### ⚠️ Provisioner Limitations

- ⚠️ **Provisioners do not run** if the resource is already up-to-date.
- ❌ This makes them **unsuitable for configuration drift management**.
- ✅ Instead, use tools like **Ansible** or **Puppet** for better control and idempotency.



### 🔬 Summary

| Feature         | Purpose                                         |
|-----------------|-------------------------------------------------|
| `file`          | Copy files to a remote machine                  |
| `remote-exec`   | Run remote shell commands via SSH               |
| `local-exec`    | Run local shell commands on the Terraform host  |
| **Best Practice** | Use for quick bootstrapping only             |
| **Better Tools** | `cloud-init`, Ansible, Packer, pre-baked AMIs |


### 📦 Terraform Example

```hcl
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = "my-key"

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
      "sudo apt update",
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
    private_key = file("~/.ssh/my-key.pem")
    host        = self.public_ip
  }
}


'''


