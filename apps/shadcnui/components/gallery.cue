// The gallery's CUE-authored screens: each demo screen composes a component's
// markup with the two panes the brief demands beside every component — the
// live row (the state IS a row, watch it move) and the machine JSON (valid
// XState config; paste it into a statechart visualizer). Assembly screens
// with no component in them (the catalog) stay authored files.
package components

import (
	"list"
	"encoding/json"

	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

// The way back, on every screen but the catalog: the strip carries the catalog
// alone, so the terminal draws none (decision-28) and this is the whole of a
// reader's navigation out of a demo.
//
// The 24px box is the arrow's rather than the stylesheet's. shell/shared/chrome.css
// reaches a screen through the @import at the top of that screen's own sheet,
// which is a request of its own: for the round trip before it lands the link is
// a 16px line box, and a target size a screen guarantees cannot be one that
// arrives late. So the arrow is a 24x24 element carrying a small glyph, and
// chrome.css restates no length.
_wayBack: """
	    <a class="up" data-route="catalog"><svg class="up-arrow" width="24" height="24"
	       viewBox="0 0 24 24" aria-hidden="true"><path d="M13.5 7.5 9 12l4.5 4.5"
	       fill="none" stroke="currentColor" stroke-width="1.75"
	       stroke-linecap="round" stroke-linejoin="round"/></svg>Components</a>
	"""

// Two instances over one collection. #Switch's markup carries no id, so the
// row in its filter is the whole of an instance's identity — which is what the
// pair demonstrates and what tests/screens.test.ts holds to.
_switch: #Switch & {collection: "switch_demo", label: "Airplane mode"}
_wifi:   #Switch & {collection: "switch_demo", row: "wifi", label: "Wi-Fi"}

switchScreen: markup: """
	<section class="screen screen-switch" data-screen="switch">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Switch</h1>
	    <p class="lede">A two-state machine wearing its ARIA contract. Zero
	    JavaScript ships with this screen: the behavior below is the data in its
	    <code>data-machine</code> attribute, executed by the terminal.</p>
	  </header>
	  <div class="demo-stage">
	\(_switch.markup)
	\(_wifi.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">Each switch's state is a row in the tab-tier
	    <code>switch_demo</code> collection — no second store of truth. Both
	    switches carry the same machine and the same collection; the id their
	    filters pin is the only thing telling them apart.</p>
	    <div class="rowview" data-live="switch_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","checked":"false"}'>
	      <code class="row-readout" data-text="id: {id} · checked: {checked}">id: the · checked: false</code>
	    </div>
	    <div class="rowview" data-live="switch_demo" data-filter="id=eq.wifi"
	         data-empty-row='{"id":"wifi","checked":"false"}'>
	      <code class="row-readout" data-text="id: {id} · checked: {checked}">id: wifi · checked: false</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">The whole behavior, as the data it is. This is
	    valid XState config — the subset with one action: write the target state
	    into the field.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_switch.machine), "", "  "))</pre>
	  </section>
	</section>
	"""

_tabs: #Tabs & {
	collection: "tabs_demo"
	label:      "Account settings"
	tabs: [
		{name: "account", label: "Account", body: "Change your display name here. At the tab tier this row dies with the visit."},
		{name: "password", label: "Password", body: "Change your password here. The active tab is one field of one row."},
	]
}

tabsScreen: markup: """
	<section class="screen screen-tabs" data-screen="tabs">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Tabs</h1>
	    <p class="lede">N triggers, one machine. Each trigger's transition is the
	    component-generated <code>click@trigger-&lt;name&gt;</code> spelling — a
	    grammar no author writes — and the panels project off the root's
	    <code>data-state</code>, exactly Radix's contract.</p>
	  </header>
	  <div class="demo-stage">
	\(_tabs.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">The active tab and each trigger's
	    <code>aria-selected</code> are columns of one tab-tier row.</p>
	    <div class="rowview" data-live="tabs_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","active":"account","sel_account":"true","sel_password":"false"}'>
	      <code class="row-readout" data-text="active: {active} · account: {sel_account} · password: {sel_password}">active: account · account: true · password: false</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">Every arrow generated, every assign a literal —
	    valid XState config with guards nowhere in sight.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_tabs.machine), "", "  "))</pre>
	  </section>
	</section>
	"""

_picker: omni.#Picker & {
	collection: "picker_demo"
	label:      "Favourite fruit"
	options: [
		{name: "apple", label: "Apple"},
		{name: "banana", label: "Banana"},
		{name: "cherry", label: "Cherry"},
	]
}

pickerScreen: markup: """
	<section class="screen screen-picker" data-screen="picker">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Picker</h1>
	    <p class="lede">Selection is a machine; openness is the platform's. The
	    listbox is a <code>popover</code> the trigger commands — light dismiss,
	    top layer and the invoker's expanded state are browser primitives, so
	    the open/close half ships zero markup beyond two attributes.</p>
	  </header>
	  <div class="demo-stage">
	\(_picker.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">The choice, its readout label and every option's
	    <code>aria-selected</code> are columns of one tab-tier row.</p>
	    <div class="rowview" data-live="picker_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","choice":"apple","label":"Apple","sel_apple":"true","sel_banana":"false","sel_cherry":"false"}'>
	      <code class="row-readout" data-text="choice: {choice} · label: {label}">choice: apple · label: Apple</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">Six generated arrows, every assign a literal —
	    the option list is the state set.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_picker.machine), "", "  "))</pre>
	  </section>
	</section>
	"""

_toggleGroup: #ToggleGroup & {
	collection: "toggle_group_demo"
	key:        "align"
	label:      "Text alignment"
	items: [
		{name: "left", label: "Left"},
		{name: "center", label: "Center"},
		{name: "right", label: "Right"},
	]
}

toggleGroupScreen: markup: """
	<section class="screen screen-toggle-group" data-screen="toggle-group">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Toggle group</h1>
	    <p class="lede">Tabs' machine, a different contract. The states, the
	    arrows and the literal assigns are the tabs generator verbatim; what
	    changed is the ARIA, and the panels are gone. It is a
	    <code>radiogroup</code> rather than a bag of pressed buttons because the
	    machine's field holds one state name, so the choice is single-valued,
	    and every arrow's literal assigns write all three
	    <code>aria-checked</code> columns together — which is what leaves no
	    transition able to check two members, or none. The sample it aligns is a
	    region of its own, reading the same row: this component projects
	    nothing.</p>
	  </header>
	  <div class="demo-stage">
	\(_toggleGroup.markup)
	    <div class="tg-preview" data-live="toggle_group_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","value":"left","chk_left":"true","chk_center":"false","chk_right":"false"}'
	         data-state="{value}">
	      <p class="tg-sample">The quick brown fox jumps over the lazy dog.</p>
	    </div>
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">The chosen value and one <code>aria-checked</code>
	    column per option are columns of one tab-tier row. The prefix names the
	    attribute the column binds — <code>chk_</code> here, <code>sel_</code>
	    in tabs — because where N triggers share one field, the field cannot
	    itself be the ARIA value.</p>
	    <div class="rowview" data-live="toggle_group_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","value":"left","chk_left":"true","chk_center":"false","chk_right":"false"}'>
	      <code class="row-readout" data-text="value: {value} · left: {chk_left} · center: {chk_center} · right: {chk_right}">value: left · left: true · center: false · right: false</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">Six generated arrows, every assign a literal, and
	    no arrow from a state to itself — which is why clicking the checked
	    option writes nothing.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_toggleGroup.machine), "", "  "))</pre>
	  </section>
	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">Tab reaches every option and Space or Enter checks
	    the focused one — native button behaviour, so activation is complete.
	    APG's radiogroup also asks for arrow keys moving a roving tabstop, and
	    that lands with the region-projection work, as it does for tabs. Until
	    it does the component emits no <code>tabindex</code> at all: a roving
	    tabstop without the arrows that move it would strand every unchecked
	    option outside the tab order, which is a worse failure than the one it
	    fixes. The deviation that ships is discoverability, never
	    reachability.</p>
	  </section>
	</section>
	"""

_accordionSingle: #Accordion & {
	collection: "accordion_single_demo"
	key:        "faq"
	type:       "single"
	label:      "Shipping FAQ"
	items: [
		{name: "shipping", label: "How fast is shipping?", body: "Orders leave the same day. Which answer is open is one column of one row — not a flag on this element."},
		{name: "returns", label: "What is the return window?", body: "Thirty days, unworn. Opening this closed the one above, because the arrow that landed here also wrote every other trigger's aria-expanded."},
		{name: "support", label: "How do I reach support?", body: "Reply to any order mail. Clicking this header again returns the group to none — the self-arrow a single-select accordion needs and a tablist must not have."},
	]
}

_accordionMulti: #Accordion & {
	collection: "accordion_multi_demo"
	key:        "notes"
	type:       "multiple"
	label:      "Release notes"
	items: [
		{name: "shipping", label: "Shipping", body: "Its own region, its own row, its own machine. Opening this one leaves the other two rows untouched — and unminted, until they are opened themselves."},
		{name: "returns", label: "Returns", body: "Two states, two arrows, no context: the field is aria-expanded's value, so there is no derived column to keep in step with it."},
		{name: "support", label: "Support", body: "Clicking inside an open panel writes nothing. Every arrow is narrowed to its trigger's id, and the panel's own id matches none of them."},
	]
}

accordionScreen: markup: """
	<section class="screen screen-accordion" data-screen="accordion">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Accordion</h1>
	    <p class="lede">A machine binds exactly one row, so multiplicity is the
	    region's. One definition ships at both of shadcn's arities: one machine
	    over one row whose states are the item names plus a closed
	    <code>none</code>, or one machine per row across N sibling regions.
	    Nothing in the vocabulary changed between them.</p>
	  </header>

	  <section class="demo-arm">
	    <h2>One at a time — <code>type="single"</code></h2>
	    <p class="arm-note">Four states over three items, twelve generated
	    arrows, and one <code>exp_</code> column per trigger moved by literal
	    assigns. This is the tabs shape plus the self-arrow tabs must not have:
	    the open item's own trigger targets <code>none</code>.</p>
	    <div class="demo-stage">
	\(_accordionSingle.markup)
	    </div>
	    <section class="demo-pane">
	      <h3>The row</h3>
	      <p class="pane-note">One row of 2+2N columns: which item is open and
	      every trigger's <code>aria-expanded</code>.</p>
	      <div class="rowview" data-live="accordion_single_demo" data-filter="id=eq.the"
	           data-empty-row='{"id":"the","open":"none","exp_shipping":"false","exp_returns":"false","exp_support":"false","caret":"shipping","cur_shipping":"true","cur_returns":"false","cur_support":"false"}'>
	        <code class="row-readout" data-text="open: {open} · shipping: {exp_shipping} · returns: {exp_returns} · support: {exp_support}">open: none · shipping: false · returns: false · support: false</code>
	      </div>
	    </section>
	    <section class="demo-pane">
	      <h3>The machine</h3>
	      <p class="pane-note">Every arrow drawn, every assign a literal. A
	      fourth item costs three more arrows and one more column, and no
	      stylesheet at all.</p>
	      <pre class="machine-json">\(json.Indent(json.Marshal(_accordionSingle._expansion), "", "  "))</pre>
	    </section>
	  </section>

	  <section class="demo-arm">
	    <h2>Independent — <code>type="multiple"</code></h2>
	    <p class="arm-note">Three sibling singleton regions on one collection,
	    each pinning <code>id=eq.&lt;item&gt;</code>, each carrying the switch's
	    two-state machine with its field renamed and its event narrowed. No
	    context, no derived column: the field is what
	    <code>aria-expanded</code> binds.</p>
	    <div class="demo-stage">
	\(_accordionMulti.markup)
	    </div>
	    <section class="demo-pane">
	      <h3>The rows</h3>
	      <p class="pane-note">Three rows of two columns, one readout each —
	      the pane's shape is the component's, region for region. A row appears
	      only once its own machine has written it.</p>
	      <div class="rowview" data-live="accordion_multi_demo" data-filter="id=eq.shipping"
	           data-empty-row='{"id":"shipping","open":"false"}'>
	        <code class="row-readout" data-text="id: {id} · open: {open}">id: shipping · open: false</code>
	      </div>
	      <div class="rowview" data-live="accordion_multi_demo" data-filter="id=eq.returns"
	           data-empty-row='{"id":"returns","open":"false"}'>
	        <code class="row-readout" data-text="id: {id} · open: {open}">id: returns · open: false</code>
	      </div>
	      <div class="rowview" data-live="accordion_multi_demo" data-filter="id=eq.support"
	           data-empty-row='{"id":"support","open":"false"}'>
	        <code class="row-readout" data-text="id: {id} · open: {open}">id: support · open: false</code>
	      </div>
	    </section>
	    <section class="demo-pane">
	      <h3>The machine</h3>
	      <p class="pane-note">Shipping's. The other two are this machine with
	      their own trigger id — a machine is data, so it is copied per region,
	      not instantiated.</p>
	      <pre class="machine-json">\(json.Indent(json.Marshal(_accordionMulti.machines.shipping), "", "  "))</pre>
	    </section>
	  </section>

	  <section class="demo-pane demo-arity">
	    <h2>The arity</h2>
	    <p class="pane-note">The same component definition twice. What differs
	    is how many rows there are and how many regions read them.</p>
	    <div class="arity-scroll">
	      <table class="arity">
	        <tr><th scope="col">·</th><th scope="col">single</th><th scope="col">multiple</th></tr>
	        <tr><th scope="row">regions</th><td>1</td><td>3</td></tr>
	        <tr><th scope="row">rows</th><td>1</td><td>3</td></tr>
	        <tr><th scope="row">states per machine</th><td>4 — the items plus none</td><td>2</td></tr>
	        <tr><th scope="row">arrows per machine</th><td>12</td><td>2</td></tr>
	        <tr><th scope="row">derived ARIA columns</th><td>3 — one per trigger</td><td>0 — the field is the value</td></tr>
	        <tr><th scope="row">group state</th><td>data-state on the region</td><td>none — there is no group row</td></tr>
	      </table>
	    </div>
	  </section>

	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">Tab reaches every trigger in document order, and
	    an open panel's content after it; Space or Enter opens the focused
	    header — native button behaviour, so APG's required contract is
	    complete at both arities. The pattern's optional keys are absent: Up
	    and Down between headers, Home and End, and Ctrl+PageUp and
	    Ctrl+PageDown. No partial roving tabindex ships in their place, because
	    a <code>tabindex="-1"</code> without the arrows that move the tabstop
	    would strand a trigger outside the tab order.</p>
	  </section>
	</section>
	"""

_dialogModal: #Dialog & {
	key:         "modal"
	trigger:     "Open the modal"
	title:       "What the browser already does"
	description: "Everything below arrived with the element. None of it is in a chart, a column or a handler."
	body: """
		      <ul class="dialog-list">
		        <li>The top layer, with no z-index anywhere on the screen.</li>
		        <li>The rest of the document inert — which is also the focus trap.</li>
		        <li>Esc, as a close request the element performs.</li>
		        <li>Focus in on open, and back to the trigger on close.</li>
		      </ul>
		"""
}

_dialogInline: #Dialog & {
	key:         "inline"
	trigger:     "Open the non-modal"
	title:       "The same content, not modal"
	description: "The page behind stays live, and a click on it dismisses this."
	modal:       false
	body: """
		      <ul class="dialog-list">
		        <li>Light dismiss: a click outside closes it, free.</li>
		        <li>The background is not inert, so Tab walks out of here.</li>
		        <li>Placement is anchor-name and position-area, in CSS.</li>
		      </ul>
		"""
}

_tip: #Tooltip & {
	key:   "tier"
	label: "What is tier 0?"
	text:  "A component with no state the platform does not already hold — so it earns no machine, and no row."
}

_hoverTip: #HoverTip & {
	key:   "aria"
	label: "aria-describedby"
	text:  "Announced when the trigger takes focus, which is the same gesture that shows it — right here, and wrong on the disclosure beside it."
}

overlaysScreen: markup: """
	<section class="screen screen-overlays" data-screen="overlays">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Dialog · Tooltip</h1>
	    <p class="lede">Two components and no machine between them. Dismissal, the
	    top layer, the inert background, Esc and placement became browser
	    primitives, so what is left of shadcn's Dialog and Tooltip is the markup
	    that earns them. This screen reads no row and runs no chart; the two
	    closing panes say why instead of printing an empty box.</p>
	  </header>
	  <h2 class="stage-name">Dialog</h2>
	  <div class="demo-stage">
	\(_dialogModal.markup)
	\(_dialogInline.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The two surfaces</h2>
	    <p class="pane-note">One definition, two surfaces, and neither contains
	    the other. Modal buys the inert background and loses backdrop light
	    dismiss; non-modal buys light dismiss and loses the inert background.
	    <code>closedby</code> would give the modal the missing half — it is
	    outside the engine matrix this tree measured, so nothing here depends on
	    it.</p>
	    <div class="matrix-wrap">
	      <table class="matrix">
	        <thead><tr><th scope="col">behaviour</th><th scope="col">modal &lt;dialog&gt;</th><th scope="col">non-modal popover</th></tr></thead>
	        <tbody>
	          <tr><th scope="row">top layer</th><td>yes</td><td>yes</td></tr>
	          <tr><th scope="row">background inert</th><td>yes</td><td class="no">no</td></tr>
	          <tr><th scope="row">focus contained</th><td>yes</td><td class="no">no — Tab walks out</td></tr>
	          <tr><th scope="row">light dismiss outside</th><td class="no">no — waits on closedby</td><td>yes</td></tr>
	          <tr><th scope="row">Esc closes</th><td>yes</td><td>yes</td></tr>
	          <tr><th scope="row">focus back to the trigger</th><td>yes</td><td>yes</td></tr>
	          <tr><th scope="row">the trigger's aria-expanded</th><td class="no">none to supply</td><td>the UA writes it</td></tr>
	        </tbody>
	      </table>
	    </div>
	  </section>
	  <h2 class="stage-name">Tooltip</h2>
	  <div class="demo-stage">
	\(_tip.markup)
	\(_hoverTip.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>What the platform withholds</h2>
	    <p class="pane-note">The measurement this gallery declines to work
	    around, from the tree's own engine matrix, taken 2026-08-03.</p>
	    <div class="matrix-wrap">
	      <table class="matrix">
	        <thead><tr><th scope="col">primitive</th><th scope="col">Chromium 147.0.7727.15</th><th scope="col">Firefox 148.0.2</th><th scope="col">WebKit 26.4</th></tr></thead>
	        <tbody>
	          <tr><th scope="row">popover · commandfor</th><td>yes</td><td>yes</td><td>yes</td></tr>
	          <tr><th scope="row">anchor-name · position-area</th><td>yes</td><td>yes</td><td>yes</td></tr>
	          <tr><th scope="row">interestfor</th><td class="no">no</td><td class="no">no</td><td class="no">no</td></tr>
	        </tbody>
	      </table>
	    </div>
	    <p class="pane-note">APG's tooltip opens on hover or focus, never takes
	    focus, and is named to its trigger by <code>aria-describedby</code>.
	    Opening one on hover with no script at all needs
	    <code>interestfor</code>, and the row above is why that is still a
	    <em>no</em>. Both surfaces ship anyway, and the two are different
	    components rather than one with a switch — what opens a surface decides
	    its ARIA, so the difference goes all the way down.</p>
	    <p class="pane-note">A click-opened popover is complete: light dismiss,
	    top layer, Esc, focus back to the trigger, and an
	    <code>aria-expanded</code> the UA writes — zero script for all of it. It
	    is APG's disclosure, not APG's tooltip, so the surface above carries no
	    <code>role="tooltip"</code> and no <code>aria-describedby</code>:
	    <code>aria-describedby</code> would read the tip's text out on every
	    focus of the trigger, open or closed, which is the announcement a
	    disclosure exists to defer. That is what ships, and it ships under the
	    name tip.</p>
	    <p class="pane-note">The second surface is the real tooltip, and it is
	    the one this wave paid for. <code>popovertarget</code> names the surface
	    a trigger opens; native popovers handle light dismiss and Escape with
	    no JavaScript.</p>
	    <p class="pane-note">Three things keep it from being a script with a
	    declaration in front of it. The waits are the terminal's clock, so
	    <code>?tempo=</code> and <code>?clock=manual</code> govern them like every
	    other delay the platform performs — a hover delay on a timer of its own
	    would be nondeterminism no replay could hold still. The surface is
	    <code>popover="auto"</code>, so 1.4.13's <em>Dismissable</em> clause is
	    the element's: light dismiss and Escape are the UA's and this code never
	    listens for a key. And it holds no state, which is the licence — a
	    surface no row decides cannot disagree with one, so nothing reaches the
	    store, nothing is journalled, and the pane below still counts zero.</p>
	    <p class="pane-note">The route that stays refused is the CSS-only hover
	    surface. It wears the tooltip's ARIA correctly and fails 1.4.13 by
	    construction — <em>Dismissable</em> wants Esc without moving pointer or
	    focus, and CSS has no Esc — and it sits outside the top layer, since a
	    popover opens only through an invoker or a call. This gallery does not
	    render it: a reference that paints a known AA failure gets the failure
	    copied.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">Every other screen here puts the live row in this
	    pane. This one has none, and the absence is checked rather than
	    asserted.</p>
	    <code class="absence">data-live: 0 · data-filter: 0 · data-empty-row: 0 · data-machine: 0</code>
	    <p class="pane-note">Nothing on this screen survives the click that made
	    it: openness dies with the dismissal that ends it. A dialog whose closing
	    carried an outcome would need a field, and a field is the next rung — not
	    this one.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">None. Printed here instead, as the same kind of data
	    the other screens print their charts as: the states these components
	    would have held, and what holds each one already.</p>
	    <div class="matrix-wrap">
	      <table class="matrix">
	        <thead><tr><th scope="col">the state it would hold</th><th scope="col">who holds it</th><th scope="col">the spelling</th></tr></thead>
	        <tbody>
	          <tr><th scope="row">open · closed</th><td>the browser</td><td>commandfor, with command show-modal and command close</td></tr>
	          <tr><th scope="row">background inert</th><td>the browser</td><td>a modal showing puts the rest of the document inert</td></tr>
	          <tr><th scope="row">focus contained</th><td>the browser</td><td>there is nowhere outside left to Tab to</td></tr>
	          <tr><th scope="row">close request</th><td>the browser</td><td>Esc fires cancel, then close</td></tr>
	          <tr><th scope="row">focus returned</th><td>the browser</td><td>the invoker gets it back</td></tr>
	          <tr><th scope="row">placement</th><td>CSS</td><td>anchor-name, position-anchor, position-area</td></tr>
	          <tr><th scope="row">the outcome</th><td class="no">nobody, here</td><td>a dialog's returnValue reaches no row; an outcome becomes one only through a machine arrow or a form submit, and this screen ships neither</td></tr>
	        </tbody>
	      </table>
	    </div>
	  </section>
	</section>
	"""

_badgeDefault:     #Badge & {variant: "default", label: "Default"}
_badgeSecondary:   #Badge & {variant: "secondary", label: "Secondary"}
_badgeDestructive: #Badge & {variant: "destructive", label: "Destructive"}
_badgeOutline:     #Badge & {variant: "outline", label: "Outline"}

_badgeDefaultIcon:     #Badge & {variant: "default", label: "Default", icon: icons.tick}
_badgeSecondaryIcon:   #Badge & {variant: "secondary", label: "Secondary", icon: icons.dot}
_badgeDestructiveIcon: #Badge & {variant: "destructive", label: "Destructive", icon: icons.warn}
_badgeOutlineIcon:     #Badge & {variant: "outline", label: "Outline", icon: icons.info}

_cardWithAction: #Card & {
	key:         "tier"
	title:       "Tab tier"
	description: "State that dies with the visit."
	action:      (#Badge & {variant: "outline", label: "no table"}).markup
	body:        "<p>No migration, no policy, no publication. The ladder's first rung is demonstrated on the other screens by rows dying with the tab, not documented.</p>"
	footer:      ##"<a class="card-link" data-route="switch">Watch a tab-tier row move</a>"##
}

_cardWithoutAction: #Card & {
	key:         "header"
	title:       "A header with no action"
	description: "The slot most reimplementations drop."
	body:        "<p>The action slot is what makes the header a grid rather than a stack. Without one the grid stays a single column, and the promotion is a real <code>:has()</code> rule rather than a variant class.</p>"
}

_alertStatic: #Alert & {
	variant:     "default"
	live:        "none"
	title:       "Heads up"
	description: "This callout is on the screen when it paints. Nothing changed, so nothing was announced, and it carries no role at all — a reader finds it through its heading."
	icon:        icons.info
}

_alertPolite: #Alert & {
	variant:     "default"
	live:        "polite"
	title:       "Draft saved"
	description: "Something changed after load and it can wait its turn, so the region is polite: the reader hears it when the current utterance ends."
	icon:        icons.check
}

_alertAssertive: #Alert & {
	variant:     "destructive"
	live:        "assertive"
	title:       "Connection lost"
	description: "Something changed after load and cannot wait, so the region interrupts. This is the case shadcn's hard-coded role is right for."
	icon:        icons.warn
}

primitivesScreen: markup: """
	<section class="screen screen-primitives" data-screen="primitives">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Badge · Card · Alert</h1>
	    <p class="lede">Three components with no behavior at all: no machine, no
	    row, no state. What they prove is the claim underneath every other
	    screen — shadcn's palette landed on the token contract without a new
	    token name, and dark is each token's <code>light-dark()</code> twin
	    rather than a <code>.dark</code> fork. Every variant below is that map
	    applied, and there is not one literal colour on this screen.</p>
	  </header>

	  <section class="demo-part">
	    <h2>Badge</h2>
	    <p class="pane-note">Four variants, and the whole component is one span
	    and four token pairs. The second row is the same four with a leading
	    icon, which is decoration: the variant's meaning is in its text, never
	    in the icon or the colour.</p>
	    <div class="demo-stage">
	      <div class="badge-row">
	\(_badgeDefault.markup)
	\(_badgeSecondary.markup)
	\(_badgeDestructive.markup)
	\(_badgeOutline.markup)
	      </div>
	      <div class="badge-row">
	\(_badgeDefaultIcon.markup)
	\(_badgeSecondaryIcon.markup)
	\(_badgeDestructiveIcon.markup)
	\(_badgeOutlineIcon.markup)
	      </div>
	    </div>
	  </section>

	  <section class="demo-part">
	    <h2>Card</h2>
	    <p class="pane-note">Every part present on the left — header, title,
	    description, action, content, footer — and the action omitted on the
	    right, so the header's one-column fallback is visible beside its
	    two-column promotion. The title is an <code>h3</code>, not shadcn's
	    <code>div</code>: a card grid of divs leaves the document with no
	    outline. The element is an <code>&lt;article&gt;</code> — a boundary a
	    screen reader announces on entry — so that same heading names it through
	    <code>aria-labelledby</code>; it takes no <code>role="region"</code>,
	    which would promise a landmark a card is not.</p>
	    <div class="demo-stage">
	      <div class="card-grid">
	\(_cardWithAction.markup)
	\(_cardWithoutAction.markup)
	      </div>
	    </div>
	  </section>

	  <section class="demo-part">
	    <h2>Alert</h2>
	    <p class="pane-note">Both visual variants, and all three live-region
	    answers, in three specimens. The rule that bites: a polite region has to
	    be mounted before its content changes, or the only change it reports is
	    its own arrival and nothing is spoken. <code>role="alert"</code> is the
	    exception — NVDA, JAWS and VoiceOver announce an alert inserted with its
	    text already in it — and this terminal injects a screen whole on
	    navigation, so the third specimen speaks on every arrival at this route.
	    That is the cost of demonstrating the role rather than a pattern to
	    copy: an alert belongs on a node that outlives the change it
	    reports.</p>
	    <div class="demo-stage">
	      <ul class="alert-specimens">
	        <li>
	\(_alertStatic.markup)
	          <p class="specimen-note">No role. Correct for a callout present when the screen paints.</p>
	        </li>
	        <li>
	\(_alertPolite.markup)
	          <p class="specimen-note"><code>role="status"</code> — polite. Correct for a change after load that can wait.</p>
	        </li>
	        <li>
	\(_alertAssertive.markup)
	          <p class="specimen-note"><code>role="alert"</code> — assertive. Correct for a change after load that cannot.</p>
	        </li>
	      </ul>
	    </div>
	  </section>

	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">There is none, and the absence is checked rather
	    than merely unmentioned: these three hold no state, so this screen
	    mounts no region and no machine, and the suite asserts the counts.</p>
	    <p class="claim"><code>[data-live]</code> 0 · <code>[data-machine]</code> 0 · handler modules 0</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The tokens</h2>
	    <p class="pane-note">For a component whose entire content is
	    presentation, this table is the machine: the complete statement of what
	    it does, in reviewable data. It names tokens and never values, because
	    each name is already one <code>light-dark()</code> pair and a hex
	    printed here would be the palette's second declaration. Each row carries
	    the selector chain it describes, so the suite folds this screen's
	    stylesheet through it and fails on a cell the rules do not set, a
	    declaration no cell lists, or a variant on the screen with no row.</p>
	    <div class="token-scroll">
	      <table class="token-table">
	        <thead>
	          <tr><th scope="col">part</th><th scope="col">variant</th><th scope="col">background</th><th scope="col">foreground</th><th scope="col">edge</th></tr>
	        </thead>
	        <tbody>
	\(tokenRows)
	        </tbody>
	      </table>
	    </div>
	  </section>
	</section>
	"""

