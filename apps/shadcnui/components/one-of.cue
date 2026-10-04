// The single-select machine every N-trigger component in this gallery runs:
// one state per option, one derived ARIA column per option, and one arrow per
// (state, other option) pair whose literal assigns write the whole derived set
// as one row. Tabs, the segmented control and the radio group differ in the
// ARIA contract and the markup wrapped around this chart, never in the chart.
//
// The field holds exactly one state name, so the choice is single-valued by
// construction, and because the derived columns move together in one stated
// row no arrow can leave two options chosen, or none. No arrow leaves a state
// for itself: a click on the chosen option finds no candidate and writes
// nothing, which is what a radiogroup promises and a bag of toggles does not.
//
// `prefix` names the attribute the derived columns bind — chk_ for
// aria-checked, sel_ for aria-selected — because where N triggers share one
// field, the field cannot itself be the ARIA value. `col` is that spelling,
// exported so the markup binds the column this chart writes rather than
// rebuilding the name beside it.
package components

import (
	"list"
	"strings"

	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#OneOf: O={
	field:  string
	prefix: string
	// Option names in document order; the first is the machine's initial state.
	names: [...string] & [_, _, ...]
	// Option name → the id of the button that chooses it. Every arrow is
	// narrowed to one of these: `from` resolves to the nearest ancestor
	// carrying an id, so an unnarrowed click would fire from whatever content
	// a reader pressed inside the group.
	id: [string]: string

	col: {for n in O.names {(n): "\(O.prefix)\(n)"}}
	tab: {for n in O.names {(n): "tab_\(n)"}}

	// The whole derived set as it stands with `n` chosen.
	_cols: {for n in O.names {(n): {
		for u in O.names {
			(O.col[u]): [if u == n {"true"}, "false"][0]
			if O.roving {
				(O.tab[u]): [if u == n {"0"}, "-1"][0]
			}
		}
	}}}

	// Whether this chart moves a caret: the arrows that walk the options, and
	// the focusin that records where a reader put themselves. Off by default,
	// because the arrows and the caret are one contract — arrows that changed
	// the choice while focus stood still would be a group whose reader is told
	// nothing.
	walk: *false | bool
	// Whether the tabstop moves with the choice (roving tabstop, APG pattern
	// with one tab stop across the group).
	roving: *false | bool
	// Whether the letters a reader types also walk it. The buffer they land in
	// is this chart's column and the arrows they draw are this chart's arrows,
	// because what typeahead does is MOVE THE CARET — a chart of its own would
	// write another's columns, which is the one thing parallel charts may not
	// do. `label` is what the letters are matched against.
	typeahead: *false | bool
	label: [string]: string
	// Whether a click chooses. A single-select control's does — that is the
	// whole gesture — but a caret's does not: the pointer already moves focus,
	// and `focusin` is what records where it went. A click arrow beside it would
	// write the same column twice for one gesture.
	clicks: *true | bool

	// Which arrows walk it. A vertical pattern emitting Left and Right answers
	// keys its reader has no reason to press; APG names the axis per pattern.
	axis: *"both" | "vertical" | "horizontal"

	_vertical: [{key: "ArrowDown", to: 1}, {key: "ArrowUp", to: -1}]
	_horizontal: [{key: "ArrowRight", to: 1}, {key: "ArrowLeft", to: -1}]
	_axis: [
		if O.axis == "vertical" {O._vertical},
		if O.axis == "horizontal" {O._horizontal},
		list.Concat([O._horizontal, O._vertical]),
	][0]

	_len: len(O.names)

	// Where each key goes from the option at `i`. The tabstop sits on the
	// chosen option, so a keydown fires from its id and the arrow leaving it is
	// the one this state draws. Next and previous WRAP, which APG's radio group
	// asks for and the read tier declines to decide — a compile-time chart can
	// state it, where a projection's lane clause answers over rows it cannot
	// know the pattern of.
	_moves: {for i, s in O.names {
		(s): list.Concat([
			[for m in O._axis {
				{key: m.key, to: O.names[(i+m.to+O._len) mod O._len]}
			}],
			[
				{key: "Home", to: O.names[0]},
				{key: "End", to: O.names[O._len-1]},
			],
		])
	}}

	// The buffer is a column like any other, and empty is where it rests.
	_context: [
		if O.typeahead {{for k, v in O._cols[O.names[0]] {(k): v}, prefix: ""}},
		O._cols[O.names[0]],
	][0]

	// The keystrokes that reach each item, computed where the labels and their
	// order both are. An item is reached by the shortest prefix of its label
	// that no EARLIER item's label carries — earlier being the order the
	// candidates are asked in, since the first guard to pass wins.
	_lower: {for n in O.names {(n): strings.ToLower(O.label[n])}}
	_reachedBy: {for i, n in O.names {
		(n): [for k in list.Range(1, len(_lower[n])+1, 1)
			if !list.Contains([for j, m in O.names if j < i {
				strings.HasPrefix(_lower[m], strings.SliceRunes(_lower[n], 0, k))
			}], true) {strings.SliceRunes(_lower[n], 0, k)}]
	}}
	// A label wholly carried by an earlier one is an item no typing can reach,
	// and there is no prefix to state for it. Refused here rather than emitted
	// as an arrow the walk would report dead every run.
	_reachable: {for n in O.names {(n): true & (len(O._reachedBy[n]) > 0)}}
	_reach: {for n in O.names {(n): O._reachedBy[n][0]}}

	// WHERE that arrow can be drawn, which a multi-character reach decides. Each
	// keystroke before the last one moves the caret — it is answered by the
	// first item its own prefix matches — so an arrow reached by "to" can only
	// be selected in the state typing "t" already landed in, and the same arrow
	// drawn anywhere else is one no reader can ever select. A single keystroke
	// needs an empty buffer, which every state can have, so those are drawn
	// throughout; "" is this map's spelling for that.
	//
	// The reader loses nothing: from any state, "t" then "o" walks the Tabs
	// arrow and then the Toast one, which is two arrows the chart does draw.
	_stem: {for n in O.names {(n): strings.SliceRunes(O._reach[n], 0, len(O._reach[n])-1)}}
	_livesIn: {for n in O.names {
		(n): [
			if len(O._stem[n]) == 0 {""},
			[for m in O.names if strings.HasPrefix(O._lower[m], O._stem[n]) {m}][0],
		][0]
	}}

	// One candidate per destination it can be selected from, asked in turn: the
	// item the prefix reaches is the one that answers, and every arrow drawn is
	// one some keystroke selects. The last is the reader mid-word whose letters name nothing yet — it
	// extends the buffer and stays put, and staying put by targeting its own
	// state is what re-arms the timer below on every keystroke rather than only
	// the first.
	_typed: {for s in O.names {
		(s): list.Concat([
			[for m in O.names if O._livesIn[m] == "" || O._livesIn[m] == s {
				{
					// `label` is what the module matches; `keys` is the
					// keystrokes that REACH this arrow — the shortest prefix of
					// its own label that no earlier item's label shares, since
					// first-guard-wins gives a shared one to the earlier arrow.
					// One character for most, two where two labels start alike,
					// and a walk cannot guess either: an event satisfying a
					// guard over accumulated text is not derivable from the
					// module's name, and the letter that disambiguates belongs
					// to no arrow of its own.
					guard: {type: "starts-with", params: {
						label: O.label[m]
						keys:  O._reach[m]
					}}
					target: m
					assign: {for k, v in O._cols[m] {(k): v}, prefix: {type: "type-into", params: {}}}
				}
			}],
			[{
				// The reader mid-word whose letters name nothing yet. A digit
				// reaches it because every label here starts with a letter, so
				// it is the keystroke that is typing and matches no item.
				guard: {type: "is-printable", params: {key: "0"}}
				target: s
				assign: prefix: {type: "type-into", params: {}}
			}],
		])
	}}

	machine: terminal.#Machine & {
		field:   O.field
		initial: O.names[0]
		context: O._context
		states: {for i, s in O.names {
			(s): {
				if O.typeahead {
					// A second after the LAST keystroke, not the first — and
					// TARGETLESS, because a timer whose transition re-enters the
					// state it fired in re-arms itself and the screen never
					// settles. What re-arms it is a keystroke: an arrow that
					// moves enters its destination, and the one that does not
					// move targets its own state and re-enters.
					after: "1000": {guard: {type: "has-prefix", params: {}}, assign: prefix: ""}
				}
				on: {
					if O.clicks {
						for n in O.names if n != s {
							("click@\(O.id[n])"): {
								target: n
								assign: O._cols[n]
							}
						}
					}

					// One ordered candidate list per state, first guard to pass
					// winning: the arrows differ only in the key that selects them,
					// so one leaf carries the key as data. An end that names its
					// own state draws no arrow, which is the same rule the clicks
					// keep.
					if O.walk {
						// The reader's own move, reported back as a cause. Focus is
						// the DOM's to give as well as the terminal's, so a Tab into
						// the group would otherwise leave the column naming an option
						// the reader is not on, and the next arrow would leave from
						// there. Hearing focusin makes that disagreement
						// unrepresentable rather than something to reconcile: the
						// column is whatever the reader is standing on. The terminal's
						// own focus lands on the member already named, so the arrow it
						// fires writes what is already written and the loop closes.
						for n in O.names if n != s {
							("focusin@\(O.id[n])"): {
								target: n
								assign: O._cols[n]
							}
						}
						("keydown@\(O.id[s])"): list.Concat([
							[for m in O._moves[s] if m.to != s {
								{
									guard: {type: "is-key", params: {key: m.key}}
									target: m.to
									assign: O._cols[m.to]
								}
							}],
							[if O.typeahead for c in O._typed[s] {c}],
						])
					}
				}
			}
		}}
	}
}
