---
name: commit
description: Create atomic Git commits using tagged commit messages
  and AI co-author attribution.
disable-model-invocation: true
argument-hint: "[scope or instructions]"
---

# Commit

Create atomic commits on the current branch.

## Inspect

Read applicable repository instructions and recent commit history.

Inspect staged, unstaged, and untracked changes. Use the
current conversation to understand their intent.

Account for every change: include it in a proposed commit
or explicitly exclude it.

Preserve unrelated work and existing staging decisions.
Ask when ownership or intent is ambiguous.

## Plan

Group changes into atomic commits.

An atomic commit represents one coherent purpose and
leaves the repository in a consistent state. Keep related
implementation, tests, and documentation together.

Prefer meaningful commit boundaries over arbitrary
file-based separation.

## Commit messages

Use the following commit message convention:

    <tag>: [<component>] <description>

Supported tags:

- `new`: New functionality or significant additions.
- `chg`: Improvements, refactoring, documentation,
  dependency updates, and maintenance.
- `fix`: Bug fixes, regressions, and security fixes.

Use a concise component name that reflects the affected
area of the repository.

Write subjects in the imperative mood. Prefer subjects
under 72 characters and omit trailing punctuation.

Add a body when the motivation, architectural decisions,
breaking changes, or trade-offs are not evident from
the subject.

Examples:

    new: [editor] add OSV record support
    chg: [api] simplify repository interface
    fix: [auth] prevent session reuse after logout
    chg: [docs] improve deployment instructions
    chg: [deps] update frontend dependencies
    chg: [tests] expand validation coverage

## Attribution

Include the following Git trailer in every commit
containing Claude-assisted implementation changes:

    Co-authored-by: Claude <noreply@anthropic.com>

Separate trailers from the subject or body with a blank line.

Preserve existing attribution and repository-specific
disclosure requirements.

If the changes are exclusively human-authored, ask
before adding AI co-author attribution.

Example complete commit message:

    fix: [editor] preserve state after validation failure

    Retain the current record when validation fails to
    prevent users from losing unsaved changes.

    Co-authored-by: Claude <noreply@anthropic.com>

## Verify

Use existing repository checks and verification evidence.
Run relevant checks that have not already been performed
against the current changes.

Check for accidentally included secrets, temporary files,
and unrelated changes.

Report failures and unverified changes. Obtain explicit
approval before committing changes with failed checks.

## Approve

Present the proposed commits using this format:

### Commit <number>

**Message:** <complete commit message including trailers>

**Scope:** <included changes>

**Intent:** <why these changes belong together>

### Verification

<checks performed and their results>

### Excluded

<changes intentionally left uncommitted>

Wait for explicit approval before modifying the Git index.

## Commit

For each approved commit:

1. Confirm the working tree has not changed unexpectedly.
2. Stage only its intended changes.
3. Inspect the staged diff and run `git diff --cached --check`.
4. Confirm the staged diff matches the approved scope.
5. Commit using the approved message and trailers.
6. Verify the resulting commit, including its trailers.

Respect Git hooks, signing configuration, and identity.

Stop on unexpected changes, signing failures, or hook
failures. Never bypass these mechanisms.

Create local commits only. Preserve existing history and
all excluded working-tree changes.

## Report

Report commit hashes, messages, verification results,
and remaining uncommitted changes.

## Instructions

$ARGUMENTS
