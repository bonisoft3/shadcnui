// omnishell/ui handler is-digits (ir: decision-44): whether what has been
// typed could still become a code.
//
// The arrow it guards is the one a reader is on for five of six keystrokes,
// and the arrow BELOW it is the one that says so out loud: a code half typed
// is not invalid, and only a character that can never be part of one is.
//
// state   unread.
// event   the input that fired; `value` is the control's own.
// params  {value} — an exemplar this arrow admits, for the walk; unread here.
(state, event, params) => String(event.value ?? "").split("").every((c) => c >= "0" && c <= "9");
