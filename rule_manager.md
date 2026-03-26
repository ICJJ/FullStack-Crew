---
agent: agent
---

# Rule Create — Copilot Rule Management

A specialized tool for creating, placing, and auditing VS Code Copilot instruction rules following best practices.

## Usage
```
/rule_create
/rule_create <rule description>
/rule_create help
/rule_create audit
/rule_create update
```

## Accepted Arguments
- **(no argument)** or **rule description** — Start the interactive rule creation workflow. If a description is provided, skip the "what rule?" question and proceed to classification.
- `help` — Display usage guide. Do NOT run any workflow.
- `audit` — Scan all instruction files, report rule count, distribution, and duplicates.
- `update` — Submit a prompt update/feedback request via `/feedback`. Do NOT run any workflow.

### When `$PROMPT_ARGS` is `help`
Print the following help message and stop:

```
Usage: /rule_create [description | help | audit | update]

Arguments:
  (no argument)     Interactive rule creation — asks what rule, classifies layer, drafts, places
  <description>     Create a rule from the given description (skips the "what rule?" question)
  help              Show this help message
  audit             Scan all rule files, report counts/distribution/duplicates
  update            Submit feedback for this prompt

Rule Injection Layers:
  L1  .github/copilot-instructions.md           Global, auto-injected to ALL agents
  L2  .github/instructions/*.instructions.md    Conditional, auto-injected when matching files are active
  L3  .github/agents/<name>.agent.md             Agent-specific, only when that agent is active
  L4  ~/.github/copilot-instructions.md          User-level, all projects

Writing Principles:
  1. Most important rules go first (top 10 lines = "golden zone")
  2. Use strong words: NEVER, MUST, FORBIDDEN, ALWAYS
  3. One rule per line, specific and actionable
  4. Give positive AND negative examples
  5. Don't duplicate across layers
  6. Group by topic with ### headers

Examples:
  /rule_create
  /rule_create "Always use python3.12 instead of python3"
  /rule_create audit
```

### When `$PROMPT_ARGS` is `update`
Delegate to `/feedback` skill:
1. Read `.github/prompts/feedback.prompt.md`
2. Auto-generate fields from this prompt
3. Generate guidance file → `/proj/cip_mi400_oxrp/jianjuncheng/dev/mini_tools/.github/prompts/rule_create/update/`
4. Follow remaining phases in `feedback.prompt.md`, then stop.

## Task Description
Create and manage VS Code Copilot instruction rules with best-practice guidance. Handle rule placement across the 4-tier injection hierarchy, enforce writing principles, detect duplicates, and prevent rule dilution.

## Input
- `$PROMPT_ARGS` — Empty, a rule description string, `help`, `audit`, or `update`

## Rule Injection Layers — Reference

Understanding the 4 layers is critical. Rules are injected into the agent's context in this order:

| Layer | File Path | Injection | Scope |
|-------|-----------|-----------|-------|
| **L1** | `.github/copilot-instructions.md` | Auto, always | Global — ALL agents, ALL conversations in this project |
| **L2** | `.github/instructions/<name>.instructions.md` | Auto, conditional | Only when files matching `applyTo` glob are active |
| **L3** | `.github/agents/<name>.agent.md` | Manual | Only when the user invokes that specific agent |
| **L4** | `~/.github/copilot-instructions.md` | Auto, always | User-level — ALL projects, ALL agents |

### Layer Selection Decision Tree

```
Is this rule specific to ONE agent's behavior?
  → YES → L3 (agent file)
Is this rule only relevant when editing certain file types?
  → YES → L2 (conditional with applyTo glob)
Is this rule specific to THIS project but applies to all agents?
  → YES → L1 (global project rules)
Is this rule a personal preference across ALL projects?
  → YES → L4 (user-level)
```

## 6 Writing Principles

Every rule created by this skill MUST follow these principles:

### Principle 1: Golden Zone — Most Important First
The top 10 lines of any instruction file are the "golden zone." Agents pay the most attention to rules that appear first. Place the most critical rules at the top.

### Principle 2: Strong Language
Use imperative, unambiguous words. The agent respects strong directives.

**GOOD:**
```
- NEVER use `grep` after a pipe (`|`).
- MUST use `python3.12` — FORBIDDEN to use `python3` or `python`.
- ALWAYS use absolute paths for file references.
```

