// The description is a sibling the button points at with aria-describedby,
// never a child: name-from-content would fold the whole paragraph into the
// option's accessible name. Carrying the id that binding needs also means a
// click on the description resolves `from` to it and matches no arrow.
//
// No name attribute and no hidden input: the write is the machine's, and a
// control named for a submit that cannot happen would imply one.
//
// aria-orientation is absent because both axes move the tabstop: #OneOf draws
// Right and Down to the next option and Left and Up to the previous, so there
// is no axis to tell a reader about.
package components

import (
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
)

#RadioGroup: R={
	collection: string
	row:        *"the" | string
	field:      *"value" | string
	// Visible, and the group's accessible name through aria-labelledby: a
	// labelled set shows its label, where a segmented control hides one in
	// aria-label.
	legend: string
	// Distinguishes instances sharing one collection: every id is
	// rg-<key>-item-<name> or rg-<key>-desc-<name>. Neither part admits a
	// hyphen, so the separators are unreachable from either side.
	key: =~"^[a-z0-9_]+$" & (*R.collection | string)
	items: [...{name: =~"^[a-z0-9_]+$", label: string, description: string}] & [_, _, ...]

	_id: {for i in R.items {(i.name): "rg-\(R.key)-item-\(i.name)"}}
	_desc: {for i in R.items {(i.name): "rg-\(R.key)-desc-\(i.name)"}}
	_legend: "rg-\(R.key)-legend"

	_choice: #OneOf & {
		walk:   true
		field:  R.field
		prefix: "chk_"
		names: [for i in R.items {i.name}]
		id: R._id
	}
	machine: _choice.machine

	_options: strings.Join([for i in R.items {
		"""
			      <div class="rg-option">
			        <button type="button" role="radio" id="\(R._id[i.name])" class="rg-item"
			                data-rove="{\(R._choice.col[i.name])}"
			                aria-checked="{\(R._choice.col[i.name])}" aria-describedby="\(R._desc[i.name])"><span class="rg-mark" aria-hidden="true"></span><span class="rg-label">\(i.label)</span></button>
			        <p class="rg-desc" id="\(R._desc[i.name])">\(i.description)</p>
			      </div>
			"""
	}], "\n")

	markup: """
		<omnishell--radio-group>
		  <div class="radio-group" data-live="\(R.collection)" data-filter="id=eq.\(R.row)"
		       data-state="{\(R.field)}"
		       data-machine='\((omni.#attrJSON & {in: R.machine}).out)'>
		    <p class="rg-legend" id="\(R._legend)">\(R.legend)</p>
		    <div role="radiogroup" aria-labelledby="\(R._legend)" class="rg-set">
		\(R._options)
		    </div>
		  </div>
		</omnishell--radio-group>
		"""
}
