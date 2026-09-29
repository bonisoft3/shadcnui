// omnishell/ui handler roll-up (ir: decision-47): what a select-all's items
// add up to, once the one being clicked has flipped.
//
// This is the value no FIELD can hold. A machine's field is what the machine
// decides, and this follows from the row instead — so it is a column, and the
// arrow that flips an item assigns the header in the same write, which is what
// keeps the two from disagreeing for a beat.
//
// The items are found by their shared prefix rather than listed: the component
// owns both the prefix and the columns, so a list here would be the same set
// written twice.
//
// state   {items: [row]} — the control's own row, as it stands BEFORE the
//         flip, which is why the flip is applied here.
// event   the click; unread.
// params  {prefix, col} — where the items live, and which one is flipping.
(state, event, params) => {
  const row = state.items[0];
  const values = Object.keys(row)
    .filter((k) => k.slice(0, params.prefix.length) === params.prefix)
    .map((k) => (k === params.col ? (row[k] === "true" ? "false" : "true") : String(row[k])));
  const on = values.filter((v) => v === "true").length;
  return on === values.length ? "true" : on === 0 ? "false" : "mixed";
};
