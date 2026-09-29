// omnishell/ui handler unless-typed (ir: decision-51): whether the freeform
// step's Next is blocked by the answer the KEYSTROKE just made.
//
// The row still holds the answer before this one, so a leaf reading it would
// block a step a reader has just answered and free one they have just emptied —
// always a keystroke behind. What the event carries is the value as it stands,
// which is the same leaf ./unless-answered.js has over the other source.
//
// state   unread: what was typed is a fact about the event.
// event   the input that fired; `value` is the control's own.
// params  none.
(state, event, params) => (String(event.value ?? "") === "" ? "disabled" : "");
