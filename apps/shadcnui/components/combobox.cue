// omnishell--combobox: the half of shadcn's Combobox that is expressible in
// this vocabulary, and nothing past it.
//
// The filtering primitive is the platform's own `<input list>` +
// `<datalist>`. The UA maps the pair to role="combobox" with
// autocomplete="list" and haspopup="listbox", and owns the popup's whole
// lifecycle — but it exposes no expanded state at all, so APG's required
// aria-expanded is one more thing neither the page nor a reader can see. A
// form holding no button submits on `change`, so picking a suggestion commits
// it.
//
// A machine could carry the typed text now — `#Command` does, through the
// event leaf — and would still not carry this control: the write here is a
// commit on a gesture rather than screen state as it changes, and virtual
// focus over the suggestions is the wall neither closes.
//
// The write being the form's, the region declares its own data-empty-row: a
// synthesized fallback row is a machine region's privilege.
//
// The option list is stated once and emitted three times: the datalist the UA
// filters, the `pattern` that refuses anything else, and the `cel` this
// exports for the column's constraint. A control-side gate and a store-side
// one that could drift are two spellings of one fact; here they are one.
package components

import (
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
)

// The alphabet a typed option is spelled in, stated once for every control
// here that admits one. It is narrow on purpose: `.` and `+` are the only
// regex metacharacters in it, which is what makes #Combobox's escaping below
// exhaustive, and it is still enough for C++, C# and Objective-C. The hyphen
// sits last and escaped because an HTML `pattern` compiles under the `v` flag,
// where a trailing `-` inside a class is a syntax error and checkValidity
// throws rather than refusing.
_optionClass: "A-Za-z0-9 .+#\\-"
// What may open one: a metacharacter or a space in first position reads as
// punctuation rather than as a name.
_optionHead: "A-Za-z0-9"

#Combobox: C={
	collection: string
	row:        *"the" | string
	field:      *"choice" | string
	// Prefixes the screen's ids; the single-instance default is the tag's name.
	key:   *"combobox" | string
	label: string
	// The #Form id this markup realizes, so the program and the markup name
	// the same form.
	form: string
	// Values as the reader types them: an <option> carries a value and its
	// text and nothing else, so the written value IS the label.
	options: [...string & =~"^[\(_optionClass)]+$"] & [_, _, ...]
	initial:     *C.options[0] | or([for o in C.options {o}])
	placeholder: string
	hint:        string
	invalid:     string

	// The column's constraint, for the entity that holds the row.
	cel: "this in [" + strings.Join([for o in C.options {"'\(o)'"}], ", ") + "]"

	_pattern: strings.Join([for o in C.options {
		strings.Replace(strings.Replace(o, ".", "\\.", -1), "+", "\\+", -1)
	}], "|")
	_options: strings.Join([for o in C.options {
		"        <option value=\"\(o)\"></option>"
	}], "\n")
	_emptyRow: (omni.#attrJSON & {in: {id: C.row, (C.field): C.initial}}).out

	// The submit path resets the form, which returns the input to its `value`
	// ATTRIBUTE and clears its dirty flag, while the binder writes the row into
	// that same attribute on the refresh the write wakes. Either order ends on
	// the row, which is why the binding is `value` and not a control the reset
	// would empty.
	markup: """
		<omnishell--combobox>
		  <div class="combobox" data-live="\(C.collection)" data-filter="id=eq.\(C.row)"
		       data-empty-row='\(C._emptyRow)'>
		    <form class="combobox-form" data-form="\(C.form)"
		          data-entity="\(C.collection)" data-action="upsert">
		      <input type="hidden" name="id" data-value="\(C.row)">
		      <label class="combobox-label" for="\(C.key)-input">\(C.label)</label>
		      <input class="combobox-input" id="\(C.key)-input" name="\(C.field)" type="text"
		             list="\(C.key)-options" value="{\(C.field)}" required autocomplete="off"
		             pattern="\(C._pattern)" placeholder="\(C.placeholder)"
		             aria-describedby="\(C.key)-hint">
		      <datalist id="\(C.key)-options">
		\(C._options)
		      </datalist>
		      <p class="combobox-hint" id="\(C.key)-hint">\(C.hint)</p>
		      <!-- Named by no aria-describedby, hidden or revealed: accname does
		           not skip a hidden node a description references directly, so the
		           reference would read the refusal into the input's description on
		           every focus, before anything is typed. What a reader gets instead
		           is the invalidity itself — noValidate suppresses the UA's bubble,
		           never the pattern's verdict. -->
		      <p class="invalid" id="\(C.key)-invalid" hidden>\(C.invalid)</p>
		    </form>
		  </div>
		</omnishell--combobox>
		"""
}
