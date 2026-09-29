// omnishell--switch: shadcn's Switch restated in the binding vocabulary — a
// role="switch" singleton region whose behavior is a #Machine, not code.
//
// The state names are the ARIA attribute's values ("true"/"false", because
// aria-checked speaks that vocabulary): one field binds the semantics and the
// styling hook, never two spellings of one fact. No data-empty-row: the
// machine is the writer of the initial fact, and the terminal synthesizes the
// fallback row from the filter's pinned id plus {field: initial}. The tag
// survives in the served HTML as an inert wrapper — visible to devtools, CSS
// and the visual battery, registered with nothing.
package components

import (
	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#Switch: S={
	collection: string
	row:        *"the" | string
	field:      *"checked" | string
	label:      string

	machine: terminal.#Machine & {
		field:   S.field
		initial: "false"
		states: {
			"false": on: click: "true"
			"true": on: click: "false"
		}
	}

	markup: """
		<omnishell--switch>
		  <button type="button" role="switch" aria-checked="{\(S.field)}" class="switch"
		          data-live="\(S.collection)" data-filter="id=eq.\(S.row)"
		          data-machine='\((omni.#attrJSON & {in: S.machine}).out)'>
		    <span class="switch-track" aria-hidden="true"><span class="switch-thumb"></span></span>
		    <span class="switch-label">\(S.label)</span>
		  </button>
		</omnishell--switch>
		"""
}
