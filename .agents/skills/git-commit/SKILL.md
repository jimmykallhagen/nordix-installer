---
name: git-commit
description: Skill to prepare a git commit, generate concise commit messages, and update README.md with a progress notice.
---
# What to do

1. **Prepare git push**
   - Read the diff from the last pull (use `git diff HEAD@{1}..HEAD` or similar).
2. **Generate 4 commit message suggestions**
   - Analyze the diff and output four short but good commit comments, each on a separate line.
3. **Create a README update notice**
   - Use the template `templates/readme_update_template.md` to fill in placeholders.
   - Insert the notice under the section `## Latest update`.
   - Send the notice to the user; allow up to two notices per section.

# Template for README notice (file: `templates/readme_update_template.md`)
{{content}}