// Public, unlike its siblings: the entity's column constraint is generated
// from the same option list the datalist and the pattern are, and the entity
// lives in program.cue.
combobox: #Combobox & {
	collection: "combobox_demo"
	label:      "Framework"
	form:       "pick-framework"
	options: ["Next.js", "SvelteKit", "Nuxt", "Remix", "Astro"]
	placeholder: "Search framework…"
	hint:        "Type to filter. Picking a suggestion commits it."
	invalid:     "Pick one of the five listed frameworks."
}

// The machine this screen declines, printed where every other screen prints
// the one it runs. Unified with #Machine, so the pane shows a chart the
// vocabulary admits rather than a sketch of one.
_comboboxDeclined: terminal.#Machine & {
	field:   "phase"
	initial: "typing"
	context: choice: ""
	states: typing: on: ("input@\(combobox.key)-input"): {
		assign: choice: {type: "event", params: field: "value"}
	}
}

comboboxScreen: markup: """
	<section class="screen screen-combobox" data-screen="combobox">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Combobox</h1>
	    <p class="lede">Filtering by typed text, handed to the platform:
	    <code>&lt;input list&gt;</code> and a <code>&lt;datalist&gt;</code> are
	    a closed option set the UA maps to <code>role="combobox"</code> and
	    filters as you type, and the form holds no button, so picking a
	    suggestion submits it. Zero JavaScript, a real row — and one wall
	    between this and shadcn's cmdk combobox.
	    <a data-route="command">Command</a> is the other answer: a list a machine's
	    own column filters, where the option set is data rather than
	    literals.</p>
	  </header>
	  <div class="demo-stage">
	\(combobox.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">The pick is a form's write, not a machine's. What
	    lands is the same kind of tab-tier row every other screen shows.</p>
	    <div class="rowview" data-live="\(combobox.collection)" data-filter="id=eq.\(combobox.row)"
	         data-empty-row='\(combobox._emptyRow)'>
	      <code class="row-readout" data-text="id: {id} · choice: {choice}">id: \(combobox.row) · choice: \(combobox.initial)</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The boundary</h2>
	    <p class="pane-note">Where the other screens print the machine they
	    run, this one prints the machine it declines. The chart below vets: the
	    event leaf is the terminal's own, and <a data-route="command">Command</a>
	    runs the same arrow over its own query column, with each option a
	    nested region the typed text filters. Its <code>phase</code> is the
	    constant column a value-carrying chart has to invent, which the
	    <a data-route="slider">slider</a> pays for real.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_comboboxDeclined), "", "  "))</pre>
	    <p class="pane-note">What it costs here is the column. Every keystroke
	    states a row, and <code>choice</code> enumerates the five frameworks —
	    <code class="cel">\(combobox.cel)</code> — so a machine writing it
	    letter by letter states values the column does not admit, and a chart
	    holds no <code>pattern</code> to refuse them: the gate is the control's
	    and it fires on submit. A pick is a commit, and a commit is a form's
	    write.</p>
	    <dl class="walls">
	      <dt>Virtual focus, for THIS control</dt>
	      <dd>Moving the active option means naming it, and there is nothing here
	      to name: the UA owns the popup, so no element in the page is the
	      suggestion and <code>aria-activedescendant</code> has no referent. The
	      wall is the native pair's, not the vocabulary's —
	      <a data-route="command">Command</a> moves a caret through a live-filtered
	      collection with no script and no <code>focus()</code>, off the
	      projection's <code>next</code> and a <code>data-key</code> naming the
	      form each option owns. What that costs is the popup: its options are
	      rows this app draws, where these are the UA's.</dd>
	    </dl>
	    <p class="pane-note">What the native pair costs, printed rather than
	    implied: no custom option markup, no <code>aria-activedescendant</code>
	    to style or to read, no empty state, no exposed
	    <code>aria-expanded</code> — the UA runs the popup's lifecycle and
	    reports none of it, so APG's required property is one nothing on this
	    page can supply — and a suggestion popup the UA draws, one of the two
	    surfaces in this gallery whose dark appearance is not ours, the
	    <a data-route="select">select</a>'s open list being the other. The
	    <a data-route="picker">picker</a> is this control with the filtering taken
	    out, and taking the filtering out is exactly what makes it complete.</p>
	  </section>
	</section>
	"""

_checkboxTerms: #Checkbox & {
	collection: "checkbox_demo"
	row:        "terms"
	label:      "Accept the terms"
}

// Exported: the row this control opens in is the machine's own context, and
// the entity states it as a seed from the same value.
selectAllDemo: #SelectAll & {
	collection: "select_all_demo"
	label:      "Select all"
	items: [
		{name: "docs", label: "Documents", initial: "true"},
		{name: "images", label: "Images", initial: "true"},
		{name: "archive", label: "Archive", initial: "false"},
	]
}

_toggle: #Toggle & {
	collection: "toggle_demo"
	key:        "bold"
	label:      "Bold"
}

_collapsible: #Collapsible & {
	collection: "collapsible_demo"
	key:        "notes"
	label:      "What changed in this release"
	body:       "One state, one row, one attribute. This panel is hidden by a rule keyed on the trigger's own aria-expanded, so nothing here carries a second spelling of open."
}

checkboxScreen: markup: """
	<section class="screen screen-checkbox" data-screen="checkbox">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Checkbox · Toggle · Collapsible</h1>
	    <p class="lede">Three controls, one generator, three attributes. The
	    switch's machine is not a switch: it is the shape every binary control
	    has, and all a component chooses is which ARIA attribute the field
	    spells — <code>aria-checked</code>, <code>aria-pressed</code>,
	    <code>aria-expanded</code>. The checkbox extends the shape by exactly
	    one state, because it spends <code>aria-checked</code>'s third value.
	    <code>aria-pressed</code> has a third too and the toggle below leaves
	    it unspent; only <code>aria-expanded</code> stops at two.</p>
	  </header>

	  <section class="demo-arm">
	    <h2>Checkbox — <code>aria-checked</code></h2>
	    <p class="arm-note">Two definitions, and the second is the first one's
	    limit. The plain checkbox is the switch's chart wearing
	    <code>role="checkbox"</code>. The select-all is the control whose value
	    is a FUNCTION of the three checkboxes under it, which is the one thing a
	    machine's field cannot be — so it stops being a field. What
	    <code>aria-checked</code> binds there is a COLUMN, every click assigns
	    it, and <code>mixed</code> is reachable as often as a reader likes:
	    uncheck one of three and the header says so. Its own click is APG's
	    rule — a partially checked select-all checks everything — and the items
	    take the value it just took.</p>
	    <div class="demo-stage">
	\(_checkboxTerms.markup)
	\(selectAllDemo.markup)
	    </div>
	    <section class="demo-pane">
	      <h3>The rows</h3>
	      <p class="pane-note">Two collections, because the two controls are two
	      shapes: the plain one's <code>checked</code> is its machine's field,
	      and the select-all's is a column beside a field with one value in it.
	      Watch the header's column follow the items — one write, so the two can
	      never be seen disagreeing.</p>
	      <div class="rowview" data-live="checkbox_demo" data-filter="id=eq.terms"
	           data-empty-row='{"id":"terms","checked":"false"}'>
	        <code class="row-readout" data-text="id: {id} · checked: {checked}">id: terms · checked: false</code>
	      </div>
	      <div class="rowview" data-live="select_all_demo" data-filter="id=eq.all"
	           data-empty-row='\(selectAllDemo.emptyRow)'>
	        <code class="row-readout" data-text="checked: {checked} · docs: {inc_docs} · images: {inc_images} · archive: {inc_archive}">checked: mixed · docs: true · images: true · archive: false</code>
	      </div>
	    </section>
	    <section class="demo-pane">
	      <h3>The machines</h3>
	      <p class="pane-note">Two shapes, and the second is the smaller one. Read
	      its <code>states</code> as a graph: one node, four arrows back to it,
	      and no branch anywhere — every one of them assigns, because what the
	      items add up to is a computation. The 2^N states the other reading
	      would have needed are the ones not here.</p>
	      <pre class="machine-json">\(json.Indent(json.Marshal(_checkboxTerms.machine), "", "  "))</pre>
	      <pre class="machine-json">\(json.Indent(json.Marshal(selectAllDemo.machine), "", "  "))</pre>
	    </section>
	  </section>

	  <section class="demo-arm">
	    <h2>Toggle — <code>aria-pressed</code></h2>
	    <p class="arm-note">shadcn's Toggle is a button that stays down, and
	    <code>pressed</code> is what a button's down-ness is called. Same two
	    states, same single narrowed arrow, field renamed: the difference from
	    the plain checkbox above is the attribute and the role, which is the
	    claim the table at the foot makes exact.</p>
	    <div class="demo-stage">
	\(_toggle.markup)
	    </div>
	    <section class="demo-pane">
	      <h3>The row</h3>
	      <p class="pane-note">One field, and it is the attribute's value — no
	      derived column, because one trigger owns one row.</p>
	      <div class="rowview" data-live="toggle_demo" data-filter="id=eq.the"
	           data-empty-row='{"id":"the","pressed":"false"}'>
	        <code class="row-readout" data-text="id: {id} · pressed: {pressed}">id: the · pressed: false</code>
	      </div>
	    </section>
	    <section class="demo-pane">
	      <h3>The machine</h3>
	      <p class="pane-note">The plain checkbox's machine with two strings
	      changed.</p>
	      <pre class="machine-json">\(json.Indent(json.Marshal(_toggle.machine), "", "  "))</pre>
	    </section>
	  </section>

	  <section class="demo-arm">
	    <h2>Collapsible — <code>aria-expanded</code></h2>
	    <p class="arm-note">The accordion's <code>multiple</code> arm with one
	    item, and no pretence otherwise: the same trigger, the same panel
	    projected by a rule keyed on the trigger's own
	    <code>aria-expanded</code>, the same two-state machine narrowed to one
	    id. What a collapsible drops is the item set and the group wrapper, and
	    that is the whole difference.</p>
	    <div class="demo-stage">
	\(_collapsible.markup)
	    </div>
	    <section class="demo-pane">
	      <h3>The row</h3>
	      <p class="pane-note">The panel's visibility is not a column: the rule
	      that hides it reads the trigger's <code>aria-expanded</code>, so open
	      is stated once.</p>
	      <div class="rowview" data-live="collapsible_demo" data-filter="id=eq.the"
	           data-empty-row='{"id":"the","open":"false"}'>
	        <code class="row-readout" data-text="id: {id} · open: {open}">id: the · open: false</code>
	      </div>
	    </section>
	    <section class="demo-pane">
	      <h3>The machine</h3>
	      <p class="pane-note">The toggle's machine with two strings
	      changed.</p>
	      <pre class="machine-json">\(json.Indent(json.Marshal(_collapsible.machine), "", "  "))</pre>
	    </section>
	  </section>

	  <section class="demo-pane demo-shape">
	    <h2>The shape</h2>
	    <p class="pane-note">Five controls across two screens, one chart. What
	    a binary component decides is the attribute its field spells and the
	    role its button wears; its states are values that attribute admits —
	    admits, not exhausts, since <code>aria-pressed</code> speaks
	    <code>mixed</code> and the toggle spends two of its three — and the
	    arrow count follows from the states. The
	    <a data-route="switch">switch</a> is in the table with its difference in
	    it: its region IS its affordance and carries no id, so its arrows keep
	    the bare <code>click</code> where the four generated here are narrowed
	    to a trigger. Erase the field, the trigger and that narrowing and one
	    chart is left across all five, which is what the suite checks.</p>
	    <div class="shape-scroll">
	      <table class="shape">
	        <tr><th scope="col">control</th><th scope="col">role</th><th scope="col">attribute</th><th scope="col">field</th><th scope="col">states</th><th scope="col">arrows</th><th scope="col">event key</th></tr>
	        <tr><th scope="row">switch</th><td>switch</td><td>aria-checked</td><td>checked</td><td>false, true</td><td>2</td><td>click</td></tr>
	        <tr><th scope="row">checkbox</th><td>checkbox</td><td>aria-checked</td><td>checked</td><td>false, true</td><td>2</td><td>click@trigger</td></tr>
	        <tr><th scope="row">checkbox, tri</th><td>checkbox</td><td>aria-checked</td><td>checked</td><td>mixed, true, false</td><td>3</td><td>click@trigger</td></tr>
	        <tr><th scope="row">toggle</th><td>button</td><td>aria-pressed</td><td>pressed</td><td>false, true</td><td>2</td><td>click@trigger</td></tr>
	        <tr><th scope="row">collapsible</th><td>button</td><td>aria-expanded</td><td>open</td><td>false, true</td><td>2</td><td>click@trigger</td></tr>
	      </table>
	    </div>
	  </section>

	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">Nothing is deferred on this screen. A checkbox, a
	    toggle button and a disclosure are all buttons, and Space and Enter
	    press a button, so APG's required contract for all three is complete
	    with no <code>tabindex</code> and no key handling at all. The deferral
	    the rest of the catalog carries — arrow keys moving a roving tabstop —
	    belongs to the patterns that group N affordances under one label, and
	    none of these three does.</p>
	  </section>
	</section>
	"""

_radioGroup: #RadioGroup & {
	collection: "radio_group_demo"
	key:        "plan"
	legend:     "Plan"
	items: [
		{name: "starter", label: "Starter", description: "One project, community support. What a choice writes here is a tab-tier row, like every other state in the gallery."},
		{name: "pro", label: "Pro", description: "Ten projects and email support. This line is referenced by aria-describedby rather than nested in the button, so the option's accessible name stays \"Pro\"."},
		{name: "team", label: "Team", description: "Unlimited projects and shared billing. Clicking this line writes nothing: it carries its own id, and no arrow is narrowed to it."},
	]
}

radioGroupScreen: markup: """
	<section class="screen screen-radio-group" data-screen="radio-group">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Radio group</h1>
	    <p class="lede">The segmented control's machine, arrow for arrow, under
	    the markup a labelled set needs. What makes this a radio group and that
	    a toggle group is entirely outside the chart: a legend the group is
	    named by, one option per line, and a description each option points at.
	    A single-valued choice is one machine; the rest is contract and
	    layout.</p>
	  </header>
	  <div class="demo-stage">
	\(_radioGroup.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">The chosen plan and one <code>aria-checked</code>
	    column per option are columns of one tab-tier row — the segmented
	    control's row with different names in it.</p>
	    <div class="rowview" data-live="radio_group_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","value":"starter","chk_starter":"true","chk_pro":"false","chk_team":"false"}'>
	      <code class="row-readout" data-text="value: {value} · starter: {chk_starter} · pro: {chk_pro} · team: {chk_team}">value: starter · starter: true · pro: false · team: false</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">Six generated arrows, every assign a literal, and
	    no arrow from a state to itself — so clicking the chosen plan writes
	    nothing, which is the promise a radiogroup makes. Rename the states, the
	    ids and the columns and this is the
	    <a data-route="toggle-group">toggle group</a>'s chart: both components call
	    one generator, and the suite folds the two emitted charts together, so
	    the two cannot drift apart unnoticed.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_radioGroup.machine), "", "  "))</pre>
	  </section>
	  <section class="demo-pane">
	    <h2>The labelled set</h2>
	    <p class="pane-note">Three differences, all of them markup. The legend
	    is on the screen and names the group through
	    <code>aria-labelledby</code>, where the segmented control hides its name
	    in an <code>aria-label</code>. Each option carries a description, and it
	    is a sibling the button points at with <code>aria-describedby</code> —
	    nested, it would fold into the option's accessible name, which is why
	    name-from-content leaves the button holding the label alone. And the set
	    is vertical, because a description per option is what a compact control
	    has no room for.</p>
	    <p class="pane-note">What it is not: a form control. A radio group in a
	    form submits its group name paired with the chosen value, so this
	    component emits no <code>name</code> and no hidden input rather than
	    dressing as something that would submit nothing. The write is the
	    machine's, one stated row. The app's forms are the
	    <a data-route="combobox">combobox</a>'s and the
	    <a data-route="select">select</a>'s, and each of them commits a pick on a
	    gesture rather than stating screen state as it changes.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">Tab reaches every option and Space or Enter chooses
	    the focused one — native button behaviour, so activation is complete.
	    APG's radio group also asks for arrow keys moving a roving tabstop, and
	    that lands with the region-projection work, as it does for tabs and the
	    toggle group. Until it does the component emits no <code>tabindex</code>
	    at all: a roving tabstop without the arrows that move it would strand
	    every unchosen option outside the tab order. It emits no
	    <code>aria-orientation</code> either — that property tells a reader
	    which arrows move a tabstop this group does not move. The deviation that
	    ships is discoverability, never reachability.</p>
	  </section>
	</section>
	"""

_pagination: #Pagination & {
	collection: "pagination_demo"
	key:        "results"
	label:      "Search results pages"
	pages: [
		{name: "p1", label: "1"},
		{name: "p2", label: "2"},
		{name: "p3", label: "3"},
		{name: "p4", label: "4"},
		{name: "p5", label: "5"},
	]
}

_carousel: #Carousel & {
	collection: "carousel_demo"
	key:        "tour"
	label:      "How the traversal works"
	slides: [
		{name: "s1", label: "One state per slide", body: "The field holds which slide you are on, and nothing else holds it. There is no index to increment, because no arrow ever needed one."},
		{name: "s2", label: "Next is an arrow", body: "From here Next targets the third slide and nothing else. The chart names the destination; the button only names the direction."},
		{name: "s3", label: "The ends are drawn", body: "The first state has no Previous arrow and the last has no Next. The same generator writes the column that disables the button, so the two cannot disagree."},
		{name: "s4", label: "Projection, not code", body: "This slide is shown by one rule keyed on the root's data-state — Radix's contract, unchanged from the tabs screen. You are at the last slide, so Next is out."},
	]
}

_pagInv: #Inventory & {machine: _pagination.machine}
_carInv: #Inventory & {machine: _carousel.machine}

paginationScreen: markup: """
	<section class="screen screen-pagination" data-screen="pagination">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Pagination · Carousel</h1>
	    <p class="lede">Relative movement, drawn absolutely. A machine has no
	    arithmetic and needs none: from page three, Next is a drawn arrow to
	    page four. Both traversals below are the same generator over an ordered
	    list — one state per position, and from each state an arrow to every
	    other position plus the two neighbours. What differs is the ARIA
	    contract and whether anything is projected.</p>
	  </header>

	  <section class="demo-arm">
	    <h2>Numbered pages — <code>&lt;nav&gt;</code></h2>
	    <p class="arm-note">A page here is a column of a row, not a location,
	    so every control is a <code>&lt;button&gt;</code>: shadcn's
	    <code>&lt;a&gt;</code> would be a link to nowhere wearing a link's
	    role. The current page carries <code>aria-current="page"</code> bound
	    from its own column — <code>aria-current</code> is a token vocabulary,
	    so the column holds the attribute's own value rather than a boolean
	    someone has to translate.</p>
	    <div class="demo-stage">
	\(_pagination.markup)
	    </div>
	    <section class="demo-pane">
	      <h3>The row</h3>
	      <p class="pane-note">The page, one <code>aria-current</code> column
	      per page, and the two columns that disable the steps. The brackets
	      are drawn around the disabled columns because their off value is the
	      empty string, and an empty string is the whole mechanism.</p>
	      <div class="rowview" data-live="pagination_demo" data-filter="id=eq.the"
	           data-empty-row='{"id":"the","page":"p1","cur_p1":"page","cur_p2":"false","cur_p3":"false","cur_p4":"false","cur_p5":"false","dis_prev":"disabled","dis_next":""}'>
	        <code class="row-readout" data-text="page: {page} · cur: {cur_p1}/{cur_p2}/{cur_p3}/{cur_p4}/{cur_p5} · dis: [{dis_prev}]/[{dis_next}]">page: p1 · cur: page/false/false/false/false · dis: [disabled]/[]</code>
	      </div>
	    </section>
	    <section class="demo-pane">
	      <h3>The machine</h3>
	      <p class="pane-note">Printed whole, at its real size. Every arrow a
	      reader can take is in here, which is the claim: a chart smaller than
	      this one would be hiding a destination.</p>
	      <pre class="machine-json">\(json.Indent(json.Marshal(_pagination.machine), "", "  "))</pre>
	    </section>
	  </section>

	  <section class="demo-arm">
	    <h2>Slides — the same traversal, projected</h2>
	    <p class="arm-note">The identical machine under a different contract:
	    <code>aria-roledescription="carousel"</code> on the group, one on each
	    slide, and dots carrying <code>aria-current="true"</code> — the token a
	    picker within a set takes, where a page list takes
	    <code>page</code>. The slide is shown by one rule keyed on the root's
	    <code>data-state</code>, exactly as the tabs screen shows a panel — and
	    because that swap moves focus nowhere, the viewport is a polite live
	    region, so the slide that arrives announces itself instead of changing
	    in silence. That is APG's required property for the element holding the
	    slides, and it costs two static attributes and nothing in the
	    chart.</p>
	    <div class="demo-stage">
	\(_carousel.markup)
	    </div>
	    <section class="demo-pane">
	      <h3>The row</h3>
	      <p class="pane-note">The same shape one position shorter. The dot
	      columns read <code>true</code> rather than <code>page</code> because
	      that is what their attribute says.</p>
	      <div class="rowview" data-live="carousel_demo" data-filter="id=eq.the"
	           data-empty-row='{"id":"the","slide":"s1","cur_s1":"true","cur_s2":"false","cur_s3":"false","cur_s4":"false","dis_prev":"disabled","dis_next":""}'>
	        <code class="row-readout" data-text="slide: {slide} · cur: {cur_s1}/{cur_s2}/{cur_s3}/{cur_s4} · dis: [{dis_prev}]/[{dis_next}]">slide: s1 · cur: true/false/false/false · dis: [disabled]/[]</code>
	      </div>
	    </section>
	    <section class="demo-pane">
	      <h3>The machine</h3>
	      <p class="pane-note">The pagination chart with one position taken
	      out. Nothing else about it is the carousel's.</p>
	      <pre class="machine-json">\(json.Indent(json.Marshal(_carousel.machine), "", "  "))</pre>
	    </section>
	  </section>

	  <section class="demo-pane demo-inventory">
	    <h2>The inventory</h2>
	    <p class="pane-note">Counted off the two charts above rather than
	    written beside them. An arrow under a step's id is an arrow to a
	    position that happens to sit next door — the two rows differ only in
	    which button the generator filed the arrow under.</p>
	    <div class="inv-scroll">
	      <table class="inventory">
	        <tr><th scope="col">·</th><th scope="col">pagination</th><th scope="col">carousel</th></tr>
	        <tr><th scope="row">positions</th><td>\(_pagInv.positions)</td><td>\(_carInv.positions)</td></tr>
	        <tr><th scope="row">arrows under a position's id</th><td>\(_pagInv.absolute)</td><td>\(_carInv.absolute)</td></tr>
	        <tr><th scope="row">arrows under a step's id</th><td>\(_pagInv.step)</td><td>\(_carInv.step)</td></tr>
	        <tr><th scope="row">arrows in all</th><td>\(_pagInv.arrows)</td><td>\(_carInv.arrows)</td></tr>
	        <tr><th scope="row">columns beside the field</th><td>\(_pagInv.columns)</td><td>\(_carInv.columns)</td></tr>
	      </table>
	    </div>
	    <p class="pane-note">A sixth page costs twelve more arrows, one more
	    column and no stylesheet rule at all, because
	    <code>aria-current</code> is the styling hook. A fifth slide costs ten
	    more arrows, one more column and one more rule, because a slide is
	    projected and a projection is per-position by construction.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The ends</h2>
	    <p class="pane-note">At the first position the chart draws no Previous
	    arrow, and the button carries <code>disabled</code> bound from
	    <code>dis_prev</code>. The binder removes a bound boolean attribute
	    when it interpolates empty, so the column holds
	    <code>"disabled"</code> or <code>""</code> and the missing arrow and
	    the dead button are one generator's two emissions. No
	    <code>aria-disabled</code> is written beside it: that would be a second
	    spelling of what the chart already says, and two spellings drift.</p>
	    <p class="pane-note">The cost is native, and stated rather than hidden:
	    a truly disabled button leaves the tab order, so at the first page Tab
	    skips Previous. Before the row arrives both steps are disabled, because
	    the placeholder in the served HTML is a non-empty string — which is the
	    right state for a control whose machine has not mounted.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The keyboard, and what is not here</h2>
	    <p class="pane-note">Tab reaches every enabled button in document order
	    and Space or Enter presses the focused one — native button behaviour,
	    so activation is complete. No roving tabindex ships, as on tabs,
	    toggle-group and accordion: a tabstop without the arrow keys that move
	    it would strand every unfocused position outside the tab order.</p>
	    <p class="pane-note">Three things shadcn ships are deliberately absent.
	    <strong>The ellipsis.</strong> A windowed page list is a per-state
	    projection and needs no new vocabulary, but hiding a button does not
	    remove its arrow: the chart would go on promising a jump the reader can
	    no longer make, and the chart being the complete inventory is this
	    screen's whole claim. <strong>Auto-rotation.</strong> The vocabulary
	    has <code>after:</code> and it would express the advance exactly;
	    WCAG 2.2.2 then requires a pause, and turning a timer off needs either
	    a guard — a Jessie module, and this app ships none — or twice the
	    states. <strong>Swipe.</strong> A machine narrows on an event type and
	    an element id; a gesture is a distance computed across several events,
	    and neither the event nor an assign carries a value.</p>
	  </section>
	</section>
	"""

_toast: #Toast & {
	collection: "toast_demo"
	key:        "save"
	trigger:    "Save changes"
	title:      "Changes saved"
	body:       "Nobody will click this away. Watch the row walk itself back to closed."
}

