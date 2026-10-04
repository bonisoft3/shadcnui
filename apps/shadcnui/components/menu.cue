// omnishell--dropdown-menu and omnishell--menubar: one `_#Surface` under two
// containers.
//
// A menu's accessibility tree admits menuitem, menuitemradio, menuitemcheckbox,
// group and separator and nothing else, so a group heading a reader can SEE is
// not a node the tree may hold: it carries the id the group's aria-labelledby
// names and is aria-hidden, one string serving both readers. That is the
// inverse of #RadioGroup, whose legend stays in the tree.
//
// A plain item is an <a> because a navigation is the only command this app
// performs without a handler module. A stateful item is a REGION of its own —
// a machine binds one row, and a region nested inside a singleton region is
// never hydrated — so the surface holds no data-live and each item mounts
// beside its siblings.
//
// No shortcut hint beside any item: a machine can key on `keydown` but carries
// no equality to test the key it read, so ⌘K would label a binding that cannot
// exist.
//
// No tabindex is emitted, so every item and every menubar trigger stays its own
// tab stop. Arrow-key roving does not ship, and what that costs under
// role="menu" is decision-29's subject.
package components

import (
	"list"
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
)

// The wrapper for items that carry no region of their own. The heading's id is
// the group's name and the group's only non-item child, hence aria-hidden.
#MenuGroup: G={
	// Unique per screen: this is the heading's id, and an ID reference
	// resolving to a duplicate names whichever the document reaches first.
	key:  =~"^[a-z0-9_]+$"
	name: string
	items: [...string] & [_, ...]

	_label: "menu-group-\(G.key)"

	markup: """
		      <div class="menu-group" role="group" aria-labelledby="\(G._label)">
		        <p class="menu-label" id="\(G._label)" aria-hidden="true">\(G.name)</p>
		\(strings.Join(G.items, "\n"))
		      </div>
		"""
}

// A navigation item. It carries an id because the surface's caret narrows an
// arrow to it: a walk that could not name a link would stop at the first one.
#MenuLink: L={
	label: string
	// A route of this app, named by its screen; the binder composes the href.
	route: string
	// Empty on a surface with no caret: nothing narrows an arrow to the link
	// there, and an id nothing names is a fact the markup does not need.
	id: *"" | string
	// The column saying the caret is here, or "" likewise.
	focus: *"" | string

	_idAttr:    [if L.id != "" {" id=\"\(L.id)\""}, ""][0]
	_focusAttr: [if L.focus != "" {" data-cur=\"{\(L.focus)}\""}, ""][0]

	markup: "        <a class=\"menu-item\" role=\"menuitem\"\(L._idAttr) data-route=\"\(L.route)\"\(L._focusAttr)>\(L.label)</a>"
}

// aria-checked over two values is _#Binary's chart, the fifth control in this
// gallery to run it. What a menu item adds is the role and the tick; the
// states, the arrow and its narrowing are the generator's.
#MenuCheckItem: I={
	collection: string
	row:        *"the" | string
	field:      *"checked" | string
	// The button's id, and the whole of the narrowing. Kept separate from the
	// row so two items over one row stay two affordances.
	key:   =~"^[a-z0-9_]+$"
	label: string

	_trigger: "mi-\(I.key)"

	// The column saying the caret is here, or "" on a surface with no caret —
	// which is also what says who runs this item's chart. A surface with a caret
	// owns the row every item writes, so the item is markup; without one the
	// item is a region of its own, as it was before any surface had a caret.
	focus: *"" | string
	_focusAttr: [if I.focus != "" {" data-cur=\"{\(I.focus)}\""}, ""][0]
	_own: [if I.focus == "" {"""
		
		                data-live="\(I.collection)" data-filter="id=eq.\(I.row)"
		                data-machine='\((omni.#attrJSON & {in: I.machine}).out)'
		"""}, ""][0]

	_gen: _#Binary & {
		field:   I.field
		initial: "false"
		trigger: I._trigger
		next: {"false": "true", "true": "false"}
		implies: {}
	}
	// The surface runs it: an item that owned a region could not be walked by a
	// caret the surface owns, because a region's members are its own.
	machine: _gen.machine

	// The tick is aria-hidden: aria-checked already carries the fact, and a
	// glyph inside the item would otherwise join its accessible name.
	markup: """
		        <button type="button" class="menu-item menu-check" role="menuitemcheckbox"
		                id="\(I._trigger)" aria-checked="{\(I.field)}"\(I._own)\(I._focusAttr)><span class="menu-tick" aria-hidden="true"></span>\(I.label)</button>
		"""
}

