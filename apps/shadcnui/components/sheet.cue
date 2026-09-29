// Specializations of ./overlays.cue's #Dialog. Placing and travelling a
// surface is the screen stylesheet's; a modal <dialog> is already in the top
// layer with the page inert behind it.
//
// A drawer is `edge: "bottom"` rather than its own definition because what
// separates it upstream is drag-to-dismiss, and a gesture is a distance across
// several events that neither an event nor an assign carries.
//
// Of Radix's four AlertDialog differences the fourth — a press outside that
// does not dismiss — arrives with the element, a modal <dialog> never having
// had outside dismissal to give up. Escape still closes it: refusing a close
// request needs `closedby="none"`, outside this tree's measured engine matrix,
// or a `cancel` listener, which is script.
package components

// The set the screen stylesheet places. An edge with no rule behind it would
// be a parameter that renders an unstyled surface, so the disjunction is the
// styled set and no wider.
#Sheet: #Dialog & {
	edge: *"right" | "left" | "bottom"
}

#Drawer: #Sheet & {
	edge: "bottom"
}

// `ask` is what carries the whole contract: #Dialog reads it as the promise
// and derives the role, the modality and the second button from it, so an
// alert dialog with nothing to answer cannot be spelled.
#AlertDialog: #Dialog & {
	ask: !=""
}
