// omnishell/ui handler is-key (ir: decision-11): which key a keydown carried,
// as a boolean a guard can read. A #Machine's guard is a module or nothing —
// there is no literal comparison in the transition grammar — and every arrow
// that moves a roving tabstop differs from its siblings only in the key that
// selects it, so one module with the key as a param serves every arrow of
// every group on the page.
//
// state   {items: [row]} — the group's own row; unread, because which key was
//         pressed is a fact about the event alone.
// event   the keydown that fired; `key` is the DOM's own name for it.
// params  {key} — the name this arrow answers to.
// result  whether this arrow is the one.
(state, event, params) => event.key === params.key;
