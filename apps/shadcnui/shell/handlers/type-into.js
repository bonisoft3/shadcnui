// omnishell/ui handler type-into (ir: decision-29): the typeahead buffer with
// this keystroke on the end.
//
// An assign holds a literal or a leaf, and buffer + key is neither a literal
// nor anything the chart can spell — so the arrow stays in the chart and the
// string it writes comes from here. It is the fold seat's shape in one line:
// the previous value and the event, and nothing else in scope.
//
// state   {items: [row]} — the surface's row, for the buffer standing before
//         this keystroke.
// event   the keydown that fired.
// params  none.
(state, event, params) => String(state.items[0].prefix ?? "") + event.key;