toastScreen: markup: """
	<section class="screen screen-toast" data-screen="toast">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Toast</h1>
	    <p class="lede">The first component here to use <code>after</code>, and
	    the reason it exists: <strong>being in a state IS the pending
	    timer</strong>. <code>open</code> declares the wait, entering it arms
	    the wait, leaving it cancels the wait, and the terminal performs it. The
	    delay is data in the chart rather than a <code>setTimeout</code> in a
	    handler — which is what leaves this machine a function of its inputs,
	    with no clock to read.</p>
	  </header>
	  <div class="demo-stage">
	\(_toast.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">Which state the machine stands in, and nothing
	    about the wait — a row holds no deadline. Click the trigger and leave
	    the page alone: the value returns to <code>closed</code> with nobody
	    touching it, stated by the same write a click would have made.</p>
	    <div class="rowview" data-live="toast_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","state":"closed"}'>
	      <code class="row-readout" data-text="id: {id} · state: {state}">id: the · state: closed</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">Four arrows, and the fourth is the one no click
	    fires. <code>after</code>'s key is the delay in milliseconds; its value
	    is an ordinary transition, so where the wait lands is drawn on the same
	    chart as everything else. The trigger's arrow out of <code>open</code>
	    targets <code>open</code>: a target re-enters the state even when it is
	    the one already held, and re-entry is the re-arm — a second click buys a
	    full delay measured from itself.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_toast.machine), "", "  "))</pre>
	  </section>
	  <section class="demo-pane">
	    <h2>The clock</h2>
	    <p class="pane-note"><code>after</code> is the relocated
	    <code>invoke</code>: the terminal owns the wait, so
	    <code>?tempo=50</code> runs it fifty times faster and
	    <code>?clock=manual</code> stops it coming due until a driver says time
	    has passed — the same two levers that govern every other effect, over a
	    component that knows about neither. A machine that could read a clock
	    would stop being a function of its inputs, and no session of it would
	    replay.</p>
	    <p class="pane-note"><code>closed</code> declares no <code>after</code>,
	    so a screen nobody touches arms nothing and this page is at rest between
	    clicks. That is a property of the chart rather than a habit: a state
	    whose wait returned to itself would leave the screen mutating forever,
	    and it would be visible right here as a fifth arrow.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The announcement</h2>
	    <p class="pane-note">The live region is the viewport, not the toast.
	    <a data-route="primitives">Badge · Card · Alert</a> printed the corollary
	    that bites here: a polite region must be mounted before its content
	    changes, or the only change it reports is its own arrival. So
	    <code>role="status"</code> sits on the container that is always there,
	    and what appears inside it is the message.</p>
	    <p class="pane-note">Polite rather than <code>role="alert"</code>, and
	    the timer is the argument: a message assertive enough to interrupt is
	    one no reader can be asked to catch inside three seconds, so
	    auto-dismissal and assertiveness exclude each other. Nothing else is
	    written — <code>role="status"</code> already carries
	    <code>aria-live="polite"</code> and <code>aria-atomic="true"</code>, and
	    spelling either again would be a second statement of what the role
	    already says. Focus never moves to the toast, which is why the dismiss
	    button is a real button in the tab order rather than the only way out —
	    and why the wait can take that button out from under a reader standing
	    on it, which is the last of the limits below.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>What it does not ship</h2>
	    <dl class="limits">
	      <dt>The top layer</dt>
	      <dd>The one primitive this gallery declines, where
	      <a data-route="overlays">Dialog · Tooltip</a> takes every one it can. A
	      <code>popover</code>'s openness is the UA's, moved by a button press,
	      while <code>after</code> states a row and commands nothing: the timer
	      would expire with the row saying <code>closed</code> and the surface
	      still open, openness living in two places. So this surface stacks
	      with the page, and a <code>z-index</code> in the stylesheet is what
	      that costs — a modal <code>&lt;dialog&gt;</code> would paint over
	      it.</dd>
	      <dt>A queue of several toasts</dt>
	      <dd>N toasts are N rows and N regions — the
	      <a data-route="accordion">accordion</a>'s answer at its
	      <code>multiple</code> arity, since a machine binds exactly one row.
	      What is missing is not the machine but the ordering: stacking,
	      collapsing and newest-first are reads across a collection, and row
	      closure gives a machine only its own row.</dd>
	      <dt>Swipe to dismiss</dt>
	      <dd>Pointer events carry coordinates; a machine event is a type plus
	      the id of the element it fired from, and nothing in between.</dd>
	      <dt>Esc to dismiss</dt>
	      <dd>The same wall one notch closer: <code>keydown</code> bubbles and
	      an arrow could be drawn on it, but the event carries no key, so that
	      arrow would fire on every key alike. Dismissal is the button.</dd>
	      <dt>A bar counting the wait down</dt>
	      <dd>The row holds which state the machine is in, never how much of
	      the wait is left — the deadline lives in the terminal's clock. A CSS
	      animation would be a second, unsynchronised declaration of the delay,
	      and under <code>?tempo=</code> the two would visibly disagree.</dd>
	      <dt>A delay the reader can lengthen</dt>
	      <dd>WCAG 2.2.1 asks that a time limit be adjustable, and this one is
	      authorable rather than adjustable: the component takes the delay as a
	      parameter and this specimen sets three seconds. The vocabulary already
	      names the seam that would close it — an <code>after</code> key may be
	      the name of a Jessie module returning milliseconds — and this app
	      declines to take it, because zero JavaScript is its own promise.</dd>
	      <dt>A wait that pauses while the toast has focus</dt>
	      <dd>Radix stops the timer while a reader is on the toast and this
	      component does not, so a Tab that lands on Dismiss can have the
	      button hidden out from under it when the wait comes due, and focus
	      falls back to the document. The chart could say the pause — a
	      <code>held</code> state declaring no <code>after</code>, entered on
	      <code>focusin</code> and left on <code>focusout</code>, both of which
	      bubble to the region — and what it could not say is the resume:
	      leaving would arm a whole delay again rather than the remainder of
	      the one it paused.</dd>
	    </dl>
	  </section>
	</section>
	"""

_slider: #Slider & {
	collection: "slider_demo"
	key:        "volume"
	value:      "volume"
	label:      "Volume"
	start:      50
}

// The slider's own row, its own column: one row driving two components, so the
// bar cannot disagree with the control that moves it.
_volumeBar: #Progress & {
	collection: "slider_demo"
	key:        "volume"
	field:      "volume"
	label:      "Volume, as a bar"
	empty:      _slider.fallback
}

// The same definition over a row nothing on this screen writes. A bar carries
// no affordance, so left alone it stands still — which is the shape of every
// real progress bar, whose value belongs to whatever is making the progress.
_exportBar: #Progress & {
	collection: "progress_demo"
	key:        "export"
	field:      "done"
	label:      "Export"
	empty: {id: "the", done: 72}
}

sliderScreen: markup: """
	<section class="screen screen-slider" data-screen="slider">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Slider · Progress</h1>
	    <p class="lede">The gallery's first continuous value. Every machine
	    before this one holds a state name out of a closed set, and a position
	    on a scale is not a name — so it cannot be the machine's field. It is a
	    second column the same transition assigns, lifted off the event the
	    control fired. The chart that remains has one state and one arrow that
	    names no target: it acts and it stays. Drag the thumb and watch a column
	    move under a machine that never changes state.</p>
	  </header>
	  <div class="demo-stage">
	\(_slider.markup)
	\(_volumeBar.markup)
	\(_exportBar.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">Two collections and one moving number. The slider
	    and the first bar bind the same row of <code>slider_demo</code> — the
	    control writes <code>volume</code> and the bar paints it, so the two
	    cannot disagree. <code>phase</code> is the machine's own field, and it
	    is the column that never moves. The control does keep a copy from the
	    reader's first drag, and the last limit below is what that costs.</p>
	    <div class="rowview" data-live="slider_demo" data-filter="id=eq.the"
	         data-empty-row='\((omni.#attrJSON & {in: _slider.fallback}).out)'>
	      <code class="row-readout" data-text="id: {id} · phase: {phase} · volume: {volume}">id: the · phase: live · volume: \(_slider.start)</code>
	    </div>
	    <p class="pane-note">The second bar's row is in
	    <code>progress_demo</code>, and nothing on this screen writes it. That
	    is not a broken specimen: <code>omnishell--progress</code> carries no
	    affordance at all, so what moves it is whoever owns the work it
	    reports.</p>
	    <div class="rowview" data-live="progress_demo" data-filter="id=eq.the"
	         data-empty-row='\((omni.#attrJSON & {in: _exportBar.empty}).out)'>
	      <code class="row-readout" data-text="id: {id} · done: {done}">id: the · done: \(_exportBar.empty.done)</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">One state, one arrow, and the arrow names no
	    target. A transition without one acts and stays, which is what lets a
	    chart record a value that changes continuously. The assign's leaf is
	    <code>{"type": "event", "params": {"field": "valueAsNumber"}}</code> —
	    the terminal's own, never a module, and its field comes from a closed
	    allowlist of four. A control carrying no such field declines the
	    transition rather than writing <code>NaN</code>, so the arrow is
	    narrowed to the range input's id and reaches nothing else.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_slider.machine), "", "  "))</pre>
	  </section>
	  <section class="demo-pane">
	    <h2>What a one-state machine is</h2>
	    <p class="pane-note">Every other chart in this gallery earns its states
	    by branching: from <code>false</code> a click goes to <code>true</code>
	    and from <code>true</code> it goes back, and reading the chart tells you
	    what can happen where. This one has a single state, so it says nothing
	    about where — and a chart that draws no branch is not drawing
	    anything.</p>
	    <p class="pane-note">What survives is three facts that were never the
	    chart's: an event key narrowed to one control's id, a column the
	    transition writes, and the one leaf that reads the event. Together they
	    are a <em>binding</em> — the terminal's write path with an allowlisted
	    read attached — and <code>field</code>, <code>initial</code> and
	    <code>states</code> are the ceremony the vocabulary charges for reaching
	    it. The schema says so out loud: <code>phase</code>'s constraint is
	    <code class="cel">this in ['live']</code>, a column whose entire value
	    set is one member.</p>
	    <p class="pane-note">So no: this is not a machine worth calling a
	    machine, and the honest spelling for a value-carrying control would name
	    the column, the event and the field it reads, and invent no state to be
	    in. This app does not ship that spelling, because a second write
	    vocabulary standing beside the machine — for the case that is one arrow
	    long — buys less than it costs. The one-state chart is the degenerate
	    case of the general thing, and the first branch the slider grows brings
	    the states back doing real work with nothing respelled: an arm that is
	    disabled, a distinction between dragging and committed, a threshold past
	    which the number means something else. A constant column is what the
	    degenerate case costs, and it is the price of there being one write path
	    rather than two.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The ARIA, and the keyboard</h2>
	    <p class="pane-note">Not one <code>aria-*</code> attribute is written on
	    this screen, because the platform has an element for each half.
	    <code>&lt;input type="range"&gt;</code> is a slider to every assistive
	    technology and <code>&lt;progress&gt;</code> is a progressbar; each
	    supplies its role and its value off its own attributes, and each is
	    labelable, so a <code>&lt;label for&gt;</code> a reader can see is the
	    accessible name. No <code>aria-valuetext</code> either — a percentage is
	    what the value and the maximum already say, and a text form would be a
	    second spelling of one fact. The number printed beside the slider is
	    <code>aria-hidden</code>, because the control announces its own value
	    and a second copy in the tree is that number said twice.</p>
	    <p class="pane-note">Both are dressed rather than rebuilt: one
	    <code>accent-color</code> paints the thumb, the rail's fill and both
	    bars, and every one of those is a shadow tree no selector on this page
	    can reach. So the exact shape of a thumb and a bar is the engine's and
	    differs a little between them — which is the price of the paragraph
	    above, and the trade shadcn declines when it rebuilds both as div towers
	    over Radix.</p>
	    <p class="pane-note">It is also why this screen defers no keyboard. The
	    range binds the arrow keys to <code>step</code>, Home and End to the
	    ends and the page keys to a larger increment, before the page loads. The
	    roving-tabstop deferral the rest of the catalog carries belongs to
	    patterns grouping N affordances under one label, and a single-thumb
	    range is one affordance. Two thumbs would be two, and that case defers
	    with the same sentence as the rest: virtual focus and arrow-key roving
	    land with the region-projection work, and until they do no
	    <code>tabindex</code> is emitted at all.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>What it does not ship</h2>
	    <dl class="limits">
	      <dt>Two thumbs</dt>
	      <dd>shadcn's Slider takes N values on one rail, and that is two
	      refusals in one. The rail with custom thumbs means giving up the
	      native control and rebuilding its role, its value and its whole
	      keyboard by hand, which is the roving-tabstop wall above. Two native
	      ranges side by side keep all of that and meet a different wall:
	      holding the low thumb under the high one is a comparison between two
	      columns, and an assign carries a literal, a module or the event leaf —
	      never an expression. A guard would decide it, and that is exactly
	      decision-02's cliff: a guard is where an app writes the reduce
	      instead, and this gallery does not cross it.</dd>
	      <dt>Any arithmetic on the value</dt>
	      <dd>The same wall stated generally. The column holds the number the
	      control produced and nothing else: no clamping, no snapping to an
	      uneven scale, no logarithmic taper, no percentage of something the row
	      does not carry. Each of those is a computation, and the chart has
	      nowhere to put one that is not a Jessie module.</dd>
	      <dt>Committing on release</dt>
	      <dd>The arrow is keyed on <code>input</code>, so every intermediate
	      position of a drag states a row — free on a <code>tab</code>
	      collection, a round trip each on a server-backed one. The fix needs no
	      new vocabulary and no second arrow: <code>change</code> fires once, on
	      release, and it is one key in the chart. This specimen picks the noisy
	      one because watching the row move is what there is to see.</dd>
	      <dt>An indeterminate bar</dt>
	      <dd>A <code>&lt;progress&gt;</code> is indeterminate when it carries
	      no <code>value</code> attribute at all, and a bound attribute is
	      present-or-empty rather than present-or-absent — the binder removes
	      only boolean and URL attributes when a binding comes out empty. An
	      empty one paints a bar at zero, which no reader can tell from a real
	      zero. So indeterminacy is not a value a column can state; it is
	      different markup, and it would be a second component.</dd>
	      <dt>A row that can move the control</dt>
	      <dd>The binding is the <code>value</code> content attribute, and an
	      <code>&lt;input type="range"&gt;</code> is in value mode: the reader's
	      first interaction sets the dirty value flag, after which the thumb
	      shows its own value and stops tracking the attribute the binder
	      writes. So the row paints the bar for as long as the reader lives, but
	      after the first drag it can no longer move the thumb — a refused write
	      cannot roll back where the reader can see it, which is the guarantee
	      the checkbox has and this does not. Nothing on this screen turns on
	      it, the control being the only writer of its row; a consumer that
	      adds a second writer needs the property path
	      <code>data-value</code> already gives a checkbox.</dd>
	    </dl>
	  </section>
	</section>
	"""

resizableDemo: #Resizable & {
	collection: "resizable_demo"
	label:      "First pane's width"
	start:      50
	panes: [
		{title: "Sources", body: "A pane is not a component. It is a box whose width is a column, and what a reader drags is the number in it."},
		{title: "Preview", body: "The second pane takes what is left: one number states both, so they cannot disagree about the space between them."},
	]
}

// Public, like the combobox and the select: the query column's constraint is
// generated from the same length the control's maxlength carries, and the
// entity lives in program.cue.
commandDemo: #Command & {
	queries:     "command_demo"
	items:       "command_item"
	label:       "Command"
	placeholder: "Type a command or search…"
	hint:        "Filters as you type. Down and Up move the caret, Enter runs what it stands on."
	run:         "Run"
	none:        "No commands match."
	commands: [
		{name: "calendar", title: "Calendar", group: "Suggestions"},
		{name: "emoji", title: "Search Emoji", group: "Suggestions"},
		{name: "calculator", title: "Calculator", group: "Suggestions"},
		{name: "profile", title: "Profile", group: "Settings"},
		{name: "billing", title: "Billing", group: "Settings"},
		{name: "preferences", title: "Preferences", group: "Settings"},
	]
}

resizableScreen: markup: """
	<section class="screen screen-resizable" data-screen="resizable">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Resizable</h1>
	    <p class="lede">A pane's width is a column, and the stylesheet does the
	    arithmetic. This is the first binding in this catalog whose target is not
	    an attribute but a custom property: one number reaches
	    <code>--split</code>, <code>calc()</code> turns it into two widths, and
	    the two panes cannot disagree about the space between them because there
	    is only one number.</p>
	  </header>
	  <h2 class="stage-name">The panes</h2>
	  <div class="demo-stage">
	\(resizableDemo.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">One row, two columns, and only one of them moves.
	    <code>state</code> is the machine's field and has exactly one value —
	    the arrow is targetless, so it acts and stays — while
	    <code>split</code> is the position, lifted off the event by the
	    terminal's leaf. That split is <a data-route="slider">the slider</a>'s
	    argument reaching a second screen: a value on a scale is not a state,
	    because <code>initial</code> must name one of a finite set of keys and a
	    percentage is not one.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(resizableDemo.machine), "", "  "))</pre>
	  </section>
	  <section class="demo-pane">
	    <h2>The binding that is not an attribute</h2>
	    <p class="pane-note">The group binds the position into
	    <code>--split</code>, and the panes read it: the first
	    is <code>flex: 0 0 calc(var(--split) * 1%)</code>, the second takes
	    what is left. A custom property inherits, so the binding lands once on
	    the box that owns both panes rather than once per pane.</p>
	    <p class="pane-note">A projection has no arithmetic and none is missing
	    here, because CSS has it. That is the same trade
	    <a data-route="pagination">pagination</a> makes from the other side, where
	    the component draws an absolute arrow per position rather than adding
	    one to anything — the platform without arithmetic keeps working as long
	    as something downstream of it can count.</p>
	    <p class="pane-note">What makes this safe to bind is who writes the
	    column. The only writer is a range, and a range hands the leaf a
	    <code>valueAsNumber</code> the browser has already clamped to
	    <code>[min, max]</code>. A column a reader could type into has no
	    business reaching a <code>style</code>, where a value carrying its own
	    semicolon would be a second declaration nobody wrote.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">Not one line of it is stated here. APG's window
	    splitter asks for arrows, Home, End and a larger page step, and an
	    <code>&lt;input type="range"&gt;</code> ships every one before the page
	    loads, with its role, its value and its bounds — so the only
	    <code>aria-*</code> on this screen is the <code>aria-hidden</code> that
	    keeps the readout from saying the number twice, exactly as
	    <a data-route="slider">the slider</a>'s does.</p>
	    <p class="pane-note">What the native role costs is the other half of
	    APG's pattern, and it is worth naming: a window splitter asks for
	    <code>role="separator"</code> with <code>aria-valuenow</code>,
	    <code>aria-valuemin</code>, <code>aria-valuemax</code> and an
	    <code>aria-controls</code> naming the panes it sizes. This ships the
	    native slider role instead, which supplies the value and the bounds for
	    free but announces the control as a slider and leaves the two panes
	    unassociated with it.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>What it does not ship</h2>
	    <dl class="limits">
	      <dt>A handle between the panes</dt>
	      <dd>shadcn's <code>ResizableHandle</code> is the bar you drag, and this
	      one is a control beneath the panes. A native range is the only
	      pointer-continuous input this vocabulary has, and its track is the
	      whole scale — so a thumb rendered as the divider means the range
	      overlays the group, and every click in a pane jumps the split to where
	      the pointer landed. Naming the trade is cheaper than a pane that
	      cannot hold anything clickable.</dd>
	      <dt>More than two panes</dt>
	      <dd>Three panes are two independent splits, which is two controls
	      grouped under one label — <a data-route="slider">the slider</a>'s
	      two-thumb refusal with the same sentence: what this vocabulary has is
	      one affordance per control, and a group of them needs the roving
	      tabstop the rest of the catalog defers.</dd>
	      <dt>A vertical group</dt>
	      <dd>The axis is the stylesheet's, not the row's: the same column drives
	      a column-direction flex and a range in <code>writing-mode:
	      vertical-lr</code>. It is left out because a second arm here proves
	      nothing a second arm on <a data-route="accordion">the accordion</a> did
	      not, and every arm is a storyboard frame to keep true.</dd>
	      <dt>A collapsed pane a double-click restores</dt>
	      <dd>Collapse is a second gesture on the same handle, and
	      <code>dblclick</code> is not a key: <code>data-key</code> admits the
	      arrows, Home and End, and a machine's own dispatch cancels nothing.
	      The wall <a data-route="menu">the context menu</a> names, met by a
	      different component.</dd>
	    </dl>
	  </section>
	</section>
	"""

commandScreen: markup: """
	<section class="screen screen-command" data-screen="command">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Command</h1>
	    <p class="lede">The screen the <a data-route="combobox">combobox</a> could
	    not be, and the one where virtual focus lands. A machine's
	    <code>assign</code> reads the value the control was showing, so what you
	    type is a column of a row; a region re-queries when the column its filter
	    reads moves; and the projection names each option's neighbour, so an
	    arrow key is a form the option itself owns. No debounce, no list held
	    anywhere but the store, and no <code>focus()</code>.</p>
	  </header>
	  <div class="demo-stage">
	\(commandDemo.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">Two collections, and the split is the design.
	    <code>command_item</code> holds one row per command, written by the
	    terminal from the entity's <code>seed:</code> when it first opens the
	    collection. <code>command_demo</code> holds the single row a keystroke
	    writes. An interpolated filter is re-resolved when its parent's row
	    moves, so a region reading the very table the keystroke wrote would race
	    its own wake — and each write wakes exactly one of them.</p>
	    <p class="pane-note">Three columns of that one row carry the whole
	    widget, and they are not interchangeable. <code>query</code> is what was
	    typed. <code>active</code> is the option
	    <code>aria-activedescendant</code> points at. <code>chosen</code> is the
	    option that was run. One column doing two of those jobs would be a
	    palette that runs a command every time you arrow past it.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">One state and one arrow, and the arrow is the new
	    thing: an <code>assign</code> whose value is
	    <code>{"type": "event"}</code>, the one leaf a machine states instead of
	    importing. It reads the event and never another row, so a transition
	    stays decidable from the row and the event that fired it. The field it
	    may name is a closed list — <code>value</code>, <code>checked</code>,
	    <code>valueAsNumber</code>, <code>key</code> — because a leaf that could
	    name any property would be a handle on the DOM.</p>
	    <p class="pane-note">That same arrow clears <code>active</code> with a
	    literal. A caret cannot outlive the read it was standing in: an option
	    the filter has dropped is not rendered, so the form an arrow would name
	    is not there — a key that threw would be the price of keeping the caret.
	    <a class="pane-link" data-route="data-table">Data table</a> met this first
	    and answers it the same way.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(commandDemo.machine), "", "  "))</pre>
	  </section>
	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">The list is one tab stop and the options are none.
	    DOM focus never leaves the input, which carries
	    <code>role="combobox"</code> and names the caret with
	    <code>aria-activedescendant</code> — a plain binding off its own row. Each
	    option is a <code>&lt;button&gt;</code>, focusable without asking, so
	    every one carries <code>tabindex="-1"</code>.</p>
	    <p class="pane-note">Then <code>data-key</code> submits a form on a key,
	    and the form each key names is <code>command-nx-</code> with the caret's
	    own id appended, interpolated from the row the field is bound to. The projection puts <code>next</code> and <code>prev</code> on
	    every option, so that form states the neighbour. Before the first arrow the caret's
	    column is empty, so the pair the keys reach is
	    the one a hidden <code>limit=1</code> region stamps from the head of
	    whatever the filter is answering now.</p>
	    <p class="pane-note">Enter is not a <code>data-key</code>: the binding
	    admits the arrows, Home and End, and nothing else. It does not have to
	    be. The input sits in a form carrying <code>chosen</code> bound to the
	    caret's column, and a form holding a text input and a submit
	    button is submitted by Enter natively — so the key that runs a command is
	    the platform's own, and <b>Run</b> is the same statement for a pointer.
	    Without it a reader could move the caret and never choose, which is
	    worse than shipping no keyboard at all.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The filter</h2>
	    <p class="pane-note">One region, ordered <code>pos.asc</code>, filtered
	    <code>label=ilike.*…*</code> with the enclosing row's query interpolated
	    between the wildcards. When that column moves the filter differs from the
	    one the node was hydrated with, so the region re-hydrates against the new
	    one — the half of the live filter that is not the event leaf. The pattern
	    is PostgREST's, so <code>*</code> is the wildcard and a reader who types
	    one matches everything; the query is URI-encoded on its way in, so
	    <code>&amp;</code>, <code>%</code> and a quote arrive as characters
	    rather than as syntax.</p>
	    <p class="pane-note">Home and End are the same shape one clause wider:
	    <code>first</code> and <code>last</code> over the region the arrows
	    already walk, so both ends are the ends of what the FILTER left rather
	    than of the collection. With nothing chosen, three of the four keys mean
	    entering a list at the top; End is the one that does not, so it takes its
	    own read — the same filter and limit under the reverse order, whose
	    single row is the last one.</p>
	    <p class="pane-note">Type something no command carries and all four do
	    nothing at all. Each names a form off the caret's own id, so an empty
	    list is a form that is not there — which the terminal reads as the empty
	    set it is rather than as markup naming a form it forgot, because the id
	    INTERPOLATES. A literal that misses is still the typo it looks like.</p>
	    <p class="pane-note">The field is <code>type="search"</code>, so Chrome
	    and Safari draw a clear button inside it and Firefox draws none. It is
	    the one control on this screen the tokens do not paint — the
	    <a data-route="combobox">combobox</a>'s suggestion popup is the other place
	    this gallery hands a surface to the UA — and pressing it fires
	    <code>input</code> like any other edit, so the row empties and the whole
	    palette comes back.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>What it does not ship</h2>
	    <dl class="limits">
	      <dt>Two labelled groups</dt>
	      <dd>shadcn's Command groups its commands under headings. A region
	      renders one read, so two groups are two reads — and the projection
	      answers <code>next</code> within a read, so the arrows would stop at
	      the boundary. The group rides each option as its own text instead. What
	      would buy the headings back is a third region over all the rows,
	      emitting the move forms in the global order while the visible groups
	      render; that is a shape this screen has not taken rather than one it
	      cannot.</dd>
	      <dt>An <code>aria-expanded</code> that can be false</dt>
	      <dd>The attribute is a literal <code>true</code>, and the list is inline
	      rather than a popup, so it is true whenever the read answers anything.
	      When the filter answers nothing it is not: the combobox reports an open
	      listbox owning no options. Binding it needs a column on the row holding
	      the QUERY that knows what the option read returned, and the projection
	      answers on the rows a region holds — the same wall the count below runs
	      into, from the other side.</dd>
	      <dt>A count for a reader who cannot see the list</dt>
	      <dd>Search-as-you-type wants a polite region saying how many matched,
	      and a count is a column no filter writes: the projection's
	      <code>count</code> answers on each option row, not on the row holding
	      the query, so the number is sayable where the options are and not where
	      this note wants it. Announcing the list itself would fail the corollary
	      <a data-route="primitives">Badge · Card · Alert</a> printed — a live
	      region that arrives with its content reports only its own arrival.</dd>
	      <dt>A palette in the top layer</dt>
	      <dd>shadcn's Command is usually a <code>&lt;dialog&gt;</code> a
	      shortcut opens, and the surface is
	      <a class="pane-link" data-route="overlays">Dialog · Tooltip</a>'s — it
	      needs no machine. The chord is expressible too:
	      <a class="pane-link" data-route="data-table">the grid</a> answers one.
	      What is missing is a chord pressed from ANYWHERE, and it is a scope
	      rather than a component — every listener the terminal attaches is a
	      region's, so a key pressed with focus elsewhere has nobody to deliver
	      it to. The shape is not the hard part (a map on the route, from chord
	      to a control it aliases, torn down with the screen); one caller is,
	      and this is the only one so far. <em>Closed by</em> a second
	      one.</dd>
	    </dl>
	  </section>
	</section>
	"""

// Public, like the combobox: the two column constraints are generated from the
// same option grammar the mint form gates on, and the entities live in
// program.cue.
selectDemo: #Select & {
	collection: "select_demo"
	options:    "select_option"
	label:      "Language"
	prompt:     "Choose a language…"
	authored: ["CUE", "Go", "Kotlin", "TypeScript"]
	authoredLabel:   "Declared in the source"
	liveLabel:       "Rows in the store"
	hint:            "This form holds no button, so a pick fires change and change submits it."
	pickForm:        "select-pick"
	mintForm:        "select-mint"
	mintLabel:       "Add an option"
	mintPlaceholder: "Zig"
	mintButton:      "Add"
	mintHint:        "This collection is seeded by nothing, so every row in the second group is one you wrote — and it dies with the tab."
}