**BAD:**
```
- You should try to use python3.12 when possible.
- It is generally preferred to avoid grep in pipelines.
- Consider using absolute paths.
```

### Principle 3: One Rule Per Line, Specific & Actionable
Each rule is a single line with a clear verb and concrete instruction. No paragraphs.

**GOOD:**
```
- NEVER modify files under `pkg_out/` — fix the upstream `.rbx` source instead.
- After every code change, run syntax check: `python3.12 -c "import ast; ast.parse(open('<file>').read())"`.
```

**BAD:**
```
- When working with package output files, you should be careful about modifying them directly
  because they are generated files. Instead, you should find the source file and make changes there.
  The package output directory is usually called pkg_out and contains various generated artifacts.
```

### Principle 4: Positive AND Negative Examples
Rules with examples are 10x more effective than abstract statements. Show both what TO do and what NOT to do.

**GOOD:**
```
- Use `awk` or `sed` for filtering — NEVER pipe into `grep`.
  - YES: `ls | awk '/pattern/'`
  - NO:  `ls | grep pattern`
```

**BAD:**
```
- Don't use grep incorrectly.
```

### Principle 5: No Duplication Across Layers
The same rule MUST appear in exactly ONE layer. Duplication wastes context window and can cause conflicts if one copy is updated but not the other.

Before adding a rule, check all existing layers for duplicates:
- `.github/copilot-instructions.md` (L1)
- `.github/instructions/*.instructions.md` (L2)
- `.github/agents/*.agent.md` (L3)
- `~/.github/copilot-instructions.md` (L4)

### Principle 6: Group by Topic
Use `###` headers to organize rules into logical groups. This improves readability and helps agents find relevant rules.

**GOOD:**
```markdown
### Terminal Commands
- NEVER use `grep` after a pipe.
- Use `python3.12` — never `python3` or `python`.

### Code Quality
- All `.py` files must pass Pylance strict type checking.
```

## L2 File Template

When creating a new L2 `.instructions.md` file, use this template:

```markdown
---
applyTo: "<glob_pattern>"
---

# <Topic> Rules

These rules apply to ALL agents when working with <scope description> files.

## <Category 1>
- **RULE** — explanation.
  - YES: `<positive example>`
  - NO: `<negative example>`

## <Category 2>
- **RULE** — explanation.
```

### Common `applyTo` Patterns

| Pattern | Matches |
|---------|---------|
| `**/*.py` | All Python files |
| `**/*.{js,ts,tsx}` | All JavaScript/TypeScript files |
| `**/ip_packager/**` | Everything under ip_packager/ |
| `**/*.{yml,yaml}` | All YAML files |
| `**/test/**` | All test directories |
| `**/*.md` | All Markdown files |
| `**/Makefile,**/*.mk` | All Makefiles |

## Workflow

### Phase 1: Gather

1. **If** `$PROMPT_ARGS` is empty, ask the user:
   > What rule do you want to add? Describe it in plain language.

   **If** `$PROMPT_ARGS` is a description string, use it directly — skip the question.

2. **Classify the layer** using the decision tree above. Present your classification to the user:
   > Based on your rule, I recommend placing it in **L<N>** (`<file path>`).
   > Reason: <why this layer fits>

3. **If L2**, determine the `applyTo` glob pattern. Ask the user if needed:
   > What file types or paths should this rule apply to? (e.g., `**/*.py`, `**/DSM/**`)

4. **Confirm** the target layer and file with the user before proceeding.

### Phase 2: Draft

1. **Draft the rule text** following all 6 writing principles:
   - Use strong language (NEVER, MUST, ALWAYS, FORBIDDEN)
   - One line, specific, actionable
   - Include positive and negative examples if the rule involves a do/don't choice
   - Start with a clear verb

2. **Show the draft** to the user in a preview block:
   ```
   ### Proposed Rule
   Layer: L<N>
   File: <target file path>
   Position: <top / under ### <header> / new section>

   Rule text:
   - <drafted rule>
     - YES: <positive example>  (if applicable)
     - NO:  <negative example>  (if applicable)
   ```

3. **Wait for user confirmation** or revision requests. Iterate until approved.

### Phase 3: Place

1. **Read the target file** (if it exists) to understand current structure.

2. **Determine exact position:**
   - **L1 (existing file):** Find the matching `###` topic group. If no matching group exists, create one. If the rule is critical, consider placing it in the golden zone (top 10 lines).
   - **L2 (new file):** Create the file using the L2 template above.
   - **L2 (existing file):** Append under the matching `##` category section.
   - **L3:** Append to the agent's instruction section.
   - **L4:** Append under the matching topic group or create one.

