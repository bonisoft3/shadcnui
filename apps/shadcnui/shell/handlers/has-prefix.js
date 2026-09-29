// omnishell/ui handler has-prefix (ir: decision-29): whether the typeahead
// buffer holds anything.
//
// The timer that clears it arms on every state entry, so without this it would
// write an empty buffer over an empty buffer once a second per move — a write
// that changes nothing still wakes the store and re-renders everything reading
// the row.
//
// state   {items: [row]} — the surface's row.
// event   the timer's own; unread.
// params  none.
(state, event, params) => String(state.items[0].prefix ?? "") !== "";
