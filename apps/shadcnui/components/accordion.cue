// omnishell--accordion: shadcn's Accordion at both of its arities, from one
// definition. A machine binds exactly one row, so `single` is ONE region over
// ONE row whose states are the item names plus a closed `none`, and
// `multiple` is one region and one machine PER ITEM — N siblings on one
// collection, each pinning its own id. Nothing in the vocabulary changed
// between them: the arity lives in the entity's shape and in how many regions
// the expansion writes, never in #Machine.
//
// Every arrow is narrowed to its trigger, including the multiple arm's, whose
// region holds exactly one button. `from` is the nearest ancestor carrying an
// id and the bare event type is the fallback key, so an unnarrowed `click`
// would fire from the panel a reader is clicking inside and collapse it. A
// bare `click` is safe only where the region IS the affordance.
//
// The tab order stays the document's, which is APG's own contract here: every
// header is in the Tab sequence and the arrows are an addition, so the caret is
// data-focus and never data-rove — a tabstop would take two of three headers
// out of a sequence the standard puts them in.
//
// The caret is its own chart beside the expansion's, over disjoint columns of
// one row. It has to be: both narrow their arrows to the same headers, and
// which header is open and which one the reader stands on are two facts one
// field cannot hold without becoming their product.
//
// Ctrl+PageUp/PageDown stay absent: the walk's key set is APG's own for moving
// through a list, and a chord is not in it.
package components

import (
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#Accordion: A={
	collection: string
	field:      *"open" | string
	// Distinguishes instances sharing a screen; every id this component emits
	// carries it. Neither key nor item name admits a hyphen, so the
	// -trigger-/-panel- separators are unreachable from either side.
	key:   =~"^[a-z0-9_]+$" & (*A.collection | string)
	label: string
	type:  *"single" | "multiple"
	// single only: the one row every item's open-state is a column of.
	row: *"the" | string
	// "none" is the single arm's closed state: an item so named would unify
	// with it in `states` rather than fail.
	items: [...{name: =~"^[a-z0-9_]+$" & !="none", label: string, body: string}] & [_, _, ...]

	_t: {for i in A.items {(i.name): "acc-\(A.key)-trigger-\(i.name)"}}
	_p: {for i in A.items {(i.name): "acc-\(A.key)-panel-\(i.name)"}}
	// One trigger per row at arity N, so the field itself is the value
	// aria-expanded wants; N triggers over one row need a column each.
	_bind: {for i in A.items {
		(i.name): [if A.type == "single" {"exp_\(i.name)"}, A.field][0]
	}}
	// The multiple arm is one region per item, so there is no set for a caret to
	// walk and every header is already its own tab stop with nothing to add.
	_caretAttr: {for i in A.items {
		(i.name): [if A.type == "single" {" data-cur=\"{cur_\(i.name)}\""}, ""][0]
	}}

	// The header level is the component's: h3 sits under the screen's h1 and
	// its section's h2. The id is on the button and on nothing inside it —
	// a nested id would shadow the trigger's and the arrow would never match.
	_inner: {for i in A.items {
		(i.name): """
			      <h3 class="acc-head"><button type="button" class="acc-trigger" id="\(A._t[i.name])"
			              aria-expanded="{\(A._bind[i.name])}" aria-controls="\(A._p[i.name])"\(A._caretAttr[i.name])><span class="acc-title">\(i.label)</span><span class="acc-chevron" aria-hidden="true"></span></button></h3>
			      <div class="acc-panel" role="region" id="\(A._p[i.name])"
			           aria-labelledby="\(A._t[i.name])"><p>\(i.body)</p></div>
			"""
	}}

	if A.type == "single" {
		// The caret: one state per header, the arrows that walk them, and the
		// focusin that records a reader who tabbed there. Vertical only — a
		// header list has no Left and Right for a reader to press.
		_caret: #OneOf & {
			field:  "caret"
			prefix: "cur_"
			walk:   true
			axis:   "vertical"
			names: [for i in A.items {i.name}]
			id: A._t
		}

		_allClosed: {for u in A.items {("exp_\(u.name)"): "false"}}
		_openOnly: {for i in A.items {
			(i.name): {for u in A.items {
				("exp_\(u.name)"): [if u.name == i.name {"true"}, "false"][0]
			}}
		}}

		// One arrow per (state, trigger) pair, the self-arrow included: it
		// targets `none`, which is the whole structural difference from #Tabs.
		_expansion: terminal.#Machine & {
			field:   A.field
			initial: "none"
			context: A._allClosed
			states: {
				none: on: {for i in A.items {
					("click@\(A._t[i.name])"): {target: i.name, assign: A._openOnly[i.name]}
				}}
				for s in A.items {
					(s.name): on: {for i in A.items {
						("click@\(A._t[i.name])"): [
							if i.name == s.name {{target: "none", assign: A._allClosed}},
							{target: i.name, assign: A._openOnly[i.name]},
						][0]
					}}
				}
			}
		}
		// Two charts, one row: the expansion writes `open` and `exp_*`, the
		// caret writes `caret` and `cur_*`, and neither knows the other runs.
		charts: [A._expansion, A._caret.machine]

		_items: strings.Join([for i in A.items {
			"""
				    <div class="acc-item">
				\(A._inner[i.name])
				    </div>
				"""
		}], "\n")

		// data-state is the GROUP's own fact — which item is open, or none —
		// and no trigger's aria-expanded spells it.
		markup: """
			<omnishell--accordion>
			  <div class="accordion" role="group" aria-label="\(A.label)"
			       data-live="\(A.collection)" data-filter="id=eq.\(A.row)"
			       data-state="{\(A.field)}"
			       data-machine='\((omni.#attrJSON & {in: A.charts}).out)'>
			\(A._items)
			  </div>
			</omnishell--accordion>
			"""
	}

	if A.type == "multiple" {
		// The binary chart, one per row: no context and no derived column,
		// because at this arity the field IS aria-expanded's value.
		machines: {for i in A.items {
			(i.name): (_#Binary & {
				field:   A.field
				initial: "false"
				trigger: A._t[i.name]
				next: {"false": "true", "true": "false"}
				implies: {}
			}).machine
		}}

		_items: strings.Join([for i in A.items {
			"""
				    <div class="acc-item" data-live="\(A.collection)" data-filter="id=eq.\(i.name)"
				         data-machine='\((omni.#attrJSON & {in: A.machines[i.name]}).out)'>
				\(A._inner[i.name])
				    </div>
				"""
		}], "\n")

		// The wrapper carries no data-live: at this arity there is no group
		// state to bind, only N rows, and each trigger's aria-expanded is the
		// only spelling of its own.
		markup: """
			<omnishell--accordion>
			  <div class="accordion" role="group" aria-label="\(A.label)">
			\(A._items)
			  </div>
			</omnishell--accordion>
			"""
	}
}
