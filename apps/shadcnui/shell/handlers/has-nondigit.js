// omnishell/ui handler has-nondigit (ir: decision-44): whether what has been
// typed holds a character no code can hold.
//
// The exact negation of is-digits, and that is the point of having both: the
// two partition every string between them, so the three arrows on this event
// are exhaustive without a guardless one — and a guardless arrow is the one
// nothing could drive, since an event with no value stated is the control
// holding whatever it last held.
//
// state   unread.
// event   the input that fired; `value` is the control's own.
// params  {value} — an exemplar this arrow admits, for the walk; unread here.
(state, event, params) => String(event.value ?? "").split("").some((c) => c < "0" || c > "9");