selectScreen: markup: """
	<section class="screen screen-select" data-screen="select">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Select</h1>
	    <p class="lede">The answer that predates every machine in this gallery.
	    An <code>&lt;optgroup&gt;</code> carrying a <code>data-live</code> is a
	    region, so a native select's options can be rows; the select's
	    <code>name</code> feeds the form it sits in, and a form holding no
	    button submits on <code>change</code>. No component tier, no machine,
	    no script — and a trade against the <a data-route="picker">picker</a> that
	    goes both ways.</p>
	  </header>
	  <div class="demo-stage">
	\(selectDemo.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">Two collections, and one control spans both. The
	    pick is one row of <code>select_demo</code>, written by the form the
	    select sits in. The second group's options are rows of
	    <code>select_option</code>, written by the form below it — which is why
	    the pick column states a length instead of enumerating its values: a
	    picker's column can name every option it admits, and this one cannot,
	    because half of them do not exist until a reader writes one.</p>
	    <div class="rowview" data-live="select_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","choice":""}'>
	      <code class="row-readout" data-text="id: {id} · choice: &quot;{choice}&quot;">id: the · choice: ""</code>
	    </div>
	    <ul class="rowlist" data-live="select_option" data-order="id.asc"
	        data-empty="No option rows yet — the second group is empty until you add one.">
	      <template data-item><li><code class="row-readout" data-text="id: {id}"></code></li></template>
	    </ul>
	  </section>
	  <section class="demo-pane">
	    <h2>The trade</h2>
	    <p class="pane-note">Where every other screen prints the machine it
	    runs, this one prints the comparison it exists to make. Neither column
	    is the better control, and the row that decides between them is the
	    first one.</p>
	    <div class="trade-wrap" tabindex="0" role="region" aria-label="Picker versus select">
	      <table class="trade">
	        <thead>
	          <tr><th scope="col">what is at stake</th><th scope="col">picker — a machine</th><th scope="col">select — a region and a form</th></tr>
	        </thead>
	        <tbody>
	          <tr><th scope="row">where the options come from</th><td>literals in the source: one machine state per option</td><td>rows: whatever the collection holds when the reader opens it</td></tr>
	          <tr><th scope="row">what a pick writes</th><td>the choice, its readout label and every option's aria-selected, as one row</td><td>the choice, as one row</td></tr>
	          <tr><th scope="row">after the write</th><td>the control renders from the row</td><td>the form resets, so the control shows its prompt again</td></tr>
	          <tr><th scope="row">the ARIA</th><td>role listbox and option, aria-selected — written on this screen</td><td>the UA's own, complete, and written nowhere</td></tr>
	          <tr><th scope="row">the keyboard</th><td>click and native Space and Enter; arrow keys deferred</td><td>the platform's whole contract, typeahead included</td></tr>
	          <tr><th scope="row">on a phone</th><td>a popover this app paints</td><td>the operating system's picker</td></tr>
	          <tr><th scope="row">the skin</th><td>design tokens, in both appearances</td><td>the open list is the UA's surface and resolves none of them</td></tr>
	        </tbody>
	      </table>
	    </div>
	    <dl class="walls">
	      <dt>A native select whose selection is bound to the row</dt>
	      <dd>Binding the control back means a machine: the event leaf writes
	      the value the control was showing straight into the row, with no form
	      and so no reset. A machine region is a slot, a region nested inside a
	      slot is never hydrated, and the live option group has to sit inside
	      the select — so the chart and the option rows cannot share one
	      control. <em>Closed by</em> either arm: a hydrated slot-nested
	      region, or a machine region that renders before its first row exists,
	      since a list region of one pinned row draws nothing until something
	      writes that row, and nothing writes this one.</dd>
	      <dt>The picked option, marked in the markup</dt>
	      <dd>Selectedness would be a bound attribute like the pagination
	      screen's <code>disabled</code>, and the column behind it has to move
	      for every option at once — which is a machine's literal assigns over
	      a closed option set, and this set is not closed. <em>Nothing closes
	      this one</em> while the options are data: it is the wall above, met
	      from the other side.</dd>
	      <dt>An option the reader can remove</dt>
	      <dd>A delete form is one submit away, and what has no answer here is
	      the row that already names the option: the pick column is text and
	      not a reference, and the tab tier arbitrates nothing between two
	      collections. <em>Not shipped</em>, rather than shipped leaving a pick
	      pointing at nothing.</dd>
	    </dl>
	    <p class="pane-note">Nothing this screen's controls do with the keyboard
	    is deferred. The roving-tabstop deferral the rest of the catalog carries
	    belongs to the patterns that group N affordances under one label and
	    have to move focus between them; a native select is one affordance, and
	    the UA owns everything inside it. The one thing here a keyboard would
	    otherwise not reach is the trade table's scroll box, which takes a
	    tabstop and a name of its own so the third column is reachable without
	    a pointer.</p>
	  </section>
	</section>
	"""

// The route's real trail, and the whole of it: this catalog is flat, so
// every screen's only ancestor is the catalog itself.
_crumbs: #Breadcrumb & {
	trail: [{text: "Components", route: "catalog"}]
	current: "Breadcrumb · Avatar · Separator · Skeleton"
}

_avatarPhoto:   #Avatar & {name: "Ada Lovelace", initials: "AL", src: _portrait}
_avatarLetters: #Avatar & {name: "Grace Hopper", initials: "GH"}
_avatarBeside:  #Avatar & {name: "Katherine Johnson", initials: "KJ", decorative: true}

_ruleSemantic:   #Separator & {decorative: false}
_ruleDecorative: #Separator & {}
_ruleVertical:   #Separator & {decorative: false, orientation: "vertical"}

_skelCircle: #Skeleton & {shape: "circle"}
_skelLine:   #Skeleton & {shape: "line"}
_skelShort:  #Skeleton & {shape: "line-short"}
_skelBlock:  #Skeleton & {shape: "block"}

breadcrumbScreen: markup: """
	<section class="screen screen-breadcrumb" data-screen="breadcrumb">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Breadcrumb · Avatar · Separator · Skeleton</h1>
	    <p class="lede">Four components with no state and no variants, so there
	    is neither a chart to print nor a variant→token map: what each of these
	    is entirely made of is the accessibility tree it emits. Three of the four
	    turn on one question — is this element content, or a picture of something
	    the markup already states — and the closing pane is that tree, printed as
	    data the suite folds this screen's markup through.</p>
	  </header>

	  <section class="demo-part">
	    <h2>Breadcrumb</h2>
	    <p class="pane-note">The trail is this route's own, and it is two deep
	    because the catalog is flat: <code>/breadcrumb</code>'s only ancestor
	    is <code>/</code>, and a trail that inserted a sibling to look deeper
	    would be stating an ancestry the app does not have. The page the reader
	    is on is the last crumb and is text: shadcn spells it
	    <code>role="link" aria-disabled="true"</code>, which announces a control
	    that cannot be used where there is no control at all —
	    <code>aria-current="page"</code> alone is the whole statement. Each
	    slash is hidden rather than presentational, because
	    <code>role="presentation"</code> drops the list item and leaves the
	    glyph's text in the tree for a reader to hear between every crumb.</p>
	    <div class="demo-stage">
	\(_crumbs.markup)
	    </div>
	    <p class="pane-note">No collapsed middle ships. shadcn's ellipsis is a
	    menu of the crumbs it hid, and a menu of links is a popover a trigger
	    commands — reachable at tier 0, and already what
	    <a class="pane-link" data-route="overlays">Dialog · Tooltip</a> demonstrates.
	    What it would add here is a windowing rule, and a trail two deep has
	    nothing to window; a flat catalog is the depth this app has, not a
	    depth this component cannot take.</p>
	  </section>

	  <section class="demo-part">
	    <h2>Avatar</h2>
	    <p class="pane-note">The fallback is not a swap: the initials are the
	    element's own content and the image paints over them, so an image that
	    never paints leaves what is underneath visible with no error handler
	    anywhere. That is why the name is on the wrapper under
	    <code>role="img"</code> and the image carries <code>alt=""</code> — an
	    <code>alt</code> holding the name would put the name on top of the
	    initials the moment the bytes failed, and would move the accessible name
	    depending on whether they arrived.</p>
	    <div class="demo-stage">
	      <div class="avatar-row">
	\(_avatarPhoto.markup)
	\(_avatarLetters.markup)
	      </div>
	      <p class="byline">
	\(_avatarBeside.markup)
	        <span class="byline-name">Katherine Johnson</span>
	        <span class="byline-meta">named beside her picture, so the picture says nothing</span>
	      </p>
	    </div>
	    <p class="pane-note">What the missing error event costs is one thing, and
	    it is not the fallback: loaded, failed and loaded-transparent are
	    indistinguishable to the page, so nothing records which happened and
	    nothing can act on it. Radix's <code>delayMs</code>, which holds the
	    initials back long enough that a fast image never flashes them, is that
	    same observation with a timer on it and has no spelling here. The first
	    specimen's bytes are a placeholder inlined as a <code>data:</code> URI —
	    the screen still makes no request — and its colours are the picture's
	    own, as a photograph's would be.</p>
	  </section>

	  <section class="demo-part">
	    <h2>Separator</h2>
	    <p class="pane-note">Both answers ship, because the element is the same
	    line twice and the tree is not. Where the boundary is already stated —
	    a heading, a landmark, a list — the rule is a picture of it and takes
	    <code>aria-hidden</code>. Where the line is the only thing stating it,
	    the role is real: horizontal is <code>&lt;hr&gt;</code>, whose implicit
	    role is <code>separator</code> and whose default orientation is
	    horizontal, so it declares nothing at all; vertical has no element, so
	    the role and the orientation are both written.</p>
	    <div class="demo-stage">
	      <p class="sep-prose">A thematic break between two passages: the rule
	      is what says the second is a new one.</p>
	\(_ruleSemantic.markup)
	      <p class="sep-prose">So the rule is content here, and an
	      <code>&lt;hr&gt;</code> is what it already was.</p>
	      <div class="sep-card">
	        <h3 class="sep-card-title">A heading already said it</h3>
	\(_ruleDecorative.markup)
	        <p class="sep-prose">The line under a heading repeats the boundary
	        the heading drew, so it is hidden.</p>
	      </div>
	      <div class="sep-split">
	        <span>Two groups on one line</span>
	\(_ruleVertical.markup)
	        <span>and only the rule between them</span>
	      </div>
	    </div>
	  </section>

	  <section class="demo-part">
	    <h2>Skeleton</h2>
	    <p class="pane-note">Four shapes and no lengths of their own: the shape
	    is a closed vocabulary the stylesheet measures, so an instance cannot
	    carry a size past the tokens. The pulse runs for
	    <code>calc(var(--motion-base) * 9)</code>, so the reduced-motion block
	    that zeroes that token stops it — a literal duration would keep running
	    where the design system said stop.</p>
	    <div class="demo-stage">
	      <div class="skeleton-card">
	        <div class="skeleton-head">
	\(_skelCircle.markup)
	          <div class="skeleton-lines">
	\(_skelLine.markup)
	\(_skelShort.markup)
	          </div>
	        </div>
	\(_skelBlock.markup)
	      </div>
	    </div>
	    <p class="pane-note">Every bar is <code>aria-hidden</code>: a placeholder
	    is the shape of content that has not arrived, and announcing it announces
	    nothing. <code>aria-busy="true"</code> is the other half and is not
	    written here — it belongs on the element whose content is on its way,
	    which is the caller's element and not the placeholder's, and on this
	    screen nothing is on its way at all. shadcn's Skeleton writes neither.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">None, and none of these four is a candidate for
	    one: a breadcrumb's current page is the route, an avatar's identity is
	    its parameter, and a separator is a boundary. The near miss is the
	    skeleton, which does stand for a loading state — but that state belongs
	    to the region whose rows have not arrived, never to the placeholder, and
	    a region with rows is not showing a skeleton. The field this screen
	    would hold is one another screen owns.</p>
	    <p class="claim"><code>[data-live]</code> 0 · <code>[data-machine]</code> 0 · <code>[id]</code> 0 · handler modules 0</p>
	    <p class="pane-note">The third count is the one worth reading: nothing
	    on this screen fires, so no arrow is narrowed to anything, so not one
	    element needs an id.</p>
	    <p class="pane-note">A fourth zero would be the keyboard, and it is
	    empty rather than unexamined. The roving-tabstop deferral the rest of
	    the catalog carries belongs to patterns that group N affordances under
	    one label and have to move focus between them; none of these four
	    groups any. The trail is links in document order, and the other three
	    hold no affordance at all — so there is nothing here to defer, which is
	    a different sentence from nothing having been considered.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">None — and unlike the two other chartless screens
	    here, not one of these four was ever a candidate, because a machine
	    holds a field and none of them has one. The table below is what stands
	    in its place: for a component with no state and no variants, the tree it
	    emits is its whole content. Each row names the node it describes and
	    exactly what that node tells a reader, so the suite folds this screen's
	    markup through it in both directions — a row whose node the markup does
	    not carry fails, and so does any role, <code>aria-*</code> or image
	    <code>alt</code> on the screen that no row lists. The last row is not
	    one of the four: the fold is over the whole screen, so the chrome every
	    route wears is listed with them.</p>
	    <div class="aria-scroll">
	      <table class="aria-table">
	        <thead>
	          <tr><th scope="col">part</th><th scope="col">what the tree is told</th><th scope="col">why that</th></tr>
	        </thead>
	        <tbody>
	\(ariaRows)
	        </tbody>
	      </table>
	    </div>
	  </section>
	</section>
	"""

// The dropdown's items in document order — three links and a radio set — and
// the whole reason the surface owns the row: a caret crosses all six, and an
// item that owned a region of its own could not be walked, because a region's
// members are its own.
_openLinks: [
	{name: "switch", label: "Switch", id: "mi-open-switch", route: "switch"},
	{name: "checkbox", label: "Checkbox", id: "mi-open-checkbox", route: "checkbox"},
	{name: "radio_group", label: "Radio group", id: "mi-open-radio-group", route: "radio-group"},
]

_openRadio: [
	{name: "andy", label: "Andy", id: "mi-profile-andy"},
	{name: "benoit", label: "Benoit", id: "mi-profile-benoit"},
	{name: "luis", label: "Luis", id: "mi-profile-luis"},
]

// The surface's own list, in document order and stripped to what a caret needs.
_openItems: [for i in list.Concat([_openLinks, _openRadio]) {
	{name: i.name, label: i.label, id: i.id}
}]

_menuPages: #MenuGroup & {
	key:  "pages"
	name: "Pages"
	items: [for i in _openLinks {
		(#MenuLink & {label: i.label, route: i.route, id: i.id, focus: "cur_\(i.name)"}).markup
	}]
}

_menuProfile: #MenuRadioGroup & {
	collection: "menu_profile_demo"
	field:      "profile"
	key:        "profile"
	name:       "Profile"
	items: [
		{name: "andy", label: "Andy"},
		{name: "benoit", label: "Benoit"},
		{name: "luis", label: "Luis"},
	]
	walked: true
	focus: {andy: "cur_andy", benoit: "cur_benoit", luis: "cur_luis"}
}

_dropdownMenu: #DropdownMenu & {
	key:        "open"
	label:      "Open"
	collection: "menu_profile_demo"
	items:      _openItems
	itemCharts: [_menuProfile.machine]
	groups: [_menuPages.markup, _menuProfile.markup]
}

// Two items, ONE row: a surface that walks its items owns the row they write,
// so what were two rows are two columns. Each keeps its own chart, run beside
// the caret's.
_viewItems: [
	{name: "bookmarks", label: "Bookmarks bar", id: "mi-bookmarks"},
	{name: "urls", label: "Full URLs", id: "mi-urls"},
]

_menuBookmarks: #MenuCheckItem & {
	collection: "menu_option_demo"
	field:      "chk_bookmarks"
	key:        "bookmarks"
	label:      "Bookmarks bar"
	focus:      "cur_bookmarks"
}

_menuUrls: #MenuCheckItem & {
	collection: "menu_option_demo"
	field:      "chk_urls"
	key:        "urls"
	label:      "Full URLs"
	focus:      "cur_urls"
}

_menuOptions: #MenuGroup & {
	key:  "view"
	name: "Options"
	items: [_menuBookmarks.markup, _menuUrls.markup]
}

_goLinks: [
	{name: "tabs", label: "Tabs", id: "mi-go-tabs", route: "tabs"},
	{name: "accordion", label: "Accordion", id: "mi-go-accordion", route: "accordion"},
	// Toast beside Tabs on purpose: two labels sharing a first letter is what
	// typeahead is FOR, and the catalog should carry the case rather than dodge
	// it. Typing "t" reaches Tabs and "to" reaches Toast, which is the pattern
	// working; what it costs is that the walk cannot select the shadowed arrow,
	// and the walk says so as an advisory rather than calling the arrow dead.
	{name: "toast", label: "Toast", id: "mi-go-toast", route: "toast"},
]

_menuGo: #MenuGroup & {
	key:  "go"
	name: "Pages"
	items: [for i in _goLinks {
		(#MenuLink & {label: i.label, route: i.route, id: i.id, focus: "cur_\(i.name)"}).markup
	}]
}

_menubar: #Menubar & {
	label:      "Menubar"
	collection: "menubar_demo"
	menus: [
		{
			key: "view", label: "View", groups: [_menuOptions.markup]
			collection: "menu_option_demo"
			items:      _viewItems
			itemCharts: [_menuBookmarks.machine, _menuUrls.machine]
		},
		{
			key: "go", label: "Go", groups: [_menuGo.markup]
			collection: "menu_go_demo"
			items: [for i in _goLinks {{name: i.name, label: i.label, id: i.id}}]
		},
	]
}

// The third container, and the one that needed the terminal to grow: the same
// surface with a right-click in front of it.
_ctxLinks: [
	{name: "popover", label: "Popover", id: "mi-ctx-popover", route: "popover"},
	{name: "sheet", label: "Sheet", id: "mi-ctx-sheet", route: "sheet"},
	{name: "overlays", label: "Overlays", id: "mi-ctx-overlays", route: "overlays"},
]

_menuCtxItems: #MenuGroup & {
	key:  "ctx"
	name: "Go to"
	items: [for i in _ctxLinks {
		(#MenuLink & {label: i.label, route: i.route, id: i.id, focus: "cur_\(i.name)"}).markup
	}]
}

_contextMenu: #ContextMenu & {
	collection: "context_menu_demo"
	key:        "ctx"
	label:      "Right-click anywhere in this panel"
	name:       "Panel"
	groups: [_menuCtxItems.markup]
	items: [for i in _ctxLinks {{name: i.name, label: i.label, id: i.id}}]
}

menuScreen: markup: """
	<section class="screen screen-menu" data-screen="menu">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Dropdown menu · Menubar</h1>
	    <p class="lede">Two containers over one surface. A menu is
	    <a data-route="overlays">the tier-0 popover</a> carrying a real ARIA
	    pattern, and what separates shadcn's DropdownMenu from its Menubar is
	    only whether one trigger stands in front of that surface or a bar of
	    them. The items are where the work is: a menu's tree admits items,
	    groups and separators and nothing else, a plain item's command is a
	    navigation because that is the one command this app performs without a
	    handler module, and a checkbox item is the fifth control here to run
	    the binary chart.</p>
	  </header>

	  <section class="demo-arm">
	    <h2>Dropdown menu</h2>
	    <p class="arm-note">One trigger, one surface, two groups with a
	    separator between them. The links go where they say; the profile set is
	    <a data-route="radio-group">the radio group's chart</a> under
	    <code>menuitemradio</code>, so exactly one is checked and clicking the
	    checked one writes nothing. Openness is in neither chart:
	    <code>commandfor</code> opens the surface, Esc and a click outside
	    close it, and focus comes back to the trigger — all of it the
	    browser's.</p>
	    <div class="demo-stage">
	\(_dropdownMenu.markup)
	    </div>
	  </section>

	  <section class="demo-arm">
	    <h2>Menubar</h2>
	    <p class="arm-note">The same surface twice, under one
	    <code>role="menubar"</code>. The bar holds triggers and nothing else —
	    both surfaces stand outside it, because a menubar admits the children a
	    menu admits and a menu is not one of them; they are in the top layer
	    when open and placed against their trigger's
	    <code>anchor-name</code>, so where they sit in the document costs
	    nothing. The two checkbox items are two regions over two rows of one
	    collection, which is the pair the <a data-route="switch">switch screen</a>
	    makes and a menu changes nothing about.</p>
	    <div class="demo-stage">
	\(_menubar.markup)
	    </div>
	  </section>

	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">Three rows across two collections, one per
	    stateful region. The profile row carries the derived
	    <code>aria-checked</code> column per option that
	    <a data-route="toggle-group">every single-select here</a> carries; each
	    checkbox item's row is its field and nothing else, because one trigger
	    owns one row.</p>
	    <div class="rowview" data-live="menu_profile_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","profile":"andy","chk_andy":"true","chk_benoit":"false","chk_luis":"false"}'>
	      <code class="row-readout" data-text="id: {id} · profile: {profile} · andy: {chk_andy} · benoit: {chk_benoit} · luis: {chk_luis}">id: the · profile: andy · andy: true · benoit: false · luis: false</code>
	    </div>
	    <div class="rowview" data-live="menu_option_demo" data-filter="id=eq.bookmarks"
	         data-empty-row='{"id":"bookmarks","checked":"false"}'>
	      <code class="row-readout" data-text="id: {id} · checked: {checked}">id: bookmarks · checked: false</code>
	    </div>
	    <div class="rowview" data-live="menu_option_demo" data-filter="id=eq.urls"
	         data-empty-row='{"id":"urls","checked":"false"}'>
	      <code class="row-readout" data-text="id: {id} · checked: {checked}">id: urls · checked: false</code>
	    </div>
	  </section>

	  <section class="demo-pane">
	    <h2>The machines</h2>
	    <p class="pane-note">Two charts, neither of them new. The first is the
	    single-select generator — one state per option, one arrow per (state,
	    other option) pair, its literal assigns moving every
	    <code>chk_</code> column as one row. The second is the binary chart the
	    switch, the checkbox, the toggle and the collapsible run, narrowed to
	    this item's own id; the other checkbox item's is that same chart with
	    <code>mi-bookmarks</code> read as <code>mi-urls</code>, which is a claim
	    the suite checks rather than one this pane repeats. Openness is in
	    neither, because openness is not this component's to hold.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_menuProfile.machine), "", "  "))</pre>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_menuBookmarks.machine), "", "  "))</pre>
	  </section>

	  <section class="demo-pane">
	    <h2>The tree</h2>
	    <p class="pane-note">A menu's accessibility tree admits
	    <code>menuitem</code>, <code>menuitemradio</code>,
	    <code>menuitemcheckbox</code>, <code>group</code> and
	    <code>separator</code>. So a group heading a reader can see is not a
	    node the tree may hold: it carries the id the group's
	    <code>aria-labelledby</code> names and is <code>aria-hidden</code>,
	    which is how one string names the group and shows above it without being
	    written twice — a hidden node still counts when
	    <code>aria-labelledby</code> points straight at it. That is
	    <a data-route="radio-group">the radio group's legend</a> inverted, where the
	    name is a node outside the group and stays in the tree.</p>
	    <div class="aria-scroll">
	      <table class="aria-table">
	        <thead>
	          <tr><th scope="col">node</th><th scope="col">what the tree is told</th><th scope="col">why that</th></tr>
	        </thead>
	        <tbody>
	          <tr><th scope="row">the dropdown trigger</th><td>a button, <code>aria-haspopup="menu"</code>, and an <code>aria-expanded</code> nobody wrote</td><td>a popover invoker's expandedness is the UA's; writing it would be a second spelling of a fact the browser already states</td></tr>
	          <tr><th scope="row">the surface</th><td><code>role="menu"</code>, named by its trigger</td><td>a menu's name is the control that opens it, so <code>aria-labelledby</code> points back at that button</td></tr>
	          <tr><th scope="row">a group</th><td><code>role="group"</code>, named by the heading inside it</td><td>a group is one of the four things a menu may hold, and it is what keeps two sets of items apart</td></tr>
	          <tr><th scope="row">a group heading</th><td>nothing — <code>aria-hidden="true"</code></td><td>it is not an item, a group or a separator, so it may not be a child of the menu; as the group's <code>aria-labelledby</code> target its text is read anyway</td></tr>
	          <tr><th scope="row">a plain item</th><td><code>role="menuitem"</code>, on an <code>&lt;a href&gt;</code></td><td>a menu item invokes a command, and a navigation is the only command with no handler module behind it</td></tr>
	          <tr><th scope="row">a checkbox item</th><td><code>role="menuitemcheckbox"</code>, <code>aria-checked</code> bound to its row</td><td>the attribute's values are the machine's state names, so one field spells the semantics and the styling hook</td></tr>
	          <tr><th scope="row">a radio item</th><td><code>role="menuitemradio"</code>, <code>aria-checked</code> bound to a derived column</td><td>N triggers share one field, so the per-option fact is a column the arrows move together</td></tr>
	          <tr><th scope="row">a tick</th><td>nothing — <code>aria-hidden="true"</code></td><td><code>aria-checked</code> already carries it, and a glyph inside the item would join the item's accessible name</td></tr>
	          <tr><th scope="row">a separator</th><td><code>role="separator"</code></td><td>the boundary between two groups, and not focusable, so nothing about orientation is stated</td></tr>
	          <tr><th scope="row">the bar</th><td><code>role="menubar"</code>, <code>aria-label="Menubar"</code></td><td>a bar that names nothing is announced as "menu bar" and no more</td></tr>
	          <tr><th scope="row">a bar trigger</th><td><code>role="menuitem"</code>, <code>aria-haspopup="menu"</code></td><td>a menubar's children are menuitems — which is exactly why the two surfaces stand outside the bar</td></tr>
	        </tbody>
	      </table>
	    </div>
	    <p class="pane-note">No shortcut hint stands beside any item. A machine
	    can key on <code>keydown</code> and can read the pressed key through the
	    event leaf, but it carries no equality to test that key with, so no
	    binding can be selected by one — and ⌘K printed beside an item that
	    answers to no such thing is an overclaim in the markup.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">What ships is the platform's and the button's: Tab
	    reaches a trigger and Space or Enter opens it, Esc closes the surface
	    and returns focus to the trigger, a click outside dismisses it, and each
	    item is a real button or a real link, so Tab reaches every one and Space
	    or Enter invokes it. What does not ship is APG's composite contract —
	    arrows moving one tab stop through the items, Home and End, typeahead,
	    and Left and Right between the bar's menus. Those want a per-row
	    <code>active</code> column and a tabstop that MOVES with it. The
	    projection answers the first — <a data-route="data-table">Data table</a> and
	    <a data-route="calendar">Calendar</a> both bind
	    <code>aria-activedescendant</code> off it — but virtual focus needs a
	    container holding the focus, and a menu's items are real buttons and
	    links, each already a tab stop of its own. No clause moves a tabstop, no
	    script stands in for one, and no <code>tabindex</code> is emitted at
	    all.</p>
	    <p class="pane-note">The deferral costs more here than on the tab strip,
	    and filing it under the same sentence would be the overclaim. The role
	    is itself a promise about the keyboard: a reader hearing "menu" is told
	    the arrows belong to the page, and here they do nothing. A tablist
	    promises less, because a reader arrives at a tab by Tab under either
	    design.</p>
	    <p class="pane-note">It ships anyway, on the line this catalog has
	    already drawn. <a data-route="command">The palette</a> claims neither
	    <code>role="combobox"</code> nor <code>role="listbox"</code>, because
	    APG's combobox needs the <code>aria-activedescendant</code> that same
	    projection would supply and without it there is no way to reach an
	    option at all. A menu falls on the other side of that line: every item
	    keeps its own tab stop, so every item is reachable and operable with no
	    arrow key anywhere. What the deferral takes is the shortcut, not the
	    capability — and the half of the pattern APG guards hardest, dismissal,
	    is the browser's and arrives whole. A roving tabstop with no arrows to
	    move it would strand every item but one, which is the trade
	    <a data-route="toggle-group">the segmented control</a> names and a menu
	    makes sharper.</p>
	  </section>

	  <section class="demo-arm">
	    <h2>Context menu</h2>
	    <p class="arm-note">shadcn's third container over this surface, opened
	    by a right-click. It is the same <code>_#Surface</code> the two above
	    are: erase how it opens and the three are one generator.</p>
	\(_contextMenu.markup)
	    <div class="demo-row" data-live="context_menu_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","open":"false","x":0,"y":0}'>
	      <code class="row-readout" data-text="open: {open} · point: {x} / {y}">open: false · point: 0 / 0</code>
	    </div>
	  </section>

	  <section class="demo-pane">
	    <h2>What a right-click cost</h2>
	    <p class="pane-note">Two rows of this table used to read <em>no</em>,
	    and both were the terminal's rather than the vocabulary's. The machine
	    could always narrow on the event — any bubbling type is an event key, so
	    <code>contextmenu@\(_contextMenu._target)</code> selects a transition
	    exactly as a click does. What it could not do was answer the event
	    without the browser answering it too.</p>
	    <div class="matrix-wrap">
	      <table class="matrix">
	        <thead><tr><th scope="col">what a context menu needs</th><th scope="col">who holds it</th><th scope="col">how</th></tr></thead>
	        <tbody>
	          <tr><th scope="row">a surface in the top layer</th><td>the browser</td><td><code>popover</code> — the surface the two containers above already use</td></tr>
	          <tr><th scope="row">an arrow that opens on right-click</th><td>the machine</td><td><code>contextmenu@&lt;id&gt;</code>, a narrowed event key like any other</td></tr>
	          <tr><th scope="row">the UA's own menu suppressed</th><td>the interpreter</td><td><code>contextmenu</code> is a DISPLACING type: its default is cancelled wherever an arrow answers it, and nowhere else</td></tr>
	          <tr><th scope="row">placement at the pointer</th><td>CSS</td><td>the row holds two shares of the target's box, in parts per thousand; <code>anchor()</code> and <code>anchor-size()</code> multiply them back out</td></tr>
	          <tr><th scope="row">opening a surface no button invoked</th><td>the machine</td><td>the state transition records openness; light dismiss and Escape close it</td></tr>
	        </tbody>
	      </table>
	    </div>
	    <p class="pane-note">The claim the third row rests on did not move: every
	    cancel the terminal makes belongs to a gesture the markup declared. What
	    changed is which markup counts — an arrow keyed on a displacing type IS
	    that declaration, as much as a <code>data-key</code> map is. The set is
	    closed and <code>contextmenu</code> is the whole of it, so an arrow can
	    only displace a default that was already incoherent to keep. Right-click
	    a part of this screen no arrow names and the browser's own menu opens,
	    which is the narrowing doing its job.</p>
	    <p class="pane-note">The fourth row is the one worth reading twice.
	    <code>anchor-name</code> still places a surface against an ELEMENT and
	    never against a point — nothing about that changed. What the row holds is
	    where in the target the pointer was, as a share of its own box, so the
	    stored point means the same thing in a window of any size and a replay
	    needs no viewport pinned to it. The pixels are CSS's, and they are
	    recomputed rather than remembered.
	    <a data-route="overlays">The tooltip</a> is the same shape one screen over,
	    where hover is the platform's and openness is nobody's.</p>
	  </section>
	</section>
	"""

