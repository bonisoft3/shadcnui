// omnishell--pagination and omnishell--carousel: shadcn's two ordinal
// traversals, generated from one #Ordinal.
//
// A machine has no arithmetic and needs none. From a position, "next" is the
// absolute arrow to the position after it — drawn at generate time, under the
// step button's id rather than that position's. Relative movement therefore
// costs no vocabulary at all, and the chart stays the complete inventory of
// where a reader can go, which is what makes it reviewable.
//
// At the first position no `click@<prefix>-<key>-prev` key exists, so Previous
// has no arrow to fire, and the button says the same thing with `disabled`
// bound from a column. The binder REMOVES a bound boolean attribute when it
// interpolates empty (screen.js BOOL_ATTRS), so the column holds "disabled" or
// "", and the arrow's absence and the affordance's absence are one generator's
// two emissions rather than two facts that can drift. The served HTML carries
// the placeholder, which is a non-empty string: both steps are disabled until
// the row arrives, which is the right state for a control whose machine has
// not mounted.
//
// aria-current is a token vocabulary, not a boolean, so decision-03 lands on
// it literally — the column holds the attribute's own value, "page" for a page
// list and "true" for a slide picker, and there is no second spelling of it.
//
// Keyboard, phased as tabs and toggle-group phased it: Tab in document order,
// native Space/Enter, no roving tabindex. `disabled` does remove the exhausted
// step from the tab order, which is the native mechanism's own cost and the
// reason it is stated on the screen.
package components

import (
	"list"
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

// The traversal itself: one state per position, and from each state one arrow
// to every OTHER position plus the two steps. Both components take their
// machine and their id namespace from here; only the markup around it differs.
//
// This is #OneOf generalized: the same one-state-per-item chart with the
// derived column's token parameterized (`current`, because aria-current is a
// token vocabulary where aria-checked and aria-selected are booleans) and the
// step arrows and their two disabled columns added. A fifth single-select
// component belongs on one of these two and not on a third copy.
#Ordinal: O={
	field: string
	// The two halves of an id namespace the positions and the steps share.
	// Neither admits a hyphen and no position may be named prev or next, so
	// `<prefix>-<key>-<name>` is unreachable from either side and two
	// traversals on one screen cannot collide.
	prefix: =~"^[a-z0-9]+$"
	key:    =~"^[a-z0-9_]+$"
	// The token aria-current takes at the position the reader is at.
	current: "page" | "true"
	// Open, and read for the name alone: what a position is called beyond that
	// is the wrapping component's business.
	items: [...{name: =~"^[a-z0-9_]+$" & !="prev" & !="next", ...}] & [_, _, ...]

	id: {for i in O.items {(i.name): "\(O.prefix)-\(O.key)-\(i.name)"}}
	prev: "\(O.prefix)-\(O.key)-prev"
	next: "\(O.prefix)-\(O.key)-next"

	// The whole row at a position, which every arrow landing there assigns:
	// one aria-current column per position, and the two disabled columns the
	// ends need.
	at: {for x, s in O.items {
		(s.name): {
			for u in O.items {("cur_\(u.name)"): [if u.name == s.name {O.current}, "false"][0]}
			dis_prev: [if x == 0 {"disabled"}, ""][0]
			dis_next: [if x == len(O.items)-1 {"disabled"}, ""][0]
		}
	}}

	machine: terminal.#Machine & {
		field:   O.field
		initial: O.items[0].name
		context: O.at[O.items[0].name]
		states: {for x, s in O.items {
			(s.name): on: {
				for u in O.items if u.name != s.name {
					("click@\(O.id[u.name])"): {target: u.name, assign: O.at[u.name]}
				}
				if x > 0 {
					("click@\(O.prev)"): {target: O.items[x-1].name, assign: O.at[O.items[x-1].name]}
				}
				if x < len(O.items)-1 {
					("click@\(O.next)"): {target: O.items[x+1].name, assign: O.at[O.items[x+1].name]}
				}
			}
		}}
	}
}

// The screen's arrow census, measured off a machine rather than restated
// beside one: a printed count that the generator does not produce is a count
// that can be wrong.
#Inventory: I={
	machine:   terminal.#Machine
	positions: len(I.machine.states)
	arrows:    list.Sum([for _, s in I.machine.states {len(s.on)}])
	absolute:  I.positions * (I.positions - 1)
	step:      I.arrows - I.absolute
	columns:   len(I.machine.context)
}

