# Web UI conventions

Keep the page background white in light mode. Use `--surface`, `--ink`,
`--muted`, `--line`, `--green` and `--soft` for forms and dialogs; dark mode
inherits the same tokens. Decorative icons are SVG components, never emoji.

Use `Choice` from `src/ui.tsx` for checkbox options with a label, optional
helper text and optional icon. Native checkbox state and keyboard behavior
remain available. Selected choices have a green border and a subtle surface;
focus is visible around the control. Checkbox margins must not inherit the
spacing for text inputs.

Forms have a maximum width of 860px. Dialogs have a maximum width of 480px,
scroll within the viewport, and keep options compact. Topic choices collapse
from two columns to one on small screens. Empty topic selection means all
topics. Level selection keeps the existing multi-select behavior.

Current audit fixes: checkbox alignment, indistinguishable selected levels,
native multiple-select topic list, excessive quiz spacing, faint helper text,
and visible horizontal tab scrollbars. Verify new controls at mobile and
desktop widths and test saved selection and keyboard focus.

Navigation uses one browser history stack (`navigation.ts`) for native back
and forward gestures and in-app back controls. Lessons, matching and the quiz
picker each have an entry; lesson entries retain their current word index.
A direct link with no internal history uses the appropriate parent fallback.

In the web lesson UI, Easy means Known: save the known flag and mastered SRS
state in one batch. Automatic sessions, quiz/matching pools and browser
reminders exclude known words. The notification client sends a small
keepalive exclusion update immediately, then refreshes the full filters.
Old SRS entries above the initial ease 2.5 prove an earlier Easy rating and
are recovered as known when loaded. Ratings whose history is no longer
identifiable are not guessed.
