# Terraform + Terragrunt — Complete Instructor Notes (One-Stop Reference)

Organized by the **official HashiCorp exam domains** (verified against HashiCorp's own Exam Content List — source at the bottom) for the Terraform files, and by logical DRY-concept groupings (verified against current official Terragrunt docs) for the Terragrunt files. Every topic from your course's lecture list is covered — nothing dropped — grouped where it logically belongs, with full depth per topic.

## Depth standard applied to every topic in every file
- A full **introduction**: what it is, what role it plays, when/where it's actually required.
- **Multiple varied examples** per concept (basic, intermediate, a realistic/edge case) — not one canonical snippet.
- An explicit **"What if you don't use this"** section — real consequences and failure modes, not a one-line caveat.
- **Minimum 2 real-world scenarios** per major concept.
- AWS-only examples throughout (no Azure/GCP).
- Mermaid diagrams only where they genuinely clarify architecture.
- Fresh Easy/Medium/Hard practice questions at the end of every file.

## File Map — Terraform (by official exam domain)

| File | Exam Domain | Course lectures folded in |
|---|---|---|
| [01-domain1-iac-concepts.md](01-domain1-iac-concepts.md) | **Domain 1** — IaC Concepts | Installation (Windows/Linux/macOS), IDE setup, AWS account/IAM/MFA, Authentication vs Authorization |
| [02-domain2-terraform-fundamentals.md](02-domain2-terraform-fundamentals.md) | **Domain 2** — Terraform Fundamentals | Providers, provider tiers, provider versioning, AWS auth config, state file overview, desired vs current state, refresh |
| [03-domain3-core-workflow.md](03-domain3-core-workflow.md) | **Domain 3** — Core Terraform Workflow | init/validate/plan/apply/destroy/fmt, graph, saving plans, output, settings block, load order, targeting, larger infra, comments, tainting, troubleshooting, bug reporting |
| [04-domain4a-resources-variables-types.md](04-domain4a-resources-variables-types.md) | **Domain 4** — Configuration (part A) | resource/data blocks, attributes, cross-references, outputs, variables, tfvars, precedence, data types (string/list/map/set/object) |
| [05-domain4b-count-foreach-functions-expressions.md](05-domain4b-count-foreach-functions-expressions.md) | **Domain 4** — Configuration (part B) | count, count.index, for_each, conditional expressions, functions, locals, dynamic blocks, splat, zipmap |
| [06-domain4c-dependencies-lifecycle-validation-secrets.md](06-domain4c-dependencies-lifecycle-validation-secrets.md) | **Domain 4** — Configuration (part C) | dependencies (implicit/explicit), lifecycle meta-arguments, variable validation, pre/postconditions, check blocks, moved blocks, sensitive data, Vault, ephemeral values |
| [07-domain5-modules.md](07-domain5-modules.md) | **Domain 5** — Modules | Module basics, custom modules, sources, variable scope, outputs, root vs child, standard structure, multi-provider, versioning, registry publishing |
| [08-domain6-state-management.md](08-domain6-state-management.md) | **Domain 6** — State Management | Local backend, state locking, S3 backend, Git/.gitignore security, workspaces, drift management, removed blocks |
| [09-domain7-maintain-infrastructure.md](09-domain7-maintain-infrastructure.md) | **Domain 7** — Maintain Infrastructure | terraform import, state CLI (list/show/mv/rm/pull), remote state data source, verbose logging/TF_LOG |
| [10-domain8-hcp-terraform.md](10-domain8-hcp-terraform.md) | **Domain 8** — HCP Terraform | Orgs/projects/workspaces, CLI-driven runs, Sentinel, private registry, teams/permissions, health assessments, run triggers, state migration, version pinning |
| [11-bonus-provisioners.md](11-bonus-provisioners.md) | Bonus (exam-adjacent) | Provisioners: local-exec, remote-exec, creation/destroy-time, failure behavior |
| [12-bonus-challenges-exam-prep.md](12-bonus-challenges-exam-prep.md) | Bonus | Terraform Challenges 1-4, exam booking/logistics, exam-day pointers, cross-domain capstone practice |

## File Map — Terragrunt (one-stop, researched against current official docs)

| File | Covers |
|---|---|
| [13-bonus-terragrunt-01-fundamentals.md](13-bonus-terragrunt-01-fundamentals.md) | Why Terragrunt, installation (Linux/Windows/macOS), version management (tfenv), basic setup, blocks explained, flow |
| [14-bonus-terragrunt-02-dry-patterns.md](14-bonus-terragrunt-02-dry-patterns.md) | The 4 DRY targets: modules, state/backend, architecture (include/generate), CLI args & provider config |
| [15-bonus-terragrunt-03-advanced-features.md](15-bonus-terragrunt-03-advanced-features.md) | Cache, auto-init, hooks, formatting, dependency/dependencies blocks, auto-retry, run-all, AWS cost caution, capstone deploy |

## File Map — Practice Questions (separate, dedicated bank)

| File | Covers |
|---|---|
| [16-practice-questions-with-answers.md](16-practice-questions-with-answers.md) | 57 practice scenarios — Beginner (7), Intermediate (10), Advanced (10), Module-Focused (10), Real-World Industry (20) — each with a full worked AWS answer plus an **Industry Best-Practice Notes** callout (what a senior engineer would change and why) |
| [17-practice-questions-by-domain.md](17-practice-questions-by-domain.md) | The same 57 scenarios, reindexed by the 8 official exam domains (matching files 01-10), then by difficulty tier (Beginner or Easy / Intermediate / Hard) within each domain — a navigation index pointing back to file 16, not a duplicate of its content |

**Status: COMPLETE.** All 17 files written. Every lecture in the original course list (both the Terraform and Terragrunt sections) has been cross-checked against these notes and folded in — including topics that needed a dedicated pass after the first draft (see below).

### Gap-fill pass (post-launch audit against the full lecture list)
After the initial 15-file build, every lecture title in the source course list was individually checked against these notes for real (not superficial) coverage. The following were found thin or missing and have since been added:
- File 01: a dedicated "Your First Resource" EC2 walkthrough + an early security-habits callout.
- File 02: standalone provider-aliasing mechanics, a full `.terraform.lock.hcl` deep-dive (incl. the multi-platform checksum gotcha), and a worked GitHub-provider example.
- File 03: a second `terraform destroy` real-world scenario, plus added depth to Comments/Troubleshooting/Bug-Reporting.
- File 04: an AWS security-group networking primer, a "reading provider docs / adapting to deprecations" skill section, and a dedicated Elastic IP explainer.
- File 05: "what if you don't use this" + real-world scenarios added for Splat Expressions and `zipmap()`.
- File 06: a full **Moved Blocks** section (this was confirmed completely absent despite being referenced elsewhere).
- File 10: an **HCP Terraform Pricing** section (confirmed absent despite being in the file's own stated scope).

## Sources
- HashiCorp's official Terraform Associate 004 Exam Content List: https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004
- Terragrunt official documentation (current, docs.terragrunt.com — verified for config block accuracy and version-specific `run-all` → `run --all` terminology): https://docs.terragrunt.com/reference/config-blocks-and-attributes
