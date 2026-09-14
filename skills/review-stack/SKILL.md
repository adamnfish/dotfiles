---
name: review-stack
description: Commit working-tree changes and push them so the user can review the diff on GitHub, then later raise PRs from the reviewed branches. Handles a stack of dependent branches, with a diff link for each branch against its parent plus one for the whole change against the default branch. Use when the user asks to "commit this and push it so I can review the diff", asks for diff URLs, or asks to raise a PR or PRs from branches.
---

# Review stack

This workflow has two stages. Work out from the request which one the user wants:

1. **Push for review**: commit, push, and give diff links. Do not open PRs.
2. **Raise PRs**: open PRs for branches the user has already reviewed.

Both stages work on a *stack*: a chain of branches where each branch is based on the one below it and the bottom branch is based on the default branch. A single branch off the default branch is a stack of one.

## Find the repo and the stack

```bash
gh repo view --json nameWithOwner,defaultBranchRef -q '.nameWithOwner + " " + .defaultBranchRef.name'
git log --oneline --decorate --first-parent <default>..HEAD
```

The branch names in the `git log` output, read from bottom to top, are the stack in order. Each branch's parent is the branch below it, and the bottom branch's parent is the default branch. Checking which branches are ancestors of `HEAD` doesn't work, because old branches that were already merged match too.

If the log shows commits that no branch name points to, or a lower branch's PR was squash-merged (`gh pr list --head <branch> --state merged`), the stack is unclear. Ask the user before going on.

## Writing style

Commit messages and PR descriptions follow the user's writing style instructions. The dotfiles installer (adamnfish/dotfiles) puts them in `~/.claude/rules/writing-style.md` for Claude Code and `~/.copilot/instructions/writing-style.instructions.md` for GitHub Copilot CLI, and both tools load them automatically. If they are not already loaded, read whichever of those files exists before writing.

## Stage 1: push for review

1. Never push to the default branch. Changes always go on a feature branch based on the default branch, so that the diff shows only the change. If `HEAD` is on the default branch, create a new branch first, named after the change. When branching from the remote default branch, use `git switch -c <branch> --no-track origin/<default>`, because a branch that tracks `origin/<default>` would push to the default branch with a plain `git push`.
2. Read `git status` and `git diff`. Stage only the files that belong to this change, by name. If anything unrelated is in the working tree, leave it out and mention it.
3. Commit, following the writing style instructions. Write the message as a pyramid, with a sharp title, a short prose summary below it, and optionally a little more context. The message should explain the diff rather than repeat it. Also follow any attribution rules from the session or the repo.
4. Push the branch with `git push -u origin <branch>`. Push any lower branches in the stack that have unpushed commits too.
5. Give the diff links. Compare URLs have the form `https://github.com/<owner>/<repo>/compare/<base>...<head>`.
   - One link per branch, compared with its parent, from the bottom of the stack to the top.
   - If the stack has more than one branch, also give one link for the top branch compared with the default branch.

```
Diffs, each compared with its parent:
1. s3-sync: Add lig sync for backing up the cache to S3
   https://github.com/owner/repo/compare/main...s3-sync
2. season: Detect the cache's season and keep seasons apart
   https://github.com/owner/repo/compare/s3-sync...season

Whole change compared with main:
https://github.com/owner/repo/compare/main...season
```

## Stage 2: raise PRs

1. **Check the branches are ready.** If there are uncommitted changes, stop and ask. Make sure every branch in the stack is pushed and up to date with its remote (`git status -sb`).
2. **Check for existing PRs.** Run `gh pr list --head <branch> --state all --json number,url,state,baseRefName` for each branch. Update an existing open PR rather than opening a second one.
3. **Create the PRs** from the bottom of the stack up. Set each PR's base to its parent branch; the bottom PR's base is the default branch. Write each body to a temporary file and pass it with `--body-file`:
   ```bash
   gh pr create --base <parent> --head <branch> --title "<title>" --body-file <file>
   ```
   Use the commit title as the PR title unless the branch has several commits.
4. **Fill in the stack sections.** PR numbers are only known once every PR exists. When the stack has more than one PR, write the final bodies after creating them all, and apply each with `gh pr edit <number> --body-file <file>`.
5. **Report the PR URLs** in stack order.

### PR body

Follow the writing style instructions.

Every PR in a stack of more than one has two parts, separated by a divider:

1. A self-contained description of this PR: what it changes and why, readable without opening the other PRs. It may say which PR it builds on.
2. The stack list: every PR in the stack in order, each with its number and a one-line summary. Mark the current PR with "(you are here)".

The **first (bottom) PR** also starts with an introduction to the whole set of changes: the problem, what the stack as a whole achieves, and how the work is split across the PRs. A divider separates the introduction from the rest of the body.

A stack of one PR has only the description, with no divider and no stack list.

Put a blank line before and after each divider. A line of dashes straight after a line of text makes that text a heading in GitHub markdown.

Add any PR attribution lines required by the session or the user at the very end of the body.

Example body for the first PR in a stack of two:

```markdown
## Introduction

<What the whole set of changes is for, and how it is split across the PRs.>

-------

<Self-contained description of this PR.>

-------

1. #12 Add lig sync for backing up the cache to S3 (you are here)
2. #13 Detect the cache's season and keep seasons apart
```

Example body for the second PR:

```markdown
<Self-contained description of this PR. Builds on #12.>

-------

1. #12 Add lig sync for backing up the cache to S3
2. #13 Detect the cache's season and keep seasons apart (you are here)
```

If a PR is added to or removed from the stack later, update the stack list in every PR in the stack.
