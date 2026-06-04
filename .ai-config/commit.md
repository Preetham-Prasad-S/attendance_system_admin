// Commit Message Guidelines

# Structure
- **Header (≤72 chars)**: `<type>(<scope>): <short summary>`
  - `type`: feat, fix, refactor, chore, docs, style, test, ci, perf, build, etc.
  - `scope` (optional): area of code affected, e.g., `auth`, `ui`.
  - `summary`: imperative present‑tense description.
- **Blank line**
- **Body (optional, wrap at 72 chars)**: Explain *what* and *why* the change was made. Include relevant context, design decisions, or references to issues.
- **Footer (optional)**:
  - `BREAKING CHANGE: <description>` for breaking changes.
  - `Closes #<issue-id>` to auto‑close issues.

# Tips
- Keep the header concise but descriptive.
- Use the imperative mood (e.g., "Add login flow").
- Limit the header to 50‑72 characters.
- Separate multiple logical changes into separate commits.
- Reference tickets/bugs when applicable.
- Avoid unnecessary metadata; let the header convey the main intent.
