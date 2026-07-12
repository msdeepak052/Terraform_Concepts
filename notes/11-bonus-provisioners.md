# Bonus — Provisioners

*Not a dedicated exam domain, but referenced by the exam's "core workflow" and "configuration" material — HashiCorp explicitly documents provisioners as a last resort, and the exam expects you to know that framing, not just the syntax.*
*Course lectures folded in: Overview of Provisioners, Type of Provisioners, Format of Defining Provisioners, local-exec Practical, remote-exec Practical, Points to Note, Creation-Time and Destroy-Time Provisioners, Failure Behaviour*

---

## 1. What a Provisioner Is, and Why HashiCorp Calls It a Last Resort

### Definition
A provisioner runs a script or command **on the local machine or on the newly-created resource itself**, at create or destroy time — a way to bolt an imperative step onto Terraform's otherwise fully declarative model.

### Why "last resort," specifically
Terraform's core strength is *declaring* a desired state and letting the provider figure out how to reach it. A provisioner reintroduces exactly the imperative, order-dependent, "run this script and hope it works" model that IaC (Domain 1) exists to move away from. HashiCorp's official guidance is to prefer, in order:
1. **Provider-native arguments** — e.g., `user_data` on `aws_instance`, which the AWS provider itself manages declaratively.
2. **Image baking** (Packer) — bake application software directly into an AMI, so instances boot ready, with no runtime configuration step at all.
3. **Dedicated configuration management** (Ansible, Chef, Puppet) — tools purpose-built for "configure software on a running machine," with idempotency and drift-detection built in, which provisioners lack entirely.
4. **Provisioners** — only when none of the above can reach the specific, narrow thing you need to do.

### What if you default to provisioners for routine application configuration instead of `user_data`/Packer?
You inherit every problem the rest of this section describes: no idempotency guarantee, a required live SSH connection at apply time, and a broken/tainted resource on any transient failure. Teams that lean heavily on `remote-exec` provisioners for routine app deployment tend to accumulate exactly the kind of flaky, hard-to-debug apply failures that provider-native alternatives (`user_data`, Packer-baked AMIs) simply don't have, because those alternatives don't depend on live network connectivity at the exact moment `apply` runs.

---

## 2. Types of Provisioners

| Type | Runs where | Typical use |
|---|---|---|
| `local-exec` | On the machine running `terraform apply` | Trigger a local script, write to a local file, call a webhook, notify Slack |
| `remote-exec` | On the newly-created remote resource (via SSH/WinRM) | Run inline commands or a script directly on the instance itself |
| `file` | Copies a local file to the remote resource | Push a config file/script onto the instance before running it |

---

## 3. Format of Defining a Provisioner

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> inventory.txt"
  }
}
```
`self` refers to the resource the provisioner is attached to — you cannot write `aws_instance.web.public_ip` from **inside** its own provisioner block, because that full reference doesn't resolve correctly in that specific scope; `self` is the required workaround.

---

## 4. `local-exec` — Full Example and Real Use

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "echo Instance ${self.id} created with IP ${self.public_ip} >> created_instances.log"
  }
}
```

### A second, more realistic example — notifying an external system
```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "curl -X POST https://hooks.slack.com/services/XXX -d '{\"text\":\"New instance ${self.id} provisioned\"}'"
  }
}
```

### Use it when
You need to do something on your **own** machine or CI runner right after a resource is created/destroyed — update a local DNS entry, append to an inventory file consumed by another tool, or fire a webhook notification. All genuinely "outside the resource itself" actions, which is exactly what `local-exec` (running locally, not on the resource) is suited for.

---