// The two sides of one parameter, so the pair demonstrates the way the switch's
// two rows do: nothing between these instances differs but the value of `edge`.
_sheetRight: #Sheet & {
	key:         "panel"
	trigger:     "Open the sheet"
	title:       "Sheet"
	description: "A dialog against a side. The element is the one /overlays centres; what pins it here is one attribute a stylesheet reads."
	body: """
		      <ul class="dialog-list">
		        <li>The top layer, the inert page and the returned focus came with the element.</li>
		        <li>The side is <code>data-edge</code>, and the margin that pins it is CSS.</li>
		        <li>The travel is <code>--motion-base</code>, so reduced motion lands it instantly.</li>
		      </ul>
		"""
}

_sheetLeft: #Sheet & {
	key:         "nav"
	edge:        "left"
	trigger:     "Open it from the left"
	title:       "The other side"
	description: "One value of one parameter apart from the panel beside it, and the same generator behind both."
	body: """
		      <p class="dialog-body">shadcn's Sheet takes a <code>side</code>; here the side is
		      <code>edge</code>, it reaches the DOM as <code>data-edge</code>, and this
		      screen's stylesheet is the only thing that reads it. No second element,
		      no variant class, no script.</p>
		"""
}

_drawer: #Drawer & {
	key:         "drawer"
	trigger:     "Open the drawer"
	title:       "Drawer"
	description: "The bottom edge, and nothing else — which is the whole of the claim that this is a name rather than a component."
	body: """
		      <p class="dialog-body">Upstream the drawer is its own component because it can be
		      dragged shut, and dragging is pointer events, which is script. Without
		      it a drawer is <code>edge: "bottom"</code>, so <code>#Drawer</code>
		      fixes that one value and adds nothing: this surface and the panel
		      behind it are one generator, called twice.</p>
		"""
}

_alert: #AlertDialog & {
	key:         "confirm"
	trigger:     "Delete the row"
	title:       "Delete this row?"
	description: "This would remove it for everyone and it cannot be undone. Nothing on this screen has a row, so the answer reaches nowhere — an outcome becomes a row through a machine arrow or a form submit, and this screen ships neither."
	dismiss:     "Cancel"
	ask:         "Delete"
	body: """
		      <p class="dialog-body">Both buttons close the surface the same way. What
		      separates them is the label and the focus, which is all a dialog can
		      separate them by until its outcome has somewhere to land.</p>
		"""
}

sheetScreen: markup: """
	<section class="screen screen-sheet" data-screen="sheet">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Sheet · Drawer · Alert dialog</h1>
	    <p class="lede">Three of shadcn's components with one generator between
	    them: the sheet is <a data-route="overlays">the dialog</a> given an edge, the
	    drawer is the sheet with that edge fixed, and the alert dialog is the
	    same surface asking a question instead of showing content. Two of those
	    differences are CSS; the third is a contract, so the screen prints that
	    contract clause by clause and says which half the platform keeps.</p>
	  </header>

	  <h2 class="stage-name">Sheet</h2>
	  <div class="demo-stage">
	\(_sheetRight.markup)
	\(_sheetLeft.markup)
	  </div>

	  <h2 class="stage-name">Drawer</h2>
	  <div class="demo-stage">
	\(_drawer.markup)
	  </div>

	  <section class="demo-pane">
	    <h2>Three names, one generator</h2>
	    <p class="pane-note">Each name fixes a parameter of the definition
	    <code>/overlays</code> already ships, and adds nothing else. What the
	    surfaces put in the document differs by the last column and by nothing
	    more, which is what the suite folds them together to check.</p>
	    <div class="matrix-wrap">
	      <table class="matrix">
	        <thead><tr><th scope="col">the name</th><th scope="col">what it fixes</th><th scope="col">what reaches the DOM</th></tr></thead>
	        <tbody>
	          <tr><th scope="row">#Sheet</th><td>edge: right, left or bottom</td><td>data-edge, on the same element</td></tr>
	          <tr><th scope="row">#Drawer</th><td>edge: bottom</td><td>data-edge="bottom", and nothing else</td></tr>
	          <tr><th scope="row">#AlertDialog</th><td>ask: the answer's label</td><td>role="alertdialog" and one more button</td></tr>
	          <tr><th scope="row">all three</th><td>modal, which either parameter forces</td><td>a &lt;dialog&gt; opened by command="show-modal"</td></tr>
	        </tbody>
	      </table>
	    </div>
	    <p class="pane-note">The edge forces modality rather than offering it: a
	    panel pinned to the side of a page that is still live is one a reader
	    Tabs straight out of without closing, and no arrangement of the
	    non-modal surface fixes that. So <code>edge</code> and <code>ask</code>
	    each unify <code>modal</code> to true, and the incoherent combinations
	    cannot be spelled.</p>
	  </section>

	  <h2 class="stage-name">Alert dialog</h2>
	  <div class="demo-stage">
	\(_alert.markup)
	  </div>

	  <section class="demo-pane">
	    <h2>What an alert dialog promises</h2>
	    <p class="pane-note">APG's alert dialog is a modal dialog that
	    interrupts to ask something, so it is named <em>and</em> described and
	    the answer is meant to be deliberate. Radix's AlertDialog differs from
	    its own Dialog in four places: the role, a description it insists on,
	    focus defaulted to the cancel control, and a press outside that does not
	    dismiss. Here is every clause and who keeps it.</p>
	    <div class="matrix-wrap">
	      <table class="matrix">
	        <thead><tr><th scope="col">the clause</th><th scope="col">who keeps it</th><th scope="col">the spelling</th></tr></thead>
	        <tbody>
	          <tr><th scope="row">modal, over an inert page</th><td>the element</td><td>command="show-modal" puts the rest of the document inert</td></tr>
	          <tr><th scope="row">role="alertdialog"</th><td>the markup</td><td>written, because a &lt;dialog&gt;'s implicit role is dialog</td></tr>
	          <tr><th scope="row">a name</th><td>the markup</td><td>aria-labelledby, at the surface's own heading</td></tr>
	          <tr><th scope="row">a description</th><td>the markup</td><td>aria-describedby — advisory on a dialog, required here, and #Dialog carried it already</td></tr>
	          <tr><th scope="row">no dismissal by a press outside</th><td>the element</td><td>a modal &lt;dialog&gt; has no light dismiss to give up</td></tr>
	          <tr><th scope="row">focus opens on the least destructive control</th><td>the markup</td><td>autofocus on Cancel, which is where Radix puts it too</td></tr>
	          <tr><th scope="row">focus contained, then returned</th><td>the element</td><td>there is nowhere outside left to Tab to, and the invoker gets it back</td></tr>
	          <tr><th scope="row">Escape does not end it</th><td class="no">nobody, here</td><td>closedby="none" is the attribute and is outside this tree's measured engine matrix; the other route is a cancel listener, which is script — and Radix's alert dialog closes on Escape too</td></tr>
	          <tr><th scope="row">the answer recorded</th><td class="no">nobody, here</td><td>returnValue reaches no row, and both buttons close the same way</td></tr>
	        </tbody>
	      </table>
	    </div>
	    <p class="pane-note">Three of those four are markup here and the fourth
	    arrives with the element: the row that reads as a lack on
	    <code>/overlays</code> — a modal surface with no light dismiss — is the
	    one that reads as the contract here. What is left is the eighth row, and
	    it is the finding: a close request cannot be refused without script in
	    this tree, so what ships is the deliberate <em>answer</em> and not an
	    undismissable surface, and the difference is printed rather than
	    glossed.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">None, for the reason <code>/overlays</code> gives:
	    openness dies with the dismissal that ends it, so there is nothing here
	    for a row to hold.</p>
	    <p class="claim"><code>[data-live]</code> 0 · <code>[data-filter]</code> 0 · <code>[data-empty-row]</code> 0 · <code>[data-machine]</code> 0 · handler modules 0</p>
	    <p class="pane-note">The near miss is the answer. An arrow narrowed to
	    the Delete button's id would record which control ended the question,
	    and the vocabulary spells that today — so this absence is a choice and
	    not a wall, the only one on the screen that is. What a dialog hands back
	    belongs to its caller, and the caller is the next rung.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">None, and the table above is what stands in its
	    place: read as a chart, every row is a state something already holds,
	    and the two the platform does not hold are the two that would need
	    one.</p>
	    <p class="pane-note">The motion sits in the same position. A sheet that
	    travels is a transition on <code>translate</code> over
	    <code>--motion-base</code>, with <code>@starting-style</code> supplying
	    the opening frame and <code>allow-discrete</code> keeping the surface
	    painted while it leaves the top layer. No duration on this screen is a
	    literal, so the reduced-motion block that zeroes the tokens lands every
	    edge instantly — the sheet arrives, and nothing depended on the arrival
	    taking time.</p>
	  </section>
	</section>
	"""

// One row, two forms, and the whole of the shell's write path. The handle is
// the form's one gated field, so the single `.invalid` the shell reveals can
// only be about it; the bio carries a length the control keeps by truncating.
formDemo: {
	row:   "the"
	table: "form_demo"

	handle: #Field & {
		id: "form-handle"
		label: text: "Handle"
		control: #Input & {
			name:           "handle"
			column:         "handle"
			required:       true
			maxLength:      24
			pattern:        "[a-z][a-z0-9_]{2,23}"
			placeholder:    "ada_lovelace"
			invalidMessage: "A lower-case letter first, then lower-case letters, digits and underscores — 3 to 24 characters."
		}
		hint: "Lower case, 3 to 24 characters: a letter first, then letters, digits and underscores. This is the field the refusal below is about."
	}

	bio: #Field & {
		id: "form-bio"
		label: text: "Bio"
		control: #Textarea & {
			name:        "bio"
			column:      "bio"
			maxLength:   240
			placeholder: "Wrote the first algorithm intended for a machine."
		}
		hint: "Up to 240 characters. The control stops at the limit instead of refusing it, so this field has nothing a submit could be turned down for."
	}

	_save:   #Button & {variant: "primary", label: "Save"}
	_delete: #Button & {variant: "danger", label: "Delete the row"}

	// The two forms the surface declares, stated here so the program's
	// declaration and the controls above it are one thing — and printed on the
	// screen where every other screen prints its chart.
	saveForm: {
		id:     "form-save"
		entity: "FormDemo"
		action: "upsert"
		flow:   "form-save"
		fields: [
			{name: "id", control: "hidden", value: row},
			handle.control.declared,
			bio.control.declared,
		]
	}
	clearForm: {
		id:     "form-clear"
		entity: "FormDemo"
		action: "delete"
		fields: []
	}

	_emptyRow: (omni.#attrJSON & {in: {id: row, handle: "", bio: ""}}).out

	// The delete sits in a LIST region over the one pinned row, so it renders
	// only once that row exists: the affordance and the thing it acts on
	// arrive together, and a delete of a row nothing wrote is unreachable
	// rather than refused.
	markup: """
		<omnishell--form>
		  <div class="formview" data-live="\(table)" data-filter="id=eq.\(row)"
		       data-empty-row='\(_emptyRow)'>
		    <form class="form-edit" data-form="\(saveForm.id)"
		          data-entity="\(table)" data-action="\(saveForm.action)">
		      <input type="hidden" name="id" data-value="\(row)">
		\(handle.markup)
		\(bio.markup)
		      <!-- Named by no aria-describedby, revealed or not: accname does not
		           skip a hidden node a description references, so the reference
		           would read the refusal into the control's description before
		           anything was typed. role="alert" is how the words reach a
		           reader instead — announced on the reveal, with its text already
		           in it. -->
		      <p class="invalid" id="form-invalid" role="alert" hidden>\(handle.control.invalidMessage)</p>
		      <div class="form-actions">
		\(_save.markup)
		      </div>
		    </form>
		  </div>
		  <div class="formclear" data-live="\(table)" data-filter="id=eq.\(row)" data-order="id.asc"
		       data-empty="No row yet. Save writes one — until then there is nothing to delete and no button to press.">
		    <template data-item><form class="form-drop" data-form="\(clearForm.id)"
		          data-entity="\(table)" data-action="\(clearForm.action)">
		\(_delete.markup)
		    </form></template>
		  </div>
		</omnishell--form>
		"""
}

formScreen: markup: """
	<section class="screen screen-form" data-screen="form">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Form</h1>
	    <p class="lede">Not a component so much as a contract, and the last
	    unexamined write path in this app. The shell turns the browser's own
	    validation OFF, gates every submit on <code>checkValidity()</code>, and
	    turns a refusal into a screen state and one revealed paragraph — which
	    is what makes a refusal a frame a reviewer can sign rather than a bubble
	    the UA draws. <a data-route="combobox">Combobox</a> and
	    <a data-route="select">Select</a> already write through this; here it is
	    written down.</p>
	  </header>
	  <div class="demo-stage">
	\(formDemo.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">One row, and the form above is a view of it. Both
	    controls bind their DEFAULT value — the input through its
	    <code>value</code> attribute, the textarea through its own text, which
	    is what a textarea's default value is — which is what makes the reset
	    the shell performs on an accepted write land on the row instead of
	    on blank. Save twice and watch the controls come back holding what the
	    row holds.</p>
	    <div class="rowview" data-live="\(formDemo.table)" data-filter="id=eq.\(formDemo.row)"
	         data-empty-row='\(formDemo._emptyRow)'>
	      <code class="row-readout" data-text="id: {id} · handle: &quot;{handle}&quot; · bio: &quot;{bio}&quot;">id: \(formDemo.row) · handle: "" · bio: ""</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The contract</h2>
	    <p class="pane-note">Where every other screen prints the machine it
	    runs, this one prints the form it declares. It is the same object the
	    program's surface carries and the same one the controls above were
	    emitted from, so a field that drifted out of the markup would drift out
	    of this too. <code>entity</code> here and <code>data-entity</code> in
	    the markup are the platform's two spellings of one collection: the
	    program's name for it, and its table's.</p>
	    <pre class="form-json">\(json.Indent(json.Marshal(formDemo.saveForm), "", "  "))</pre>
	    <dl class="contract">
	      <dt><code>form.noValidate = true</code></dt>
	      <dd>Set by the shell on every form it wires, deliberately. The UA's
	      own bubble is a surface no stylesheet reaches, no storyboard frame
	      holds and no visual battery photographs; what replaces it is a screen
	      state and a paragraph this page owns.</dd>
	      <dt><code>checkValidity()</code></dt>
	      <dd>The gate, and the only one. A form that fails it reaches no
	      store: no row is stated, the screen takes
	      <code>validation-error</code>, and the form's first
	      <code>.invalid</code> is revealed.</dd>
	      <dt>the FIRST <code>.invalid</code></dt>
	      <dd>One message per form is the whole vocabulary — the shell reveals
	      <code>form.querySelector(".invalid")</code> and nothing else. That is
	      why one control here carries a <code>pattern</code> and the other only
	      a <code>maxlength</code>: a second gated field would be refused in the
	      first one's words.</dd>
	      <dt>any <code>input</code> in the form</dt>
	      <dd>Hides the message and hands the screen back to its base state. A
	      keystroke is the only thing that clears a refusal; nothing expires and
	      nothing else forgives.</dd>
	      <dt><code>form.reset()</code>, then <code>success</code></dt>
	      <dd>Called on an accepted write — unless the reader typed into the
	      form while it was in flight, unsent edits not being the store's to
	      discard — before the state flashes for 600ms and hands back. Reset returns each control to its default
	      value, which is the row — the reason neither control here uses
	      <code>data-value</code>, which writes the shown value and would leave
	      the default blank. A late refusal landing inside that window keeps the
	      screen; only an undisturbed success hands back.</dd>
	      <dt><code>.store-error</code></dt>
	      <dd>The other refusal: a write the STORE turns down, revealed in the
	      submitting form beside the state it sets. Nothing on this screen can
	      reach it — every collection in this gallery is tab-tier, an in-memory
	      table with no constraint to break — so the paragraph is named here
	      rather than shipped, a paragraph nothing can reveal being a claim
	      nothing checks.</dd>
	    </dl>
	    <dl class="walls">
	      <dt><code>aria-invalid</code> on the refused control</dt>
	      <dd>The verdict is <code>checkValidity()</code>'s, taken inside the
	      shell's submit listener. It is not a column, so no binding carries it,
	      and the <code>invalid</code> event that names each refused control
	      does not bubble, so no region's delegated listener sees it either.
	      What the accessibility tree gets is the message, assertive and on the
	      reveal; what it does not get is the association between that message
	      and the field. <em>Closed by</em> the shell writing the attribute
	      where it already reveals the paragraph — this one needs no new
	      vocabulary, only the terminal doing it.</dd>
	      <dt>Two gated fields in one form</dt>
	      <dd>There is one paragraph to reveal, so a second gate would be
	      reported in the first one's words. <em>Not shipped</em>: the form
	      carries one gate and says which field it belongs to, rather than a
	      message that names the wrong one.</dd>
	      <dt>A Reset button</dt>
	      <dd>The shell already resets the form, calling
	      <code>form.reset()</code> itself on a success the reader did not
	      disturb, so a reset control would duplicate a reset the screen does
	      not own. <em>Not shipped</em>: the only reset here is that one, and
	      the default-value binding above is what it restores.
	      Two variants ship because two is what there is work for.</dd>
	    </dl>
	    <p class="pane-note">Nothing on this screen defers a keyboard contract.
	    A form is not a composite widget: every control is its own tab stop, its
	    label is what a reader hears on arrival, and the UA owns the order. The
	    roving-tabindex deferral the rest of the catalog carries belongs to the
	    patterns that group N affordances under one name, and a form groups
	    none.</p>
	  </section>
	</section>
	"""

// Public, like the combobox and the select: the query column's constraint is
// generated from the same length the filter control carries, and the entities
// live in program.cue.
tableDemo: #Table & {
	collection:   "table_row"
	queries:      "table_query"
	caption:      "Invoices. The order is one of four the header offers, and the caption is not it."
	filterColumn: "payer"
	filterLabel:  "Filter by payer"
	placeholder:  "Ada"
	hint:         "Every keystroke states a row, and the table's region reads again under the new predicate."
	none:         "No rows here. Add one above, or clear the filter."
	columns: [
		{col: "id", head: "Invoice", control: "text", placeholder: "INV-004"},
		{col: "payer", head: "Payer", control: "text", placeholder: "Ada Lovelace"},
		{col: "status", head: "Status", control: "select", options: ["Paid", "Pending", "Unpaid"]},
		{col: "amount", head: "Amount", control: "text", placeholder: "250.00", numeric: true},
	]
	mintForm:    "table-mint"
	mintLegend:  "Add a row"
	mintButton:  "Add"
	mintHint:    "This collection is seeded by nothing, so every row in the table is one you wrote — and it dies with the tab."
	mintInvalid: "Every column is required: an invoice number, a payer, a status and an amount."
}

_notes: #ScrollArea & {
	axis: "y"
	name: "Release notes"
	body: """
		    <div class="notes">
		      <h3 class="notes-head">0.4.0</h3>
		      <p>A table is a region of many rows, and its row is an item
		      template like any other.</p>
		      <h3 class="notes-head">0.3.0</h3>
		      <p>A machine reads the value off its own event, so what a reader
		      types is a column.</p>
		      <h3 class="notes-head">0.2.0</h3>
		      <p>Being in a state is the pending timer: a delay is data in the
		      chart, and the terminal performs it.</p>
		      <h3 class="notes-head">0.1.0</h3>
		      <p>A component is a tag that expands to markup, tokens, and a
		      state machine that is data.</p>
		    </div>
		"""
}

_ratioWide:    #AspectRatio & {ratio: "16-9", body: "        <p class=\"ratio-face\">16 / 9</p>"}
_ratioClassic: #AspectRatio & {ratio: "4-3", body: "        <p class=\"ratio-face\">4 / 3</p>"}
_ratioSquare:  #AspectRatio & {ratio: "1-1", body: "        <p class=\"ratio-face\">1 / 1</p>"}

tableScreen: markup: """
	<section class="screen screen-table" data-screen="table">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Table</h1>
	    <p class="lede">The first component here whose content is a collection.
	    Everything before it bound one row or a fixed set of them; a table binds
	    however many rows there are, through the same <code>data-item</code>
	    template every list on this site uses. What a reader may then DO to those
	    rows is the screen's subject: the filter narrows them, and nothing sorts
	    them — the two halves of a table, and only one of them is expressible.</p>
	  </header>
	  <div class="demo-stage">
	\(tableDemo.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">No row readout stands beside this component,
	    because the component IS one. Every other screen prints the row its
	    control writes; here the rows are the content, and they are ordinary
	    rows of an ordinary collection — <code>table_row</code>, tab tier, dying
	    with the visit — rendered by a region whose item is a
	    <code>&lt;tr&gt;</code>.</p>
	    <p class="pane-note">They are yours because nothing else writes them:
	    <code>table_row</code> declares no <code>seed:</code>, so the collection
	    opens empty and the minting form ships with the component, as it does on
	    <a class="pane-link" data-route="select">Select</a>.
	    <a class="pane-link" data-route="command">Command</a> answers an empty
	    collection with six columns of one row instead, which is the one answer a
	    table cannot take — collapsing rows into columns is what this screen exists
	    not to do. It could have been
	    seeded — the terminal writes a <code>tab</code> entity's seed rows when it
	    first opens the collection, which is how
	    <a class="pane-link" data-route="data-table">Data table</a> states eight
	    invoices and ships no minting form at all. The columns are stated once and
	    emitted three times either way: the header row, the row template, and that
	    form's controls.</p>
	    <p class="pane-note">The other row on the screen is the filter's, and it
	    is a row like any other.</p>
	    <div class="rowview" data-live="table_query" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","state":"pending","query":""}'>
	      <code class="row-readout" data-text="id: {id} · state: {state} · query: {query}">id: the · state: pending · query: </code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">Two states, and the first is the arrival.
	    <code>after: {"0": "typing"}</code> is the terminal's clock striking on
	    entry, the only wait a screen can arm with no reader in it, and here it
	    is aimed at the row the table's frame hangs off, because a table has to
	    be on the screen before anyone types. A seeded row needs no such arrow —
	    which is why <a class="pane-link" data-route="data-table">Data table</a> and
	    <a class="pane-link" data-route="command">Command</a> draw none. <code>typing</code> then records what the
	    reader types through a targetless arrow: it acts and stays, which is how
	    one state holds a continuously changing value. That state declares no
	    wait, so the screen comes to rest as soon as it has arrived.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(tableDemo.machine), "", "  "))</pre>
	  </section>
	  <section class="demo-pane">
	    <h2>The filter, and the sort</h2>
	    <p class="pane-note">Filtering ships. The field's arrow assigns the
	    event's own <code>value</code> into the query row, and the
	    <code>&lt;tbody&gt;</code> is a region nested inside the frame's item
	    whose filter interpolates that column — <code>payer=ilike.*…*</code>,
	    with the enclosing row's query between the wildcards. When the column
	    moves, the filter no longer matches the one the node was hydrated with,
	    and the region reads again. That is the whole of it: no debounce, no list held anywhere but
	    the store, no script.</p>
	    <p class="pane-note">One thing had to be spelled a particular way to
	    work at this arity. A region's render sweeps every child that is not one
	    of its rows, the <code>&lt;template data-item&gt;</code> included — so a
	    nested region that re-hydrates finds no template, reads as a slot, and
	    throws on the second matching row. The row template is therefore NAMED,
	    and the <code>&lt;tbody&gt;</code> points at it with
	    <code>data-template</code>: a named template lives in the screen's own
	    map, which no render sweeps.
	    <a class="pane-link" data-route="command">Command</a> never met this, because
	    every one of its filtered regions binds a single row.</p>
	    <p class="pane-note">Sorting does not ship, and no column header here is
	    a control. A region's order is <code>data-order</code>, and the
	    interpreter reads it RAW: the filter beside it is interpolated against
	    the row, this is handed to the store as written. No column can reach it,
	    and no machine can write it either — a machine writes columns of its own
	    row, and a region's order is not one. The order the caption states is a
	    literal in the markup, and editing the markup is the only way to change
	    it.</p>
	    <p class="pane-note">The contrast with
	    <a class="pane-link" data-route="pagination">Pagination</a> is exact. Moving
	    through pages is expressible because the component draws an ABSOLUTE
	    arrow per position, so relative movement needs no arithmetic. A sort has
	    that same shape — the columns are known, so four of them in two
	    directions are eight states, which is
	    <a class="pane-link" data-route="radio-group">the single-select chart</a>
	    once more — and the wire is not missing either. A region's item
	    templates may be narrowed by <code>data-when</code> matched against the
	    row, so eight arms each carrying a <code>&lt;tbody&gt;</code> whose
	    <code>data-order</code> is that arm's LITERAL needs no interpolation at
	    all. What it costs is a stamped copy of the table per order, and the
	    affordance moved off the column headers — a header lives in the frame
	    region and a machine hears only its own, so no arrow could reach one.
	    Refused for that price, not for want of a wire.</p>
	  </section>
	  <section class="demo-part">
	    <h2>Scroll area</h2>
	    <p class="pane-note">CSS, and one fact about it that is not CSS: a box
	    that scrolls is a box a keyboard reader has to be able to reach, so it
	    takes <code>tabindex="0"</code> and a name. Without the tabstop the only
	    way to move the content is a pointer or a wheel; without the name the
	    reader lands in a region that announces nothing. The table above is
	    inside this same component — its box is named by the caption it already
	    has, this one by a label of its own — and the axis is the only
	    parameter, because how far a box scrolls is the stylesheet's business.</p>
	    <div class="demo-stage">
	\(_notes.markup)
	    </div>
	  </section>
	  <section class="demo-part">
	    <h2>Aspect ratio</h2>
	    <p class="pane-note">One CSS property, and a closed vocabulary of
	    ratios: the shape is a class the stylesheet measures, so no instance
	    carries a length of its own — the rule
	    <a class="pane-link" data-route="breadcrumb">Skeleton</a>'s shapes follow.
	    No machine, no row, nothing to click: a component whose whole content is
	    one declaration earns none of the three.</p>
	    <div class="demo-stage ratio-row">
	\(_ratioWide.markup)
	\(_ratioClassic.markup)
	\(_ratioSquare.markup)
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>What it does not ship</h2>
	    <dl class="limits">
	      <dt>A sortable column header</dt>
	      <dd>Closed, by exactly the two things this entry named:
	      <code>data-order</code> takes a closed map now — every order in the
	      file, a column choosing among them — and a nested region re-hydrates on
	      a changed order the way it always did on a changed filter. Both halves
	      of the read count, which is what the second thing was.
	      <a data-route="data-table">The data table</a> is where it ships. This
	      screen still sorts nothing, and now that is a choice rather than a
	      wall: its caption states one order, and a table nobody can reorder is
	      the smaller thing to read.</dd>
	      <dt>A total, a count, or any aggregate row</dt>
	      <dd>A sum is a read across rows, and a region hands its template one
	      row at a time — row closure, the wall
	      <a data-route="command">the command palette</a> meets when it wants to say
	      how many matched. <em>Closed by</em> a pipeline at a tier that has one;
	      the tab tier has nothing to run it.</dd>
	      <dt>Selecting rows</dt>
	      <dd>A checkbox per row is one machine per row, which is
	      <a data-route="accordion">the accordion's multiple arm</a> and costs
	      nothing new. What has no answer is the header's tri-state box: it is a
	      function of the rows under it, one field cannot hold a function of a
	      collection, and the states that could are the subsets —
	      <a data-route="checkbox">the exponent the checkbox screen names</a> rather
	      than pays.</dd>
	      <dt>Deleting a row</dt>
	      <dd>A delete form is one submit away and would work. It is out because
	      the rows here are ones a reader minted seconds ago into a collection
	      that dies with the tab, and a per-row control that only removes turns
	      a component demo into a CRUD screen — <a data-route="catalog">a different app</a>,
	      not a different component.</dd>
	      <dt>The grid keyboard: arrow keys between cells</dt>
	      <dd>APG's grid moves a tabstop cell to cell, which is a per-cell
	      <code>tabindex</code> and an <code>active</code> column.
	      <a class="pane-link" data-route="data-table">Data table</a> is where that
	      lands, and it lands one level up: the grid is one tab stop,
	      <code>aria-activedescendant</code> names a ROW, and the arrows are
	      <code>data-key</code> over the projection's <code>next</code> and
	      <code>prev</code>. Nothing moves cell to cell there either. This screen
	      stays a plain table: the cells are text, the controls on it are in
	      document order, and no partial roving tabindex ships in their place — a
	      tabstop without the arrows that move it strands every cell it is not
	      on.</dd>
	    </dl>
	  </section>
	</section>
	"""

