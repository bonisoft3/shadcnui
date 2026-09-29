// omnishell--dialog and omnishell--tooltip: shadcn's Dialog and Tooltip with
// nothing left for a machine to hold. Openness, the top layer, the inert
// background that IS the focus trap, Esc as a close request, the return of
// focus to the invoker and the surface's placement are browser primitives —
// commanded by commandfor/command, positioned by anchor-name in CSS. So
// neither definition carries a #Machine and neither mounts a region: what
// they hold is the markup that earns those primitives, which is the
// accessible name and description the UA does not supply, plus the ids that
// keep two surfaces on one screen apart.
//
// Neither #Dialog surface contains the other. Modal buys the inert background
// and loses backdrop light dismiss; non-modal buys light dismiss and loses the
// inert background. `closedby` would close that gap and is outside the engine
// matrix this tree measured (plugins/omnishell/docs/terminal.md), so the surface is
// a parameter and nothing here depends on it.
//
// The other two parameters are what shadcn ships as Sheet, Drawer and
// AlertDialog: `edge` places the same element against a side, `ask` turns it
// into a question. ./sheet.cue names them and its screen defends the
// factoring.
//
// #Tooltip ships APG's DISCLOSURE, not APG's tooltip: it opens on click and
// carries neither role="tooltip" nor aria-describedby, because a hover-opened
// surface needs `interestfor` and no engine implements it. aria-describedby
// would read the tip's text out on every focus of the trigger, open or
// closed — the announcement a disclosure exists to defer.
package components

#Dialog: D={
	key:         string
	trigger:     string
	title:       string
	description: string
	// The dialog's own content, markup the caller composes.
	body:    string
	dismiss: *"Close" | string
	// Modality is the whole variant: it decides the element, the command pair,
	// and which half of the dismissal contract ships.
	modal: *true | bool

	// The edge the surface arrives from, and the whole of what a sheet is:
	// "none" is the centred dialog, and every other value is the same element
	// placed and travelled by CSS off the data-edge below. An edge surface is
	// modal because the alternative is a panel over a live page that a reader
	// Tabs out of without closing.
	edge: *"none" | "right" | "left" | "bottom"
	if D.edge != "none" {modal: true}

	// The label of the deliberate answer. Where it is present the surface asks
	// a question rather than showing content, and everything role="alertdialog"
	// promises follows from that one fact: modal, described as well as named,
	// answered beside the refusal, and opened on the refusal.
	ask: *"" | string
	if D.ask != "" {modal: true}

	_id:    "dialog-\(D.key)"
	_open:  "dialog-open-\(D.key)"
	_title: "\(D._id)-title"
	_desc:  "\(D._id)-desc"

	// aria-expanded is written nowhere: the UA supplies it for a popover
	// invoker, and a modal invoker has none to supply. Either hand-written
	// attribute would be a second spelling of a fact the browser already
	// states, and the modal one would be a lie that never moves.
	_trigger: """
		    <button type="button" id="\(D._open)" class="dialog-trigger"
		            commandfor="\(D._id)" command="\([if D.modal {"show-modal"}, "toggle-popover"][0])"
		            aria-haspopup="dialog">\(D.trigger)</button>
		"""

	// Attributes that exist only where their parameter is set, so the centred
	// content dialog emits neither and the markup carries no default spelled out.
	_edgeAttr: [if D.edge != "none" {" data-edge=\"\(D.edge)\""}, ""][0]
	_roleAttr: [if D.ask != "" {" role=\"alertdialog\""}, ""][0]
	_answer: [if D.ask != "" {"\n        <button type=\"button\" class=\"dialog-ask\" commandfor=\"\(D._id)\" command=\"close\">\(D.ask)</button>"}, ""][0]

	// autofocus on the dismiss button: engines differ on whether focus
	// otherwise lands on the surface itself, and the least destructive control
	// is the one to land on. The answer is second in the DOM and never carries
	// it, which is the same rule read from the other end.
	_content: """
		      <h2 id="\(D._title)" class="dialog-title">\(D.title)</h2>
		      <p id="\(D._desc)" class="dialog-desc">\(D.description)</p>
		\(D.body)
		      <footer class="dialog-footer">
		        <button type="button" class="dialog-dismiss" autofocus
		                commandfor="\(D._id)" command="\([if D.modal {"close"}, "hide-popover"][0])">\(D.dismiss)</button>\(D._answer)
		      </footer>
		"""

	// role="dialog" and the modal semantics are the UA's on <dialog>; the
	// non-modal surface is a plain element in the top layer, so it declares
	// the role itself — and declares no aria-modal, because it is not one.
	if D.modal {
		markup: """
			<omnishell--dialog>
			\(D._trigger)
			  <dialog id="\(D._id)" class="dialog"\(D._edgeAttr)\(D._roleAttr)
			          aria-labelledby="\(D._title)" aria-describedby="\(D._desc)">
			\(D._content)
			  </dialog>
			</omnishell--dialog>
			"""
	}
	if !D.modal {
		markup: """
			<omnishell--dialog>
			\(D._trigger)
			  <div id="\(D._id)" class="dialog" popover role="dialog"
			       aria-labelledby="\(D._title)" aria-describedby="\(D._desc)">
			\(D._content)
			  </div>
			</omnishell--dialog>
			"""
	}
}

#Tooltip: T={
	key:   string
	label: string
	text:  string
	// The resolved side, carried as data the skin keys on: position-area is
	// the placement vocabulary, and a component that hard-coded a side in CSS
	// would put the choice where the author cannot reach it.
	place: *"top" | "bottom"

	_id:   "tip-\(T.key)"
	_open: "tip-open-\(T.key)"

	markup: """
		<omnishell--tooltip>
		  <span class="tip">
		    <button type="button" id="\(T._open)" class="tip-trigger"
		            commandfor="\(T._id)" command="toggle-popover">\(T.label)</button>
		    <span id="\(T._id)" class="tip-surface" data-place="\(T.place)" popover>\(T.text)</span>
		  </span>
		</omnishell--tooltip>
		"""
}

// omnishell--hover-tip: APG's TOOLTIP, where #Tooltip above is APG's
// disclosure. The two differ in what opens them and in everything that follows
// from it, which is why they are two components and not one parameter.
//
// This one opens on hover or focus, so `aria-describedby` is right where it was
// wrong above: a tooltip is MEANT to be announced when the trigger takes focus,
// and the same gesture that announces it is the one that shows it. The surface
// therefore carries role="tooltip" and the trigger points at it.
//
// The surface is popover="auto" and that is load-bearing rather than tidy: light
// dismiss and Escape are WCAG 1.4.13's DISMISSIBLE clause, and they come from
// the element. What the terminal adds is the open, the grace that makes the
// surface HOVERABLE, and nothing else — no row, no chart, no column. Openness
// nobody stores cannot disagree with anything, which is the same licence the
// dialogs on this screen already run on.
#HoverTip: H={
	key:   string
	label: string
	text:  string
	place: *"top" | "bottom"

	_id:      "htip-\(H.key)"
	_trigger: "htip-open-\(H.key)"

	markup: """
		<omnishell--hover-tip>
		  <span class="tip">
		    <button type="button" id="\(H._trigger)" class="tip-trigger"
		            data-interest="\(H._id)" aria-describedby="\(H._id)">\(H.label)</button>
		    <span id="\(H._id)" class="tip-surface" role="tooltip" data-place="\(H.place)"
		          popover="auto">\(H.text)</span>
		  </span>
		</omnishell--hover-tip>
		"""
}
