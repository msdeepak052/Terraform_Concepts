# Bonus — Terraform Challenges, Exam Booking, and Final Exam Prep

*Course lectures folded in: Terraform Challenges 1-4 (overview, hints, solutions), Our Community, Exam Appointment Rules, Booking the Exam, Important Pointers for Exams (Parts 1-3), Additional Pointers, Practice Tests 1-7, What's Next*

---

## 1. The Terraform Challenges — What They're Actually For

The course's four challenges exist to force you to *combine* concepts across the domains covered so far, in a self-contained scenario, rather than practicing each concept in isolation. Each challenge follows the same rhythm: an overview (the task), hints (a nudge if you're stuck, not an answer), and a solution walkthrough.

**How to actually get value from them (not just watch the solution video):**
1. Read the challenge's full requirements before writing any code — most failures come from missing a stated requirement (a specific tag, a specific output name), not a Terraform syntax mistake.
2. Attempt the *entire* challenge yourself, including getting genuinely stuck, before opening the hints.
3. After watching the solution, don't just check "did I get the same final code" — check "did I reach for the same *concepts*" (the right meta-argument, the right data type, the right dependency pattern). Different code that satisfies the same requirements is completely fine; Terraform rarely has exactly one correct way to solve a problem.

### What each challenge tends to emphasize
| Challenge | Primary skills exercised |
|---|---|
| 1 | Fundamentals: resources, variables, outputs — the "gentlest" one |
| 2 | Multiple resources with real dependencies — `for_each`, cross-resource references, implicit vs. explicit dependency |
| 3 | Expression-heavy: functions, locals, conditional logic, `dynamic` blocks |
| 4 | Capstone: modules, state, a small multi-tier architecture — plan the resource graph on paper *before* writing code |

### What if you skip straight to the solution video without attempting the challenge yourself?
You'll recognize the syntax when you see it, but you won't have practiced the actual skill the exam tests: reading a requirement and independently deciding *which* Terraform feature solves it. That decision-making is exactly what multiple-choice exam questions probe — "given this scenario, which of these four approaches is correct" — and it's a muscle that only builds through genuine, unaided attempts, not passive video-watching.

---

## 2. Exam Booking and Logistics

### Exam format
- **Duration:** 60 minutes.
- **Format:** ~57-60 questions, multiple-choice and multiple-select (some questions specify exactly how many answers to pick — read that instruction carefully).
- **No negative marking** — always answer every question, even a guess beats a blank.
- **Proctored**, either online (via webcam, from home/office) or at a physical test center.

### Booking process
1. Create/sign in to your HashiCorp certification account.
2. Select "Terraform Associate (004)."
3. Choose online-proctored or a physical test center, and pick a date/time.
4. Pay the exam fee and receive a confirmation email with instructions.

**Don't** book before you're consistently scoring well across every domain file's practice questions in these notes — a failed attempt costs both the fee and a mandatory waiting period before retaking.

### Requirements to check well before your slot
A government-issued photo ID; if testing online, a clean/private testing space (no other people, no extra monitors, a clear desk), a stable internet connection, and a working webcam/mic. Requirements do get updated by HashiCorp/the proctoring vendor — always confirm the *current* official candidate handbook rather than relying on secondhand summaries (including this one) for exam-day logistics specifically.

---

## 3. Exam-Day Strategy and Pointers

### Time management
Budget roughly one minute per question on average. Flag long, scenario-heavy questions mentally and come back to them rather than burning five minutes on one question early and running out of time for easier ones later.

### Reading technique
Read the question stem **twice** before reading the answer options. A large fraction of wrong-but-tempting answers are technically true statements *about Terraform in general* — they just don't answer the specific thing the question actually asked. Multiple-select questions usually tell you how many answers to choose ("select two") — miscounting is an easy, avoidable way to lose a point you otherwise knew.