// Public, like /table's: the query column's constraint and the two seeds are
// read out of this instance by program.cue, so the schema and the markup are
// one declaration.
dataTable: #DataTable & {
	collection:   "data_row"
	cursors:      "data_cursor"
	key:          "dt"
	caption:      "Invoices. The order is one of four the header offers, and the caption is not it."
	filterColumn: "payer"
	filterLabel:  "Filter by payer"
	placeholder:  "Ada"
	hint:         "Every keystroke states the query and clears the choice, and the grid reads again under the new predicate."
	none:         "No payer matches that filter."
	opensOn:      "INV-1024"
	opensSorted:  "id_asc"
	pickForm:     "dt-pick"
	stepForm:     "dt-step"
	sortForm:     "dt-sort"
	pickLabel:    "Choose invoice"
	columns: [
		{col: "id", head: "Invoice", sortable: true},
		{col: "payer", head: "Payer"},
		{col: "status", head: "Status"},
		{col: "amount", head: "Amount", numeric: true, sortable: true},
	]
	rows: [
		{id: "INV-1024", payer: "Ada Lovelace", status: "Paid", amount: "250.00"},
		{id: "INV-1025", payer: "Grace Hopper", status: "Pending", amount: "150.00"},
		{id: "INV-1026", payer: "Ada Byron", status: "Unpaid", amount: "80.00"},
		{id: "INV-1027", payer: "Alan Turing", status: "Paid", amount: "420.00"},
		{id: "INV-1028", payer: "Barbara Liskov", status: "Pending", amount: "95.00"},
		{id: "INV-1029", payer: "Adele Goldberg", status: "Paid", amount: "310.00"},
		{id: "INV-1030", payer: "Frances Allen", status: "Unpaid", amount: "60.00"},
		{id: "INV-1031", payer: "Karen Sparck", status: "Paid", amount: "175.00"},
	]
}

// The attribute as it is emitted, with the one interpolated value elided: a
// screen may not paint a placeholder, because a rendered brace is how the
// visual battery catches a binding that never bound. The prose beside it says
// what the ellipsis stands for.
_projectShown: {chosen: eq: ["id", "…"], seat: "index", seats: "count", nxt: "next", prv: "prev"}

dataTableScreen: markup: """
	<section class="screen screen-data-table" data-screen="data-table">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Data table</h1>
	    <p class="lede">The same <code>&lt;tbody&gt;</code>
	    <a class="pane-link" data-route="table">Table</a> ships, under two facts it
	    did not have: the rows are stated by the program, and the region states
	    facts about them. What falls out is a grid whose selection is a derived
	    column rather than a column per row, and whose arrow keys are that
	    column's neighbour plus a form.</p>
	  </header>
	  <div class="demo-stage">
	\(dataTable.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">Eight invoices are on the screen and nobody typed
	    them. <code>seed:</code> is the program stating a collection's opening
	    world: a server tier renders those rows into
	    <code>900_seed.sql</code>, and a <code>tab</code> entity — which has no
	    migration to render into — has them written by the terminal itself when
	    it first opens the collection. Delete one and it stays deleted for as
	    long as the store lives; reload and the store is a new one, so the eight
	    are back.</p>
	    <p class="pane-note">That is the fact three shipped notes argue from the
	    other way round.
	    <a class="pane-link" data-route="command">Command</a>'s palette is six
	    columns of one row, <a class="pane-link" data-route="select">Select</a>
	    mints its options and <a class="pane-link" data-route="table">Table</a>
	    mints its rows, all three because a tab collection was taken to be
	    unseedable. Those screens are not rebuilt — their answers are still
	    honest components — but the record is corrected in place, and each
	    decision now says what it would be free to do.</p>
	    <p class="pane-note">The second row is the cursor's, and it is one row
	    of a second collection for the reason
	    <a class="pane-link" data-route="table">Table</a>'s is: an interpolated
	    filter is re-resolved when its parent's row moves, so the collection a
	    keystroke writes is not the collection the grid reads. It is seeded from
	    the machine's own initial world — the seed, the machine's
	    <code>context</code> and the readout's <code>data-empty-row</code> are
	    one CUE value emitted three times, so the three cannot disagree about
	    what the screen opens on. Two of them are observable: the seed is the row
	    the readout below prints, and the <code>context</code> is what the chart
	    carries. The third never runs — a read prepares its collection before it
	    answers, so the readout always finds its row — and it is emitted anyway
	    because a guard stating a different world would be worse than one that is
	    never reached.</p>
	    <div class="rowview" data-live="data_cursor" data-filter="id=eq.the"
	         data-empty-row='\(dataTable.emptyRow)'>
	      <code class="row-readout" data-text="id: {id} · state: {state} · query: {query} · cursor: {cursor}">id: the · state: typing · query:  · cursor: INV-1024</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">One state and one arrow, and the arrow has no
	    target: it acts and stays, which is how a single state holds a
	    continuously changing value.
	    <a class="pane-link" data-route="table">Table</a> carries a second state and
	    an <code>after</code> ahead of this one, and that arrow exists only to
	    state a row nothing else could write. The seed writes it here, so the
	    arrival is not a beat the screen passes through — it is where the screen
	    starts.</p>
	    <p class="pane-note">The arrow writes two columns. The query is the
	    event's own <code>value</code>; the cursor is the literal empty string,
	    because a row the filter has removed is not rendered — the id
	    <code>aria-activedescendant</code> points at is gone with it, and so are
	    the two forms the arrow keys submit. Clearing is the only answer a
	    machine has here: it writes columns of its own row, and which rows the
	    region holds is not one of them.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(dataTable.machine), "", "  "))</pre>
	  </section>
	  <section class="demo-pane">
	    <h2>The projection</h2>
	    <p class="pane-note">One attribute on the <code>&lt;tbody&gt;</code>,
	    five derived columns, and every clause out of a closed set:</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_projectShown), "", "  "))</pre>
	    <p class="pane-note">The ellipsis is where the cursor column is
	    interpolated — this screen prints no placeholder anywhere, because a
	    rendered brace is how the visual battery catches a binding that never
	    bound. It resolves against the ENCLOSING row, the cursor row the frame
	    binds, by the same interpolation a nested region's filter already uses:
	    the comparison happens once per pass, and the markup never compares
	    anything.</p>
	    <p class="pane-note">The answers are merged into each row before
	    binding, so nothing downstream learns a projection was there. Each
	    <code>&lt;tr&gt;</code> binds <code>aria-selected</code> from
	    <code>chosen</code> exactly as it binds a cell's text from
	    <code>payer</code> — one attribute binding, no comparison in the
	    markup, and no second spelling of the state.</p>
	    <p class="pane-note">That is what the <code>sel_</code> prefixes on
	    <a class="pane-link" data-route="tabs">Tabs</a>,
	    <a class="pane-link" data-route="picker">Picker</a> and
	    <a class="pane-link" data-route="menu">Menu</a> are paying for. There N ARIA
	    columns share one row, so none of them can be called
	    <code>aria-selected</code>, the chart carries an arrow per ordered pair
	    writing N literal assigns on each, and the option list is frozen at build
	    time. Here selection is one column on one row at any N, the chart carries
	    no arrow for it at all, and a ninth invoice is a row.</p>
	    <p class="pane-note">The derived columns never reach a transition. The
	    region keeps the STORED rows for a machine to read, so a chart stays
	    decidable from the row and the event that fired it — which is the
	    property a comparison leaking into a guard would have cost.</p>
	    <p class="pane-note">Three clauses and no more:
	    <code>chosen</code>, <code>nxt</code> and <code>prv</code>. The
	    projection's <code>index</code> and <code>count</code> answer a position
	    in the presented set, which is exactly what narrows when the filter
	    narrows — and this screen asks for neither, because a grid's rows have
	    nowhere to put them. Both pairs that could are refused below.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">The grid is one tab stop. Focus lands on the
	    <code>&lt;table&gt;</code> and stays there;
	    <code>aria-activedescendant</code> names the chosen row, and every row's
	    <code>aria-selected</code> is the same derived column, so what a reader
	    hears and what the stylesheet paints cannot disagree. Nothing calls
	    <code>focus()</code> — the interpreter has no such verb — which is why
	    the pattern that needs no focus move is the one this vocabulary can
	    state.</p>
	    <p class="pane-note">ArrowDown and ArrowUp are one attribute:
	    <code>data-key</code> maps a key to a form id, the id interpolates from
	    the cursor row, and it is read at event time — so it always names a form
	    the CHOSEN row owns. That row's two forms carry <code>nxt</code> and
	    <code>prv</code> in their hidden inputs — the neighbour the projection
	    named, clamped at the ends because wrapping is a pattern's decision and
	    APG makes it differently per pattern. No chart, no arithmetic, no module: a key
	    submits a form, the way a form with no button submits on change.</p>
	    <p class="pane-note">With nothing chosen the ids resolve to
	    <code>dt-next-</code> and <code>dt-prev-</code>, which a
	    <code>limit=1</code> region owns: one list under a cap over the same read,
	    writing the first row of it. So an arrow has somewhere to go on the beat
	    right after a keystroke cleared the choice. When the read matches nothing
	    it renders no pair — and the grid is not drawn either, because
	    <code>.dt-body</code> is then <code>:empty</code>. A table with no rows is
	    no tab stop, which is what keeps a key from reaching for a form the read
	    never rendered.</p>
	    <p class="pane-note">The keys are a closed set — the six APG moves
	    through a list — checked once at hydration. A key outside it is refused
	    there rather than going quiet at the first press, and an id naming no
	    form on the screen is refused at the press, before the key is cancelled:
	    an arrow that neither moved the grid nor scrolled the page would leave a
	    reader no signal at all.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>What it does not ship</h2>
	    <dl class="limits">
	      <dt>Home and End</dt>
	      <dd>The clause it asked for exists — <code>first</code> and
	      <code>last</code> took the walk against the refusals and passed, since
	      an extremum of the region's own rows is the same kind of answer a
	      neighbour is. What stands is the entry pair: a blank cursor
	      interpolates <code>dt-first-</code>, and the <code>limit=1</code>
	      region that answers the arrow keys' blank pair reads the first row by
	      construction. End wants the last, which is that read reversed — and
	      reversing it now means reversing every clause of the order map, one per
	      direction. <a data-route="command">The command palette</a> stands on the
	      same step with a literal order under it.</dd>
	      <dt>Arrow keys between cells</dt>
	      <dd>APG's grid moves within a row as well as between rows. Every
	      clause here answers about a ROW — a cell is not a row, and no clause
	      names one — so what ships is the row-level half, over cells that are
	      static text with nothing in them to move to. <em>Closed by</em> a
	      per-cell active column, which is this same design one level down.</dd>
	      <dt>Every positional ARIA attribute a row could carry</dt>
	      <dd><code>aria-rowcount</code> and <code>aria-rowindex</code> count the
	      TABLE's rows, its header row included, and the projection answers about
	      the region's own — so the index is off by the header, and the count has
	      nowhere to land, since <code>aria-rowcount</code> belongs on the grid
	      element while every answer arrives on a row. ARIA asks for neither while
	      every row is in the DOM, which is the case here.
	      <code>aria-posinset</code> and <code>aria-setsize</code> are the pair
	      the projection could answer, and ARIA 1.2 forbids them outright on a row
	      that descends from a table or a grid: with
	      <code>aria-level</code> and <code>aria-expanded</code> they belong to a
	      treegrid's hierarchy, and this is a flat grid. So a row here carries
	      exactly one ARIA state, <code>aria-selected</code>, and the position a
	      reader hears is the one <a class="pane-link" data-route="picker">the
	      picker's</a> <code>role="option"</code> may state.</dd>
	      <dt>Multiple selection, and the header's tri-state box</dt>
	      <dd>A checkbox per row is a stored column per row and costs nothing —
	      <a data-route="accordion">the accordion's multiple arm</a>. The header box
	      is the wall: <code>aria-checked="mixed"</code> is an aggregate over the
	      rows below it and has to land on the row that OWNS the list, while
	      every clause here answers on the rows the region itself holds — and at
	      zero checked there are no rows left to say it on. <em>Closed by</em> a
	      projection that writes onto the parent's row, which is a different
	      mechanism and wants its own walk.</dd>
	      <dt>An order the reader did not ask for</dt>
	      <dd>The header sorts, so what is refused here is the other direction:
	      an order that is not in the map. <code>data-order</code> interpolates a
	      KEY and never a clause — a row holding <code>amount.desc</code> would
	      be a row naming a COLUMN, and the orders this screen has would stop
	      being enumerable. A key the map does not carry is a
	      <code>ProgramError</code>, not an unordered read, and one sentence in
	      the component generates the map, the header's commands and the column's
	      own constraint — so the three cannot drift apart.</dd>
	      <dt>A total, or any aggregate over the rows</dt>
	      <dd>Unchanged, and for the reason the tri-state box is:
	      <code>count</code> answers on each row, so a sum has nowhere to land
	      that is not a row. <em>Closed by</em> a pipeline at a tier that has
	      one; the tab tier has nothing to run it.</dd>
	    </dl>
	  </section>
	</section>
	"""

// Two sections, six links, and every one naming a route this app serves — the
// suite checks each composed address against shell.yaml, as it does the menu
// screen's.
_navMenu: #NavigationMenu & {
	label: "Main"
	sections: [{
		key:   "controls"
		label: "Controls"
		items: [
			{label: "Switch", route: "switch"},
			{label: "Checkbox", route: "checkbox"},
			{label: "Slider", route: "slider"},
		]
	}, {
		key:   "surfaces"
		label: "Surfaces"
		items: [
			{label: "Overlays", route: "overlays"},
			{label: "Sheet", route: "sheet"},
			{label: "Menu", route: "menu"},
		]
	}]
}

// The same rail on the two boards it is written for. Nothing between them
// differs but where the rail is put: the wide one keeps it on the page behind
// a disclosure, the narrow one hands it to a dialog that already holds its own
// openness. The two nav landmarks are named apart because a reader meeting two
// regions called the same thing has no way to tell which one they are in.
_railBoard: #Sidebar & {
	key:    "board"
	label:  "Component pages"
	canvas: "The page the rail sits beside. Collapse it and this fills the width: the rail goes off the canvas rather than narrowing, which is shadcn's own offcanvas default."
}

_railDrawer: #Sidebar & {
	key:         "drawer"
	board:       "sheet"
	label:       "Component pages, narrow board"
	trigger:     "Open the rail"
	title:       "Component pages"
	description: "The rail a wide board keeps on the page. Here it is /sheet's left-edge dialog, so the top layer, the inert page, Esc and the returned focus all arrive with the element."
}

navigationScreen: markup: """
	<section class="screen screen-navigation" data-screen="navigation">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Navigation menu · Sidebar</h1>
	    <p class="lede">Two components assembled out of parts this catalog
	    already shipped: the bar is <a data-route="menu">the menubar</a> with links
	    for items, the rail's collapse is
	    <a data-route="checkbox">the binary chart</a> under
	    <code>aria-expanded</code>, and the narrow board is
	    <a data-route="sheet">the left-edge sheet</a>. What is new is one thing —
	    the rail's items are <em>rows</em>, so <code>aria-current</code> is a
	    column the region derives rather than a literal somebody keeps in step
	    with the router.</p>
	  </header>

	  <section class="demo-arm">
	    <h2>Navigation menu</h2>
	    <p class="arm-note">One trigger per section, one popover surface per
	    trigger, and every item an <code>&lt;a href&gt;</code> under
	    <code>role="menuitem"</code> — a navigation being the one command this
	    app performs with no handler module. The bar carries no
	    <code>aria-label</code>: the <code>&lt;nav&gt;</code> around it is
	    named, and a widget inside a landmark of the same name would hand a
	    reader the string twice. Openness is in no chart at all.</p>
	    <div class="demo-stage">
	\(_navMenu.markup)
	    </div>
	  </section>

	  <section class="demo-arm">
	    <h2>Sidebar — the wide board</h2>
	    <p class="arm-note">The rail stays on the page, and the control that
	    collapses it carries <code>aria-expanded</code> bound to its own row and
	    points at the <code>&lt;nav&gt;</code> through
	    <code>aria-controls</code>. That is a disclosure, whole: one field, one
	    arrow narrowed to the button's id, and a stylesheet reading the ARIA the
	    machine wrote. The rail is the button's sibling rather than its child,
	    because a region nested inside a singleton region is never hydrated.</p>
	    <div class="demo-stage">
	\(_railBoard.markup)
	    </div>
	  </section>

	  <section class="demo-arm">
	    <h2>Sidebar — the narrow board</h2>
	    <p class="arm-note">Where a rail will not fit beside the page it becomes
	    a dialog, and this one is <a data-route="sheet">the sheet</a> with
	    <code>edge: "left"</code> and the same rail for a body. It runs no
	    chart: a dialog holds its own openness, so the wide board's one machine
	    is exactly what the narrow board does not need.</p>
	    <div class="demo-stage">
	\(_railDrawer.markup)
	    </div>
	  </section>

	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">Three collections. The first is the disclosure's, a
	    field and nothing else. The second names the route the reader is on. The
	    third is the rail itself — five rows the program states as
	    <code>seed:</code>, which a <code>tab</code> collection has no migration
	    to render into, so the terminal writes them when it first opens the
	    collection. After each item's stored columns comes
	    <code>current</code>, which no row carries: it is the projection's
	    answer, merged in before binding and gone again before any chart could
	    read it.</p>
	    <div class="rowview" data-live="nav_sidebar_demo" data-filter="id=eq.the"
	         data-empty-row='{"id":"the","open":"true"}'>
	      <code class="row-readout" data-text="nav_sidebar_demo — id: {id} · open: {open}">nav_sidebar_demo — id: the · open: true</code>
	    </div>
	    <div class="rowbox" data-live="nav_state" data-filter="id=eq.the">
	      <template data-item>
	        <div class="rowgroup">
	          <code class="row-readout" data-text="nav_state — id: {id} · current: {current}"></code>
	          <ul class="rowlist" data-live="nav_rail_item" data-order="pos.asc"
	              data-project='{"current":{"eq":["id","{current}"]}}'>
	            <template data-item>
	              <li><code class="row-readout" data-text="nav_rail_item — pos: {pos} · id: {id} · label: {label} · route: {route} → current: {current}"></code></li>
	            </template>
	          </ul>
	        </div>
	      </template>
	    </div>
	  </section>

	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">One chart on the screen, and it is the generator
	    five other controls in this catalog already run —
	    <a class="pane-link" data-route="checkbox">the checkbox, the toggle and the
	    collapsible</a>, <a class="pane-link" data-route="menu">the menu's checkbox
	    item</a>, and <a class="pane-link" data-route="accordion">the accordion's
	    multiple arm</a>, one per row. Two states, one arrow each, narrowed to the
	    trigger's own id. <a class="pane-link" data-route="switch">The switch</a> is
	    not one of them: its two arrows are unnarrowed, because the whole control
	    is the trigger.
	    Canonicalized by field name and trigger id it differs from
	    <a data-route="checkbox">the collapsible's</a> by exactly one key — a
	    sidebar opens expanded and a collapsible opens closed — and the suite
	    checks that rather than this pane asserting it. Nothing else on this
	    screen has a chart: the bar's openness is the browser's, the drawer's
	    is the element's, and the rail's item set is data.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(_railBoard.machine), "", "  "))</pre>
	  </section>

	  <section class="demo-pane">
	    <h2 id="nav-projection-head">The projection</h2>
	    <p class="pane-note">The rail is two regions deep because the comparison
	    needs both sides: the outer one binds the row naming the open route, the
	    inner one reads the items and asks, per row, whether its id is that
	    name. The comparison happens in the projection and never in a binding,
	    which is the rule the whole design rests on — a binding interpolates and
	    does not evaluate, so two rows have nowhere in the markup to meet.</p>
	    <omnishell--scroll-area>
	    <div class="scroll-area scroll-x aria-scroll" tabindex="0" role="region"
	         aria-labelledby="nav-projection-head">
	      <table class="aria-table">
	        <thead>
	          <tr><th scope="col">what</th><th scope="col">where it comes from</th><th scope="col">why not the other way</th></tr>
	        </thead>
	        <tbody>
	          <tr><th scope="row">the item set</th><td>rows of <code>nav_rail_item</code>, seeded by the program</td><td>a sixth page is a row, where every other item set in this catalog is a CUE-time list a machine's states are built from</td></tr>
	          <tr><th scope="row">the order</th><td><code>data-order="pos.asc"</code>, a literal</td><td>the interpreter reads <code>data-order</code> raw, so no column interpolates into it — the wall <a data-route="table">the table</a> names</td></tr>
	          <tr><th scope="row">the open route</th><td>the <code>current</code> column of <code>nav_state</code></td><td>a screen is handed only the params its path declares, and a static route declares none, so the route is a fact the program states</td></tr>
	          <tr><th scope="row">which item is current</th><td><code>data-project</code>'s <code>eq</code> clause, over each row's <code>id</code> and the enclosing row's <code>current</code></td><td>a binding interpolates and does not evaluate, so a row carrying its id and a row carrying the route have nowhere in the markup to meet</td></tr>
	          <tr><th scope="row"><code>aria-current</code></th><td>the answer, bound — so it reads <code>"true"</code> and <code>"false"</code></td><td>both are in the attribute's own vocabulary; the pattern's token <code>"page"</code> is what does not ship, and the note under this table says why</td></tr>
	          <tr><th scope="row">what a chart sees</th><td>the stored columns, and only those</td><td>the region keeps the stored rows for its machine, so a derived column reaches no guard, no assign and no target, and a chart stays decidable from the row alone</td></tr>
	        </tbody>
	      </table>
	    </div>
	    </omnishell--scroll-area>
	    <p class="pane-note"><code>aria-current="page"</code> would be a literal
	    on an item template narrowed by
	    <code>data-when="current=eq.true"</code> — the design's own answer to a
	    projection that emits booleans. The interpreter runs it; the emitter
	    does not let it out. Its kind lint checks a
	    <code>data-when</code>'s columns against the entity's declared fields
	    alone, and nothing there knows a region's <code>data-project</code>
	    widens the set a row can be matched on, so the arm is refused as naming
	    a column <code>nav_rail_item</code> does not have. What ships is the
	    weaker of two values the attribute admits, rather than a second column
	    carrying the token — the gap is one lint away and is named here instead
	    of worked around.</p>
	  </section>

	  <section class="demo-pane">
	    <h2 id="nav-not-head">What this is not</h2>
	    <p class="pane-note">shadcn's NavigationMenu opens on hover and slides a
	    shared viewport between panels. Neither half ships, and the two have
	    different reasons.</p>
	    <omnishell--scroll-area>
	    <div class="scroll-area scroll-x matrix-wrap" tabindex="0" role="region"
	         aria-labelledby="nav-not-head">
	      <table class="matrix">
	        <thead><tr><th scope="col">what it adds</th><th scope="col">who would hold it</th><th scope="col">today</th></tr></thead>
	        <tbody>
	          <tr><th scope="row">a panel that opens on hover</th><td>the browser</td><td class="no">no — <code>interestfor</code> is implemented in no engine, which is the wall <a data-route="overlays">the tip</a> prints</td></tr>
	          <tr><th scope="row">one viewport resized to the open panel</th><td>CSS</td><td class="no">no — the box has to be measured from the panel inside it, and a measurement is script</td></tr>
	          <tr><th scope="row">the panel placed under its trigger</th><td>CSS</td><td><code>anchor-name</code>, already how every surface in this gallery is placed</td></tr>
	          <tr><th scope="row">menu semantics on site navigation</th><td>ARIA</td><td>shipped, and it is a divergence: upstream is a plain <code>&lt;nav&gt;</code> with a list, where APG's menu pattern is written for a list of choices and also carries a navigation menubar example</td></tr>
	        </tbody>
	      </table>
	    </div>
	    </omnishell--scroll-area>
	    <p class="pane-note">The last row is the one to argue with rather than
	    the first two, and it is open rather than settled. What this catalog has
	    is the menu surface, whose one handler-free command is a navigation, so
	    a bar of links wears the roles it already carries; the landmark around
	    it is what tells a reader the region is navigation, and every item stays
	    a real link the browser follows. The cost of being wrong about it is
	    named one pane down: <code>role="menubar"</code> promises a reader that
	    the arrows belong to the bar, and here they do nothing.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">The rail asks for nothing. APG has no composite
	    pattern for a list of links, so every link being its own tab stop is the
	    contract in full — Tab reaches each one, Enter follows it, and no roving
	    <code>tabindex</code>, no <code>aria-activedescendant</code> and no key
	    binding is emitted anywhere on this screen. The disclosure is the same
	    story: a button is pressed by Space and Enter, which is the whole of what
	    a disclosure asks for. The two <code>tabindex</code> attributes that ARE
	    emitted are the prose tables', because a box that scrolls is a tab stop
	    and an unnamed one is a region a reader arrives in with nothing said —
	    <a class="pane-link" data-route="table">the rule the table's component
	    carries</a>.</p>
	    <p class="pane-note">The bar is where something is missing, and it is
	    one thing: APG's menubar moves a single tab stop between its triggers
	    with Left and Right, opens a menu on Down, and walks its items with the
	    arrows. This bar gives every trigger and every item a tab stop of its
	    own instead, so nothing is unreachable — what the gap costs is the
	    shortcut, not the capability, which is <a data-route="menu">the menu
	    screen's</a> trade unchanged.</p>
	    <p class="pane-note">It is worth saying exactly why that one is still
	    open, because a neighbouring gap has closed. A region may project the
	    <code>next</code> and <code>prev</code> row onto each row it holds, and
	    <code>data-key</code> submits a named form on an arrow key; together
	    they walk a list with no chart, no arithmetic and no
	    <code>focus()</code>. That closes the keyboard for the patterns APG
	    gives virtual focus, where moving is moving a <em>selection</em> and DOM
	    focus never leaves the container — listbox, combobox, grid, tree. A
	    menubar is not one of them: APG moves real focus between its triggers,
	    and moving focus is a DOM write with a reader on the other end of it. So
	    this is deferred on a mechanism nobody has built, not on a projection
	    that has already landed.</p>
	  </section>
	</section>
	"""

_popBare: #Popover & {
	key:   "bare"
	label: "What arrived free"
	body: """
		      <ul class="pop-list">
		        <li>The top layer, so no z-index is written anywhere on this screen.</li>
		        <li>A press anywhere outside closes it.</li>
		        <li>Escape closes it, and focus goes back to the button.</li>
		        <li>The button's <code>aria-expanded</code>, written by the UA.</li>
		      </ul>
		"""
}