## 5. `remote-exec` — Full Example, Its Real Fragility, and the Better Alternative

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
    ]
  }
}
```
Requires a `connection` block so Terraform knows how to reach the instance over SSH.

### What if the CI runner's IP isn't allow-listed in the instance's security group?
The provisioner hangs, then times out and fails — a very common, genuinely frustrating source of flaky pipelines, because the *cause* (a network reachability issue) has nothing to do with the actual Terraform code being wrong. This exact fragility is the concrete, lived reason HashiCorp recommends alternatives.

### The better alternative for the same goal — AWS `user_data`
```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  user_data     = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              EOF
}
```
`user_data` runs via cloud-init at first boot, needs **no** SSH connectivity from wherever `terraform apply` happens to run, and — importantly — re-runs cleanly and correctly if the instance is ever replaced (a new AMI forces recreation, for example), since it's baked into the instance's own boot process rather than depending on a live connection back to whoever is running Terraform at that moment.

### Real-World Scenario 1 — A Flaky CI Pipeline, Diagnosed and Fixed
A team's CI-driven Terraform pipeline intermittently fails with SSH timeout errors on `remote-exec` provisioners, roughly one run in six. The root cause: the CI runner's IP address is dynamic (a new IP on every run), and the security group only allow-lists a static office CIDR. Migrating the same bootstrap logic from `remote-exec` to `user_data` eliminates the failure entirely — the fix isn't "retry more," it's removing the SSH dependency altogether.

### Real-World Scenario 2 — A Replaced Instance Silently Missing Its Software
A team relies on a `remote-exec` provisioner to install application software, and later changes the instance's AMI, forcing a destroy-and-recreate. The **new** instance boots, and the provisioner *does* re-run against it (provisioners re-run whenever the resource is recreated) — but only if the SSH connection succeeds at that exact moment; if the security group or key pair configuration has drifted since the original apply, the new instance silently comes up *without* the expected software, and nobody notices until someone tries to use the service. A Packer-baked AMI with the software already installed would have made this entire failure mode structurally impossible — there'd be nothing left to provision at boot time.

---

## 6. Creation-Time vs. Destroy-Time Provisioners

```hcl
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo Created ${self.id}"
    # default: runs on CREATE
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo Destroying ${self.id} - deregistering from monitoring"
  }
}
```
- **Creation-time** (default, no `when`): runs once, immediately after the resource is created.
- **Destroy-time** (`when = destroy`): runs immediately before the resource is destroyed — useful for graceful deregistration (pulling an instance from a load balancer, removing it from a monitoring system) before it disappears entirely.

### The nuance that trips people up: destroy-time provisioners have limited scope
A destroy-time provisioner only has access to the resource's **own** attributes (via `self`) — it **cannot** reference other resources, because by the time it runs, other resources in the same `destroy` operation may already be gone or altered, depending on the overall destroy ordering. There is no way around this limitation from inside the provisioner itself.

### What if you need to call an external API (deregister from a monitoring system) that requires information from a *different* resource, at destroy time?
Since the destroy-time provisioner can't reference other resources, the practical fix is to make sure any information it needs is captured in the resource's **own** attributes/tags at creation time (so `self.tags["monitoring_id"]`, for example, is available at destroy time), or to handle the deregistration through an entirely separate mechanism outside the provisioner (a Lambda triggered by the EC2 termination lifecycle event, for instance) — not something the provisioner itself can be stretched to do.

### Real-World Scenario — Graceful Load Balancer Deregistration
```hcl
resource "aws_instance" "web" {
  # ...
  provisioner "local-exec" {
    when    = destroy
    command = "aws elbv2 deregister-targets --target-group-arn ${self.tags["tg_arn"]} --targets Id=${self.id}"
  }
}
```
Before an instance is terminated (e.g., during a scale-down), it's gracefully removed from its load balancer's target group first — preventing the load balancer from routing new requests to an instance that's mid-shutdown, which would otherwise cause a handful of failed requests during every scale-down event.

---

## 7. Failure Behaviour

```hcl
provisioner "remote-exec" {
  inline = ["sudo systemctl start nginx"]

  on_failure = continue   # default is "fail"
}
```

| Setting | Behavior on provisioner error |
|---|---|
| `fail` (default) | Terraform marks the resource **tainted** and the apply run stops with an error |
| `continue` | Logs the error but proceeds as if it succeeded — resource is **not** tainted |

### What if you set `on_failure = continue` broadly, "just to make red output go away"?
You silently ship broken bootstrap steps — the resource is marked healthy in state even though a step that was supposed to configure it actually failed. The next person to notice is whoever discovers the application isn't actually running, with no error anywhere in the Terraform output pointing them at the real cause. Reserve `continue` only for genuinely optional, best-effort steps (a non-critical notification call) where failure truly doesn't matter to the resource's correctness.

---

## 8. Points to Note (exam-style gotchas, gathered in one place)

- Provisioners are **not idempotent-checked** by Terraform — Terraform has no understanding of what the script actually does; it just runs it once, at the specified time, and trusts the exit code.
- A failed creation-time provisioner **taints** the resource (Domain 3) — the next `apply` destroys and recreates it, then re-runs the provisioner from scratch.
- Provisioners live inside a `resource` block but don't appear in `terraform plan` diffs the way argument changes do — conceptually, they're closer to an escape hatch bolted onto the resource's lifecycle than a first-class part of its declarative state.

---

## 9. Practice Questions

### Easy
1. Which keyword lets a provisioner reference the current resource's own attributes?
2. Which provisioner type runs on the machine executing `terraform apply`, rather than on the created resource?
3. True/False: HashiCorp recommends provisioners as the primary way to install application software on a new VM.

### Medium
4. Write a `remote-exec` provisioner (with its required `connection` block) that installs Docker on a freshly-created EC2 instance over SSH as user `ubuntu`.
5. A `remote-exec` provisioner intermittently times out in CI because the CI runner's IP isn't allow-listed in the instance's security group. Name two fixes — one provisioner-based, one that avoids provisioners entirely.
6. What happens to a resource's state if its creation-time provisioner fails and `on_failure` is left at its default?

### Hard
7. Design a destroy-time provisioner that deregisters an instance from a load balancer's target group before termination. Explain why this provisioner cannot reference a *different* resource's live attribute at that point, and how you'd work around that limitation using the resource's own tags.
8. A team currently uses `remote-exec` to install and configure application software on every EC2 instance at creation. Propose a migration plan to `user_data` or Packer-baked AMIs instead, and explain two concrete reliability benefits this gives over the provisioner-based approach — referencing the "replaced instance silently missing its software" failure mode described in this section.

---
**Next:** [12-bonus-challenges-exam-prep.md](12-bonus-challenges-exam-prep.md)
