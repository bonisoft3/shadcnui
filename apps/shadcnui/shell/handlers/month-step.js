// omnishell/ui handler month-step (ir: decision-38): the calendar's month
// arithmetic, and the only Jessie in this app. A chart's assign holds a
// literal or a leaf, and a month away from a month is neither — so the arrow
// stays in the chart and the number it writes comes from here.
//
// state   {items: [row]} — the calendar row alone. The compartment endows
//         nothing, so there is no clock in scope and no second row to read.
// event   the click that fired; unread.
// params  {by, min, max, emit} — the step, the ends of the seeded window, and
//         which of the stepped month's three columns this assign wants.
// result  "month" the key YYYY-MM, "label" its name and year, "cell" the same
//         grid position in the stepped month.
//
// Clamping to [min, max] happens here because the window is the seed's extent
// and an end that names itself is what the projection's next/prev already
// answer at the ends of a list. The chart carries the two ends as literals
// rather than the five months as states.
const NAMES = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

// Months since year 0, so a step is an addition and a comparison.
const ordinal = (key) => Number(key.slice(0, 4)) * 12 + Number(key.slice(5, 7)) - 1;
const monthKey = (n) => {
  const m = n % 12;
  return String((n - m) / 12) + "-" + String(m + 1).padStart(2, "0");
};

(state, event, params) => {
  const row = state.items[0];
  const n = ordinal(row.month) + params.by;
  const at = Math.min(Math.max(n, ordinal(params.min)), ordinal(params.max));
  if (params.emit === "month") return monthKey(at);
  if (params.emit === "label") return NAMES[at % 12] + " " + String((at - at % 12) / 12);
  // The cell key is the grid and the position in it: the reader keeps the
  // square they were on, which is the only square the new grid is sure to have.
  return monthKey(at) + row.value.slice(7);
};
