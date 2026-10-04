// omnishell--tabs: shadcn's Tabs restated in the binding vocabulary — a
// tablist running #OneOf's chart, with panels projected off the root's
// data-state exactly as Radix stamps it. The projection is what this component
// adds to the shared generator; the segmented control and the radio group wrap
// the same arrows in markup that projects nothing.
//
// The discrimination grammar is component-GENERATED, never hand-written: one
// `click@trigger-<name>` transition per (state, trigger) pair, the spelling
// the interpreter already resolves before the bare event type. Each
// transition's literal assigns keep one aria-selected column per trigger in
// step with the active tab, so the ARIA contract is bindings over row
// columns — no computed attribute anywhere.
package components

import (
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
)

#Tabs: T={
	collection: string
	row:        *"the" | string
	field:      *"active" | string
	// Prefixes every id this instance emits. aria-controls and
	// aria-labelledby are ID references, so two instances sharing a prefix
	// point a reader's tab at the other one's panel.
	key: *T.collection | string
	label:      string
	tabs: [...{name: string, label: string, body: string}] & [_, _, ...]

	_id: {for t in T.tabs {(t.name): "\(T.key)-trigger-\(t.name)"}}

	_choice: #OneOf & {
		walk:   true
		roving: true
		field:  T.field
		prefix: "sel_"
		names: [for t in T.tabs {t.name}]
		id: T._id
	}
	machine: _choice.machine

	_triggers: strings.Join([for t in T.tabs {
		"""
			      <button type="button" role="tab" id="\(T._id[t.name])" class="tab-trigger"
			              tabindex="{\(T._choice.tab[t.name])}"
			              aria-selected="{\(T._choice.col[t.name])}" aria-controls="\(T.key)-panel-\(t.name)">\(t.label)</button>
			"""
	}], "\n")
	_panels: strings.Join([for t in T.tabs {
		"""
			    <div role="tabpanel" id="\(T.key)-panel-\(t.name)" data-panel="\(t.name)"
			         aria-labelledby="\(T._id[t.name])" class="tab-panel">\(t.body)</div>
			"""
	}], "\n")

	markup: """
		<omnishell--tabs>
		  <div class="tabs" data-live="\(T.collection)" data-filter="id=eq.\(T.row)"
		       data-state="{\(T.field)}"
		       data-machine='\((omni.#attrJSON & {in: T.machine}).out)'>
		    <div role="tablist" aria-label="\(T.label)">
		\(T._triggers)
		    </div>
		\(T._panels)
		  </div>
		</omnishell--tabs>
		"""
}
