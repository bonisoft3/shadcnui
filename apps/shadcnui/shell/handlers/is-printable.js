// omnishell/ui handler is-printable (ir: decision-29): whether a keydown is a
// reader typing rather than reaching for a key the chart already answers.
//
// A single character is typing; Tab, Escape, Enter, Home, End and the arrows
// are all longer, and every one of them is somewhere else's arrow. It guards
// the arrow that extends the buffer without moving the caret — a reader
// mid-word whose letters name nothing yet.
//
// state   unread: what makes a key typing is the key.
// event   the keydown.
// params  none.
(state, event, params) => typeof event.key === "string" && event.key.length === 1;