// One instance per place, so the vocabulary is the stage rather than a caption
// under it. Opening a second while the first is still open is the other half of
// what the stage shows: an auto popover is in a stack the UA closes for you.
_popPlaces: [for p in placements {#Popover & {
	key:   p.place
	place: p.place
	label: p.place
	body:  "      <p class=\"pop-text\">\(p.says)</p>"
}}]

// A short label on purpose: the trigger is flush with the column's edge, so its
// own width is what is left for the surface to land in once the fallback fires.
_popFlip: #Popover & {
	key:   "flip"
	place: "inline-end"
	label: "Ask for the right"
	body: """
		      <p class="pop-text">This surface asks for the gutter after the trigger
		      and falls back to the one before it. Which side you are reading it on
		      is the browser's answer to whether the first one fits.</p>
		"""
}

_popManual: #Popover & {
	key:     "manual"
	label:   "Open the manual one"
	dismiss: "Close"
	manual:  true
	body: """
		      <p class="pop-text">One attribute different, and the press outside and
		      the Escape are both gone. This button is the only way out, which is
		      why the definition refuses a manual surface that has none.</p>
		"""
}

popoverScreen: markup: """
	<section class="screen screen-popover" data-screen="popover">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Popover</h1>
	    <p class="lede">The surface three screens in this catalog already open,
	    and none of them names. A button carrying <code>commandfor</code> and an
	    element carrying <code>popover</code> are the whole component: the top
	    layer, a press outside, Escape and the expanded state a reader hears all
	    arrive with those two attributes. Placement does not, and the matrix below
	    is where that row is marked. No row, no chart, no module — what this screen
	    has to show is the list of things it did not have to build, and the one
	    thing it did.</p>
	  </header>

	  <h2 class="stage-name">The primitive</h2>
	  <div class="demo-stage">
	\(_popBare.markup)
	  </div>

	  <h2 class="stage-name">Placement</h2>
	  <p class="stage-note">Four areas, one property. Open one and then another
	  without closing the first: a <code>popover="auto"</code> surface is in a
	  stack the UA keeps, so the one that was open goes.</p>
	  <div class="demo-stage pop-places">
	\(_popPlaces[0].markup)
	\(_popPlaces[1].markup)
	\(_popPlaces[2].markup)
	\(_popPlaces[3].markup)
	  </div>

	  <h2 class="stage-name">The fallback</h2>
	  <p class="stage-note">The trigger below is flush with the right edge of
	  this column and its surface asks for the gutter after it — a gutter this
	  page keeps narrower than the surface at every width short of a wide
	  desktop, so what paints is the mirrored area.
	  <code>position-try-fallbacks</code> is the whole of that: one declaration,
	  nothing measured, and the browser deciding at paint. Widen the window until
	  the gutter fits and the surface goes back to the side it asked for.</p>
	  <div class="demo-stage pop-edge">
	\(_popFlip.markup)
	  </div>

	  <h2 class="stage-name">The same element with the contract withdrawn</h2>
	  <p class="stage-note">A gift is only measurable against its absence.
	  <code>popover="manual"</code> is the same surface opened by the same
	  command, with light dismiss, Escape and the stack all gone.</p>
	  <div class="demo-stage">
	\(_popManual.markup)
	  </div>

	  <section class="demo-pane">
	    <h2 id="pop-values-head">What the attribute's two values buy</h2>
	    <p class="pane-note">Both surfaces above are one generator called twice.
	    Every row is a behaviour no line of this app implements, and the third
	    column is what is left when the value changes.</p>
	    <omnishell--scroll-area>
	    <div class="scroll-area scroll-x matrix-wrap" tabindex="0" role="region"
	         aria-labelledby="pop-values-head">
	      <table class="matrix">
	        <thead><tr><th scope="col">behaviour</th><th scope="col">popover="auto"</th><th scope="col">popover="manual"</th></tr></thead>
	        <tbody>
	          <tr><th scope="row">in the top layer</th><td>yes</td><td>yes</td></tr>
	          <tr><th scope="row">opened and closed by the invoker</th><td>yes</td><td>yes</td></tr>
	          <tr><th scope="row">the invoker's aria-expanded</th><td>the UA writes it</td><td>the UA writes it</td></tr>
	          <tr><th scope="row">a press outside closes it</th><td>yes</td><td class="no">no — nothing outside it closes it</td></tr>
	          <tr><th scope="row">Escape closes it</th><td>yes</td><td class="no">no</td></tr>
	          <tr><th scope="row">opening another closes this one</th><td>yes</td><td class="no">no — a manual surface is in no stack</td></tr>
	          <tr><th scope="row">focus returns to the invoker</th><td>nothing returns it — on Escape and on the invoker's own press it never left</td><td class="no">no — Tab to the surface's Close, press it, and focus lands on the document</td></tr>
	          <tr><th scope="row">placed against the trigger</th><td class="no">CSS, not the element</td><td class="no">CSS, not the element</td></tr>
	        </tbody>
	      </table>
	    </div>
	    </omnishell--scroll-area>
	    <p class="pane-note">The focus row is the one to read carefully, because
	    both cells have the same cause. A <code>command</code> invoker shows a
	    popover with the spec's <em>shouldRestoreFocus</em> false, so no popover
	    on this screen records an element to go back to — the auto surface only
	    looks like it restores because Escape and the invoker's own press are
	    both pressed with focus already ON the invoker. Tab into either surface
	    and close it from inside and focus lands on the document. Nothing here
	    calls <code>focus()</code>, so this is the platform's behaviour reported
	    and not a gap this screen chose.</p>
	    <p class="pane-note">The last row is the one the other screens lean on
	    hardest and the only one the element does not keep: an unplaced popover
	    opens in the middle of the viewport. What places it is
	    <code>anchor-name</code> on the trigger, <code>position-anchor</code> on
	    the surface and <code>position-area</code> for the side — three
	    properties in this screen's stylesheet, and no script.</p>
	  </section>

	  <section class="demo-pane">
	    <h2 id="pop-placement-head">The placement</h2>
	    <p class="pane-note">Printed as data where a stateful component prints
	    its chart, because for a component with no state this pairing is the
	    whole of what it does. Each place is a <code>position-area</code>
	    keyword, so the value on the element and the value in the property are
	    one spelling; each fallback is that keyword's mirror on the axis it
	    places on, derived from the place's own name rather than written beside
	    it. The suite folds this table through the screen's stylesheet and fails
	    on a place with no rule, a rule with no row, and a rule whose declared
	    area or fallback is not the row's.</p>
	    <omnishell--scroll-area>
	    <div class="scroll-area scroll-x placement-scroll" tabindex="0" role="region"
	         aria-labelledby="pop-placement-head">
	      <table class="placement-table">
	        <thead>
	          <tr><th scope="col">place</th><th scope="col">what the rule declares</th><th scope="col">fallback</th><th scope="col">where it lands</th></tr>
	        </thead>
	        <tbody>
	\(placementRows)
	        </tbody>
	      </table>
	    </div>
	    </omnishell--scroll-area>
	  </section>

	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">None, for the reason <a data-route="overlays">the
	    overlays screen</a> gives: openness dies with the dismissal that ends it,
	    so there is nothing here for a row to hold. The absence is counted rather
	    than claimed.</p>
	    <code class="absence">data-live: 0 · data-filter: 0 · data-empty-row: 0 · data-machine: 0 · handler modules: 0</code>
	  </section>

	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">None. What would be the chart on this screen is the
	    placement above, and placement is CSS. Printed here instead is the thing
	    this screen exists to name: four definitions this gallery already renders
	    are this surface with something added, and each of them re-derived it.</p>
	    <dl class="stands-on">
	      <dt><a data-route="overlays">The tip</a></dt>
	      <dd>This surface with text in it, its place fixed by the caller, and no
	      way out but the two the element supplies.</dd>
	      <dt><a data-route="overlays">The non-modal dialog</a></dt>
	      <dd>This surface plus a heading, a description,
	      <code>role="dialog"</code> naming both, and a dismiss button.</dd>
	      <dt><a data-route="picker">The picker's listbox</a></dt>
	      <dd>This surface carrying <code>role="listbox"</code>, its body a
	      region, and each option's command closing it on the way to writing a
	      row. It is the terminal's own definition rather than this app's, which
	      is where the factoring would have to land if it graduated.</dd>
	      <dt><a data-route="menu">The menu surface</a></dt>
	      <dd>This surface carrying <code>role="menu"</code> and a tree that
	      admits items alone, stood outside its trigger because a menubar admits
	      no menus.</dd>
	    </dl>
	    <p class="pane-note">None of the four is rewritten here. Each is its
	    screen's reviewed contract, and folding four artifacts onto a fifth is a
	    change to four screens for a factoring this one only has to state. What
	    ships is the primitive under its own name, so the next component that
	    wants a surface has somewhere to point.</p>
	    <p class="pane-note">What this screen does not ship, beyond the row and
	    the chart: a hover-opened surface, because <code>interestfor</code> is
	    implemented in no engine (<a data-route="overlays">the overlays screen</a>
	    prints that measurement); a surface placed at a point rather than against
	    an element, which <code>anchor-name</code> cannot express
	    (<a data-route="menu">the menu screen</a> refuses the context menu for it);
	    and any keyboard beyond the element's own — the trigger is a button, so
	    Space and Enter are native, and arrow keys inside a surface belong to the
	    content, which here is prose.</p>
	  </section>
	</section>
	"""
_weekdays: [
	{short: "Su", name: "Sunday"},
	{short: "Mo", name: "Monday"},
	{short: "Tu", name: "Tuesday"},
	{short: "We", name: "Wednesday"},
	{short: "Th", name: "Thursday"},
	{short: "Fr", name: "Friday"},
	{short: "Sa", name: "Saturday"},
]

// The window is the seed's, and the two instances share it: five grids of
// forty-two, opened on September and on the square three weeks in.
_calendarWindow: {
	firstMonth: "2026-07"
	lastMonth:  "2026-11"
	month:      "2026-09"
	monthLabel: "September 2026"
	value:      "2026-09-p15"
	weekdays:   _weekdays
}

calendarDemo: #Calendar & _calendarWindow & {
	key: "cal"
	row: "the"
}

datePickerDemo: #DatePicker & {
	calendar: #Calendar & _calendarWindow & {
		key:         "dp"
		row:         "picker"
		chosenLabel: "Chosen"
	}
	trigger: "Pick a date"
	label:   "Chosen"
}

calendarScreen: markup: """
	<section class="screen screen-calendar" data-screen="calendar">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Calendar</h1>
	    <p class="lede">The first screen here that names a Jessie module, and the
	    only one entitled to. A month away from a month is arithmetic, and a chart
	    has none — so the arrow stays in the chart and the number it writes comes
	    from a leaf. Everything else on the screen is the ARIA projection: which
	    day is chosen, which days are the neighbouring month's, where a day sits
	    in its week, and which day each arrow key moves to.</p>
	  </header>
	  <div class="demo-stage">
	\(calendarDemo.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">Two collections, and only one of them moves. The
	    calendar's own row holds the grid it is showing, that grid's name, and the
	    key of the cell the reader is on — three columns and a state. The other
	    collection is the day cells, and nothing on this screen writes one.</p>
	    <div class="rowview" data-live="calendar_demo" data-filter="id=eq.the">
	      <code class="row-readout" data-text="id: {id} · state: {state} · month: {month} · value: {value}">id: the · state: browsing · month: 2026-09 · value: 2026-09-p15</code>
	    </div>
	    <p class="pane-note">No <code>data-empty-row</code> anywhere on the
	    screen, and no arrival arrow either: this row is SEEDED, and what the seed
	    states is the machine's own initial world — <code>{…context, id, state:
	    initial}</code>, which is exactly what a machine region with no item
	    template would have synthesized. One statement, written as well as
	    synthesized, because the grid is a region WITH an item template and such a
	    region renders only rows that exist.</p>
	    <p class="pane-note">Both collections are SEEDED, which is the answer two
	    earlier screens could not give. <a class="pane-link" data-route="command">The
	    command palette</a> folded its six options into six columns of one row and
	    <a class="pane-link" data-route="table">the table</a> made a reader mint every
	    row it shows, both because a tab collection had no way to arrive with rows
	    in it. It has one now: an entity states <code>seed:</code>, and where there
	    is no migration to render them into the terminal writes them itself when it
	    first opens the collection. Two hundred and ten cells arrive that way —
	    five grids of forty-two — and two calendar rows beside them, one per
	    instance on this page.</p>
	    <p class="pane-note">Seeded rather than minted, and not for taste. A
	    machine writes ONE row, its own; a grid is forty-two. No arrow could
	    produce a month, which is why the months this screen can show are the
	    months the program states.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">One state and two arrows, and both arrows are
	    targetless: each acts and stays, and each writes three columns — the grid
	    being shown, that grid's name, and the cell the caret lands on. Not the
	    chosen date: a month step moves where the reader IS, never what they
	    picked. A chart
	    with one state makes no claim of the kind a statechart is for — that from
	    HERE this event goes THERE and from elsewhere it does not — which is
	    <a class="pane-link" data-route="slider">the admission the slider prints</a>,
	    and the entity prints it here the same way, as a one-member enum. What is
	    left is what was never the chart's: two event keys narrowed to their
	    buttons, three columns each writes, and the leaf that computes them.</p>
	    <p class="pane-note">All three values are the same leaf under different
	    params. That is what params are for — the module is called
	    <code>(state, event, params)</code> and the thresholds live in the chart as
	    data, so one file serves both arrows and both instances on this page. What
	    it is handed is <code>{items: [row]}</code>: the calendar's own row and
	    nothing else, in a compartment endowed with nothing. No clock, no DOM, no
	    second row.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(calendarDemo.machine), "", "  "))</pre>
	    <p class="pane-note">The window's ends ride in those params rather than in
	    the chart's shape. Five months as five states would be five states and
	    eight arrows, restated every time a month is seeded; two literals say the
	    same thing once, and the leaf clamps to them — so an arrow at either end
	    names the month it is already on, which is exactly what the projection's
	    <code>next</code> and <code>prev</code> answer at the ends of a list.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The projection</h2>
	    <p class="pane-note">A week is a <code>role="row"</code>, and it is a
	    region: six of them, siblings, each pinning its own week under the grid the
	    enclosing row names. Every cell then answers three questions it has no
	    column for.</p>
	    <dl class="limits">
	      <dt><code>"inmonth": {"eq": ["month", …]}</code></dt>
	      <dd>Whether the day belongs to the grid it is drawn in — the ellipsis is
	      the enclosing row's own month, interpolated. A cell carries the month the
	      DAY is in; the grid it appears in is a different column, so the
	      neighbouring month's days are the ones where the two disagree. No
	      invented boolean, and nothing dims a cell but this answer.</dd>
	      <dt><code>"sel": {"eq": ["id", …]}</code></dt>
	      <dd><code>aria-selected</code>, straight, against the enclosing row's
	      <code>value</code> — the cell a pick chose. The comparison happens in the
	      projection because the markup cannot make one: a binding interpolates and
	      never evaluates.</dd>
	      <dt><code>{"colindex": "index"}</code></dt>
	      <dd><code>aria-colindex</code>: the cell's place in its week. Every week
	      here is seven cells wide, which is why the position IS the weekday and no
	      column has to carry it.</dd>
	    </dl>
	    <p class="pane-note">The <code>count</code> clause earns no place on this
	    screen, and the reason is which pattern is being spelled. A listbox says
	    <code>aria-posinset</code> and <code>aria-setsize</code> on each option; a
	    grid says <code>aria-colindex</code> on a cell and
	    <code>aria-rowcount</code> on the grid — and a count of the grid's rows is
	    a fact about the GRID, so it is a literal there rather than an answer
	    repeated onto forty-two rows.</p>
	    <p class="pane-note">Six weeks of seven, always — the grid is a fixed
	    forty-two cells and the days at either end are the neighbouring months'.
	    That is what keeps every <code>role="row"</code> full, and it is what makes
	    a step's landing square exist: a month arrow keeps the reader's POSITION,
	    and every grid has all forty-two.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The keyboard</h2>
	    <p class="pane-note">The grid is one tab stop. Focus never moves between
	    cells — the container holds it and names the active cell with
	    <code>aria-activedescendant</code>, which is a plain binding off the
	    enclosing row. A day cell is a <code>&lt;button&gt;</code>, focusable
	    without asking, so every one of the forty-two carries
	    <code>tabindex="-1"</code> and Tab reaches the grid and nothing under it.
	    Then <code>data-key</code> submits a form on a key, the way
	    a form with no button submits on <code>change</code>, and the form each key
	    names is the one the cell it is standing on carries. No chart, no
	    arithmetic, no <code>focus()</code>, no module.</p>
	    <p class="pane-note">Two columns carry that, not one.
	    <code>active</code> is the cell <code>aria-activedescendant</code> points
	    at, and it is what an arrow key and a month step write;
	    <code>value</code> is the cell <code>aria-selected</code> marks and the
	    readout prints, and only a pick writes it — a pick writing both, because
	    choosing a date is also standing on it. One column doing both jobs would be
	    a date picker whose committed value moved every time the reader paged the
	    month.</p>
	    <p class="pane-note">Left and right are the grid's own reading order:
	    <code>next</code> and <code>prev</code> over a region ordered
	    <code>pos.asc</code>, so Saturday's neighbour is the following Sunday. Up
	    and down are a SECOND region over the same cells, ordered down each weekday
	    column, where a neighbour is a week away. A region declares one order, so
	    two orders are two regions — both hidden, both carrying nothing but the
	    forms the keys submit.</p>
	    <p class="pane-note">Where the two differ is what an end IS, and the answer
	    is a column rather than a rule. Horizontally the month is continuous:
	    Saturday's neighbour is the following Sunday, so a week's edge is no edge
	    and only the grid's own ends name themselves. Vertically a lane is one
	    weekday, so <code>{"next": "dow"}</code> is the neighbour among the cells
	    sharing this one's column, and the foot of that column names ITSELF.
	    Without the partition it named the head of the next column — the
	    neighbour in the column-major reading — and a caret walking down a Monday
	    arrived on a Tuesday. That was a wrong answer rather than a missing one,
	    which is the kind worth a clause.</p>
	    <p class="pane-note">Home and End are the same clause pair at the other
	    end of the vocabulary: <code>{"first": "week"}</code> and
	    <code>{"last": "week"}</code> over the horizontal lane, so they reach the
	    ends of the week the caret stands in rather than the corners of the grid
	    — which is what a date grid means by the two keys. The partition column
	    differs from the walk's on the same lane, and it has to: the arrows walk
	    the month and Home is the start of a week.</p>
	    <p class="pane-note">What still does not ship is APG's paging at an edge —
	    ArrowDown off the last row moving into the next month. Paging is a month
	    step, a month step is the chart's, and a key that submits a form cannot
	    reach one. The clamp is the honest answer to that, not a substitute for
	    it.</p>
	  </section>
	  <section class="demo-part">
	    <h2>Date picker</h2>
	    <p class="pane-note">A popover and a calendar, and nothing between them:
	    the surface's openness, its top layer, its light dismiss and the invoker's
	    <code>aria-expanded</code> are the platform's, commanded by
	    <code>commandfor</code>. So this definition is a composition rather than a
	    third machine — it is the calendar above on a second row of the same
	    collection, which is the two-instance shape
	    <a class="pane-link" data-route="switch">the switch screen</a> opened with.
	    The one thing the composition has to add is the pairing:
	    <code>aria-haspopup="dialog"</code> on the trigger promises a dialog, so
	    the surface carries <code>role="dialog"</code> and an
	    <code>aria-label</code>, the way every other invoker in this catalog is
	    paired with the role it names.</p>
	    <div class="demo-stage">
	\(datePickerDemo.markup)
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>What it does not ship</h2>
	    <dl class="limits">
	      <dt><code>aria-current="date"</code> — today</dt>
	      <dd>Today is a clock reading, and a leaf's compartment endows nothing:
	      <code>endow: () =&gt; ({})</code>, so there is no clock in scope and
	      never will be by this route. The terminal's own clock reaches two places,
	      a machine's <code>after</code> delay and the hidden <code>now</code> a
	      form resolves at submit, and neither is a date a chart can read — the
	      second is a gesture besides. <em>Closed by</em> nothing available: the screen marks
	      no day as today rather than marking one that is not.</dd>
	      <dt>Any month the program did not seed</dt>
	      <dd>The leaf's arithmetic is unbounded and the rows are not, so the
	      window is stated twice on purpose: as the seed, and as the two literals
	      the leaf clamps to. <em>Closed by</em> a machine writing one row — a
	      month's forty-two cells are not a machine's to mint, and until something
	      can mint them the honest edge is an arrow that does nothing.</dd>
	      <dt>A range, and a second calendar beside it</dt>
	      <dd>A range is two picks that have to know which of them is which, which
	      is a second column and a rule about the pair. The columns are free; the
	      rule is a comparison between them, and a comparison is exactly what the
	      projection refuses to put in the markup. <em>Closed by</em> nothing —
	      it is a component's worth of work, not a wall.</dd>
	      <dt>A day with anything on it</dt>
	      <dd>A dot under the 14th is a fact about another collection, and a
	      projection may read the region's rows and the enclosing row and nothing
	      else. <em>Closed by</em> the refusal that keeps this from becoming a
	      query language — the same one
	      <a class="pane-link" data-route="table">the table's totals</a> meet.</dd>
	    </dl>
	  </section>
	</section>
	"""

// Both instances' forms, in the order the screen carries them: two per
// calendar, and the surface's whole write vocabulary for this route.
calendarForms: [for c in [calendarDemo, datePickerDemo.calendar] for f in c.forms {f}]

// The two calendar rows the seed states, in the order the screen carries them.
// Each is its own instance's machine-initial world, so the row a region renders
// and the row a machine would synthesize cannot disagree.
calendarRows: [calendarDemo.seedRow, datePickerDemo.calendar.seedRow]

// Exported: the entity's constraint on the code column is emitted from the
// same `digits` the control's maxlength and the guard's param are.
otpDemo: #Otp & {
	collection: "otp_demo"
	label:      "Verification code"
	hint:       "Six digits, from the message we sent. Paste works — it arrives as one event, into one control."
	verify:     "Verify"
	again:      "Use another code"
	done:       "Code accepted."
}

otpScreen: markup: """
	<section class="screen screen-input-otp" data-screen="input-otp">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Input OTP</h1>
	    <p class="lede">One control, six boxes, and the boxes are the stylesheet's.
	    The famous shape for this component is six inputs with focus chasing the
	    reader across them — which this vocabulary can spell, and which costs the
	    paste, the autofill and the Backspace the platform is already doing. What
	    the chart is for is the one fact the platform will not hold: whether what
	    has been typed is a code.</p>
	  </header>
	  <div class="demo-stage">
	\(otpDemo.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">Every keystroke writes it, including the ones the
	    chart calls wrong. An arrow that declined to write would leave the
	    control showing text the row has not got — and no wake to correct it
	    with, since a write that does not happen raises no delta.</p>
	    <div class="rowview" data-live="otp_demo" data-filter="id=eq.the"
	         data-empty-row='\(otpDemo.emptyRow)'>
	      <code class="row-readout" data-text="state: {state} · code: {code} · invalid: {invalid}">state: typing · code:  · invalid: false</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">Three arrows on one event, asked in turn: a complete
	    code, a code still being typed, and a keystroke that can never be part of
	    one. First guard to pass wins, so the order in the list is the meaning —
	    and the third has no guard at all, which is what makes it the answer for
	    everything the two above declined.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(otpDemo.machine), "", "  "))</pre>
	  </section>
	  <section class="demo-pane">
	    <h2>Why one input</h2>
	    <p class="pane-note">Six boxes is moving focus in script wearing a
	    costume — this catalog has that mechanism and
	    <a class="pane-link" data-route="accordion">uses it where it belongs</a>. Here
	    it would buy a caret and sell three things:</p>
	    <table class="matrix">
	      <thead><tr><th>What a reader does</th><th>One input</th><th>Six inputs</th></tr></thead>
	      <tbody>
	        <tr><th scope="row">Pastes the code</th><td>one <code>input</code> event carrying six digits</td>
	        <td class="no">six fields, one paste; the rest is script</td></tr>
	        <tr><th scope="row">Takes the SMS autofill</th><td><code>autocomplete="one-time-code"</code>, on the control that holds the code</td>
	        <td class="no">names one box, so it fills one box</td></tr>
	        <tr><th scope="row">Presses Backspace at a box's head</th><td>the caret is the browser's, and so is the answer</td>
	        <td class="no">a rule somebody writes, per box</td></tr>
	        <tr><th scope="row">Sees where they are</th><td>the caret, drawn by the browser</td>
	        <td>a column, chased by the terminal</td></tr>
	      </tbody>
	    </table>
	    <p class="pane-note">The boxes survive the trade: they are a background
	    under one field, sized off the same <code>digits</code> the maxlength and
	    the guard are emitted from.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>What <code>pattern</code> would have bought</h2>
	    <p class="pane-note">A browser can already say whether six digits have
	    been typed — a <code>pattern</code> of six digits and <code>:valid</code>
	    would style this control with no chart at all. It is refused for the reason
	    <a class="pane-link" data-route="form">the form screen</a> turns the UA's own
	    validation off: a fact only CSS knows is one no row holds, no test reads
	    and no reviewer can sign. Here it is a column, so the button's
	    <code>disabled</code> is that column and the verify arrow needs no guard —
	    what makes the click unreachable is the same fact that makes the boxes
	    green.</p>
	  </section>
	</section>
	"""

// Two instances, and the difference between them is what a reader can Tab
// into. The first is shadcn's own demo — a profile whose card carries a link —
// and the second is a card of prose, which is the tip's shape at a size the
// tip's role would be wrong for.
_hoverProfile: #HoverCard & {
	key:   "profile"
	label: "@nextjs"
	route: "hover-card"
	body: """
		      <div class="hc-head">
		        <span class="hc-avatar" aria-hidden="true">N</span>
		        <span class="hc-who">
		          <b class="hc-name">Next.js</b>
		          <span class="hc-handle">@nextjs</span>
		        </span>
		      </div>
		      <p class="hc-bio">The React framework — created and maintained by
		      @vercel. This card holds a link, which is the whole reason it is not
		      a tooltip.</p>
		      <p class="hc-meta">Joined December 2021</p>
		      <a class="hc-link" data-route="popover">Where its surface comes from</a>
		"""
}

_hoverTerm: #HoverCard & {
	key:   "term"
	place: "block-start"
	label: "roving tabstop"
	route: "toggle-group"
	body: """
		      <p class="hc-bio">One tab stop for a whole set, and the arrows move
		      it. The set's current member is a column, so the tab order and the
		      selection are one write.</p>
		"""
}

