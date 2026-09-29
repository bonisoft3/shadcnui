// omnishell--message, omnishell--bubble, omnishell--marker,
// omnishell--attachment, omnishell--scroller: shadcn's conversation family,
// which is the first set in this catalog whose CONTENT is a growing collection
// rather than a fixed one.
//
// A transcript is rows, and the kinds in it are a column: a message, a system
// marker, a file. So there is one template per kind and one region over all of
// them, ordered by the seat they arrived in — which is what lets a composer add
// a row without any of these definitions knowing about it.
//
// The scroller is the interesting one, and its answer is a LAYOUT. Sticking to
// the live edge while a transcript grows is what `flex-direction: column-reverse`
// does for free: the scroll origin is the bottom, so new content lands under the
// reader's eye and their position is preserved when older content is prepended.
// A listener measuring `scrollTop` against `scrollHeight` is the usual answer
// and this platform has no seat for one — which turns out not to matter, and
// what it cannot do is named on the screen rather than approximated.
package components

// One row of a transcript, whatever kind it is. The kind decides the template,
// and the templates are named so the region can re-render without sweeping
// them (decision-33).
#Transcript: T={
	collection: string
	// The row a composer writes into, and the column it grows.
	composer: string
	row:      *"the" | string
	key:      *"chat" | string
	// Whose side is whose. A message's alignment is the SEAT, not a style: two
	// bubbles differing only in colour is a transcript nobody can follow.
	me: *"you" | string

	_list:  "\(T.key)-list"
	_input: "\(T.key)-say"
	_form:  "\(T.key)-send"

	// Every kind's template, by the column that picks it. `data-when` narrows
	// each to its own rows, which is the arm the interpreter runs and the
	// emitter checks against the entity's declared values.
	markup: """
		<omnishell--scroller>
		  <div class="chat" data-live="\(T.composer)" data-filter="id=eq.\(T.row)">
		    <template data-item>
		      <div class="chat-hold">
		        <!-- The live edge is the scroll origin: column-reverse puts the
		             newest row where the reader is already looking, and keeps
		             their place when older rows arrive above. No listener, no
		             measurement, no seat for either. -->
		        <div class="chat-scroller" id="\(T._list)" role="log" aria-label="Transcript"
		             tabindex="0" data-live="\(T.collection)" data-order="at.desc"
		             data-template="\(T.key)-row"></div>
		\(T._composer)
		      </div>
		    </template>
		  </div>
		</omnishell--scroller>
		\(T.rowTemplate)
		"""

	// A create states every column, because a row half stated is a row the
	// bindings read as blank: the seat, the kind and the two names are literals
	// this composer knows, and `at` is the terminal's clock — the only thing
	// here neither the program nor the reader supplies.
	_composer: """
		        <form class="chat-composer" id="\(T._form)" data-form="\(T._form)"
		              data-entity="\(T.collection)" data-action="create">
		          <label class="chat-label" for="\(T._input)">Message</label>
		          <input class="chat-input" id="\(T._input)" name="body" type="text"
		                 autocomplete="off" maxlength="120" placeholder="Say something">
		          <input type="hidden" name="kind" data-value="message">
		          <input type="hidden" name="seat" data-value="\(T.me)">
		          <input type="hidden" name="who" data-value="You">
		          <input type="hidden" name="initials" data-value="YO">
		          <input type="hidden" name="note" data-value="">
		          <input type="hidden" name="when" data-value="just now">
		          <input type="hidden" name="state" data-value="done">
		          <input type="hidden" name="at" data-value="{now}">
		          <button type="submit" class="chat-send">Send</button>
		        </form>
		"""

	// The form as the program declares it, from the same statement the markup
	// comes from: one list, emitted twice, so the surface and the control
	// cannot come to disagree.
	form: {
		id:     T._form
		entity: "ChatRow"
		action: "create"
		flow:   "chat-say"
		fields: [
			{name: "body", control: "text", required: true, maxLength: 120},
			{name: "kind", control: "hidden", value: "message"},
			{name: "seat", control: "hidden", value: T.me},
			{name: "who", control: "hidden", value: "You"},
			{name: "initials", control: "hidden", value: "YO"},
			{name: "note", control: "hidden", value: ""},
			{name: "when", control: "hidden", value: "just now"},
			{name: "state", control: "hidden", value: "done"},
			{name: "at", control: "hidden", value: "{now}"},
		]
	}

	// One template, three kinds, and the kind is a column: a marker is not a
	// message with different styling — it is a row nobody said, so it carries
	// no seat, no bubble and no avatar.
	rowTemplate: """
		    <template data-item data-name="\(T.key)-row">
		      <div class="chat-row" data-kind="{kind}" data-seat="{seat}" data-state="{state}">
		        <span class="chat-avatar" aria-hidden="true" data-text="{initials}"></span>
		        <div class="chat-content">
		          <p class="chat-head"><b data-text="{who}"></b> <span class="chat-at" data-text="{when}"></span></p>
		          <div class="chat-bubble"><span data-text="{body}"></span></div>
		          <div class="chat-file">
		            <span class="chat-file-media" aria-hidden="true"></span>
		            <span class="chat-file-text"><b data-text="{body}"></b><span data-text="{note}"></span></span>
		            <span class="chat-file-state" data-text="{state}"></span>
		          </div>
		          <p class="chat-marker"><span data-text="{body}"></span></p>
		        </div>
		      </div>
		    </template>
		"""
}

// The seeded transcript: rows the program states, so the screen stands on its
// first paint and a reader's own message is the only thing that grows it.
#ChatSeed: S={
	rows: [...{
		id:       =~"^[a-z0-9-]+$"
		kind:     *"message" | "marker" | "file"
		seat:     *"them" | "you" | "none"
		who:      *"" | string
		initials: *"" | string
		body:     string
		note:     *"" | string
		when:     *"" | string
		at:       string
		state:    *"done" | "uploading" | "error"
	}]
	seed: [for i, r in S.rows {
		id:       r.id
		kind:     r.kind
		seat:     r.seat
		who:      r.who
		initials: r.initials
		body:     r.body
		note:     r.note
		when:     r.when
		at:       r.at
		state:    r.state
	}]
}
