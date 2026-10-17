Write git commit messages in this style:

SUBJECT LINE
- Lead with the ticket in brackets: [AL-435], [PLAT-11609]. Omit it for
  chores/docs/tooling.
- Imperative, sentence case, 50–72 chars. Name the actual symbol you touched
  (isDefaultView, getTenantInfo, GetAdjustersList), not a generic verb.
- Keep it to one idea. If the change has two distinct halves, lead with the
  primary one and split the rest into body bullets. Don't append the PR number.

BODY — default to NONE. Add one only when the "why" isn't obvious from the subject.
- One lead sentence: what changed and why. Then, if truly needed, up to ~3 bullets.
- One line per bullet. State the mechanism, not a walkthrough. If a bullet wraps
  past one line, it's too detailed — cut it down.
- Don't restate the subject, don't narrate the diff, don't over-justify.
- Close with "Depends on …" only for a real cross-PR dependency.
