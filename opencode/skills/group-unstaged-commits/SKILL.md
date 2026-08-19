---
name: group-unstaged-commits
description: >-
  Group unstaged Git changes into related commits with short summaries and
  detailed descriptions. Use when asked to organize, split, or commit
  unstaged work.
---

# Group Unstaged Commits

Create small, reviewable commits from the current repository's unstaged
changes. A group represents one coherent behavior, feature, fix, refactor, or
documentation update, not merely a directory or file type.

## Safety Rules

- Work only with unstaged changes unless the user explicitly includes staged
  changes. Inspect `git diff --cached` but do not stage, unstage, amend, or
  commit its contents by default.
- Never discard, reset, checkout, stash, or otherwise overwrite changes.
- Never include untracked files without inspecting their complete contents.
- Do not mix unrelated changes into a commit. Leave unclear or unrelated files
  unstaged and state why.
- Do not commit secrets, credentials, generated local state, or ignored files.
- Do not use interactive Git commands. Stage selected files with `git add --`
  and selected hunks with a reviewed `git apply --cached` patch when necessary.
- Do not amend, force-push, or push unless the user explicitly requests it.

## Workflow

1. Inspect the repository state before making changes:

   ```sh
   # Separate unstaged, staged, and untracked work before grouping it.
   git status --short
   git diff --check
   git diff --cached --check
   git log --oneline -10
   ```

2. Review every unstaged modification and every untracked file. Use file
   content and the diff, not filenames alone, to identify related work.

3. Form the smallest sensible groups. Keep implementation and its necessary
   tests or documentation together. Split independent features, fixes,
   formatting-only changes, lockfile updates, and documentation-only changes
   into separate commits when they can stand alone.

4. If more than one reasonable grouping exists, a file contains changes for
   multiple groups, or the desired history is unclear, present the proposed
   groups and ask the user for confirmation before staging. Otherwise, proceed.

5. For each group, in dependency order:

   ```sh
   # Stage only the reviewed paths for this one coherent change.
   git add -- path/to/file-a path/to/file-b
   # Verify the index contains only this group before committing.
   git diff --cached --check
   git diff --cached
   # Use a concise subject and a substantive commit body.
   git commit -m "type: concise summary" \
     -m "Describe the behavior changed, implementation details, and verification."
   ```

6. After every commit, run `git status --short`. At the end, report each commit
   hash, its short summary, files included, verification performed, and any
   intentionally uncommitted changes.

## Commit Messages

Follow the repository's recent commit-message style. Use a short imperative
subject, preferably `type: summary` when that style is established. Keep the
subject to approximately 72 characters or fewer.

Every commit must include a detailed body. Write it from the actual diff and
include these facts in prose:

- What user-visible behavior or repository state changed.
- How the implementation achieves it, including important constraints.
- What validation was run, or why validation was not applicable.

Use a body that adds useful review context. Do not use placeholder text, repeat
the subject, or make claims that the reviewed diff cannot support.

## Verification

Run the narrowest relevant checks for each group before committing, then run
`git diff --check`. For configuration and documentation changes, run the
repository's available formatter, linter, or syntax check. If a check cannot
run, state the exact blocker in the commit body and final report.

When all commits are complete, verify the worktree and inspect the new history:

```sh
# Confirm the commits left no unexpected staged or unstaged changes.
git status --short
git log --oneline -10
```
