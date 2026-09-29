// omnishell/ui handler flip-of (ir: decision-47): the value a column takes
// next, which is the opposite of the one it holds — and for a select-all's
// three-valued column, APG's own cycle.
//
// A machine's assign holds a literal or a leaf, and "the opposite of what is
// there" is neither: the chart is closed over the row and can read it, but it
// has no expression to write. So the arrow stays in the chart and the value
// comes from here.
//
// One leaf serves the header and its items. An item is only ever true or
// false, so its third case never arises; the header can be mixed, and a
// partially checked select-all checks everything — which is the same sentence
// as "mixed is not false".
//
// state   {items: [row]} — the control's own row.
// event   the click; unread.
// params  {col} — the column to read.
(state, event, params) => (String(state.items[0][params.col]) === "true" ? "false" : "true");
