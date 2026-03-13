# CLAUDE.md

## Workflow

- After every `git push`, update the PR body (using `gh pr edit --body`) to reflect the current state of the PR overall, including all changes made so far.
- After updating the PR body, comment `@claude please review this PR` on the associated pull request using `gh pr comment`.
- After requesting the review, poll the PR review status (using `gh pr view` and `gh api` to check for new reviews/comments) until Claude finishes the review.
- Once the review is complete, address **all** review items — blockers, non-blockers, and suggestions — then commit and push the fixes.
- The push will naturally trigger another `@claude please review this PR` comment, repeating the cycle until the review passes clean.
- A "clean review" means the review has no blockers, no non-blockers, and no suggestions — only approval.
- After receiving a clean review, request one more review immediately (without pushing) to confirm. The goal is **2 consecutive clean reviews**.
- If the second review comes back clean, merge the PR using `gh pr merge --squash`.
- If the second review raises any items, address them all, commit, push, and restart the clean-review counter at 0.