### The highest-yield final review list (topics that repeatedly trip up candidates)
- `count` vs. `for_each` index-instability (Domain 4b) — arguably the single most-tested "gotcha" concept in the whole exam.
- Implicit vs. explicit dependency (Domain 4c).
- The state-file-plaintext-secrets caveat, even with `sensitive = true` (Domain 2, Domain 4c).
- Variable definition precedence order (Domain 4a) — memorize the exact five-level order.
- `terraform validate` vs. `plan` — what each actually checks, and what neither one does (Domain 3).
- Module state ownership: no separate state per module (Domain 5).
- Backend blocks cannot use variables (Domain 6) — a specific, frequently-tested exception.
- HCP Terraform "workspace" ≠ CLI `terraform workspace` (Domain 6, Domain 8) — a very commonly confused pair of terms.
- Sentinel enforces policy *before* apply, organization-wide, regardless of who runs it (Domain 8) — don't confuse with per-config variable validation.
- Provisioners are a documented "last resort," not the recommended way to configure software (Bonus: Provisioners).

If any of these feel shaky, go back to that specific domain file rather than re-reading the whole set of notes linearly — targeted review of known weak spots is a far better use of remaining study time than a uniform re-read.

---

## 4. Final Capstone Practice — Cross-Domain Scenario Questions

*These are intentionally harder and span multiple domains at once, simulating the "combine several concepts in one question" style the real exam frequently uses. Fresh questions, not copied from any bank.*

### Scenario Set A — State & Collaboration
1. Two engineers, each with their own local Terraform state, both create a security group intended to be "the" application security group for the same VPC. Explain the two separate root-cause failures at play (one about backends, one about team process) and the single architectural change that would have prevented both simultaneously.
2. A workspace's `remote_state`-consuming downstream project starts returning `null` for a value that used to work. The upstream team insists "we didn't remove anything." What's the most likely explanation, and how would you confirm it using `terraform state show`?

### Scenario Set B — Configuration Language
3. A `count`-based resource list has an item removed from the middle, and a completely unrelated resource — one that references the `count`-based resource via a splat expression (`aws_instance.web[*].id`) — also shows an unexpected change in the next `plan`. Explain the chain of cause and effect connecting the list removal to the splat-referencing resource's diff.
4. A module's `variables.tf` has no `validation` block on `instance_type`, but the calling root module's own `variables.tf` does. Someone bypasses the root module's validation entirely by calling the child module directly with a hardcoded, invalid value. Whose validation (if any) actually catches this, and why?

### Scenario Set C — Governance & Lifecycle
5. A resource has both `prevent_destroy = true` and is referenced by a `moved` block renaming it. Walk through whether the `moved` block's operation is blocked by `prevent_destroy`, and explain your reasoning based on what each mechanism actually guards against.
6. An HCP Terraform workspace has a Sentinel policy blocking public S3 buckets, but an engineer runs `terraform apply` from their own laptop against the same state, using local credentials, bypassing HCP Terraform's run pipeline entirely. Does the Sentinel policy still apply? Why or why not, and what workspace/permission configuration would prevent this bypass?

### Scenario Set D — Debugging & Operations
7. A `terraform plan` intermittently fails with a generic AWS error roughly one run in eight, in a CI pipeline. Walk through the troubleshooting model (Domain 3) step by step, including when you'd escalate to `TF_LOG` verbose logging, and what specific log content you'd be looking for.
8. A provisioner-based EC2 bootstrap works fine on initial `apply` but silently fails to configure the application after the instance is replaced due to an AMI change six months later. Diagnose the likely cause and propose the specific alternative (from the Provisioners section) that would prevent this class of failure entirely.

---

## 5. What's Next

After passing the Associate exam, the natural next steps are: (1) apply these concepts on a real, non-toy project rather than letting the knowledge stay theoretical, (2) go deeper on Sentinel/OPA policy-as-code if your organization uses (or is considering) HCP Terraform, and (3) the Terragrunt material that follows — which builds directly on everything covered here, solving the specific "how do I keep dozens of near-identical environments DRY" problem that plain Terraform intentionally leaves to other tooling.

---
**Next:** [13-bonus-terragrunt-01-fundamentals.md](13-bonus-terragrunt-01-fundamentals.md)
