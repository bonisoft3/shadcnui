// omnishell--form: the write path two other screens already lean on.
//
// The shell owns validation, not the UA. `screen.js` sets `noValidate` on every
// form it wires, so a refused submit becomes a screen STATE rather than the
// browser's bubble, and `checkValidity()` is the whole gate: a form failing it
// reaches no store and stays in `validation-error` until the next keystroke.
//
// One message per form, because the shell reveals the FIRST `.invalid`. That
// bound is why exactly one control carries a `pattern`: a `maxlength` is kept
// by truncating, so the other field has nothing to refuse and the one message
// can only be about the handle.
//
// Both controls bind their DEFAULT value, not their shown one — the input
// through `value`, the textarea through its own text. The shell resets a form
// whose write it accepts, and a default is where a reset lands; `data-value`
// would write the shown value and put the controls back on blank.
//
// No `aria-invalid` is reachable: the verdict is `checkValidity()`'s, taken
// inside the shell's submit listener, so it is not a column any binding could
// carry, and the `invalid` event naming each refused control does not bubble.
// What reaches the tree is the message, in an assertive live region — never
// through `aria-describedby`, which would read the refusal into the control's
// description before anything was typed.
package components

// The label, and the only place a control's name is written. `for` is #Field's
// to set: a label pointing at an id an author typed a second time is a label
// pointing at nothing.
#Label: L={
	for:  string
	text: string

	markup: """
		    <label class="field-label" for="\(L.for)">\(L.text)</label>
		"""
}

// A single-line control. `column` is the row column it shows, bound as the
// `value` ATTRIBUTE: the binder writes the control's default value, which a
// dirty control ignores and a reset returns to.
#Input: I={
	id:          string
	describedBy: string
	name:        string
	column:      string
	required:    bool
	maxLength:   int & >=1
	placeholder: string
	// The grammar the control refuses outside of — the one gate on the form,
	// so the form's single message is this field's.
	pattern:        string
	invalidMessage: string
	// The column's constraint, from the same sentence as the control's gate.
	cel: "this.matches('^\(I.pattern)$')"
	// The same field as the program's surface declares it: one statement
	// behind the control, the form object and the pane that prints it.
	declared: {
		name:            I.name
		control:         "text"
		required:        I.required
		maxLength:       I.maxLength
		placeholder:     I.placeholder
		invalidMessage:  I.invalidMessage
	}

	markup: """
		    <input class="field-control" id="\(I.id)" name="\(I.name)" type="text"
		           value="{\(I.column)}" autocomplete="off" pattern="\(I.pattern)"
		           maxlength="\(I.maxLength)" placeholder="\(I.placeholder)"
		           aria-describedby="\(I.describedBy)"\(I._required)>
		"""
	if I.required {_required: " required"}
	if !I.required {_required: ""}
}

// A multi-line control. Its content IS its default value, so `data-text` is
// the binding that makes a reset land on the row; the element ships empty, so
// the placeholder text of an unbound column is never painted.
#Textarea: T={
	id:          string
	describedBy: string
	name:        string
	column:      string
	rows:        *4 | int & >=2
	maxLength:   int & >=1
	placeholder: string
	// A length is the whole constraint: `maxlength` truncates, so nothing this
	// control can hand a submit is outside it.
	cel: "this.size() <= \(T.maxLength)"
	declared: {
		name:        T.name
		control:     "textarea"
		required:    false
		maxLength:   T.maxLength
		placeholder: T.placeholder
	}

	markup: """
		    <textarea class="field-control field-textarea" id="\(T.id)" name="\(T.name)"
		              rows="\(T.rows)" maxlength="\(T.maxLength)" placeholder="\(T.placeholder)"
		              aria-describedby="\(T.describedBy)" data-text="{\(T.column)}"></textarea>
		"""
}

// A control, its label and its help text as one unit — and the only place the
// three ids are written. The label's `for`, the control's own id and the
// `aria-describedby` that reaches the hint are all unified from `id`, so the
// association cannot drift into a reference that resolves to nothing.
#Field: F={
	id:      string
	hintId:  "\(F.id)-hint"
	label:   #Label & {for: F.id}
	// Open: what a field holds is one of the control definitions above, and
	// what #Field requires of it is only the three names it writes into.
	control: {id: F.id, describedBy: F.hintId, markup: string, declared: _, ...}
	hint:    string

	markup: """
		  <div class="field">
		\(F.label.markup)
		\(F.control.markup)
		    <p class="field-hint" id="\(F.hintId)">\(F.hint)</p>
		  </div>
		"""
}

// A real button, dressed by variant. Two variants, because two is what this
// screen has work for: a variant rendered with nothing behind it is a control
// that does nothing, which decision-09's catalog rule refuses. `type` is not a
// parameter either: the shell resets the form itself on an undisturbed success
// (screen.js:765), so every button here submits.
#Button: B={
	variant: "primary" | "danger"
	label:   string

	markup: """
		      <button type="submit" class="btn btn-\(B.variant)">\(B.label)</button>
		"""
}
