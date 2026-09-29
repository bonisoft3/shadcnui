// omnishell--navigation-menu and omnishell--sidebar: neither is a new
// mechanism. The bar is ./menu.cue's menubar with links for items, the rail's
// collapse is ./checkbox.cue's binary chart under aria-expanded, and the narrow
// board is ./sheet.cue's dialog — a change to any of those three lands here.
// What is new is the rail's CONTENT: its items are rows, and aria-current is a
// derived column rather than a literal somebody keeps in step with the router.
//
// The screen carries the arguments: which half of shadcn's hover-opened
// NavigationMenu ships, why aria-current binds "true"/"false" instead of the
// pattern's "page", and why a site's navigation wears menu roles at all.
package components

import (
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
)

// The rail's list. Two regions deep, because the projection's `eq` resolves
// against the ENCLOSING row: `nav_state` names the route the reader is on, and
// the item region compares that name against each item's own id
// (plugins/omnishell/docs/accessibility.md). Flattening the two into
// one region takes the comparison's other side away.
//
// The route is a column the program states, not one the terminal supplies: a
// screen is handed only the params its path declares (`{param.x}`), and a
// static route declares none.
_#Rail: R={
	// Unique per screen: it is the nav's id, which the collapse control names.
	key:   =~"^[a-z0-9_]+$"
	label: string
	// The row naming the open route, and the collection the items are.
	state: *"nav_state" | string
	row:   *"the" | string
	items: *"nav_rail_item" | string

	_id: "nav-rail-\(R.key)"

	// The list sits INSIDE the outer template's item rather than being it: a
	// region hydrates the nested regions found under an item node, and a node
	// that is itself the region is under nothing.
	//
	// No id on a link: nothing narrows an arrow to one, and an id inside an
	// item template would have to derive from the row to stay unique.
	markup: """
		      <nav class="sb-rail" id="\(R._id)" aria-label="\(R.label)">
		        <div class="sb-scope" data-live="\(R.state)" data-filter="id=eq.\(R.row)">
		          <template data-item>
		            <div class="sb-holder">
		              <ul class="sb-list" data-live="\(R.items)" data-order="pos.asc"
		                  data-project='{"current":{"eq":["id","{current}"]}}'>
		                <template data-item>
		                  <li class="sb-item"><a class="sb-link" data-route="{route}" aria-current="{current}" data-text="{label}"></a></li>
		                </template>
		              </ul>
		            </div>
		          </template>
		        </div>
		      </nav>
		"""
}

// The rail on both boards. `inline` is the rail that stays on the page with a
// disclosure over it; `sheet` is the same rail inside ./sheet.cue's left-edge
// dialog, where openness is the element's and no chart exists at all.
//
// Collapsed takes the rail off the canvas, which is shadcn's `offcanvas`
// default. Its `collapsible="icon"` — a narrow rail of glyphs at the collapsed
// width — cannot be expressed here: an icon per item is a column these rows do
// not carry, and a glyph per route in CSS would be the compile-time list the
// rows were adopted to retire.
#Sidebar: S={
	key:   =~"^[a-z0-9_]+$"
	label: string
	board: *"inline" | "sheet"

	_rail: _#Rail & {key: S.key, label: S.label}

	if S.board == "inline" {
		collection: *"nav_sidebar_demo" | string
		row:        *"the" | string
		field:      *"open" | string
		// The control's name, and it does not move: aria-expanded carries
		// which state it is in, so a label that changed with it would be a
		// second spelling of the same fact.
		toggle: *"Sidebar" | string
		// What sits beside the rail, so a reader can see the rail is beside
		// something rather than alone in a box.
		canvas:       string
		trigger?:     _|_
		title?:       _|_
		description?: _|_

		_toggle: "nav-toggle-\(S.key)"
		_gen: _#Binary & {
			field:   S.field
			initial: "true"
			trigger: S._toggle
			next: {"true": "false", "false": "true"}
			implies: {}
		}
		machine: _gen.machine

		// The button is the region, as it is on the toggle: one row, one
		// field, one arrow narrowed to the id it is written on. The rail is
		// its sibling rather than its child, because a region nested inside a
		// singleton region is never hydrated — and the collapsed frame is a
		// stylesheet reading the trigger's own aria-expanded.
		markup: """
			<omnishell--sidebar>
			  <div class="sidebar">
			    <button type="button" class="sb-toggle" id="\(S._toggle)"
			            aria-expanded="{\(S.field)}" aria-controls="\(S._rail._id)"
			            data-live="\(S.collection)" data-filter="id=eq.\(S.row)"
			            data-machine='\((omni.#attrJSON & {in: S.machine}).out)'><span class="sb-bars" aria-hidden="true"></span>\(S.toggle)</button>
			    <div class="sb-body">
			\(S._rail.markup)
			      <div class="sb-canvas"><p>\(S.canvas)</p></div>
			    </div>
			  </div>
			</omnishell--sidebar>
			"""
	}

	if S.board == "sheet" {
		trigger:     string
		title:       string
		description: string
		collection?: _|_
		row?:        _|_
		field?:      _|_
		toggle?:     _|_
		canvas?:     _|_
		machine?:    _|_

		_sheet: #Sheet & {
			key:         S.key
			edge:        "left"
			trigger:     S.trigger
			title:       S.title
			description: S.description
			body:        S._rail.markup
		}

		markup: """
			<omnishell--sidebar>
			\(S._sheet.markup)
			</omnishell--sidebar>
			"""
	}
}

// ./menu.cue's menubar, with links where the menu screen has stateful items:
// one trigger per section, one surface per trigger, and every item an <a> to a
// route this app serves. The bar carries no aria-label of its own — the <nav>
// around it is named, and a widget inside a landmark of the same name would
// hand a reader the string twice.
#NavigationMenu: N={
	label: string
	sections: [...{
		key:   =~"^[a-z0-9_]+$"
		label: string
		items: [...{label: string, route: string}] & [_, ...]
	}] & [_, _, ...]

	// A section's items are the surface's one group: they are menuitems
	// directly under role="menu", which is what a menu admits, and a
	// role="group" around a single set would separate it from nothing.
	_bar: #Menubar & {
		menus: [for s in N.sections {{
			key:   s.key
			label: s.label
			groups: [strings.Join([for i in s.items {(#MenuLink & {label: i.label, route: i.route}).markup}], "\n")]
		}}]
	}

	markup: """
		<omnishell--navigation-menu>
		  <nav class="navmenu" aria-label="\(N.label)">
		\(N._bar.markup)
		  </nav>
		</omnishell--navigation-menu>
		"""
}
