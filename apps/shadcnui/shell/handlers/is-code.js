// omnishell/ui handler is-code (ir: decision-44): whether what has been typed
// is a complete code — `digits` characters, every one of them a digit.
//
// A guard is a module or nothing: the transition grammar has no comparison, no
// length and no character class, and a chart that could state them would be a
// chart with an expression language in it. So the predicate is a leaf and the
// number is its param, which is the same number the control's maxlength and
// the column's constraint are emitted from.
//
// state   unread: whether a code is complete is a fact about the code.
// event   the input that fired; `value` is the control's own.
// params  {digits} — how long a complete code is; and `value`, an exemplar
//         this arrow admits, which is the walk's and unread here.
(state, event, params) => {
  const v = String(event.value ?? "");
  return v.length === params.digits && v.split("").every((c) => c >= "0" && c <= "9");
};
