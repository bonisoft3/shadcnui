// omnishell/ui handler starts-with (ir: decision-29): whether the letters a
// reader has typed name this item.
//
// Typeahead's whole decision, as one boolean per item: the chart draws an arrow
// to every item and asks each in turn, so the item that answers is the one the
// prefix reaches. That keeps the inventory in the chart — an arrow per
// destination — rather than in a module that would pick one.
//
// state   {items: [row]} — the surface's row, for the buffer standing before
//         this keystroke.
// event   the keydown; `key` is the letter just typed.
// params  {label} — this item's visible label.
// result  whether buffer + key is a prefix of the label.
//
// A key that is not a single character is not typing — Tab, Escape, Enter and
// the arrows are all longer — so it never extends the buffer and never matches.
(state, event, params) => {
  if (typeof event.key !== "string" || event.key.length !== 1) return false;
  const typed = String(state.items[0].prefix ?? "") + event.key;
  return params.label.toLowerCase().startsWith(typed.toLowerCase());
};