3. **Write the rule** to the target file.

4. **Run syntax validation** on the target file:
   - For `.md` files: ensure valid Markdown structure
   - For L2 files: ensure YAML frontmatter has valid `applyTo` pattern
   - Ensure no broken formatting (unclosed code blocks, mismatched headers)

### Phase 4: Validate

1. **Re-read the target file** to confirm the rule was written correctly.

2. **Duplicate check** — Read ALL instruction files across all layers and search for semantically similar rules:
   - `.github/copilot-instructions.md`
   - `.github/instructions/*.instructions.md`
   - `.github/agents/*.agent.md`
   - `~/.github/copilot-instructions.md` (if accessible)

   If duplicates found, warn the user:
   > ⚠ Duplicate detected: "<rule>" also appears in `<file>` (L<N>). Consider removing one copy.

3. **L1 rule count check** — Count total rules in `.github/copilot-instructions.md`. If count exceeds 40:
   > ⚠ L1 has <N> rules (recommended max: 40). Consider moving less critical rules to L2 or L3 to avoid dilution.

4. **Report success:**
   > ✅ Rule added to `<file>` (L<N>).
   > Total rules in this file: <N>

## Audit Workflow

When `$PROMPT_ARGS` is `audit`:

1. **Scan all instruction files:**
   - `.github/copilot-instructions.md` (L1)
   - `.github/instructions/*.instructions.md` (L2)
   - `.github/agents/*.agent.md` (L3)
   - `~/.github/copilot-instructions.md` (L4, if accessible)

2. **For each file, collect:**
   - File path
   - Layer (L1/L2/L3/L4)
   - Rule count (lines starting with `- ` under a `#` header, excluding template/example lines)
   - `applyTo` patterns (L2 only)

3. **Generate the audit report:**

   ```
   ## Rule Audit Report

   ### Summary
   | Layer | Files | Total Rules |
   |-------|-------|-------------|
   | L1    | 1     | <N>         |
   | L2    | <N>   | <N>         |
   | L3    | <N>   | <N>         |
   | L4    | <N>   | <N>         |
   | **Total** | **<N>** | **<N>** |

   ### File Details
   | File | Layer | Rules | Status |
   |------|-------|-------|--------|
   | .github/copilot-instructions.md | L1 | <N> | ✅ / ⚠ >40 |
   | ... | ... | ... | ... |

   ### Duplicate Analysis
   - <duplicate 1> (found in L1 and L2: <file>)
   - <duplicate 2> ...
   - (none found) ✅

   ### Recommendations
   - <actionable suggestion, if any>
   ```

4. **Stop** after printing the report. Do not modify any files.

## Key Principles

- **NEVER duplicate rules across layers** — each rule lives in exactly one place
- **L1 MUST stay under 40 rules** — exceeding this dilutes agent attention
- **Every rule MUST have a clear verb** — use NEVER, MUST, ALWAYS, FORBIDDEN, not "should" or "prefer"
- **`applyTo` patterns MUST use valid glob syntax** — test with examples before committing
- **Rules MUST be testable/observable** — "write good code" is vague; "all `.py` files must pass Pylance strict" is testable
- **NEVER write paragraph rules** — one line per rule, use sub-items only for examples
- **Always confirm with the user** before writing to any file
- **Always read the target file** before writing to it

## Error Handling

| Situation | Action |
|-----------|--------|
| Target file does not exist (L1/L4) | Create it with a minimal header structure |
| Target file does not exist (L2) | Create using L2 template with user-specified `applyTo` |
| L1 rule count > 40 after adding | Warn user, suggest moving rules to L2/L3 |
| Duplicate found across layers | Warn user, suggest which copy to remove |
| Invalid `applyTo` glob | Show common patterns, ask user to correct |
| User describes a vague rule | Ask clarifying questions until the rule is specific and testable |

## Terminal Command Rules
- NEVER use `grep` after a pipe (`|`). Use `awk`, `sed`, or variable checks instead.

## Update Prompt
- This prompt is maintained by the CIP_SS_Infra team. Source file:
  `/proj/cip_mi400_oxrp/jianjuncheng/dev/mini_tools/.github/prompts/rule_create.prompt.md`
- To request changes, run `/rule_create update`