hoverCardScreen: markup: """
	<section class="screen screen-hover-card" data-screen="hover-card">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Hover card</h1>
	    <p class="lede">The same gesture <a class="pane-link" data-route="overlays">the
	    tip</a> opens on, over a surface a reader can reach into. That difference
	    decides the ARIA all the way down — and it is what made the terminal hear
	    focus on the surface, not only the pointer.</p>
	  </header>

	  <h2 class="stage-name">A name that goes somewhere</h2>
	  <p class="stage-note">Rest on it, or Tab to it. Then Tab again: the card's
	  own link is next in the document, so it is next in the tab order — and the
	  card stays open under a reader who is inside it.</p>
	  <div class="demo-stage">
	    <p class="hc-line">Deployed on <span class="hc-hold">\(_hoverProfile.markup)</span>, and this card
	    holds a link of its own.</p>
	  </div>

	  <h2 class="stage-name">A card that is only prose</h2>
	  <p class="stage-note">The same component with nothing to reach. Its surface
	  is still not a tooltip: what a tooltip's role promises is that there is
	  nothing inside to go to, and a card whose body is a paragraph today can
	  hold a link tomorrow without changing what it is.</p>
	  <div class="demo-stage">
	    <p class="hc-line">APG calls this pattern a \(_hoverTerm.markup).</p>
	  </div>

	  <section class="demo-pane">
	    <h2>What it does not carry</h2>
	    <p class="pane-note">Both rows are refusals, and the tip beside them is
	    the same terminal behaviour with the opposite answer to each.</p>
	    <table class="matrix">
	      <thead><tr><th></th><th>Hover tip</th><th>Hover card</th></tr></thead>
	      <tbody>
	        <tr><th scope="row"><code>role="tooltip"</code></th><td>yes — nothing inside to reach</td>
	        <td class="no">no — the role promises what this surface is not</td></tr>
	        <tr><th scope="row"><code>aria-describedby</code></th><td>yes — its surface is a string</td>
	        <td class="no">no — a structure flattened into one announcement, read out on every focus of the name</td></tr>
	        <tr><th scope="row">Reachable content</th><td class="no">no</td><td>yes, in document order</td></tr>
	        <tr><th scope="row">A row deciding openness</th><td class="no">no</td><td class="no">no</td></tr>
	      </tbody>
	    </table>
	  </section>

	  <section class="demo-pane">
	    <h2>Who holds what</h2>
	    <p class="pane-note">Three owners, and none of them is this app. The list
	    is the whole of the component's behaviour.</p>
	    <table class="matrix">
	      <thead><tr><th>What happens</th><th>Whose</th></tr></thead>
	      <tbody>
	        <tr><th scope="row">A press outside closes it</th><td><code>popover="auto"</code> — WCAG 1.4.13's dismissible clause, from the element</td></tr>
	        <tr><th scope="row">Escape closes it</th><td>the element's, the same way</td></tr>
	        <tr><th scope="row">The top layer, and no z-index anywhere</th><td>the element's</td></tr>
	        <tr><th scope="row">It opens after the pointer rests</th><td>the terminal, on the terminal's own clock</td></tr>
	        <tr><th scope="row">It survives the pointer crossing the gap</th><td>the terminal — 1.4.13's hoverable clause</td></tr>
	        <tr><th scope="row">It survives focus moving into it</th><td>the terminal, and the reason this screen exists</td></tr>
	        <tr><th scope="row">Whether it is open</th><td>nobody: no row, no column, no chart</td></tr>
	      </tbody>
	    </table>
	  </section>

	  <section class="demo-pane">
	    <h2>The chart</h2>
	    <p class="pane-note">None, and the absence is the licence rather than a
	    gap. Openness nobody stores cannot disagree with anything: nothing is
	    written, nothing is journalled, and a replay has nothing to reproduce. A
	    surface has one owner — <code>popovertarget</code> naming one whose
	    openness is already a column is refused rather than arbitrated, because
	    the two would disagree the moment either moved.</p>
	  </section>
	</section>
	"""

// shadcn's own bar-chart numbers, so the picture is the one a reader of that
// catalog recognises. The scale is derived from them and never stated beside
// them: 305 is a fact about this list, computed where the list is.
chartDemo: #BarChart & {
	points:  "chart_point"
	cursors: "chart_cursor"
	caption: "Visitors, last six months"
	unit:    "visitors"
	opensOn: "mar"
	bars: [
		{name: "jan", label: "January", value: 186},
		{name: "feb", label: "February", value: 305},
		{name: "mar", label: "March", value: 237},
		{name: "apr", label: "April", value: 173},
		{name: "may", label: "May", value: 209},
		{name: "jun", label: "June", value: 264},
	]
}

chartScreen: markup: """
	<section class="screen screen-chart" data-screen="chart">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Chart</h1>
	    <p class="lede">Every other screen here says <em>chart</em> for a
	    statechart. This one means the picture, and it is the only place in the
	    catalog where the word is the shadcn component's. What draws it is a
	    number reaching a stylesheet, and what a reader moves through it is the
	    same caret <a class="pane-link" data-route="data-table">the grid</a> walks —
	    over rows the program states.</p>
	  </header>
	  <div class="demo-stage">
	\(chartDemo.markup)
	  </div>
	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">Six points and a caret, in two collections. Two for
	    the reason <a class="pane-link" data-route="command">the palette's</a> are
	    two: a region's projection is re-resolved when the row it is nested in
	    moves, so the table a keystroke writes must not be the table the points
	    are read from.</p>
	    <div class="rowview" data-live="chart_cursor" data-filter="id=eq.the">
	      <code class="row-readout" data-text="the caret: {active}">the caret: mar</code>
	    </div>
	  </section>
	  <section class="demo-pane">
	    <h2>Where the geometry is</h2>
	    <p class="pane-note">Each bar carries its own row's number as the custom
	    property <code>--v</code>, and the frame carries the domain as
	    <code>--chart-max</code>, so a length is <code>calc()</code> over two
	    bound numbers and the markup does no arithmetic at all — the same trade
	    <a class="pane-link" data-route="pagination">pagination</a> makes from the
	    other side, and the binding
	    <a class="pane-link" data-route="resizable">the splitter</a> introduced. What
	    keeps it safe is who writes: these numbers are the program's, which is
	    the narrower half of that rule rather than a widening of it.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The scale is the program's, not the rows'</h2>
	    <p class="pane-note">305 is computed where the six points are stated, by
	    <code>list.Max</code> over the same list the seed comes from — so the
	    domain and the data are one declaration and cannot drift. A scale derived
	    at RUNTIME would be an aggregate, which this platform has
	    <a class="pane-link" data-route="table">two seats for and no clause</a>; it
	    would also move every bar in the picture whenever one row arrived, and
	    two readings of a chart whose axis moves under it are not comparable.
	    Stating the domain is what a y-axis has always been.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The chart is its own table</h2>
	    <p class="pane-note">A picture's accessible alternative is the data it
	    draws. Shipping both means keeping two things in step, so this ships the
	    data and lets the stylesheet draw it: a row header per category, a cell
	    per value, and the bar is that cell's own button. A reader in table mode
	    hears the categories and the numbers; a reader looking at it sees the
	    lengths.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>The tooltip is a row</h2>
	    <p class="pane-note">shadcn's follows the pointer, which states a fact
	    about the pointer. This one is the point the caret names — a column, so
	    the readout is a nested region over it, and a keyboard reader has the
	    same thing a pointer reader has. The bar is a submit button, so a click
	    writes the column the arrows write; one caret, one meaning.</p>
	  </section>
	  <section class="demo-pane">
	    <h2>What the line costs</h2>
	    <p class="pane-note">A polyline's <code>points</code> is ONE value over
	    every row, and a binding answers about the row it is on — so the line is
	    not a polyline. It is a segment per row, which is a binding again, and
	    the only thing it needs that a bar does not is the NEXT row's value: a
	    bar's length is this row's own number, and a segment reaches somewhere
	    else. The projection names that neighbour and answers ids and positions
	    rather than its columns, so the value is carried in a column of its own.</p>
	    <p class="pane-note">Which is exactly where the seat comes in. Here the
	    program states that column, because the program states the rows — the
	    same declaration the seed and the domain come from, so nothing can drift.
	    Over rows a READER can change, the neighbour's value is a derived column
	    somebody has to maintain, and the seats for that are a browser-tier fold
	    woken by a mutation and <code>#Pipeline</code>'s four pure functions at a
	    server tier. The line is not waiting on a capability; it is waiting on
	    whoever owns the rows.</p>
	    <p class="pane-note">It is not SVG, and not by preference: a
	    <code>&lt;template&gt;</code>'s content is parsed as HTML, so a region
	    filling an <code>&lt;svg&gt;</code> from one puts elements in the wrong
	    namespace — present, carrying every attribute the binding wrote, and
	    drawn by nothing. So a segment is a box holding its own two numbers and
	    the shape is a clip between them: the same <code>calc()</code> the bars
	    use, with the axis flipped by subtracting from 100%, and no trigonometry
	    because the horizontal step is the box itself.</p>
	    <h3 class="walls-head">Still not drawn</h3>
	    <dl class="walls">
	      <dt>An area, or a curve through the points</dt>
	      <dd>An area closes the line against the axis and a curve needs control
	      points between one row and the next — both of them shapes over the
	      whole set rather than over a row and its neighbour. <em>Closed by</em>
	      the same seat as the neighbour's value, one derivation further
	      out.</dd>
	      <dt>A stacked or grouped bar</dt>
	      <dd>Two series over one category are two columns, which the row can
	      carry and the stylesheet can draw — the missing piece is the LEGEND's
	      relationship to them, and a second <code>--v</code> is not the
	      interesting half. <em>Closed by</em> nothing: it is a component's worth
	      of work rather than a wall.</dd>
	      <dt>An axis whose ticks are computed</dt>
	      <dd>Nice ticks are arithmetic over the domain — a rounding rule, not a
	      length — and the markup has none. <em>Closed by</em> the same seat as
	      the line: the program can compute them where it computes the max, and
	      what it cannot do is compute them from rows a reader made.</dd>
	    </dl>
	  </section>
	</section>
	"""

_emptyFolder: #Empty & {
	glyph:       "folder"
	title:       "No projects yet"
	description: "A project is where a deploy comes from. Make one and it lands here."
	action:      "New project"
	route:       "form"
}

_emptySearch: #Empty & {
	glyph:       "search"
	title:       "Nothing matches “zzz”"
	description: "The filter is doing its job — there is simply no row on the other side of it."
	action:      "See the palette"
	route:       "command"
}

_spinners: [
	#Spinner & {label: "Loading the table", size: "sm"},
	#Spinner & {label: "Loading the table"},
	#Spinner & {label: "Loading the table", size: "lg"},
]

_kbdSave:    #Kbd & {keys: ["Ctrl", "S"]}
_kbdPalette: #Kbd & {keys: ["Ctrl", "K"]}
_kbdEnd:     #Kbd & {keys: ["End"]}

atomsScreen: markup: """
	<section class="screen screen-atoms" data-screen="atoms">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Empty &middot; Spinner &middot; Kbd &middot; Typography</h1>
	    <p class="lede">The tier below a machine, below a row and below a
	    projection: markup and tokens, and nothing else. Three of these four are
	    things this platform already has under another name, which is the whole
	    reason they are worth a screen — a component that claims a fact the
	    platform holds is one that can come to disagree with it.</p>
	  </header>

	  <h2 class="stage-name">Empty</h2>
	  <p class="stage-note">shadcn's Empty is a component you place. Here it is a
	  STATE something already has: a region whose read answers nothing renders
	  its <code>data-empty</code>, and a route declares an <code>empty</code>
	  state the terminal stamps on the screen —
	  <a class="pane-link" data-route="select">the select screen</a> draws its
	  arrival frame that way. So what this definition adds is the skin, and the
	  one thing a paragraph saying "nothing here" does not have: a way out.</p>
	  <div class="demo-stage atoms-pair">
	\(_emptyFolder.markup)
	\(_emptySearch.markup)
	  </div>

	  <h2 class="stage-name">Spinner</h2>
	  <p class="stage-note">A wait a reader can see, and the one component here
	  that may not depend on its own animation. The brief holds every screen to
	  collapsing under <code>prefers-reduced-motion</code>, so the spin goes and
	  what is left has to carry the fact alone — which is why
	  <code>role="status"</code> and the label are the component, and the ring is
	  the decoration.</p>
	  <div class="demo-stage atoms-row">
	\(_spinners[0].markup)
	\(_spinners[1].markup)
	\(_spinners[2].markup)
	  </div>

	  <h2 class="stage-name">Kbd</h2>
	  <p class="stage-note">The element, wearing the tokens.
	  <code>&lt;kbd&gt;</code> is what a keystroke IS in HTML and this catalog
	  already prints its shortcuts in one, so what ships is a class and a rule.
	  A chord is two elements rather than one string with a plus in it: a key
	  named <q>Ctrl+K</q> is a key nobody has, and a reader hears it that
	  way.</p>
	  <div class="demo-stage atoms-row">
	    <p class="atoms-line">Save \(_kbdSave.markup)</p>
	    <p class="atoms-line">Open the palette \(_kbdPalette.markup)</p>
	    <p class="atoms-line">Last row \(_kbdEnd.markup)</p>
	  </div>

	  <h2 class="stage-name">Typography</h2>
	  <p class="stage-note">The one entry in the roster with no markup of its
	  own: it is the type scale, and the type scale is the design block every
	  screen in this gallery already resolves against. So the specimen is a
	  document, and what it proves is that a screen needs no rule of its own to
	  read correctly.</p>
	  <article class="demo-stage prose">
	    <h1>The reader is also a writer</h1>
	    <p>A machine writes a row, and a row is what the screen is looking at.
	    Everything below is styled by the tokens the shell declares and by
	    nothing this screen adds.</p>
	    <h2>What a scale is for</h2>
	    <p>Sizes that stand in a relation to each other, so a heading is a
	    heading because of its neighbours rather than because of a number
	    somebody picked. The <code>--sp-</code> tokens do the same for space.</p>
	    <blockquote>A component that claims a fact the platform holds is one
	    that can come to disagree with it.</blockquote>
	    <h3>Three things it carries</h3>
	    <ul>
	      <li>A measure that does not run past the eye's reach.</li>
	      <li>A rhythm between blocks, which is one token rather than a margin
	      per element.</li>
	      <li>Both appearances, because a colour here is a token and every token
	      has a dark twin.</li>
	    </ul>
	    <p>And inline: <code>data-empty</code>, <a data-route="catalog">a link</a>, and
	    <strong>emphasis that means it</strong>.</p>
	  </article>

	  <section class="demo-pane">
	    <h2>What each one is a skin over</h2>
	    <table class="matrix">
	      <thead><tr><th>Component</th><th>What holds the fact</th><th>What the definition adds</th></tr></thead>
	      <tbody>
	        <tr><th scope="row">Empty</th><td>the region's <code>data-empty</code>, and the route's <code>empty</code> state</td>
	        <td>the skin, and a way out of the dead end</td></tr>
	        <tr><th scope="row">Spinner</th><td>the motion tokens, which collapse under reduced motion</td>
	        <td><code>role="status"</code> and the label the collapse leaves behind</td></tr>
	        <tr><th scope="row">Kbd</th><td><code>&lt;kbd&gt;</code>, the element</td>
	        <td>a box per key, so a chord is two of them</td></tr>
	        <tr><th scope="row">Typography</th><td>the design block's scale</td>
	        <td class="no">nothing — and that is the entry</td></tr>
	      </tbody>
	    </table>
	  </section>
	</section>
	"""

_items: [
	#Item & {
		media: "PR", title: "Pull request #1681", route: "data-table"
		description: "A row that goes somewhere is a link, and a row that does not is not a link with no href."
	},
	#Item & {
		media: "CI", title: "Nightly build", variant: "outline", action: "Retry"
		description: "The trailing slot, used once: an action on every row is a toolbar nobody asked for."
	},
	#Item & {
		media: "DB", title: "Migration 0042", variant: "muted"
		description: "Three slots and one relationship — which element the title is."
	},
]

compositionDemo: #CompositionDemo & {
	collection: "composition_demo"
	search: #InputGroup & {
		key:    "ig-search"
		label:  "Search projects"
		value:  "query"
		lead:   "repo:"
		button: "Clear"
	}
	group: #ButtonGroup & {
		label: "Row actions"
		buttons: [
			{name: "copy", label: "Copy"},
			{name: "share", label: "Share"},
			{name: "archive", label: "Archive"},
		]
	}
}

compositionScreen: markup: """
	<section class="screen screen-composition" data-screen="composition">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Item &middot; Input group &middot; Button group</h1>
	    <p class="lede">Three components that hold nothing and arrange
	    something, and a fourth this catalog already had.
	    Each is exactly one relationship, and each has a contract an expansion
	    can quietly break — a label that names nothing, an addon that steals the
	    control's edge, a group of actions wearing a choice's ARIA. The chart on
	    this screen belongs to none of them: it is here so the controls inside
	    them are real.</p>
	  </header>

	  <h2 class="stage-name">Item</h2>
	  <p class="stage-note">Media, content, actions. The whole of it is which
	  element the title is: a row that goes somewhere is a link, and a row that
	  does not is a <code>div</code> rather than a link with no
	  <code>href</code> — which is a control a keyboard cannot reach and a
	  reader is told about anyway.</p>
	  <div class="demo-stage item-list">
	\(_items[0].markup)
	\(_items[1].markup)
	\(_items[2].markup)
	  </div>

	  <h2 class="stage-name">Field</h2>
	  <p class="stage-note">The roster's fourth arrangement is
	  <a class="pane-link" data-route="form">the form screen's</a>, and it predates
	  the entry: a control, its label and its help text as one unit, with the
	  label's <code>for</code>, the control's id and the
	  <code>aria-describedby</code> all unified from one name, so the
	  association cannot drift into a reference that resolves to nothing. A
	  second definition here would be one relationship declared twice.</p>
	  <p class="stage-note">What that Field does not carry is a per-control
	  <code>aria-invalid</code>, and the reason is on that screen rather than
	  missing from it: the verdict is <code>checkValidity()</code>'s, taken
	  inside the shell's submit listener, so it is not a column any binding
	  could hold. What reaches a reader is the message, in an assertive live
	  region — and never through <code>aria-describedby</code>, which would read
	  the refusal into the control's description before anything was typed.</p>

	  <h2 class="stage-name">Input group &middot; Button group</h2>
	  <p class="stage-note">Both of these act, because a screen with dead
	  controls on it teaches the wrong thing. The input group's box is a lie the
	  stylesheet tells — the control's own border is gone and the group wears it
	  — so the focus ring has to move there too, or a keyboard reader loses the
	  edge the box was drawing. The button group is a shared border over
	  independent actions, and it is <em>not</em> a choice: a group whose
	  buttons are one answer is
	  <a class="pane-link" data-route="toggle-group">the toggle group</a>, and wears
	  <code>aria-checked</code> and one tab stop.</p>
	  <div class="demo-stage">
	\(compositionDemo.markup)
	  </div>

	  <h2 class="stage-name">Direction</h2>
	  <p class="stage-note">The roster's entry is a provider and a hook. Here it
	  is an attribute: <code>dir="rtl"</code> on any element, and the components
	  inside mirror because their rules name logical edges —
	  <code>padding-inline-start</code>, <code>margin-inline</code>,
	  <code>text-align: start</code> — rather than left and right. Nothing in
	  the terminal is told, and nothing in the components changes. What this
	  frame proves is scoped to what is in it: the rest of the catalog is
	  unaudited, and a rule naming <code>left</code> anywhere is a rule this
	  attribute cannot reach.</p>
	  <div class="demo-stage" dir="rtl">
	\(_items[1].markup)
	  </div>

	  <section class="demo-pane">
	    <h2>The contract each one can break</h2>
	    <table class="matrix">
	      <thead><tr><th>Component</th><th>Its one relationship</th><th>What breaks it</th></tr></thead>
	      <tbody>
	        <tr><th scope="row">Item</th><td>which element the title is</td>
	        <td class="no">a link with no <code>href</code>, reachable by nobody and announced to everybody</td></tr>
	        <tr><th scope="row">Field <em>(on /form)</em></th><td><code>for</code> and <code>aria-describedby</code>, unified from one name</td>
	        <td class="no">a label pointing at an id somebody typed a second time</td></tr>
	        <tr><th scope="row">Input group</th><td>the box is the group's</td>
	        <td class="no">a ring left on the control, so the visible edge and the focused thing are two boxes</td></tr>
	        <tr><th scope="row">Button group</th><td>a border over independent actions</td>
	        <td class="no"><code>aria-checked</code> on buttons that are not a choice</td></tr>
	      </tbody>
	    </table>
	  </section>

	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">One collection for the whole screen, because only
	    two of these four have anything to write. The chart is
	    <a class="pane-link" data-route="slider">the one-state shape</a>: what is
	    typed is a value, and what was pressed is a literal each arrow states.</p>
	    <div class="rowview" data-live="composition_demo" data-filter="id=eq.the"
	         data-empty-row='\(compositionDemo.emptyRow)'>
	      <code class="row-readout" data-text="query: {query} · last: {last}">query:  · last: nothing yet</code>
	    </div>
	  </section>
	</section>
	"""

chatDemo: #Transcript & {
	collection: "chat_row"
	composer:   "chat_demo"
}

// A conversation with all three kinds in it, and the file mid-upload — the one
// state a transcript has that a message does not.
chatSeed: #ChatSeed & {
	rows: [
		{id: "m1", seat: "them", who: "Ada", initials: "AL", when: "09:58", at: "2026-09-04T09:58:00Z",
			body: "The walk drives the typeahead now — every arrow fires."},
		{id: "m2", seat: "you", who: "You", initials: "YO", when: "10:01", at: "2026-09-04T10:01:00Z",
			body: "Even the one two labels shared a letter with?"},
		{id: "m3", seat: "them", who: "Ada", initials: "AL", when: "10:02", at: "2026-09-04T10:02:00Z",
			body: "That one is not drawn any more. It could never have been selected."},
		{id: "k1", kind: "marker", seat: "none", at: "2026-09-04T10:03:00Z",
			body: "Ada added Grace to the thread"},
		{id: "f1", kind: "file", seat: "them", who: "Ada", initials: "AL", when: "10:04",
			at: "2026-09-04T10:04:00Z", state: "uploading",
			body: "walker-trace.json", note: "84 KB · uploading"},
		{id: "m4", seat: "them", who: "Ada", initials: "AL", when: "10:04", at: "2026-09-04T10:04:30Z",
			body: "Trace attached. The advisory is gone on every app."},
	]
}

chatScreen: markup: """
	<section class="screen screen-chat" data-screen="chat">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Message &middot; Bubble &middot; Marker &middot; Attachment &middot; Scroller</h1>
	    <p class="lede">The first set in this catalog whose content GROWS. A
	    transcript is rows and the kinds in it are a column, so five names arrive
	    as one region over one template — and a sixth kind would be a value
	    rather than a definition. The scroller is the one with behaviour, and its
	    answer is a layout.</p>
	  </header>
	  <div class="demo-stage">
	\(chatDemo.markup)
	  </div>

	  <section class="demo-pane">
	    <h2>One region, three kinds</h2>
	    <p class="pane-note">A marker is not a message with different styling: it
	    is a row nobody said, so it carries no seat, no bubble and no avatar. The
	    kind is a column and the template branches on it, which is why a fourth
	    kind is a value rather than a second region — the same move
	    <a class="pane-link" data-route="data-table">the data table</a> makes for
	    everything about a row that is not the row.</p>
	    <table class="matrix">
	      <thead><tr><th>Kind</th><th>What it is</th><th>What it carries</th></tr></thead>
	      <tbody>
	        <tr><th scope="row">message</th><td>somebody said it</td><td>a seat, an avatar, a bubble</td></tr>
	        <tr><th scope="row">marker</th><td>nobody said it — the system did</td><td>a line and the text, centred, with no side</td></tr>
	        <tr><th scope="row">file</th><td>somebody attached it</td><td>a seat, and a state of its own</td></tr>
	      </tbody>
	    </table>
	  </section>

	  <section class="demo-pane">
	    <h2>The live edge is a layout</h2>
	    <p class="pane-note">Sticking to the newest row while a transcript grows
	    is what <code>flex-direction: column-reverse</code> does for free: the
	    scroll origin is the bottom, so a new row lands under the eye and older
	    rows arriving above do not move the reader. The usual answer is a
	    listener measuring <code>scrollTop</code> against
	    <code>scrollHeight</code>, and this platform has no seat for one — which
	    turns out not to matter. Send a message and watch: nothing measured
	    anything.</p>
	    <p class="pane-note">What a layout cannot do is OPEN a saved thread at a
	    remembered position — that is a measurement taken on the way out and
	    restored on the way in, and neither end of it is a fact about a row. It
	    is named here rather than approximated.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The attachment's state</h2>
	    <p class="pane-note">An upload has states a message does not — idle,
	    uploading, done, refused — and they are a column like any other, so the
	    shimmer is a rule keyed on it. What this screen does not have is
	    something to upload with: the blob path is a capability this app
	    declares <code>false</code>, so the row's state is stated by the seed
	    rather than driven, and the screen says so instead of animating a
	    progress nothing is behind.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The rows</h2>
	    <p class="pane-note">Six seeded, and a seventh the moment you send one.
	    The composer states every column, because a row half stated is one the
	    bindings read as blank — and <code>at</code> is the terminal's clock,
	    which is the only value here neither the program nor the reader
	    supplies.</p>
	    <div class="rowview" data-live="chat_row" data-order="at.desc">
	      <template data-item>
	        <code class="row-readout" data-text="{kind} · {seat} · {body}"></code>
	      </template>
	    </div>
	  </section>
	</section>
	"""

quizDemo: #Questionnaire & {
	collection: "quiz_demo"
	title:      "Three questions about this catalog"
	done:       "Answered. Every step of that was a chart: which question you are on is the field, and each answer is a column an arrow stated."
	steps: [
		{
			name: "one", col: "a_shape", ask: "What is a component here?"
			options: [
				{name: "markup", label: "Markup and tokens"},
				{name: "chart", label: "Markup, tokens and a chart"},
				{name: "library", label: "A runtime library"},
			]
		},
		{
			name: "two", col: "a_state", ask: "Where does a control's state live?", skippable: true
			options: [
				{name: "row", label: "In a row"},
				{name: "dom", label: "In the DOM"},
				{name: "memory", label: "In a store somewhere"},
			]
		},
		{name: "three", col: "a_note", ask: "What would you take out of it?", freeform: true},
	]
}

questionnaireScreen: markup: """
	<section class="screen screen-questionnaire" data-screen="questionnaire">
	  <header class="demo-head">
	\(_wayBack)
	    <h1>Questionnaire</h1>
	    <p class="lede">The first chart here whose STATES are the screen's own
	    steps rather than a control's. Everything else about it is vocabulary
	    this catalog already had: an answer is a column an arrow states, which
	    question is showing is the field, and the progress is a rule keyed on
	    that field rather than a number computed from it.</p>
	  </header>
	  <div class="demo-stage">
	\(quizDemo.markup)
	  </div>

	  <section class="demo-pane">
	    <h2>What a step is</h2>
	    <p class="pane-note">Next is blocked until the question is answered, and
	    the block is a COLUMN rather than a guard — the rule
	    <a class="pane-link" data-route="input-otp">the one-time code</a> ships
	    under, followed here rather than deciding one fact twice. Skip is the
	    arrow with no such column, which is what <q>skippable</q> means once the
	    difference is written down: it states the answer <q>Skipped</q> and goes
	    on.</p>
	    <p class="pane-note">Back is the arrow that makes the block interesting.
	    Coming forward again must not ask a question you have already answered,
	    so what a step arrow assigns is the DESTINATION's block — read off the
	    row by a leaf, because <q>is there an answer</q> is a value the chart can
	    read and has no expression to write.</p>
	  </section>

	  <section class="demo-pane">
	    <h2>The row</h2>
	    <p class="pane-note">One row, one column per question, and the field is
	    which question you are on. Nothing here counts: the progress bar is a
	    rule keyed on the field, because a number computed from where you are is
	    a second spelling of where you are, and two spellings drift.</p>
	    <div class="rowview" data-live="quiz_demo" data-filter="id=eq.the"
	         data-empty-row='\(quizDemo.emptyRow)'>
	      <code class="row-readout" data-text="step: {step} · {a_shape} · {a_state} · {a_note}">step: one</code>
	    </div>
	  </section>

	  <section class="demo-pane">
	    <h2>The machine</h2>
	    <p class="pane-note">Four states and no guard among them. Read the
	    <code>done</code> state: one arrow out, which clears every answer and
	    the block with them — a restart is a row stated, not a screen
	    reloaded.</p>
	    <pre class="machine-json">\(json.Indent(json.Marshal(quizDemo.machine), "", "  "))</pre>
	  </section>

	  <section class="demo-pane">
	    <h2>What it does not do</h2>
	    <dl class="walls">
	      <dt>Branch on an answer</dt>
	      <dd>A question that appears only if you said yes to another is a
	      transition guarded on a column, which the grammar has — what it costs
	      is that the step set stops being the question set, and a reader of the
	      chart can no longer see the path by reading its states. <em>Closed
	      by</em> nothing; it is a design choice this screen makes in the
	      simple direction.</dd>
	      <dt>Resume where it was left</dt>
	      <dd>The row is <code>tab</code>, so the answers die with the visit —
	      which is this whole gallery's tier. A questionnaire that resumes is
	      the same chart over a <code>device</code> row, and the only thing that
	      changes is one word in the program.</dd>
	      <dt>Say how many are left</dt>
	      <dd>A count of remaining steps is an aggregate over the step set, and
	      the step set is the chart's own states rather than rows — so nothing
	      can count them at runtime. The program can, where it states them.
	      <em>Closed by</em> the same seat every other count on this catalog
	      points at.</dd>
	    </dl>
	  </section>
	</section>
	"""