// #OneOf's chart under menuitemradio — the same arrows the radio group and the
// segmented control run, and the same one-checked promise: the field holds
// exactly one state name and the derived columns move together as one row.
//
// The region IS the group, so the heading this wrapper carries is the same
// aria-hidden node #MenuGroup's is; the two cannot share a definition because
// only this one has a machine to host.
#MenuRadioGroup: R={
	collection: string
	row:        *"the" | string
	field:      *"choice" | string
	key:        =~"^[a-z0-9_]+$"
	name:       string
	items: [...{name: =~"^[a-z0-9_]+$", label: string}] & [_, _, ...]

	_label: "menu-group-\(R.key)"
	_id: {for i in R.items {(i.name): "mi-\(R.key)-\(i.name)"}}

	// Column per item saying the caret is on it, "" where the surface has none —
	// which is also what says who runs this group's chart, as #MenuCheckItem's
	// does.
	// Set by a surface that walks these items, which is also what says who runs
	// this group's chart. Stated as a flag rather than read off `focus`: a
	// lookup against a default answers the default, not the absence.
	walked: *false | bool
	focus: [string]: string
	_own: [if !R.walked {"""
		
		           data-live="\(R.collection)" data-filter="id=eq.\(R.row)"
		           data-machine='\((omni.#attrJSON & {in: R.machine}).out)'
		"""}, ""][0]
	_focusAttr: {for i in R.items {
		(i.name): [if R.walked {" data-cur=\"{\(R.focus[i.name])}\""}, ""][0]
	}}

	_choice: #OneOf & {
		field:  R.field
		prefix: "chk_"
		names: [for i in R.items {i.name}]
		id: R._id
	}
	// The surface runs it, beside the caret and beside every other item's:
	// a group nested in the surface's region would never hydrate, and one
	// standing outside it could not be walked by a caret the surface owns.
	machine: _choice.machine

	_items: strings.Join([for i in R.items {
		"""
			        <button type="button" class="menu-item menu-radio" role="menuitemradio"
			                id="\(R._id[i.name])" aria-checked="{\(R._choice.col[i.name])}"\(R._focusAttr[i.name])><span class="menu-tick" aria-hidden="true"></span>\(i.label)</button>
			"""
	}], "\n")

	markup: """
		      <div class="menu-group" role="group" aria-labelledby="\(R._label)"\(R._own)>
		        <p class="menu-label" id="\(R._label)" aria-hidden="true">\(R.name)</p>
		\(R._items)
		      </div>
		"""
}

// The surface both containers open. Separators are drawn BETWEEN groups rather
// than declared with them, so no caller can leave one at an edge, where it
// would separate a group from nothing.
_#Surface: S={
	key: =~"^[a-z0-9_]+$"
	groups: [...string] & [_, ...]

	// The row every chart on this surface writes. `role="menu"` is a promise
	// about the keyboard, so a surface states where the caret lives and the
	// items it walks; the region is the surface's own div, which is what lets
	// one caret reach items an item-owned region could never be walked across.
	// A surface with items walks them; one without is markup, and the two are
	// distinguished by whether the caller states any. Every surface wants the
	// caret — `role="menu"` promises it — and the ones still without say so in
	// decision-29 rather than here.
	// The id is the caller's, not derived here: each item kind already spells
	// its own, and a second spelling would be an id that agreed by luck.
	items: [...{name: =~"^[a-z0-9_]+$", label: string, id: string}] | *[]
	collection: *"" | string
	row:        *"the" | string
	// Charts the items contribute, run beside the caret's over disjoint columns
	// of the one row.
	itemCharts: [...] | *[]
	// Whether the surface is the region. A container that is already one — the
	// context menu, whose own chart holds where the surface stands — runs the
	// caret beside its own instead: a region nested in a singleton never
	// hydrates, so a second one here would be a caret that never mounted.
	owns: *true | bool

	_id:      "menu-\(S.key)"
	_trigger: "menu-\(S.key)-trigger"
	_itemId: {for i in S.items {(i.name): i.id}}

	if len(S.items) > 0 {
		// One chart, because typeahead moves the caret and the caret is what it
		// moves: the letters land in this chart's buffer and draw this chart's
		// arrows. A chart of its own would write another's columns, which is
		// the one thing parallel charts may not do.
		_caret: #OneOf & {
			field:     "caret"
			prefix:    "cur_"
			walk:      true
			typeahead: true
			clicks:    false
			axis:      "vertical"
			names: [for i in S.items {i.name}]
			label: {for i in S.items {(i.name): i.label}}
			id: S._itemId
		}

		charts: list.Concat([[S._caret.machine], S.itemCharts])

		if S.owns {
			_region: """
				
				         data-live="\(S.collection)" data-filter="id=eq.\(S.row)"
				         data-machine='\((omni.#attrJSON & {in: S.charts}).out)'
				"""
		}
		if !S.owns {
			_region: ""
		}
	}
	if len(S.items) == 0 {
		charts: []
		_region: ""
	}

	// The column each item binds to say the caret is on it.
	focus: {for i in S.items {(i.name): "cur_\(i.name)"}}

	markup: """
		    <div class="menu-surface" id="\(S._id)" popover role="menu"
		         aria-labelledby="\(S._trigger)"\(S._region)>
		\(strings.Join(S.groups, "\n      <div role=\"separator\"></div>\n"))
		    </div>
		"""
}

