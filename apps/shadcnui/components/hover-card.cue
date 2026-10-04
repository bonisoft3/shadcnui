// omnishell--hover-card: shadcn's HoverCard, a popover surface with its own
// links — following ./overlays.cue's tip, which is a surface holding one sentence.
//
// What makes it a component of its own is the CONTENT. A tooltip's surface is a
// string, so it may be a description a trigger points at; a hover card's is a
// structure with its own links, so it may be neither. `aria-describedby`
// flattens what it names into one announcement and would read a card's whole
// layout out on every focus of the trigger, and `role="tooltip"` promises a
// surface nothing inside can be reached — which is exactly what this surface is
// not. So this one carries neither, and the pair the tip carries
// (decision-42's) is the contrast rather than an omission here.
//
// The surface follows its trigger in DOM order, which is the whole of what
// makes the card reachable: sequential focus navigation walks an open popover
// in tree order, so Tab moves from the trigger into the card. That is what
// forced the terminal to hear focus on the surface as well as the pointer —
// before it did, the card closed on the reader's way into it, taking their
// focus with it, because the element holding it was gone.
package components

#HoverCard: H={
	// Distinguishes instances on one screen: ids must be unique per screen, and
	// this one names both halves of the pair.
	key: string
	// The trigger is a link and not a button: a hover card sits on a name that
	// goes somewhere, and its own gesture is neither a command nor a toggle.
	label: string
	route: string
	body:  string
	place: *"block-end" | "block-start" | "inline-start" | "inline-end"

	_id:      "hc-\(H.key)"
	_trigger: "hc-open-\(H.key)"

	markup: """
		<omnishell--hover-card>
		  <span class="hc">
		    <a class="hc-trigger" id="\(H._trigger)" data-route="\(H.route)"
		       popovertarget="\(H._id)">\(H.label)</a>
		    <div id="\(H._id)" class="hc-surface" data-place="\(H.place)" popover="auto">
		\(H.body)
		    </div>
		  </span>
		</omnishell--hover-card>
		"""
}
