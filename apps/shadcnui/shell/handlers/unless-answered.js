// omnishell/ui handler unless-answered (ir: decision-51): whether a step's Next
// is blocked by the answer the ROW holds.
//
// A machine's assign holds a literal or a leaf, and "is there an answer" is
// neither: the chart is closed over the row and can read it, and has no
// expression to write with. So the arrow stays in the chart and the value comes
// from here.
//
// It reads the row and never the event, which is the pair's whole point. Every
// click carries a `value` — a button's own, which is the empty string — so a
// leaf that preferred the event would read every Back and every Next as an
// unanswered question and block a step the reader had already answered.
//
// state   {items: [row]} — the questionnaire's own row.
// event   the click; unread, deliberately.
// params  {col} — the column the destination's answer lives in.
(state, event, params) => (String(state.items[0][params.col] ?? "") === "" ? "disabled" : "");