// aria-expanded is written nowhere: the UA supplies it for a popover invoker,
// and a second spelling of it would be a fact the browser already states.
#DropdownMenu: D={
	key:   =~"^[a-z0-9_]+$"
	label: string
	groups: [...string] & [_, ...]
	collection: *"" | string
	row:        *"the" | string
	items: [...{name: string, label: string, id: string}] | *[]
	itemCharts: [...] | *[]

	_surface: _#Surface & {
		key:        D.key
		groups:     D.groups
		collection: D.collection
		row:        D.row
		items:      D.items
		itemCharts: D.itemCharts
	}

	markup: """
		<omnishell--dropdown-menu>
		  <div class="menu">
		    <button type="button" class="menu-trigger" id="\(D._surface._trigger)"
		            commandfor="\(D._surface._id)" command="toggle-popover"
		            aria-haspopup="menu">\(D.label)</button>
		\(D._surface.markup)
		  </div>
		</omnishell--dropdown-menu>
		"""
}

// The surfaces stand OUTSIDE the bar: role="menubar" admits the same children
// role="menu" does, so a menu sitting beside its trigger would put a node in
// the bar that belongs in no menubar. They are in the top layer when open and
// placed by anchor-name against the trigger's id, so where they sit in the
// document costs nothing.
//
// APG gives a menubar ONE tab stop and moves it with the arrows, and this bar
// has it: the triggers are a set, the caret is data-rove because a menubar is a
// pattern the standard hands a single tab stop, and the arrows are horizontal
// because a bar runs across. The surfaces it opens each keep their own caret,
// which is vertical and theirs.
#Menubar: M={
	// Optional: a bar standing inside a <nav> that already carries the name
	// would hand a reader the same string twice, once per node.
	label?: string
	menus: [...{
		key: =~"^[a-z0-9_]+$"
		label: string
		groups: [...string] & [_, ...]
		// The surface's own row and items, as the dropdown's are.
		collection: *"" | string
		row:        *"the" | string
		items: [...{name: string, label: string, id: string}] | *[]
		itemCharts: [...] | *[]
	}] & [_, _, ...]

	// The bar's own row, holding where its tab stop is. Empty leaves the bar as
	// it was: one tab stop per trigger and no chart.
	collection: *"" | string
	row:        *"bar" | string

	_labelAttr: string
	if M.label != _|_ {_labelAttr: " aria-label=\"\(M.label)\""}
	if M.label == _|_ {_labelAttr: ""}

	_surfaces: [for m in M.menus {_#Surface & {
		key:        m.key
		groups:     m.groups
		collection: m.collection
		row:        m.row
		items:      m.items
		itemCharts: m.itemCharts
	}}]

	if M.collection != "" {
		_bar: #OneOf & {
			field:  "caret"
			prefix: "cur_"
			walk:   true
			roving: true
			clicks: false
			axis:   "horizontal"
			names: [for m in M.menus {m.key}]
			id: {for i, m in M.menus {(m.key): M._surfaces[i]._trigger}}
		}
		_barRegion: """
			
			         data-live="\(M.collection)" data-filter="id=eq.\(M.row)"
			         data-machine='\((omni.#attrJSON & {in: [M._bar.machine]}).out)'
			"""
		_barStop: {for m in M.menus {(m.key): " tabindex=\"{\(M._bar.tab[m.key])}\""}}
	}
	if M.collection == "" {
		_barRegion: ""
		_barStop: {for m in M.menus {(m.key): ""}}
	}

	_triggers: strings.Join([for i, m in M.menus {
		"""
			      <button type="button" class="menu-trigger menubar-trigger" role="menuitem"
			              id="\(M._surfaces[i]._trigger)"\(M._barStop[m.key])
			              commandfor="\(M._surfaces[i]._id)" command="toggle-popover"
			              aria-haspopup="menu">\(m.label)</button>
			"""
	}], "\n")

	markup: """
		<omnishell--menubar>
		  <div class="menubar-wrap">
		    <div class="menubar" role="menubar"\(M._labelAttr)\(M._barRegion)>
		\(M._triggers)
		    </div>
		\(strings.Join([for s in M._surfaces {s.markup}], "\n"))
		  </div>
		</omnishell--menubar>
		"""
}

