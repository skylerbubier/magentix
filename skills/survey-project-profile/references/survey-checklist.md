# Survey Checklist

What to look for, where to look, and which `category` the resulting fact becomes. Read this before asking anyone anything — per [`01-fact-format.md`](${CLAUDE_PLUGIN_ROOT}/profiles/project/01-fact-format.md), most project facts are observable, and the interview should be short.

| Thing to look for | Where to look | Becomes category | Typical `verification.method` |
|---|---|---|---|
| Repository boundaries, monorepo/polyrepo structure, what this project actually is | Top-level layout, README, repo list | `identity` | `observed` |
| Languages, frameworks, runtime/platform anchors | Dependency manifests (`package.json`, `requirements.txt`, `go.mod`, `*.csproj`, `Gemfile`), lockfiles, Dockerfiles | `stack` | `observed` |
| APIs, schemas, contracts exposed or consumed | OpenAPI/Swagger specs, `.proto` files, GraphQL schemas, published client packages | `interface` | `observed` |
| CI pipeline definition | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `azure-pipelines.yml` | `capability` (if a stage blocks merge) or `cadence` (release rhythm) | `observed` |
| Required status checks, branch protection rules | Repo host settings/API (GitHub branch protection, GitLab merge rules) | `capability` and `authority` | `observed` — see [inventory-capabilities](../../inventory-capabilities/SKILL.md) |
| Who must approve what | `CODEOWNERS`, branch protection required-reviewers config | `authority` | `observed` (config) or `asserted` (the social reality behind it) |
| Test suite and its invocation | `package.json` scripts, `Makefile`, CI job steps, test runner config | `capability` (only if a failing test actually blocks merge) — otherwise a `convention` pointer | `observed` |
| Pre-commit / local hooks | `.pre-commit-config.yaml`, `.husky/`, `.git/hooks/` | `capability` only if unbypassable and blocking — otherwise instrumentation, not a fact at all, or a `convention` | `observed` |
| Linting / formatting enforcement | Same CI config — is a failing lint a required check, or just a report? | `capability` if blocking, `convention` if advisory | `observed` |
| Release cadence, environments, promotion order | `CHANGELOG.md`, git tags, release workflow, environment configs | `cadence` | `observed` or `asserted` |
| Risk tier | Rarely written down anywhere; usually social | `cadence` | `asserted` — ask a person |
| Repository's own stated conventions (build steps, layering rules, style guide) | `CONTRIBUTING.md`, `docs/conventions*`, architecture docs | `convention` | `pointer` — record that it exists and where, never its content |
| Regulatory, contractual, platform, or cost constraints | Compliance docs, platform limits, contract terms — often nowhere written down | `constraint` | `asserted` — justify or drop if untestable |
| Existing agent tooling already in the repo | `CLAUDE.md`, `.claude/`, `.cursor/rules`, `AGENTS.md` | `harness` | `observed` — see [bind-harness](../../bind-harness/SKILL.md) |
| Prior manifests from the adoption loop | `adoption/{practice-id}/practice-manifest.json` | feeds `practices.yaml`, not a fact category | `observed` |
| Paths already claimed by a live practice | `practices.yaml` in this or a sibling project | feeds `path_collisions` in the cross-project `INDEX.yaml` | `observed` |

## Notes

- **`convention` facts are always pointers.** Never copy the repository's own conventions text into the profile — record that the statement exists and where. A second copy is the one nobody updates.
- **`capability` facts require a real `how`.** An `observed` label with no way to re-check it is an assertion wearing a stronger label than it earned. See [inventory-capabilities](../../inventory-capabilities/SKILL.md) for the full discipline — this checklist only tells you where to look, not how to verify a capability by violating it.
- **If nothing observable settles it, it becomes a human question** — and per this checklist, that should be rare: mostly `constraint`, risk tier, and the social half of `authority`.