// The page list is a <nav> of buttons, not of links: a page here is a column
// of a row and has no URL, so shadcn's <a> would be a link to nowhere wearing
// a link's role.
#Pagination: P={
	collection: string
	row:        *"the" | string
	field:      *"page" | string
	key:        =~"^[a-z0-9_]+$"
	label:      string
	pages: [...{name: =~"^[a-z0-9_]+$", label: string}] & [_, _, ...]

	_o: #Ordinal & {field: P.field, prefix: "pag", key: P.key, current: "page", items: P.pages}

	machine: _o.machine

	_pages: strings.Join([for i in P.pages {
		"""
			      <li><button type="button" class="pag-page" id="\(P._o.id[i.name])"
			              aria-current="{cur_\(i.name)}" aria-label="Page \(i.label)">\(i.label)</button></li>
			"""
	}], "\n")

	// data-state is Radix's observable contract, and here it drives nothing:
	// the per-position fact is per-position, and aria-current carries it.
	markup: """
		<omnishell--pagination>
		  <nav class="pagination" aria-label="\(P.label)"
		       data-live="\(P.collection)" data-filter="id=eq.\(P.row)"
		       data-state="{\(P.field)}"
		       data-machine='\((omni.#attrJSON & {in: P.machine}).out)'>
		    <ul class="pag-list">
		      <li><button type="button" class="pag-step" id="\(P._o.prev)" disabled="{dis_prev}"><span class="pag-chev" aria-hidden="true">‹</span>Previous</button></li>
		\(P._pages)
		      <li><button type="button" class="pag-step" id="\(P._o.next)" disabled="{dis_next}">Next<span class="pag-chev" aria-hidden="true">›</span></button></li>
		    </ul>
		  </nav>
		</omnishell--pagination>
		"""
}

// The same traversal with the slide projected off the root's data-state,
// exactly as #Tabs projects panels, and the dots as APG's slide picker.
//
// The viewport is a polite live region, which is APG's required property for
// the element holding the slides: pressing a dot or a step moves focus
// nowhere and the projection swaps one slide for another under the reader, so
// without it the change is silent. `polite` rather than `off` because this
// carousel never auto-rotates, and aria-atomic="false" so the region reports
// the slide that arrived rather than re-reading the whole viewport.
#Carousel: C={
	collection: string
	row:        *"the" | string
	field:      *"slide" | string
	key:        =~"^[a-z0-9_]+$"
	label:      string
	slides: [...{name: =~"^[a-z0-9_]+$", label: string, body: string}] & [_, _, ...]

	_o: #Ordinal & {field: C.field, prefix: "car", key: C.key, current: "true", items: C.slides}
	_n: len(C.slides)

	machine: _o.machine

	// The heading level is the component's: h3 sits under the screen's h1 and
	// its arm's h2.
	_slides: strings.Join([for x, s in C.slides {
		"""
			      <div class="car-slide" data-slide="\(s.name)" role="group" aria-roledescription="slide"
			           aria-label="\(x+1) of \(C._n)">
			        <h3 class="car-title">\(s.label)</h3>
			        <p class="car-body">\(s.body)</p>
			      </div>
			"""
	}], "\n")

	// A dot has no text, so its name is the label; the position is the reader's
	// ordinal rather than the state's name, which is the component's.
	_dots: strings.Join([for x, s in C.slides {
		"""
			        <li><button type="button" class="car-dot" id="\(C._o.id[s.name])"
			                aria-current="{cur_\(s.name)}" aria-label="Slide \(x+1)"></button></li>
			"""
	}], "\n")

	markup: """
		<omnishell--carousel>
		  <div class="carousel" role="group" aria-roledescription="carousel" aria-label="\(C.label)"
		       data-live="\(C.collection)" data-filter="id=eq.\(C.row)"
		       data-state="{\(C.field)}"
		       data-machine='\((omni.#attrJSON & {in: C.machine}).out)'>
		    <div class="car-viewport" aria-live="polite" aria-atomic="false">
		\(C._slides)
		    </div>
		    <div class="car-bar">
		      <button type="button" class="car-step" id="\(C._o.prev)" disabled="{dis_prev}" aria-label="Previous slide"><span aria-hidden="true">‹</span></button>
		      <ul class="car-dots">
		\(C._dots)
		      </ul>
		      <button type="button" class="car-step" id="\(C._o.next)" disabled="{dis_next}" aria-label="Next slide"><span aria-hidden="true">›</span></button>
		    </div>
		  </div>
		</omnishell--carousel>
		"""
}