// omnishell--context-menu: the same `_#Surface`, opened by a right-click.
//
// Two things it needs that no other menu does, and both are the terminal's.
// `contextmenu` is a DISPLACING type — the UA opens its own menu on it — so an
// arrow answering it has its default cancelled, and the reader sees one menu
// rather than two.
//
// The point is the affordance's own, not the viewport's: `pointerX`/`pointerY`
// are fractions of the target's box, and CSS multiplies them back out against
// the anchor. Nothing on the screen holds a pixel, so nothing has to know how
// large the window was when the reader clicked.
#ContextMenu: C={
	collection: string
	row:        *"the" | string
	field:      *"open" | string
	key:        =~"^[a-z0-9_]+$"
	// What the target says to a reader who can see it, and what the SURFACE is
	// called: an invoker's own words name the button, never the menu it opens,
	// so a menu whose trigger is a whole panel needs a name of its own.
	label: string
	name:  string
	groups: [...string] & [_, ...]

	// Items in document order, for the caret. Empty leaves the surface as it
	// was: every item its own tab stop and no walk.
	items: [...{name: =~"^[a-z0-9_]+$", label: string, id: string}] | *[]

	_surface: _#Surface & {key: C.key, groups: C.groups}
	_target:  "\(C._surface._id)-target"

	// This component IS the region — its chart holds whether the surface stands
	// and where — so the caret runs beside that chart rather than in a region of
	// its own, which nested inside a singleton would never hydrate.
	if len(C.items) > 0 {
		_caret: #OneOf & {
			field:     "caret"
			prefix:    "cur_"
			walk:      true
			typeahead: true
			clicks:    false
			axis:      "vertical"
			names: [for i in C.items {i.name}]
			label: {for i in C.items {(i.name): i.label}}
			id: {for i in C.items {(i.name): i.id}}
		}
		_charts: [C.machine, C._caret.machine]
	}
	if len(C.items) == 0 {
		_charts: [C.machine]
	}

	// One arrow per state, narrowed to the target: a right-click while the menu
	// stands moves it to the new point rather than being ignored, which is what
	// every desktop menu does. The close arrow is the UA's — an auto popover
	// light-dismisses and answers Escape, and a second spelling of a dismissal
	// the element already performs is one fact stated twice.
	_open: {
		target: "true"
		assign: {
			x: {type: "event", params: field: "pointerX"}
			y: {type: "event", params: field: "pointerY"}
		}
	}

	machine: {
		field:   C.field
		initial: "false"
		context: {x: 0, y: 0}
		states: {
			"false": on: "contextmenu@\(C._target)": [C._open]
			"true": on: "contextmenu@\(C._target)":  [C._open]
		}
	}

	markup: """
		<omnishell--context-menu>
		  <div class="ctx" data-live="\(C.collection)" data-filter="id=eq.\(C.row)"
		       data-machine='\((omni.#attrJSON & {in: C._charts}).out)'>
		    <div class="ctx-target" id="\(C._target)" tabindex="0">\(C.label)</div>
		    <div class="menu-surface ctx-surface" id="\(C._surface._id)" popover role="menu"
		         aria-label="\(C.name)"
		         style="--ctx-x: {x}; --ctx-y: {y}">
		\(strings.Join(C.groups, "\n      <div role=\"separator\"></div>\n"))
		    </div>
		  </div>
		</omnishell--context-menu>
		"""
}
