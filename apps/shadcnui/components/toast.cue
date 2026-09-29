// omnishell--toast: shadcn's Toast, and the gallery's first consumer of
// `after`. Being in a state IS the pending timer — `open` declares the wait,
// entering it arms the wait, leaving it cancels the wait, and the terminal
// performs it. So the delay is data in the chart rather than a setTimeout in a
// handler, and the machine never reads a clock: it stays a function of its
// inputs, which is what lets ?tempo= and ?clock=manual govern it.
//
// The trigger's arrow out of `open` targets `open`: a target re-enters the
// state even when it is the one already held, and re-entry is the re-arm. The
// closed state declares no `after`, so a screen nobody touches arms nothing.
//
// There is no ARIA attribute spelling shown-ness, so the observable contract
// is Radix's `data-state="open"|"closed"` and the column is named for it. The
// live region is the viewport, not the toast: a polite region has to be
// mounted before its content appears, or the only change it reports is its own
// arrival. role="status" rather than role="alert" because the two are
// mutually exclusive by construction — a message assertive enough to interrupt
// is one no reader can be asked to catch inside a few seconds.
//
// No popover: a popover's openness is the UA's, moved by a button press, and
// `after` writes a row and commands nothing — the timer would expire with the
// row saying closed and the surface still in the top layer.
package components

import (
	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#Toast: T={
	collection: string
	row:        *"the" | string
	field:      *"state" | string
	// Distinguishes instances sharing a screen; every id this component emits
	// carries it.
	key:     =~"^[a-z0-9_]+$" & (*T.collection | string)
	trigger: string
	title:   string
	body:    string
	dismiss: *"Dismiss" | string
	// Milliseconds the toast stands. #Machine's after key is digits or the
	// name of a Jessie module returning them; this app ships no module, so a
	// reader cannot lengthen this and WCAG 2.2.1 is unmet by that much.
	delay: int & >0 | *3000

	_open:  "toast-\(T.key)-trigger"
	_close: "toast-\(T.key)-close"

	machine: terminal.#Machine & {
		field:   T.field
		initial: "closed"
		states: {
			closed: on: {(("click@" + T._open)): "open"}
			open: {
				on: {
					(("click@" + T._open)):  "open"
					(("click@" + T._close)): "closed"
				}
				after: {("\(T.delay)"): "closed"}
			}
		}
	}

	// The trigger sits inside the region because `from` resolves to the
	// nearest ancestor carrying an id WITHIN the region; the viewport leaves
	// the flow in CSS, not in the tree.
	markup: """
		<omnishell--toast>
		  <div class="toast-mount" data-live="\(T.collection)" data-filter="id=eq.\(T.row)"
		       data-state="{\(T.field)}"
		       data-machine='\((omni.#attrJSON & {in: T.machine}).out)'>
		    <button type="button" id="\(T._open)" class="toast-trigger">\(T.trigger)</button>
		    <div class="toast-viewport" role="status">
		      <div class="toast">
		        <p class="toast-title">\(T.title)</p>
		        <p class="toast-body">\(T.body)</p>
		        <button type="button" id="\(T._close)" class="toast-close">\(T.dismiss)</button>
		      </div>
		    </div>
		  </div>
		</omnishell--toast>
		"""
}
