// The gallery's acceptance suite: every demo screen mounted WHOLE through the
// app's own emitted markup, a store that answers the fragment grammar, and the
// table's clock in the test's hand. Assertion ids cite acceptance.md's
// checklist.
import {
  assert,
  boxOf,
  type El,
  mountApp,
  type Mounted,
  oneByRole,
  only,
  type Row,
  textOf,
  writes,
} from "../../../plugins/omnishell/test/screen-harness.ts";
import { parseFilter } from "../../../plugins/omnishell/interpreter/fragment.js";

const APP = new URL("../", import.meta.url);
const read = (rel: string) => Deno.readTextFile(new URL(`../${rel}`, import.meta.url));

// No machine in this gallery is random, so the value only has to be fixed.
const SEED = 20260901;

// The clock's start, and it belongs to the file rather than to a case: one app
// mount serves every test here, so the instant a `{now}` lands on is stated
// once. Only the chat screen's composer reads it.
const EPOCH = "2026-09-04T10:30:00.000000Z";

const screen = (name: string, tables: Record<string, Row[]> = {}) =>
  mountApp({ appDir: APP, screen: name, seed: SEED, epoch: EPOCH, tables });

// Both switch regions carry byte-identical markup; the id in data-filter is
// the whole of an instance's identity, so every readout is reached through the
// row its own region pins.
const SW_READOUT = (row: string) => `.rowview[data-filter="id=eq.${row}"] .row-readout`;
const SW_ops = (m: Mounted) => writes(m).map((c) => `${c.op} ${c.table} ${c.id}`);

Deno.test({
  name: "accept-initial-synthesized: the machine alone binds the initial state",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("switch", { switch_demo: [] });
    await m.settle();
    const control = oneByRole(m.mount, "switch", "Airplane mode");
    assert(control.getAttribute("aria-checked") === "false", "aria-checked bound from initial, no row, no empty-row");
    assert(
      textOf(m.one(SW_READOUT("the"))) === "id: the · checked: false",
      "the readout's empty row agrees with the machine's initial",
    );
    // Two instances, so the wrapper's survival is a claim about both: one() on
    // the bare tag reports the pair rather than answering for the first.
    const wrappers = m.all("omnishell--switch");
    assert(wrappers.length === 2, `the component tag survives as an inert wrapper, saw ${wrappers.length}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-switch-toggles / accept-state-is-a-row: toggles write one row both panes read",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("switch", { switch_demo: [] });
    await m.settle();
    const control = oneByRole(m.mount, "switch", "Airplane mode");

    m.fire(control, "click");
    await m.settle();
    assert(control.getAttribute("aria-checked") === "true", "first click checks the switch");
    assert(
      textOf(m.one(SW_READOUT("the"))) === "id: the · checked: true",
      "the readout moved with the control — one row, one fact",
    );
    assert(
      JSON.stringify(only(m.rows("switch_demo"), "after the first click")) ===
        JSON.stringify({ id: "the", checked: "true" }),
      `the first click states the whole row, got ${JSON.stringify(m.rows("switch_demo"))}`,
    );

    m.fire(control, "click");
    await m.settle();
    assert(control.getAttribute("aria-checked") === "false", "second click is the way back");
    assert(
      JSON.stringify(SW_ops(m)) === JSON.stringify(["put switch_demo the", "put switch_demo the"]),
      `two writes, targets in machine order, got ${JSON.stringify(SW_ops(m))}`,
    );
    assert(
      JSON.stringify(only(m.rows("switch_demo"), "after the round trip")) ===
        JSON.stringify({ id: "the", checked: "false" }),
      `a stated row twice is one row, got ${JSON.stringify(m.rows("switch_demo"))}`,
    );
    // The neighbour is on the same collection and woke on both writes; it owns
    // no row, so it is still reading its own synthesized fallback.
    assert(
      textOf(m.one(SW_READOUT("wifi"))) === "id: wifi · checked: false",
      `the other pane followed writes it does not cover: "${textOf(m.one(SW_READOUT("wifi")))}"`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-tabs-activate: a trigger's click moves the row, the ARIA, and the panel projection",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("tabs", { tabs_demo: [] });
    await m.settle();
    const root = m.one(".tabs");
    const account = oneByRole(m.mount, "tab", "Account");
    const password = oneByRole(m.mount, "tab", "Password");

    // The synthesized fallback: context seeds every sel_* column.
    assert(root.getAttribute("data-state") === "account", "initial data-state from the machine's initial");
    assert(account.getAttribute("aria-selected") === "true", "first trigger selected at rest");
    assert(password.getAttribute("aria-selected") === "false", "second trigger unselected at rest");

    m.fire(password, "click");
    await m.settle();
    assert(root.getAttribute("data-state") === "password", "the panel projection's input moved");
    assert(password.getAttribute("aria-selected") === "true", "aria-selected followed the row");
    assert(account.getAttribute("aria-selected") === "false", "the other trigger unselected");
    const first = only(m.rows("tabs_demo"), "after activating password");
    assert(
      first.id === "the" && first.active === "password" && first.sel_account === "false",
      `the first write states the whole fallback row, got ${JSON.stringify(first)}`,
    );
    assert(writes(m).length === 1, `one activation, one write, got ${JSON.stringify(writes(m))}`);

    m.fire(account, "click");
    await m.settle();
    assert(root.getAttribute("data-state") === "account", "the way back is its own drawn arrow");
    const rows = m.rows("tabs_demo");
    assert(
      rows.length === 1 && rows[0].active === "account" && rows[0].sel_password === "false",
      `one row carries the whole contract, got ${JSON.stringify(rows)}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-tabs-activate: a click on the active trigger is a no-op, not a rewrite",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("tabs", { tabs_demo: [] });
    await m.settle();
    m.fire(oneByRole(m.mount, "tab", "Account"), "click");
    await m.settle();
    assert(writes(m).length === 0, `no transition is declared for the active trigger, got ${JSON.stringify(writes(m))}`);
    assert(m.rows("tabs_demo").length === 0, `and nothing landed, got ${JSON.stringify(m.rows("tabs_demo"))}`);
    await m.stop();
  },
});
// --- picker ---------------------------------------------------------------

Deno.test({
  name: "accept-picker-select: an option's click writes choice, label and every aria-selected as one row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("picker", { picker_demo: [] });
    await m.settle();
    const trigger = m.one(".picker-trigger");
    const banana = oneByRole(m.mount, "option", "Banana");

    assert(textOf(m.one(".picker-value")) === "Apple", "context seeds the readout label");
    assert(oneByRole(m.mount, "option", "Apple").getAttribute("aria-selected") === "true", "first option selected at rest");

    // Openness is the platform's, asserted as the attributes that summon it —
    // linkedom performs no popover behavior, so the open/close half is the
    // visual battery's at integrate. Both halves of the declarative pair:
    const list = oneByRole(m.mount, "listbox", "Favourite fruit");
    assert(list.hasAttribute("popover"), "the listbox is a popover");
    assert(
      trigger.getAttribute("commandfor") === list.getAttribute("id") &&
        trigger.getAttribute("command") === "toggle-popover",
      "the trigger commands the popover",
    );
    assert(banana.getAttribute("command") === "hide-popover", "an option's click also closes the list");

    m.fire(banana);
    await m.settle();
    const row = only(m.rows("picker_demo"), "after choosing banana");
    assert(
      row.choice === "banana" && row.label === "Banana" &&
        row.sel_apple === "false" && row.sel_banana === "true",
      `one stated row moves choice, label and every aria-selected, got ${JSON.stringify(row)}`,
    );
    assert(textOf(m.one(".picker-value")) === "Banana", "the readout followed the row");
    assert(oneByRole(m.mount, "option", "Banana").getAttribute("aria-selected") === "true", "aria followed too");
    assert(m.rows("picker_demo").length === 1, "a stated row is one row");

    // A click on the chosen option is a no-op: no arrow is drawn for it.
    m.fire(oneByRole(m.mount, "option", "Banana"));
    await m.settle();
    assert(writes(m).length === 1, `the active option has no transition, got ${JSON.stringify(writes(m))}`);
    await m.stop();
  },
});

// --- toggle group ---------------------------------------------------------

/** Re-read each time: an assertion holding element handles across a refresh
 * would be reading whatever the last render left behind. */
const tgOptions = (m: Mounted): El[] => m.all('[role="radiogroup"] [role="radio"]');
const tgChecked = (m: Mounted) => tgOptions(m).map((o) => o.getAttribute("aria-checked"));

Deno.test({
  name: "accept-toggle-group-selects: one option checks, every other unchecks, as one row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("toggle-group", { toggle_group_demo: [] });
    await m.settle();

    assert(
      tgOptions(m).map((o) => o.getAttribute("id")).join(",") ===
        "tg-align-item-left,tg-align-item-center,tg-align-item-right",
      `ids are keyed and part-slotted, got ${tgOptions(m).map((o) => o.getAttribute("id")).join(",")}`,
    );
    // One tabstop, on the chosen option: tabindex binds the column
    // aria-checked binds, so the tab order and the selection are one write and
    // a reader tabs into the group at the option it is showing.
    assert(
      tgOptions(m).map((o) => o.getAttribute("tabindex")).join(",") === "0,-1,-1",
      `one tabstop, on the chosen option, got ${tgOptions(m).map((o) => o.getAttribute("tabindex"))}`,
    );
    assert(tgChecked(m).join(",") === "true,false,false", "the machine's context checks the first option");

    m.fire("#tg-align-item-center");
    await m.settle();
    assert(tgChecked(m).join(",") === "false,true,false", `one checked, the others not, got ${tgChecked(m)}`);
    const row = only(m.rows("toggle_group_demo"), "after checking center");
    assert(
      row.value === "center" && row.chk_left === "false" && row.chk_center === "true",
      `one stated row moves the value and every aria-checked, got ${JSON.stringify(row)}`,
    );
    assert(
      m.one(".tg-preview").getAttribute("data-state") === "center",
      "the sample's own region followed the same column",
    );

    // A radiogroup has no deselect: no arrow leaves a state for itself.
    m.fire("#tg-align-item-center");
    await m.settle();
    assert(writes(m).length === 1, `the checked option has no transition, got ${JSON.stringify(writes(m))}`);
    assert(m.rows("toggle_group_demo").length === 1, "a stated row is one row");
    await m.stop();
  },
});

// --- accordion ------------------------------------------------------------

const ACC_TABLES = (): Record<string, Row[]> => ({ accordion_single_demo: [], accordion_multi_demo: [] });

/** Two `.accordion` groups ship on this screen — the single arm's and the
 * multiple arm's — so the group a fact belongs to is named by its collection. */
const ACC_SINGLE = '.screen-accordion .accordion[data-live="accordion_single_demo"]';

const accExpanded = (m: Mounted, key: string) =>
  ["shipping", "returns", "support"].map((n) => m.one(`#acc-${key}-trigger-${n}`).getAttribute("aria-expanded"));

const accClick = async (m: Mounted, id: string) => {
  m.fire(`#${id}`);
  await m.settle();
};

/** The caret's own reading: which header is current, and whether the tab order
 * was left alone. Both matter — APG keeps every header in the Tab sequence, so
 * a tabindex appearing here is the bug this pattern was held back to avoid. */
const accCaret = (m: Mounted, key: string) =>
  ["shipping", "returns", "support"].map((n) => m.one(`#acc-${key}-trigger-${n}`).getAttribute("data-cur"));

const accTabindex = (m: Mounted, key: string) =>
  ["shipping", "returns", "support"].map((n) => m.one(`#acc-${key}-trigger-${n}`).getAttribute("tabindex"));

const accPress = async (m: Mounted, id: string, key: string) => {
  m.fire(`#${id}`, "keydown", { key });
  await m.settle();
};

Deno.test({
  name: "accept-accordion-single: two charts, one row, and a self-arrow back to none",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("accordion", ACC_TABLES());
    await m.settle();

    assert(
      m.one(ACC_SINGLE).getAttribute("data-state") === "none",
      "the group arrives closed, from the machine's initial alone",
    );
    assert(
      JSON.stringify(accExpanded(m, "faq")) === JSON.stringify(["false", "false", "false"]),
      "context seeds every trigger's aria-expanded",
    );

    await accClick(m, "acc-faq-trigger-shipping");
    assert(m.one(ACC_SINGLE).getAttribute("data-state") === "shipping", "the group's own fact moved");
    assert(
      JSON.stringify(accExpanded(m, "faq")) === JSON.stringify(["true", "false", "false"]),
      "the arrow's literal assigns wrote every trigger, not just the one clicked",
    );

    await accClick(m, "acc-faq-trigger-returns");
    assert(
      JSON.stringify(accExpanded(m, "faq")) === JSON.stringify(["false", "true", "false"]),
      "opening one closed the other, because a field holds one value",
    );

    await accClick(m, "acc-faq-trigger-returns");
    assert(
      m.one(ACC_SINGLE).getAttribute("data-state") === "none",
      "the open item's own trigger is the self-arrow to none",
    );
    assert(
      JSON.stringify(accExpanded(m, "faq")) === JSON.stringify(["false", "false", "false"]),
      "and it closes every trigger with it",
    );
    // Two charts run here, so a click can be two writes: the expansion states
    // its target, and the caret states the header the reader is now on — which
    // is what a click does as much as an arrow key. Each states only its own
    // columns, and every one lands on the group's single row.
    assert(
      JSON.stringify(writes(m).map((w) => [w.table, w.id, w.row?.open ?? null, w.row?.caret ?? null])) ===
        JSON.stringify([
          ["accordion_single_demo", "the", "shipping", "shipping"],
          ["accordion_single_demo", "the", "returns", null],
          ["accordion_single_demo", "the", null, "returns"],
          ["accordion_single_demo", "the", "none", null],
        ]),
      `each chart states its own target onto the group's one row, got ${JSON.stringify(writes(m))}`,
    );
    assert(
      writes(m).every((w) => w.op === "put" && !(w.row?.open !== undefined && w.row?.caret !== undefined)) ||
        writes(m)[0].row?.caret === "shipping",
      "no write carries both charts' fields except the first, which states the whole synthesized row",
    );
    assert(
      only(m.rows("accordion_single_demo"), "the group's row").open === "none",
      `the row came to rest on ${JSON.stringify(m.rows("accordion_single_demo"))}`,
    );
    assert(m.rows("accordion_single_demo").length === 1, "N items share one row");
    await m.stop();
  },
});

Deno.test({
  name: "accept-accordion-multiple: one machine per row, and the others stay unminted",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("accordion", ACC_TABLES());
    await m.settle();

    assert(
      JSON.stringify(accExpanded(m, "notes")) === JSON.stringify(["false", "false", "false"]),
      "three regions, three synthesized fallbacks, no row anywhere",
    );

    await accClick(m, "acc-notes-trigger-shipping");
    await accClick(m, "acc-notes-trigger-support");
    assert(
      JSON.stringify(accExpanded(m, "notes")) === JSON.stringify(["true", "false", "true"]),
      "each item's aria-expanded binds its own row's field",
    );
    const rows = m.rows("accordion_multi_demo");
    assert(rows.length === 2, `only the toggled items exist as rows, got ${JSON.stringify(rows.map((r) => r.id))}`);
    assert(!rows.some((r) => r.id === "returns"), "an untouched item's row was never minted");
    assert(
      JSON.stringify(writes(m).map((w) => [w.op, w.table, w.id, w.row])) === JSON.stringify([
        ["put", "accordion_multi_demo", "shipping", { id: "shipping", open: "true" }],
        ["put", "accordion_multi_demo", "support", { id: "support", open: "true" }],
      ]),
      `each write states its own row and nothing else, got ${JSON.stringify(writes(m))}`,
    );
    assert(
      JSON.stringify(rows) === JSON.stringify([{ id: "shipping", open: "true" }, { id: "support", open: "true" }]),
      `each write stated its own row's field alone, got ${JSON.stringify(rows)}`,
    );
    assert(
      textOf(m.one('.rowview[data-live="accordion_multi_demo"][data-filter="id=eq.support"] .row-readout')) ===
        "id: support · open: true",
      "the readout pane's third region followed the third row",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-accordion-narrowed: a click inside an open panel matches no arrow",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("accordion", ACC_TABLES());
    await m.settle();

    await accClick(m, "acc-notes-trigger-shipping");
    assert(writes(m).length === 1, "the trigger opened it");

    // `from` resolves to the panel's id, and every arrow is narrowed to a
    // trigger's — so the bare event type is never reached.
    m.fire("#acc-notes-panel-shipping p");
    await m.settle();
    assert(writes(m).length === 1, `the panel's own click writes nothing, got ${JSON.stringify(writes(m))}`);
    assert(
      m.one("#acc-notes-trigger-shipping").getAttribute("aria-expanded") === "true",
      "the panel a reader is clicking inside stays open",
    );
    await m.stop();
  },
});
// ---- overlays + primitives: the two tier-0 screens -------------------------

/** linkedom carries these; the harness's structural El does not name them. */
const ovlTag = (el: El): string => (el as unknown as { tagName: string }).tagName;
const ovlClasses = (el: El): string[] => String((el as unknown as { className: unknown }).className).split(/\s+/);

Deno.test({
  name: "accept-overlays-no-state: the tier-0 claim is a counted absence, not a sentence",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("overlays");
    await m.settle();
    const html = await read("shell/screens/overlays.html");
    for (const attr of ["data-live", "data-filter", "data-empty-row", "data-machine"]) {
      assert(m.all(`[${attr}]`).length === 0, `the screen mounts no ${attr}`);
    }
    assert(!/data-on-[a-z]|data-handler/.test(html), "the markup binds no Jessie");
    // The whole visit's traffic, reads included: a region that quietly queried
    // would be a region, and the claim above is that there is none.
    assert(
      m.store.calls.length === 0,
      `nothing on the screen reaches the store, got ${m.store.calls.map((c) => `${c.op} ${c.table}`).join(", ")}`,
    );
    const shell = await read("shell/shell.yaml");
    assert(/screen: overlays[\s\S]{0,200}handlers: \[\]/.test(shell), "the emitted route lists no handler module");
    assert(
      m.all("omnishell--dialog").length > 0 && m.all("omnishell--tooltip").length > 0,
      "both component tags survive as inert wrappers",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-overlays-platform-dismissal: openness is two attributes, and the UA's ARIA is written nowhere",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("overlays");
    await m.settle();
    assert(
      JSON.stringify(m.all("[command]").map((el) => el.getAttribute("command"))) ===
        JSON.stringify(["show-modal", "close", "toggle-popover", "hide-popover", "toggle-popover"]),
      // The hover tip adds no command: what opens it is not an activation.
      "each surface is opened and closed by the command pair its modality dictates",
    );
    for (const el of m.all("[commandfor]")) {
      assert(
        m.all(`#${el.getAttribute("commandfor")}`).length === 1,
        `commandfor="${el.getAttribute("commandfor")}" resolves on this screen`,
      );
    }
    // A hand-written one would be a second spelling where the UA supplies it,
    // and a lie where it does not: the modal trigger has no expanded state.
    for (const attr of ["[aria-modal]", "[aria-expanded]"]) {
      assert(m.all(attr).length === 0, `nothing on the screen writes ${attr}`);
    }
    // The name and the description are the two things the UA does NOT supply.
    for (const surface of m.all(".dialog")) {
      for (const rel of ["aria-labelledby", "aria-describedby"]) {
        assert(
          m.all(`#${surface.getAttribute(rel)}`).length === 1,
          `the dialog's ${rel} points at an element that exists`,
        );
      }
    }
    // The two tips differ in exactly this, which is why they are two
    // components. The disclosure opens on a CLICK and its surface takes focus,
    // so role="tooltip" would be a role it does not meet and aria-describedby
    // would read the text out on every focus of the trigger — the announcement
    // a disclosure exists to defer.
    const disclosure = (sel: string) => m.one(`omnishell--tooltip ${sel}`);
    assert(!disclosure(".tip-trigger").hasAttribute("aria-describedby"), "the disclosure describes nothing");
    assert(!disclosure(".tip-surface").hasAttribute("role"), "the disclosure's surface claims no role it does not meet");

    // The hover tip opens on hover or focus and never takes it, so it IS APG's
    // tooltip: the role is met and the description is right, because the
    // gesture that announces it is the gesture that shows it.
    const hover = (sel: string) => m.one(`omnishell--hover-tip ${sel}`);
    const tipId = hover(".tip-surface").getAttribute("id");
    assert(hover(".tip-surface").getAttribute("role") === "tooltip", "the hover tip's surface is a tooltip");
    assert(
      hover(".tip-trigger").getAttribute("aria-describedby") === tipId,
      "and it describes its own trigger",
    );
    // Its openness is the terminal's to perform and nobody's to hold: the
    // trigger names the surface, and no invoker, column or chart does.
    assert(
      hover(".tip-trigger").getAttribute("popovertarget") === tipId,
      "the trigger names the surface it opens",
    );
    assert(!hover(".tip-trigger").hasAttribute("commandfor"), "no invoker: a hover is not an activation");
    assert(hover(".tip-surface").getAttribute("popover") === "auto", "and light dismiss and Escape stay the element's");
    assert(!m.one("dialog.dialog").hasAttribute("role"), "role=dialog is the UA's on <dialog>, so the element writes none");
    assert(
      m.one(".dialog[popover]").getAttribute("role") === "dialog",
      "a popover is a plain element, so the non-modal surface names its own role",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-primitives-stateless: the componentless tier mounts no region and no machine",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("primitives");
    await m.settle();
    assert(m.all("[data-live]").length === 0, "no region: these three hold no state");
    assert(m.all("[data-machine]").length === 0, "no machine: there is nothing to be in a state about");
    const shell = await read("shell/shell.yaml");
    assert(
      /screen: primitives[\s\S]{0,200}handlers: \[\]/.test(shell),
      "the emitted route lists no handler module",
    );
    // The one affordance on the screen is a link: a gallery entry rendering a
    // control that does nothing fails the catalog's own rule.
    assert(m.all("button").length === 0, "no dead control anywhere on the stage");
    assert(m.one(".card-link").getAttribute("href") === "/switch", "the footer's affordance is a real link");
    assert(
      m.all("omnishell--badge").length === 9 &&
        m.all("omnishell--card").length === 2 &&
        m.all("omnishell--alert").length === 3,
      "every component tag survives as an inert wrapper, the card's nested action badge included",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-primitives-alert-roles: the three live-region answers, and no role the others did not earn",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("primitives");
    await m.settle();
    const roles = m.all(".alert").map((el) => el.getAttribute("role") ?? "");
    assert(
      JSON.stringify(roles) === JSON.stringify(["", "status", "alert"]),
      `the static callout carries no role, then polite, then assertive; got ${JSON.stringify(roles)}`,
    );
    for (const el of m.all(".badge")) {
      assert(el.getAttribute("role") === null, "a badge is a label, never a live region");
    }
    for (const el of m.all(".card")) {
      assert(el.getAttribute("role") === null, 'no role="region": a card is not a landmark');
      // <article> has an implicit role a reader is told about on entry, so the
      // attribute alone is not the whole question — the boundary is named.
      const named = m.all(`#${el.getAttribute("aria-labelledby")}`);
      assert(
        ovlTag(el) === "ARTICLE" && named.length === 1 && ovlClasses(named[0]).includes("card-title"),
        "every card names its article boundary with its own title",
      );
    }
    // shadcn's title is a div; a card grid of divs leaves no outline.
    assert(
      m.all(".card-title, .alert-title").every((el) => ovlTag(el) === "H3"),
      "every title is a real heading",
    );
    for (const el of m.all(".alert-icon, .badge-icon")) {
      assert(el.getAttribute("aria-hidden") === "true", "an icon is decoration; the meaning is in the text");
    }
    await m.stop();
  },
});

/** Declaration blocks of a screen stylesheet, by selector: comments and
 * at-rules stripped, a grouped prelude split into its members, and repeats of
 * one selector concatenated in source order so the fold below sees a cascade. */
function ovlRules(css: string): Map<string, string> {
  const src = css.replace(/\/\*[\s\S]*?\*\//g, "").replace(/@[a-z-]+[^;{]*;/gi, "");
  const out = new Map<string, string>();
  for (const m of src.matchAll(/([^{}]+)\{([^{}]*)\}/g)) {
    for (const sel of m[1].split(",")) {
      const key = sel.trim().replace(/\s+/g, " ");
      if (key !== "") out.set(key, `${out.get(key) ?? ""};${m[2]}`);
    }
  }
  return out;
}

/** Every rung the design layer declares at `:where(html)`. The scale is the
 * value vocabulary and holds no appearance, so a rung standing in a value is
 * never the paint — which is how ovlPainted finds a colour inside a shorthand
 * that also carries a width. */
async function ovlScale(): Promise<Set<string>> {
  const block = /:where\(html\)\s*\{([^}]*)\}/.exec(await read("shell/design.css"));
  assert(block !== null, "design.css declares the scale at :where(html)");
  return new Set([...block![1].matchAll(/--([a-z0-9-]+)\s*:/gi)].map((m) => m[1]));
}

/** What a block paints, in the token names the table prints. A slot the block
 * declares in some other currency — `border: 1px solid transparent` — reads as
 * the em dash, because that is what the table would have to say about it.
 * `border` is `<width> || <style> || <colour>` in any order, so the paint is
 * the first token that is not a rung rather than the first token. */
function ovlPainted(block: string, scale: Set<string>): Record<string, string> {
  const out: Record<string, string> = {};
  for (const d of block.split(";")) {
    const i = d.indexOf(":");
    if (i < 0) continue;
    const prop = d.slice(0, i).trim();
    const token = [...d.slice(i + 1).matchAll(/var\(\s*--([a-z0-9-]+)\s*\)/gi)]
      .map((m) => m[1]).find((t) => !scale.has(t)) ?? "—";
    if (prop === "background" || prop === "background-color") out.background = token;
    else if (prop === "color") out.foreground = token;
    else if (prop === "border" || prop === "border-color") out.edge = token;
  }
  return out;
}

Deno.test({
  name: "accept-primitives-token-map: the printed map is the stylesheet it describes",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("primitives");
    await m.settle();
    const sheet = ovlRules(await read("shell/screens/primitives.css"));
    const scale = await ovlScale();
    const rows = m.all(".token-table tbody tr");
    assert(rows.length >= 10, `the pane prints the whole map, got ${rows.length} rows`);
    const covered = new Set<string>();
    for (const tr of rows) {
      const cells = [...tr.querySelectorAll("td")].map(textOf);
      const [part, variant, ...paint] = cells;
      covered.add(`${part}|${variant}`);
      const want = {
        background: paint[0].replace(/^--/, ""),
        foreground: paint[1].replace(/^--/, ""),
        edge: paint[2].replace(/^--/, ""),
      };
      const got: Record<string, string> = { background: "—", foreground: "—", edge: "—" };
      for (const sel of JSON.parse(tr.getAttribute("data-css") as string) as string[]) {
        const key = `.screen-primitives ${sel}`;
        const block = sheet.get(key);
        assert(block !== undefined, `${part} ${variant}: the stylesheet carries no rule for ${key}`);
        Object.assign(got, ovlPainted(block!, scale));
      }
      assert(
        JSON.stringify(got) === JSON.stringify(want),
        `${part} ${variant}: the row says ${JSON.stringify(want)}, its rules paint ${JSON.stringify(got)}`,
      );
    }
    // The other direction the map can drift in: a variant the screen renders
    // and the table never mentions.
    for (const el of m.all(".badge, .alert")) {
      const classes = ovlClasses(el);
      const part = classes.find((c) => c === "badge" || c === "alert")!;
      const variant = classes.find((c) => c.startsWith(`${part}-`))!.slice(part.length + 1);
      assert(covered.has(`${part}|${variant}`), `${part} ${variant} is on the screen with no row in the map`);
    }
    await m.stop();
  },
});
// ── combobox + checkbox ─────────────────────────────────────────────────────

const cbxCombobox = () => screen("combobox", { combobox_demo: [] });

/** Four machine regions over three collections, two of them siblings pinning
 * different ids on one. */
const cbxCheckbox = () =>
  screen("checkbox", { checkbox_demo: [], select_all_demo: [], toggle_demo: [], collapsible_demo: [] });

const cbxAria = (m: Mounted, id: string, attr: string) => m.one(`#${id}`).getAttribute(attr);

const cbxClick = async (m: Mounted, id: string) => {
  m.fire(`#${id}`);
  await m.settle();
};

/** The event key of a binary machine's one arrow, split back into the trigger
 * id it is narrowed to — undefined where the key is the bare event type,
 * which is the switch, whose region IS its affordance and carries no id. */
const cbxTriggerOf = (machine: { states: Record<string, { on: Record<string, unknown> }> }) => {
  const keys = new Set(Object.values(machine.states).flatMap((s) => Object.keys(s.on)));
  if (keys.size !== 1) throw new Error(`expected one event key, got ${[...keys]}`);
  return [...keys][0].split("@")[1];
};

/** A binary chart with everything a component chooses erased: the field name,
 * the trigger id, and whether the key is narrowed to that trigger at all. What
 * survives is the shape the table on the shape pane claims all five share. */
const cbxBinaryChart = (machine: { field: string }, trigger?: string) => {
  const narrowed = JSON.stringify(machine);
  const bare = trigger === undefined ? narrowed : narrowed.replaceAll(`click@${trigger}`, "click");
  return bare.replaceAll(machine.field, "F");
};

Deno.test({
  name: "accept-combobox-commits: a form with no button submits on change and upserts the row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cbxCombobox();
    await m.settle();
    const form = m.one("form");
    const input = m.one("#combobox-input");

    assert(
      form.querySelectorAll('button, [type="submit"]').length === 0,
      "the form holds no button — that is what makes change the submit trigger",
    );
    assert(input.getAttribute("value") === "Next.js", "the empty row binds the initial choice");
    assert(
      m.one("#combobox-options").querySelectorAll("option").length === 5,
      "the datalist carries the whole option set the UA filters",
    );

    m.set(input, "value", "Nuxt");
    m.fire(input, "change");
    await m.settle();

    // writes() carries no payload, so the stated row is read back off the
    // collection and the gesture's shape off the call log. The upsert lands as
    // an insert: the collection holds no row under the hidden id yet, and the
    // store logs the delegate it resolved to.
    assert(
      JSON.stringify(writes(m).map((w) => [w.op, w.table, w.id])) ===
        JSON.stringify([["create", "combobox_demo", "the"]]),
      `the pick states one row, keyed by the form's hidden id, got ${JSON.stringify(writes(m))}`,
    );
    const rows = m.rows("combobox_demo");
    assert(rows.length === 1, "a stated row is one row");
    assert(
      JSON.stringify(only(rows, "after the pick")) === JSON.stringify({ id: "the", choice: "Nuxt" }),
      `the stated row reads ${JSON.stringify(rows)}`,
    );
    assert(
      textOf(m.one(".row-readout")) === "id: the · choice: Nuxt",
      "the readout followed the row the form wrote",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-combobox-refuses: the generated pattern refuses a value the option list does not carry",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cbxCombobox();
    await m.settle();
    const input = m.one("#combobox-input");

    // change also fires on blur after partial typing, which is the whole
    // reason the pattern is generated rather than optional.
    m.set(input, "value", "Nu");
    m.fire(input, "change");
    await m.settle();

    assert(writes(m).length === 0, `a half-typed value reached the store: ${JSON.stringify(writes(m))}`);
    assert(m.screen.getAttribute("data-state") === "validation-error", "the refusal is a screen state");
    assert(!m.one(".invalid").hasAttribute("hidden"), "and it says which values are listed");
    await m.stop();
  },
});

Deno.test({
  name: "accept-checkbox-one-shape: three attributes over one chart, and the switch is the fifth row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cbxCheckbox();
    await m.settle();
    const regions = m.all("[data-machine]");
    assert(regions.length === 4, `four machines on the screen, got ${regions.length}`);

    // Every arrow on this screen is narrowed to an affordance's own id, the
    // select-all's four included: `from` resolves to the nearest ancestor
    // carrying one, so an unnarrowed click fires from whatever it sits beside.
    for (const region of regions) {
      const machine = JSON.parse(region.getAttribute("data-machine")!);
      for (const state of Object.values(machine.states) as { on?: Record<string, unknown> }[]) {
        for (const key of Object.keys(state.on ?? {})) {
          assert(key.includes("@"), `${machine.field}'s "${key}" is narrowed to an id`);
        }
      }
    }

    // The binary ones, which is what the table's rows are. The select-all is
    // not among them and cannot be: its value is a column rather than a field,
    // so its chart has one state and no branch (ir decision-47).
    const charts = new Set<string>();
    const attributes: string[] = [];
    for (const region of regions) {
      const machine = JSON.parse(region.getAttribute("data-machine")!);
      if (Object.keys(machine.states).length !== 2) continue;
      const trigger = cbxTriggerOf(machine);
      const control = m.one(`#${trigger}`);
      const bound = ["aria-checked", "aria-pressed", "aria-expanded"]
        .filter((a) => control.getAttribute(a) !== null);
      assert(bound.length === 1, `${trigger} binds exactly one ARIA attribute, got ${bound}`);
      attributes.push(bound[0]);
      charts.add(cbxBinaryChart(machine, trigger));
    }
    assert(attributes.length === 3, `three binary controls on the screen, got ${attributes.length}`);
    assert(charts.size === 1, `one chart under three attributes, got ${[...charts].join(" | ")}`);
    assert(
      JSON.stringify(attributes) ===
        JSON.stringify(["aria-checked", "aria-pressed", "aria-expanded"]),
      `the three bind their own attribute in document order, got ${JSON.stringify(attributes)}`,
    );
    await m.stop();

    // The shape pane's table has five rows, and the fifth is on another
    // screen. The switch's region IS its affordance and carries no id, so its
    // arrows keep the bare `click` where these four are narrowed — the one
    // difference the table states, and the only one: erase it along with the
    // field and the trigger and the same chart is left.
    const sw = await screen("switch", { switch_demo: [] });
    await sw.settle();
    const switches = sw.all("[data-machine]");
    assert(switches.length === 2, `two switches on that screen, got ${switches.length}`);
    for (const region of switches) {
      const machine = JSON.parse(region.getAttribute("data-machine")!);
      assert(
        cbxTriggerOf(machine) === undefined,
        `the switch's key is the bare event type, got ${JSON.stringify(Object.keys(machine.states.false.on))}`,
      );
      assert(
        region.getAttribute("role") === "switch" &&
          region.getAttribute("aria-checked") !== null,
        "and it wears the role the table gives it, over aria-checked like the plain checkbox",
      );
      charts.add(cbxBinaryChart(machine, cbxTriggerOf(machine)));
    }
    assert(charts.size === 1, `one chart across all five rows, got ${[...charts].join(" | ")}`);
    await sw.stop();
  },
});

Deno.test({
  name: "accept-checkbox-tristate: mixed is what the items add up to, and a reader can get back to it",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cbxCheckbox();
    await m.settle();
    const header = () => cbxAria(m, "sa-all-trigger", "aria-checked");
    const items = () =>
      ["docs", "images", "archive"].map((n) => cbxAria(m, `sa-all-item-${n}`, "aria-checked"));

    assert(header() === "mixed", "the row arrives partially checked");
    assert(
      JSON.stringify(items()) === JSON.stringify(["true", "true", "false"]),
      "the context seeds the items, and they are what makes the header mixed",
    );

    await cbxClick(m, "sa-all-trigger");
    assert(header() === "true", "a partially checked select-all checks everything — APG's own rule");
    assert(JSON.stringify(items()) === JSON.stringify(["true", "true", "true"]), "and the items took it with it");

    await cbxClick(m, "sa-all-trigger");
    assert(header() === "false", "and from there it is the two-cycle");
    assert(JSON.stringify(items()) === JSON.stringify(["false", "false", "false"]), "the items rode that arrow too");

    // The claim the old shape could not make: the third value is reachable,
    // because it is not a state anything enters — it is what the items say.
    await cbxClick(m, "sa-all-item-docs");
    assert(header() === "mixed", `one of three checked reads ${header()}`);
    assert(JSON.stringify(items()) === JSON.stringify(["true", "false", "false"]), "and only that item moved");

    await cbxClick(m, "sa-all-item-images");
    await cbxClick(m, "sa-all-item-archive");
    assert(header() === "true", "checking the last one rolls the header up");

    // One write per click, header and item together: a second writer would put
    // the two of them out of step for a beat, which is what a column assigned
    // by the same arrow cannot do.
    assert(
      JSON.stringify(writes(m).map((w) => [w.table, w.row?.checked])) ===
        JSON.stringify([
          ["select_all_demo", "true"],
          ["select_all_demo", "false"],
          ["select_all_demo", "mixed"],
          ["select_all_demo", "mixed"],
          ["select_all_demo", "true"],
        ]),
      `five clicks, five writes, all on the header's own row: ${JSON.stringify(writes(m))}`,
    );
    const row = only(m.rows("select_all_demo"), "after the clicks");
    assert(row.phase === "live", `the field holds one value throughout, got ${JSON.stringify(row.phase)}`);
    assert(m.rows("checkbox_demo").length === 0, "the plain checkbox beside it was never clicked");
    await m.stop();
  },
});

Deno.test({
  name: "accept-checkbox-attributes: each control flips its own attribute and states its own row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cbxCheckbox();
    await m.settle();

    await cbxClick(m, "cb-terms-trigger");
    await cbxClick(m, "tgl-bold-trigger");
    await cbxClick(m, "col-notes-trigger");
    assert(cbxAria(m, "cb-terms-trigger", "aria-checked") === "true", "the checkbox checked itself");
    assert(cbxAria(m, "tgl-bold-trigger", "aria-pressed") === "true", "the toggle stayed down");
    assert(cbxAria(m, "col-notes-trigger", "aria-expanded") === "true", "the collapsible opened");
    assert(
      JSON.stringify(writes(m).map((w) => [w.table, w.id])) ===
        JSON.stringify([["checkbox_demo", "terms"], ["toggle_demo", "the"], [
          "collapsible_demo",
          "the",
        ]]),
      `three writes on three collections, got ${JSON.stringify(writes(m).map((w) => w.table))}`,
    );
    assert(
      new Set(writes(m).map((w) => w.table)).size === 3,
      `one collection per control, got ${[...new Set(writes(m).map((w) => w.table))]}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-checkbox-narrowed: a click inside the open panel matches no arrow",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cbxCheckbox();
    await m.settle();

    await cbxClick(m, "col-notes-trigger");
    assert(writes(m).length === 1, "the trigger opened it");

    m.fire("#col-notes-panel p");
    await m.settle();
    assert(writes(m).length === 1, `the panel's own click writes nothing, got ${JSON.stringify(writes(m))}`);
    assert(cbxAria(m, "col-notes-trigger", "aria-expanded") === "true", "the panel stays open");
    await m.stop();
  },
});
// The two traversal screens: a radiogroup's single-valued choice, and the
// pagination/carousel pair that draw one generated chart twice.

/** linkedom answers more than the harness's structural El, and these tests ask
 * for the parts a labelled set is made of. */
type RpEl = El & {
  readonly id: string;
  readonly localName: string;
  contains(other: unknown): boolean;
  querySelector(selector: string): RpEl | null;
};

const rpOne = (m: Mounted, selector: string) => m.one(selector) as RpEl;
const rpAll = (m: Mounted, selector: string) => m.all(selector) as RpEl[];
/** Two rowviews sit on the pagination screen, one per collection, and both pin
 * `id=eq.the` — so the readout an assertion means is named by its table. */
const RP_READOUT = (table: string) => `.rowview[data-live="${table}"] .row-readout`;
/** Every non-read call, as `op table id`: `writes()` carries no payload, so the
 * sequence is what is left of a written row's identity. */
const rpCalls = (m: Mounted) => writes(m).map((c) => `${c.op} ${c.table} ${c.id}`);

Deno.test({
  name: "accept-radio-group-selects: one option chosen, every other unchosen, as one row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("radio-group", { radio_group_demo: [] });
    await m.settle();
    const group = rpOne(m, '[role="radiogroup"]');
    const options = () => [...group.querySelectorAll('[role="radio"]')] as RpEl[];
    const checked = () => options().map((o) => o.getAttribute("aria-checked")).join(",");

    assert(
      options().map((o) => o.id).join(",") ===
        "rg-plan-item-starter,rg-plan-item-pro,rg-plan-item-team",
      `ids are keyed and part-slotted, got ${options().map((o) => o.id).join(",")}`,
    );
    assert(checked() === "true,false,false", "the machine's context chooses the first option");
    assert(m.rows("radio_group_demo").length === 0, `hydration stored ${JSON.stringify(m.rows("radio_group_demo"))}`);

    m.fire("#rg-plan-item-pro");
    await m.settle();
    assert(checked() === "false,true,false", `one chosen, the others not, got ${checked()}`);
    // The old suite read the written payload here. `writes()` carries none, so
    // the stated row is read back off the store: one write, and the row it
    // landed on holds the value and every aria-checked column.
    assert(rpCalls(m).join(",") === "put radio_group_demo the", `one stated row, got ${rpCalls(m)}`);
    const row = only(m.rows("radio_group_demo"), "after choosing pro");
    assert(
      row.value === "pro" && row.chk_starter === "false" && row.chk_pro === "true" && row.chk_team === "false",
      `one stated row moves the value and every aria-checked, got ${JSON.stringify(row)}`,
    );

    // A radiogroup has no deselect: no arrow leaves a state for itself.
    m.fire("#rg-plan-item-pro");
    await m.settle();
    // And the description carries its own id, so `from` resolves to it and
    // matches no arrow — the narrowing, exercised where a reader clicks text.
    m.fire("#rg-plan-desc-pro");
    await m.settle();
    assert(writes(m).length === 1, `neither the chosen option nor a description writes, got ${JSON.stringify(writes(m))}`);
    assert(m.rows("radio_group_demo").length === 1, "a stated row is one row");
    await m.stop();
  },
});

Deno.test({
  name: "accept-radio-group-labelled: named by its legend, described by siblings, and in no form",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("radio-group", { radio_group_demo: [] });
    await m.settle();
    const group = rpOne(m, '[role="radiogroup"]');
    const options = [...group.querySelectorAll('[role="radio"]')] as RpEl[];

    const legend = rpOne(m, `#${group.getAttribute("aria-labelledby")}`);
    assert(textOf(legend) === "Plan", "the group's name is the legend on the screen");
    assert(
      !group.contains(legend) || legend.getAttribute("role") === null,
      "the legend is a paragraph, not a member of the group",
    );

    // Name from content: the button holds the label alone, so the description
    // has to be a sibling it points at rather than a child.
    assert(
      options.map((o) => textOf(o)).join(",") === "Starter,Pro,Team",
      `an option's name is its label alone, got ${options.map((o) => textOf(o))}`,
    );
    for (const o of options) {
      const desc = rpOne(m, `#${o.getAttribute("aria-describedby")}`);
      assert(desc !== null, `${o.id} points at a description that exists`);
      assert(!o.contains(desc), `${o.id}'s description is a sibling, not part of its name`);
      assert(textOf(desc).length > 0, `${o.id}'s description carries text`);
    }

    assert(
      options.map((o) => o.getAttribute("tabindex")).join(",") === "0,-1,-1",
      `one tabstop, on the chosen option, got ${options.map((o) => o.getAttribute("tabindex"))}`,
    );
    assert(
      options.every((o) => !o.hasAttribute("name")) && m.all("form, input").length === 0,
      "no name and no hidden input: the group is the shape a form submits, and is in no form",
    );
    await m.stop();
  },
});

// Two traversals on two collections, so the store keys its rows by table: a
// shared bag would let one machine read the other's row and hide exactly the
// independence the carousel assertion is making.
const rpPagination = () => screen("pagination", { pagination_demo: [], carousel_demo: [] });

Deno.test({
  name: "accept-pagination-relative / accept-pagination-absolute: a step is the absolute arrow the state drew",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await rpPagination();
    await m.settle();
    const nav = rpOne(m, ".pagination");
    const pages = () => [...nav.querySelectorAll(".pag-page")] as RpEl[];
    const current = () => pages().map((p) => p.getAttribute("aria-current")).join(",");

    assert(
      pages().map((p) => p.id).join(",") ===
        "pag-results-p1,pag-results-p2,pag-results-p3,pag-results-p4,pag-results-p5",
      `ids are prefixed, keyed and part-slotted, got ${pages().map((p) => p.id).join(",")}`,
    );
    assert(current() === "page,false,false,false,false", "the machine's context marks the first page");
    assert(nav.localName === "nav", "the page list is a nav of buttons, not of links");
    assert(nav.querySelector("a") === null, "and holds no anchor, because a page here has no URL");

    m.fire("#pag-results-next");
    await m.settle();
    assert(current() === "false,page,false,false,false", `next landed on page two, got ${current()}`);
    m.fire("#pag-results-next");
    await m.settle();
    assert(current() === "false,false,page,false,false", `and on page three, got ${current()}`);
    // The old suite asserted the two written pages, "p2,p3". `writes()` carries
    // no payload, so what is left is that two presses made two writes on the
    // one row — the positions themselves are the aria-current reads above,
    // taken between the presses.
    assert(
      rpCalls(m).join(",") === "put pagination_demo the,put pagination_demo the",
      `two presses walked two positions, got ${rpCalls(m)}`,
    );

    // The same arrow kind under a different id: a number lands from anywhere.
    m.fire("#pag-results-p5");
    await m.settle();
    assert(current() === "false,false,false,false,page", `page five is one arrow away, got ${current()}`);
    assert(
      textOf(m.one(RP_READOUT("pagination_demo"))) ===
        "page: p5 · cur: false/false/false/false/page · dis: []/[disabled]",
      `the readout is the same row the nav binds, got ${textOf(m.one(RP_READOUT("pagination_demo")))}`,
    );
    assert(m.rows("pagination_demo").length === 1, "a traversal is one row, however far it walks");
    await m.stop();
  },
});

Deno.test({
  name: "accept-pagination-ends: no arrow is drawn, and the bound boolean says the same thing",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await rpPagination();
    await m.settle();
    const prev = () => rpOne(m, "#pag-results-prev");
    const next = () => rpOne(m, "#pag-results-next");

    assert(
      prev().getAttribute("disabled") === "disabled" && !next().hasAttribute("disabled"),
      "at the first page the exhausted step carries the attribute and the live one has none",
    );
    // The chart has no click@pag-results-prev key in p1 at all: the affordance
    // and the arrow are absent together, which is the claim.
    m.fire("#pag-results-prev");
    await m.settle();
    assert(writes(m).length === 0, `the exhausted step matched no arrow, got ${JSON.stringify(writes(m))}`);

    m.fire("#pag-results-next");
    await m.settle();
    assert(
      !prev().hasAttribute("disabled"),
      "one position along the binder removed the attribute, because the column interpolated empty",
    );
    // The old suite read the first written payload's two step columns. One
    // write has happened, so the stored row IS that payload.
    const row = only(m.rows("pagination_demo"), "after one step");
    assert(
      row.dis_prev === "" && row.dis_next === "",
      `the stated row carries both step columns, got ${JSON.stringify(row)}`,
    );

    m.fire("#pag-results-p5");
    await m.settle();
    assert(
      next().getAttribute("disabled") === "disabled" && !prev().hasAttribute("disabled"),
      "and the far end is the near end mirrored",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-pagination-carousel: the same chart, projected, on a row of its own",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await rpPagination();
    await m.settle();
    const car = () => rpOne(m, ".carousel");
    const dots = () => [...car().querySelectorAll(".car-dot")] as RpEl[];
    const carNext = () => rpOne(m, "#car-tour-next");
    const carPrev = () => rpOne(m, "#car-tour-prev");
    const current = () => dots().map((d) => d.getAttribute("aria-current")).join(",");

    assert(car().getAttribute("aria-roledescription") === "carousel", "the group says what it is");
    assert(
      rpAll(m, ".car-slide").every((s) => s.getAttribute("aria-roledescription") === "slide"),
      "and so does each slide",
    );
    assert(current() === "true,false,false,false", "a dot picks within a set, so its token is true");
    assert(car().getAttribute("data-state") === "s1", "the root binds the field the slide projects off");

    m.fire(dots()[2]);
    await m.settle();
    assert(car().getAttribute("data-state") === "s3", "a dot jumps absolutely, like a page number");
    assert(current() === "false,false,true,false", `and moves every dot column, got ${current()}`);

    m.fire(carNext());
    await m.settle();
    assert(car().getAttribute("data-state") === "s4", "next is the arrow s3 drew");
    assert(
      carNext().getAttribute("disabled") === "disabled" && !carPrev().hasAttribute("disabled"),
      "the last slide draws no next arrow",
    );

    // Two machines, two collections, two rows: the traversals share a screen
    // and nothing else.
    assert(
      rpOne(m, ".pagination").getAttribute("data-state") === "p1",
      "walking the carousel moved no page",
    );
    assert(m.rows("pagination_demo").length === 0, "and minted no page row at all");
    assert(m.rows("carousel_demo").length === 1, "the carousel is one row");
    await m.stop();
  },
});
// ── toast ─────────────────────────────────────────────────────────────────
// The delay comes out of the emitted chart, never out of this file: a test
// carrying its own copy of the number would keep passing against a machine
// that had stopped waiting that long. Under the held clock it is table
// milliseconds, which is the unit `after` is written in.
const toastScreen = () => screen("toast", { toast_demo: [] });
const TOAST_MOUNT = ".toast-mount";
const toastMachine = (m: Mounted) => JSON.parse(m.one(TOAST_MOUNT).getAttribute("data-machine")!);
const toastDelay = (m: Mounted) => Number(Object.keys(toastMachine(m).states.open.after)[0]);
const toastState = (m: Mounted) => m.one(TOAST_MOUNT).getAttribute("data-state");
const toastRowState = (m: Mounted) => only(m.rows("toast_demo"), "the toast's row").state;

Deno.test({
  name: "accept-toast-after / accept-toast-rearms: the terminal performs the wait, and re-entry re-arms it",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await toastScreen();
    await m.settle();
    assert(toastState(m) === "closed", "the machine's initial alone, with no row and no data-empty-row");
    assert(m.rows("toast_demo").length === 0, `hydration stored ${JSON.stringify(m.rows("toast_demo"))}`);
    const delay = toastDelay(m);

    m.fire("#toast-save-trigger");
    await m.quiet();
    assert(
      toastState(m) === "open" && writes(m).length === 1,
      `the click states one row, got ${toastState(m)} after ${JSON.stringify(writes(m))}`,
    );
    assert(toastRowState(m) === "open", `the click wrote state ${toastRowState(m)}`);

    // Back into `open` from `open`, before the first wait comes due.
    m.advance(delay * 0.6);
    await m.quiet();
    m.fire("#toast-save-trigger");
    await m.quiet();
    assert(writes(m).length === 2, `the self-target restates the row it is already standing in, got ${JSON.stringify(writes(m))}`);
    assert(toastRowState(m) === "open", `the restatement moved the row to ${toastRowState(m)}`);

    // Past the FIRST deadline — 1.1 delays of table time since the first
    // click. Still open only because re-entering the state armed a new wait
    // and killed the old one; a component that armed once would have closed
    // here.
    m.advance(delay * 0.5);
    await m.quiet();
    assert(
      toastState(m) === "open" && writes(m).length === 2,
      `the first wait died when the state was re-entered, got ${toastState(m)} after ${JSON.stringify(writes(m))}`,
    );
    assert(toastRowState(m) === "open", `the row is at ${toastRowState(m)} with its second wait still standing`);

    // And past the second, which nobody is waiting on but the terminal.
    m.advance(delay * 0.8);
    await m.quiet();
    assert(toastState(m) === "closed", "the wait came due with nobody clicking");
    assert(toastRowState(m) === "closed", `the timer wrote state ${toastRowState(m)}`);
    assert(
      JSON.stringify(writes(m).map((c) => `${c.op} ${c.table}/${c.id} ${c.row?.state}`)) ===
        JSON.stringify([
          "put toast_demo/the open",
          "put toast_demo/the open",
          "put toast_demo/the closed",
        ]),
      `two clicks and one timer make three writes, the last one the terminal's own, got ${
        JSON.stringify(writes(m))
      }`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-toast-at-rest / accept-toast-early-dismiss: an unentered state arms nothing, and a left state cancels",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await toastScreen();
    await m.settle();
    const machine = toastMachine(m);
    const delay = toastDelay(m);

    // The guarantee is the chart's: a wait is armed by entering the state
    // that declares one, so the screen is still because `closed` declares
    // none — not because nothing has happened to it yet.
    assert(
      JSON.stringify(Object.keys(machine.states).filter((s: string) => machine.states[s].after !== undefined)) ===
        JSON.stringify(["open"]),
      "exactly one state declares a wait, and it is not the initial one",
    );
    m.advance(delay * 0.2);
    await m.quiet();
    assert(writes(m).length === 0 && toastState(m) === "closed", "an untouched screen writes nothing at all");

    m.fire("#toast-save-trigger");
    await m.quiet();
    m.fire("#toast-save-close");
    await m.quiet();
    assert(
      toastState(m) === "closed" && writes(m).length === 2,
      `the dismiss button returns the row before the wait is due, got ${toastState(m)} after ${JSON.stringify(writes(m))}`,
    );
    assert(toastRowState(m) === "closed", `the dismiss wrote state ${toastRowState(m)}`);

    m.advance(delay * 1.1);
    await m.quiet();
    assert(
      writes(m).length === 2,
      `the wait armed in open died with the state, so its deadline passed silently, got ${JSON.stringify(writes(m))}`,
    );
    assert(toastRowState(m) === "closed", `a dead deadline moved the row to ${toastRowState(m)}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-toast-live-region: the viewport announces, the toast does not",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    // Read off the tree, not the source: the screen's prose quotes every one
    // of these attributes, and a text scan would count the sentences too.
    const m = await toastScreen();
    await m.settle();
    assert(m.all('[role="status"]').length === 1, "one live region on the screen");
    assert(
      m.all('[role="alert"]').length === 0,
      "and it is the polite one, because a message that dismisses itself is one a reader may miss",
    );
    assert(
      m.all("[aria-live], [aria-atomic]").length === 0,
      "neither is written: role=status already carries polite and atomic",
    );

    const live = m.one('[role="status"]');
    assert(live.getAttribute("class") === "toast-viewport", "the role is the always-mounted container's");
    assert(live.querySelectorAll(".toast").length === 1, "and the message that appears is inside it");
    assert(
      m.one(".toast").getAttribute("role") === null,
      "the surface that appears carries no role of its own — it would announce its own arrival",
    );

    // What keeps the region mounted is the stylesheet hiding the message and
    // never the region: a live region hidden with its content announces the
    // one change it must not, its own.
    const css = await read("shell/screens/toast.css");
    assert(
      !/\.toast-viewport[^{}]*\{[^}]*(display:\s*none|visibility:\s*hidden)/.test(css),
      "the live region itself is never hidden",
    );
    assert(
      /\.toast-mount\[data-state="open"\]\s+\.toast\s*\{/.test(css),
      "and what shows the message is a projection off the data-state the machine writes",
    );
    await m.stop();
  },
});

// ── slider ────────────────────────────────────────────────────────────────
// Two collections on one screen: the slider's bar and the bar nobody writes
// are told apart by nothing but the table their region names.
const sliderScreen = () => screen("slider", { slider_demo: [], progress_demo: [] });
const SLIDER_INPUT = "#slider-volume-input";
/** The reader's gesture, not a write behind the control's back: the control is
 * left showing the new position and the event is what carries it. */
const sliderDrag = async (m: Mounted, to: number) => {
  const input = m.one(SLIDER_INPUT);
  input.setAttribute("value", String(to));
  m.fire(input, "input");
  await m.settle();
};
const sliderBar = (m: Mounted, id: string) => m.one(`#${id}`).getAttribute("value");
const sliderRow = (m: Mounted) => only(m.rows("slider_demo"), "the slider's row");

Deno.test({
  name: "accept-slider-value: the leaf lifts the control's number off the event and into the row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await sliderScreen();
    await m.settle();
    assert(
      m.one(SLIDER_INPUT).getAttribute("value") === "50",
      `the control opens on the machine's context, with no row, got ${m.one(SLIDER_INPUT).getAttribute("value")}`,
    );
    assert(m.rows("slider_demo").length === 0, `hydration stored ${JSON.stringify(m.rows("slider_demo"))}`);
    assert(writes(m).length === 0, "and hydration writes nothing at all");

    await sliderDrag(m, 72);
    assert(sliderRow(m).volume === 72, `the drag states the position it landed on, got ${JSON.stringify(sliderRow(m))}`);
    await sliderDrag(m, 13);
    assert(sliderRow(m).volume === 13, `the second drag states its own position, got ${JSON.stringify(sliderRow(m))}`);
    assert(writes(m).length === 2, `two drags, ${writes(m).length} writes: ${JSON.stringify(writes(m))}`);

    // The spelling is the claim, not the digits: `value` would have carried
    // "13" through the same arrow, and an int column compared strictly against
    // a decimal string disowns its own rows.
    assert(
      typeof sliderRow(m).volume === "number",
      `valueAsNumber puts a number in the column, got ${typeof sliderRow(m).volume}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-slider-one-state: the targetless arrow acts and stays, so only the value column moves",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await sliderScreen();
    await m.settle();
    const machine = JSON.parse(m.one("[data-machine]").getAttribute("data-machine")!);

    // Read off the emitted chart, which is where the guarantee lives: one
    // state, and no transition naming a target. Both are what leaves the field
    // constant, and either one lost would show up here before the row did.
    assert(Object.keys(machine.states).length === 1, "one state");
    const arrows = Object.values(machine.states).flatMap((s: any) => Object.values((s as { on: Record<string, unknown> }).on));
    assert(arrows.length === 1, `one arrow, got ${arrows.length}`);
    assert(
      arrows.every((a: any) => (a as { target?: string }).target === undefined),
      "and it names no target",
    );

    for (const to of [72, 13, 99]) {
      await sliderDrag(m, to);
      assert(
        sliderRow(m).phase === "live",
        `every write states the same field, got ${sliderRow(m).phase} after dragging to ${to}`,
      );
      assert(sliderRow(m).volume === to, `the value column is the one that moved, got ${JSON.stringify(sliderRow(m))}`);
    }
    assert(writes(m).length === 3, `three drags, ${writes(m).length} writes: ${JSON.stringify(writes(m))}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-slider-one-row: the bar paints the control's row, and the bar with no writer stands still",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await sliderScreen();
    await m.settle();
    assert(sliderBar(m, "progress-volume-bar") === "50", `both bind the same synthesized row, got ${sliderBar(m, "progress-volume-bar")}`);
    assert(sliderBar(m, "progress-export-bar") === "72", `the other bar's row is its own, got ${sliderBar(m, "progress-export-bar")}`);

    await sliderDrag(m, 88);
    assert(
      sliderBar(m, "progress-volume-bar") === "88",
      `the bar followed the control's row, got ${sliderBar(m, "progress-volume-bar")}`,
    );
    assert(
      sliderBar(m, "progress-export-bar") === "72",
      "and the bar nothing writes is where it started — a component with no affordance",
    );
    assert(m.rows("progress_demo").length === 0, `the unwritten collection holds ${JSON.stringify(m.rows("progress_demo"))}`);
    assert(
      JSON.stringify([...new Set(writes(m).map((c) => c.table))]) === JSON.stringify(["slider_demo"]),
      `one collection was written, got ${JSON.stringify(writes(m))}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-slider-aria: nothing about the contract is written, because each half is a native element",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await sliderScreen();
    await m.settle();
    // Counted over the whole screen rather than per control: a role or a value
    // property written anywhere here would be a second spelling of what the
    // element already carries.
    const aria = [
      ...new Set(
        m.all("*").flatMap((el) =>
          [...(el as unknown as { attributes: { name: string }[] }).attributes]
            .map((a) => a.name)
            .filter((n) => n.startsWith("aria-") || n === "role" || n === "tabindex")
        ),
      ),
    ].sort();
    assert(
      JSON.stringify(aria) === JSON.stringify(["aria-hidden"]),
      `the only attribute left keeps the printed number from being said twice, found ${aria.join(", ")}`,
    );

    const controls = m.all("input, progress");
    assert(
      JSON.stringify(
        controls.map((c) =>
          (c as unknown as { localName: string }).localName === "input"
            ? `input[type=${c.getAttribute("type")}]`
            : (c as unknown as { localName: string }).localName
        ),
      ) === JSON.stringify(["input[type=range]", "progress", "progress"]),
      "a slider and two progressbars, each an element the platform already knows",
    );
    // Both are labelable, so the accessible name is a label a reader can see.
    for (const c of controls) {
      const labels = m.all(`label[for="${c.getAttribute("id")}"]`);
      assert(
        labels.length === 1 && textOf(labels[0]).length > 0,
        `${c.getAttribute("id")} is named by no visible label`,
      );
    }
    await m.stop();
  },
});
// -------------------------------------------------------------- resizable ---

const rsScreen = () => screen("resizable", { resizable_demo: [] });
const rsRow = (m: Mounted): Row => only(m.rows("resizable_demo"), "the split row");
const rsBound = (m: Mounted) => m.one(".rs-group").getAttribute("style");

/** The handle as a reader drags it: the control is left showing the new
 * position and the event is what carries it, the way ./slider's does. */
const rsDrag = async (m: Mounted, to: number) => {
  m.one("#rs-handle").setAttribute("value", String(to));
  m.fire("#rs-handle", "input");
  await m.settle();
};

Deno.test({
  name: "accept-resizable-sizes: one number states both panes, and the stylesheet reads it",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await rsScreen();
    await m.settle();
    // The machine is the writer of the initial fact, so the panes have a width
    // before anyone touches the handle.
    assert(rsBound(m) === "--split: 50", `the group opened bound to ${JSON.stringify(rsBound(m))}`);

    const split: unknown[] = [];
    for (const to of [25, 80]) {
      await rsDrag(m, to);
      split.push(rsRow(m).split);
      // The claim that would fail if the binding lagged the row: the divider is
      // drawn where the number says, not where an earlier value put it.
      assert(rsBound(m) === `--split: ${to}`, `the row says ${rsRow(m).split} and the group says ${rsBound(m)}`);
    }
    assert(JSON.stringify(split) === JSON.stringify([25, 80]), `the drags stated ${JSON.stringify(split)}`);

    // Counted over the whole screen, like the slider's: a value or a bound
    // written anywhere here would be a second spelling of what the range
    // already carries, and scoping the count to the names it expects is how a
    // false claim survives.
    const aria = [
      ...new Set(
        m.all("*").flatMap((el) =>
          [...(el as unknown as { attributes: { name: string }[] }).attributes]
            .map((a) => a.name)
            .filter((n) => n.startsWith("aria-") || n === "role" || n === "tabindex")
        ),
      ),
    ].sort();
    assert(
      JSON.stringify(aria) === JSON.stringify(["aria-hidden", "role"]),
      `the screen writes ${aria.join(", ")}`,
    );
    assert(
      m.all("[role]").every((el) => el.getAttribute("role") === "presentation"),
      "and the only role is the divider's, which names a 1px box as decoration",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-resizable-clamps: the ends are the control's own, and no chart states them",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await rsScreen();
    await m.settle();
    const handle = m.one("#rs-handle");
    assert(
      handle.getAttribute("min") === "15" && handle.getAttribute("max") === "85",
      `the control carries its own bounds, got ${handle.getAttribute("min")}..${handle.getAttribute("max")}`,
    );

    // The chart's half of the property, by shape and not by substring: one
    // transition, whose whole assignment is the event leaf. A bound stated
    // here — as a guard, or as a second state — would be this screen
    // re-deciding what the control already decided.
    const chart = JSON.parse(m.one("[data-machine]").getAttribute("data-machine")!);
    const on = chart.states.sizing.on;
    const move = Object.values(on)[0] as Record<string, unknown>;
    assert(Object.keys(on).length === 1, `one transition, got ${Object.keys(on).join(", ")}`);
    assert(
      JSON.stringify(move) ===
        JSON.stringify({ assign: { split: { type: "event", params: { field: "valueAsNumber" } } } }),
      `the transition assigns the leaf and nothing else, got ${JSON.stringify(move)}`,
    );
    assert(!JSON.stringify(chart).includes("cond"), `no guard, got ${JSON.stringify(chart)}`);

    // The store's half, and the reason it is a drag PAST each end: a browser
    // clamps to the control's bounds before the leaf reads the value, so a
    // machine that had lost the clamp would land 5 and 99 in the row.
    const before = writes(m).length;
    for (const [to, want] of [[5, 15], [99, 85]]) {
      await rsDrag(m, to);
      assert(rsRow(m).split === want, `dragging to ${to} stored ${rsRow(m).split}`);
    }
    assert(writes(m).length > before, "and each out-of-range drag was still a write");
    await m.stop();
  },
});

// ---------------------------------------------------------------- command ---

// Both of this screen's collections are seeded by their entities, and what a
// test passes for a collection REPLACES that seed — so it passes neither.
const cmdScreen = () => screen("command");

/** A keystroke as the reader makes it: the control is showing the value when
 * `input` fires, which is the whole of what the machine's event leaf reads. */
const cmdType = async (m: Mounted, value: string) => {
  m.set("#command-query", "value", value);
  m.fire("#command-query", "input");
  await m.settle();
};

/** An arrow pressed where the reader's focus is: the field, which is what
 * carries the binding and never gives up DOM focus. */
const cmdPress = async (m: Mounted, key: string) => {
  m.fire("#command-query", "keydown", { key });
  await m.settle();
};

const cmdListed = (m: Mounted) => m.texts(".cmd-option-label");
const cmdRow = (m: Mounted): Row => only(m.rows("command_demo"), "the query row");
const cmdActive = (m: Mounted) => m.one("#command-query").getAttribute("aria-activedescendant");
const cmdWrites = (m: Mounted, table: string) => writes(m).filter((w) => w.table === table);

Deno.test({
  name: "accept-command-types: the value the control was showing lands in the row, keystroke by keystroke",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cmdScreen();
    await m.settle();
    // The query row arrives with the visit; what no keystroke has done yet is
    // write it.
    assert(cmdRow(m).query === "", `the seeded row opens on ${JSON.stringify(cmdRow(m))}`);
    assert(writes(m).length === 0, `hydration wrote ${JSON.stringify(writes(m))}`);

    for (const value of ["cal", "cale", ""]) await cmdType(m, value);
    assert(
      JSON.stringify(cmdWrites(m, "command_demo").map((w) => w.row?.query)) ===
        JSON.stringify(["cal", "cale", ""]),
      `every keystroke states the query it was showing, got ${JSON.stringify(cmdWrites(m, "command_demo"))}`,
    );
    // Emptying the field is a value like any other: a machine treating it as
    // nothing would strand the list on the query before it.
    assert(cmdRow(m).query === "", `the row came to rest on ${JSON.stringify(cmdRow(m))}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-command-filters: the palette is one region over the rows, and the query is its filter",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cmdScreen();
    await m.settle();
    const all = cmdListed(m);
    assert(all.length === 6, `the seed puts six commands on the screen, got ${JSON.stringify(all)}`);

    await cmdType(m, "cal");
    assert(
      JSON.stringify(cmdListed(m)) === JSON.stringify(["Calendar", "Calculator"]),
      `cal lists ${JSON.stringify(cmdListed(m))}`,
    );
    // Shouted, because the operator is ilike and not like.
    await cmdType(m, "PROF");
    assert(JSON.stringify(cmdListed(m)) === JSON.stringify(["Profile"]), `PROF lists ${JSON.stringify(cmdListed(m))}`);
    await cmdType(m, "zzz");
    assert(cmdListed(m).length === 0, `zzz lists ${JSON.stringify(cmdListed(m))}`);
    await cmdType(m, "");
    assert(JSON.stringify(cmdListed(m)) === JSON.stringify(all), `the empty field lists ${JSON.stringify(cmdListed(m))}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-command-ends: Home and End reach both ends of what the filter left",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cmdScreen();
    await m.settle();
    const all = cmdListed(m);

    // With nothing chosen, three of the four keys mean the same thing —
    // entering a list at the top — and End is the one that does not, so it
    // takes its own read under the reverse order.
    await cmdPress(m, "End");
    assert(cmdActive(m) === "preferences", `End with no caret is the last command, got ${cmdActive(m)}`);
    await cmdPress(m, "Home");
    assert(cmdActive(m) === "calendar", `Home is the first, got ${cmdActive(m)}`);

    // Both ends are the FILTER's, not the collection's: the clauses answer over
    // the rows the region holds, which is what the reader can see.
    await cmdType(m, "cal");
    assert(
      JSON.stringify(cmdListed(m)) === JSON.stringify(["Calendar", "Calculator"]),
      `cal lists ${JSON.stringify(cmdListed(m))}`,
    );
    await cmdPress(m, "End");
    assert(cmdActive(m) === "calculator", `End is the last of what matched, got ${cmdActive(m)}`);
    await cmdPress(m, "Home");
    assert(cmdActive(m) === "calendar", `Home is the first of what matched, got ${cmdActive(m)}`);

    // A key whose target set is empty does nothing and says nothing. Every key
    // here names a form off the caret's own id, so with no rows there is no
    // form — an ordinary state a reader types into, not a broken program.
    await cmdType(m, "zzz");
    assert(cmdListed(m).length === 0, `zzz lists ${JSON.stringify(cmdListed(m))}`);
    const before = JSON.stringify(cmdRow(m));
    for (const key of ["Home", "End", "ArrowDown", "ArrowUp"]) {
      await cmdPress(m, key);
      assert(JSON.stringify(cmdRow(m)) === before, `${key} on an empty list wrote ${JSON.stringify(cmdRow(m))}`);
    }

    await cmdType(m, "");
    assert(JSON.stringify(cmdListed(m)) === JSON.stringify(all), "and the whole palette is back");
    await cmdPress(m, "End");
    assert(cmdActive(m) === "preferences", `End again reaches the last, got ${cmdActive(m)}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-command-seeds: the commands arrive with the visit and nothing on the screen writes one",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cmdScreen();
    await m.settle();
    assert(m.rows("command_item").length === 6, `the terminal wrote ${m.rows("command_item").length} rows from the seed`);
    assert(
      JSON.stringify(m.rows("command_item").map((r) => r.pos)) === JSON.stringify([1, 2, 3, 4, 5, 6]),
      `the seed states its own order, got ${JSON.stringify(m.rows("command_item"))}`,
    );
    // The list is the store's answer in the store's order, not the markup's.
    assert(
      JSON.stringify(cmdListed(m)) ===
        JSON.stringify(["Calendar", "Search Emoji", "Calculator", "Profile", "Billing", "Preferences"]),
      `the rendered order is ${JSON.stringify(cmdListed(m))}`,
    );
    assert(
      cmdWrites(m, "command_item").length === 0,
      `the screen wrote the palette it was given: ${JSON.stringify(cmdWrites(m, "command_item"))}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-command-caret: the arrows walk the caret off the projection's neighbours",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cmdScreen();
    await m.settle();
    // Empty rather than a built id: an aria-activedescendant naming an element
    // that is not on the screen is a dangling IDREF.
    assert(cmdActive(m) === "", `no option is active before the first arrow, got ${JSON.stringify(cmdActive(m))}`);

    // Stated as "every option carries it" and not "no option lacks it": the
    // second form passes when there are no options, which is what the filter
    // makes of this list further down.
    const opts = m.all(".cmd-option");
    assert(opts.length === 6, `six options to keep out of the tab order, got ${opts.length}`);
    assert(
      opts.every((b) => b.getAttribute("tabindex") === "-1"),
      "every option is out of the tab sequence",
    );

    // The first arrow is the one worth naming: {active} is empty, so the form
    // it reaches is the pair the hidden limit=1 region stamped from the head of
    // the current read.
    const walk: (string | null)[] = [];
    await cmdPress(m, "ArrowDown");
    walk.push(cmdRow(m).active as string);
    await cmdPress(m, "ArrowDown");
    walk.push(cmdRow(m).active as string);
    await cmdPress(m, "ArrowUp");
    walk.push(cmdRow(m).active as string);
    await cmdType(m, "bil");
    walk.push(cmdRow(m).active as string);
    assert(
      JSON.stringify(walk) === JSON.stringify(["calendar", "emoji", "calendar", ""]),
      `down, down, up and a keystroke walk the caret to ${JSON.stringify(walk)}`,
    );
    await cmdPress(m, "ArrowDown");
    assert(
      cmdActive(m) === cmdRow(m).active && m.all(`#${cmdActive(m)}[role="option"]`).length === 1,
      `the field names the caret's own option and that option is on the screen, got ${cmdActive(m)}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-command-runs: the caret and the choice are two columns, and Enter runs the one it stands on",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cmdScreen();
    await m.settle();

    await cmdPress(m, "ArrowDown");
    await cmdPress(m, "ArrowDown");
    assert(cmdRow(m).active === "emoji", `the caret stands on ${cmdRow(m).active}`);
    // The claim that would fail if one column did both jobs.
    assert(cmdRow(m).chosen === "", `arrowing past a command ran it: ${JSON.stringify(cmdRow(m))}`);

    // Enter is the platform's own: a form holding a text input and a submit
    // button submits on it, and the form carries {active}.
    (m.one("#command-run") as any).requestSubmit();
    await m.settle();
    assert(cmdRow(m).chosen === "emoji", `Enter ran ${JSON.stringify(cmdRow(m))}`);

    // A pointer states both columns at once, because choosing is also standing.
    // Submitted rather than clicked: linkedom models no implicit submission
    // from a submit button, so a click on the option would assert the host's
    // gap and not the screen's wiring.
    (m.one("#command-pick-billing") as any).requestSubmit();
    await m.settle();
    assert(
      cmdRow(m).chosen === "billing" && cmdRow(m).active === "billing",
      `the click ran and moved to ${JSON.stringify(cmdRow(m))}`,
    );
    assert(
      m.one("#billing").getAttribute("aria-selected") === "true" &&
        m.all('.cmd-option[aria-selected="true"]').length === 1,
      "and exactly the run command is marked",
    );
    await m.stop();
  },
});


// ----------------------------------------------------------------- select ---

const SEL_TABLES = (): Record<string, Row[]> => ({ select_demo: [], select_option: [] });

/** A pick is made by moving the `selected` ATTRIBUTE, which is what linkedom's
 * select reads its value off and what the HTML reset algorithm reads. */
const selPick = async (m: Mounted, value: string) => {
  m.choose("#select-choice", value);
  await m.settle();
};

const selMint = async (m: Mounted, value: string) => {
  m.set("#select-mint", "value", value);
  (m.one(".select-mint") as unknown as { requestSubmit(): void }).requestSubmit();
  await m.settle();
};

const selGroup = (m: Mounted, label: string) =>
  m.all(`optgroup[label="${label}"] option`).map((o) => o.getAttribute("value"));

// The rowview's readout and the rowlist's rows are both `.row-readout`, so the
// pick's row is named by the region that binds it.
const SEL_READOUT = ".rowview .row-readout";

Deno.test({
  name: "accept-select-commits: a form with no button submits on change, and the select's name is the field",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("select", SEL_TABLES());
    await m.settle();

    assert(
      m.all('.select-pick button, .select-pick [type="submit"]').length === 0,
      "the pick form holds no button — that is what makes change the submit trigger",
    );
    assert(
      (m.one('.select-pick [name="choice"]') as unknown as { tagName: string }).tagName === "SELECT",
      "and the field is the select itself, with no hidden mirror of its value",
    );
    assert(
      textOf(m.one(SEL_READOUT)) === 'id: the · choice: ""',
      "before a pick the readout binds the empty row the region declares",
    );

    await selPick(m, "Kotlin");

    // A Call carries no payload, so the stated row is read back out of the
    // store: one write, on the collection the form names, keyed by the form's
    // hidden id, and holding exactly the pick.
    assert(
      JSON.stringify(writes(m)) ===
        JSON.stringify([{ op: "create", table: "select_demo", id: "the", row: { id: "the", choice: "Kotlin" } }]),
      `one pick states one row, keyed by the form's hidden id, got ${JSON.stringify(writes(m))}`,
    );
    assert(
      JSON.stringify(m.rows("select_demo")) === JSON.stringify([{ id: "the", choice: "Kotlin" }]),
      `the row the pick stated reads ${JSON.stringify(m.rows("select_demo"))}`,
    );
    assert(
      textOf(m.one(SEL_READOUT)) === 'id: the · choice: "Kotlin"',
      "and the readout followed the row the pick wrote",
    );
    assert(m.all("omnishell--select").length === 1, "the component tag survives as an inert wrapper");
    await m.stop();
  },
});

Deno.test({
  name: "accept-select-options-are-rows: the optgroup is the region, and a minted row is an option",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("select", SEL_TABLES());
    await m.settle();

    assert(
      JSON.stringify(selGroup(m, "Declared in the source")) ===
        JSON.stringify(["CUE", "Go", "Kotlin", "TypeScript"]),
      "the authored group is four literal options",
    );
    assert(
      selGroup(m, "Rows in the store").length === 0,
      "and the live group starts empty, because nothing seeds this collection",
    );
    assert(
      m.all(".rowlist .empty").length === 1,
      "which the row list says rather than rendering a blank box",
    );

    await selMint(m, "Zig");

    assert(
      JSON.stringify(m.rows("select_option")) === JSON.stringify([{ id: "Zig" }]),
      `the mint states one option row, got ${JSON.stringify(m.rows("select_option"))}`,
    );
    assert(
      JSON.stringify(selGroup(m, "Rows in the store")) === JSON.stringify(["Zig"]),
      "which arrives in the live group as an option",
    );
    assert(
      m.one("#select-choice > option").getAttribute("value") === "" &&
        selGroup(m, "Declared in the source").length === 4,
      "and the region's sweep left the prompt and the authored group alone — the optgroup is the region, not the select",
    );
    assert(
      textOf(m.one(".rowlist code")) === "id: Zig",
      "the row list shows the same row the option was rendered from",
    );

    await selPick(m, "Zig");

    assert(
      JSON.stringify(m.rows("select_demo")) === JSON.stringify([{ id: "the", choice: "Zig" }]),
      `a minted option is pickable like any other, got ${JSON.stringify(m.rows("select_demo"))}`,
    );
    assert(
      writes(m).filter((w) => w.table === "select_demo").length === 1,
      `one pick, ${writes(m).filter((w) => w.table === "select_demo").length} writes: ${JSON.stringify(writes(m))}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-select-mint-refuses: the generated pattern is where the option grammar refuses",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("select", SEL_TABLES());
    await m.settle();

    // A leading space is the case the length bound alone would let through,
    // and the one an option label most easily arrives with.
    await selMint(m, " Zig");

    assert(writes(m).length === 0, `an id outside the grammar reached the store: ${JSON.stringify(writes(m))}`);
    assert(m.one(".screen").getAttribute("data-state") === "validation-error", "the refusal is a screen state");
    assert(!m.one(".invalid").hasAttribute("hidden"), "and it says which ids are admitted");
    assert(
      (m.one(".invalid") as unknown as { closest(s: string): { className: string } }).closest("form")!.className ===
        "select-mint",
      "the refusal belongs to the minting form: the pick form's prompt is disabled, so it has nothing to refuse",
    );
    await m.stop();
  },
});
// ---------------------------------------------------------------- breadcrumb

/** Whether this attribute on this node reaches the accessibility tree by name.
 * `alt` is in for an <img> because it is the one non-aria attribute on this
 * screen that states an accessible name: without it the reverse fold below
 * would let an <img alt="Ada Lovelace"> added outside .avatar-image pass a
 * check whose acceptance text says nothing on the screen goes unlisted. */
const bcNamed = (localName: string | undefined, n: string) =>
  n === "role" || n.startsWith("aria-") || (n === "alt" && localName === "img");

/** Every attribute on a node that reaches the accessibility tree by name. */
// deno-lint-ignore no-explicit-any
const bcTreeAttrs = (el: any): string[] =>
  [...el.attributes].map((a: { name: string }) => a.name).filter((n: string) => bcNamed(el.localName, n)).sort();

/** The store calls a screen made, spelled for a failure message. The old suite
 * proxied every store method and counted names touched; the memory store
 * records the reads and the writes alike, which is the same claim about a
 * screen that declares no region. */
const bcTouched = (m: Mounted) => m.store.calls.map((c) => `${c.op} ${c.table}`);

Deno.test({
  name: "accept-breadcrumb-stateless: nothing to be in a state about, and nothing to narrow an arrow to",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("breadcrumb");
    await m.settle();
    const html = await read("shell/screens/breadcrumb.html");
    for (const attr of ["data-live", "data-filter", "data-empty-row", "data-machine"]) {
      assert(m.all(`[${attr}]`).length === 0, `the screen mounts no ${attr}`);
    }
    assert(!/data-on-[a-z]|data-handler/.test(html), "the markup binds no Jessie");
    assert(bcTouched(m).length === 0, `nothing on the screen reaches the store, got ${bcTouched(m).join(", ")}`);
    const shell = await read("shell/shell.yaml");
    assert(/screen: breadcrumb[\s\S]{0,200}handlers: \[\]/.test(shell), "the emitted route lists no handler module");
    // The count the screen prints: `from` resolves to the nearest ancestor
    // carrying an id, and nothing here fires, so nothing needs one.
    assert(m.all("[id]").length === 0, "not one element on the screen carries a DOM id");
    assert(m.all("button").length === 0, "no dead control: every affordance here is a link");
    for (const tag of ["omnishell--breadcrumb", "omnishell--avatar", "omnishell--separator", "omnishell--skeleton"]) {
      assert(m.all(tag).length > 0, `${tag} survives as an inert wrapper`);
    }
    await m.stop();
  },
});

Deno.test({
  name: "accept-breadcrumb-trail: ancestors are links that resolve, the current page is text",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("breadcrumb");
    await m.settle();
    const routes = [...(await read("shell/shell.yaml")).matchAll(/^\s*-?\s*path: (\S+)/gm)].map((r) => r[1]);
    const hrefs = m.all(".breadcrumb-link").map((a) => a.getAttribute("href"));
    assert(hrefs.length > 0, "the trail has ancestors");
    for (const href of hrefs) {
      assert(routes.includes(href!), `${href} is a route this app serves, of ${routes.join(" ")}`);
    }
    const current = m.one(".breadcrumb-current");
    assert(current.getAttribute("aria-current") === "page", "the page the reader is on says so");
    // deno-lint-ignore no-explicit-any
    assert((current as any).tagName === "SPAN" && !current.hasAttribute("href"), "the current page is text, not a link");
    // shadcn spells it role="link" aria-disabled="true", which announces a
    // control that cannot be used where there is no control.
    assert(m.all("[aria-disabled]").length === 0, "nothing in the trail claims to be disabled");
    assert(
      m.one(".breadcrumb").getAttribute("aria-label") === "Breadcrumb",
      "the landmark is named: an unnamed nav is announced as \"navigation\"",
    );
    // role="presentation" would drop the list item and leave the glyph.
    const seps = m.all(".breadcrumb-sep");
    assert(seps.length === hrefs.length, "one separator between each pair of crumbs");
    for (const sep of seps) {
      assert(sep.getAttribute("aria-hidden") === "true", "the glyph is out of the tree, not merely unlabelled");
      assert(!sep.hasAttribute("role"), "and it is hidden rather than presentational");
    }
    await m.stop();
  },
});

Deno.test({
  name: "accept-breadcrumb-fallback: the initials are behind the image, so the name never moves",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("breadcrumb");
    await m.settle();
    // deno-lint-ignore no-explicit-any
    const avatars = m.all(".avatar") as any[];
    assert(
      JSON.stringify(avatars.map((el) => el.getAttribute("aria-label") ?? "")) ===
        JSON.stringify(["Ada Lovelace", "Grace Hopper", ""]),
      "each avatar standing alone is named; the one beside its own name is not",
    );
    for (const el of avatars) {
      const fallback = el.querySelector(".avatar-fallback");
      assert(fallback !== null, "every avatar carries its initials as its own content");
      assert(bcTreeAttrs(fallback!).length === 0, "the initials say nothing: role=img already hides the subtree");
      const img = el.querySelector(".avatar-image");
      // The fallback appears first, so the image is painted over it and an
      // image that never paints leaves it showing — no error event needed.
      if (img !== null) {
        assert(el.children[0] === fallback, "the initials are behind the image, not beside it");
        assert(img.getAttribute("alt") === "", "the name is the wrapper's, so the image adds nothing");
      }
      const decorative = el.getAttribute("aria-hidden") === "true";
      assert(
        decorative ? !el.hasAttribute("role") : el.getAttribute("role") === "img",
        "an avatar is one named image node, or it is decoration — never half of each",
      );
    }
    assert(
      m.all(".avatar-image").length === 1,
      "one specimen carries bytes; the others are the fallback with nothing over it",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-breadcrumb-tree: the printed tree is the markup it describes, both ways",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("breadcrumb");
    await m.settle();
    const rows = m.all(".aria-table tbody tr");
    assert(rows.length >= 12, `the pane prints the whole tree, got ${rows.length} rows`);
    const covered = new Set<unknown>();
    for (const tr of rows) {
      const sel = JSON.parse(tr.getAttribute("data-sel")!) as string;
      const says = JSON.parse(tr.getAttribute("data-attrs")!) as { k: string; v: string }[];
      // deno-lint-ignore no-explicit-any
      const nodes = m.all(sel) as any[];
      assert(nodes.length > 0, `the markup carries no ${sel}, which the table describes`);
      for (const node of nodes) {
        covered.add(node);
        for (const { k, v } of says) {
          const got = node.getAttribute(k);
          if (v === "*") assert(got !== null && got !== "", `${sel}: ${k} carries the instance's own value`);
          else assert(got === v, `${sel}: the table says ${k}="${v}", the node says ${k}="${got}"`);
        }
        // The row is the whole statement, so an attribute the node carries and
        // the row does not name is the map drifting from the markup.
        const want = says.map((a) => a.k).filter((k) => bcNamed(node.localName, k)).sort();
        assert(
          JSON.stringify(bcTreeAttrs(node)) === JSON.stringify(want),
          `${sel}: the row names ${JSON.stringify(want)}, the node carries ${JSON.stringify(bcTreeAttrs(node))}`,
        );
      }
    }
    // The direction a table drifts in silently: an attribute added to a
    // component and never written down.
    // deno-lint-ignore no-explicit-any
    for (const el of m.all("*") as any[]) {
      if (bcTreeAttrs(el).length === 0) continue;
      assert(covered.has(el), `<${el.tagName.toLowerCase()}> carries ${bcTreeAttrs(el).join(", ")} and no row lists it`);
    }
    await m.stop();
  },
});

Deno.test({
  name: "accept-breadcrumb-motion: the pulse stops where the design system says stop",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const css = (await read("shell/screens/breadcrumb.css")).replace(/\/\*[\s\S]*?\*\//g, "");
    // A literal duration outlives the reduced-motion block, which reaches the
    // screen only by zeroing the tokens.
    const literals = css.match(/(?<![-\w.])\d+(?:\.\d+)?m?s(?![-\w])/g) ?? [];
    assert(literals.length === 0, `every duration is a token here, got ${literals}`);
    assert(
      /animation:[^;]*calc\(\s*var\(--motion-base\)\s*\*\s*\d+\s*\)/.test(css),
      "the pulse is a multiple of the token, so zeroing the token zeroes the pulse",
    );
    const m = await screen("breadcrumb");
    await m.settle();
    for (const el of m.all(".skeleton")) {
      assert(el.getAttribute("aria-hidden") === "true", "a placeholder announces nothing");
    }
    // aria-busy belongs to the element whose content is on its way, and
    // nothing on this screen is loading.
    assert(m.all("[aria-busy]").length === 0, "no busyness is claimed that the screen does not have");
    await m.stop();
  },
});

// --------------------------------------------------------------------- sheet

/** A surface with its instance identity folded out: the key is in the id and
 * in both relations that point back at it, so replacing it is what leaves the
 * generator's own writing behind to compare. */
// deno-lint-ignore no-explicit-any
const shFoldKey = (el: any, key: string): Record<string, string> => {
  const out: Record<string, string> = {};
  for (const name of el.getAttributeNames()) out[name] = el.getAttribute(name)!.replaceAll(key, "K");
  return out;
};

const shDifferingNames = (a: Record<string, string>, b: Record<string, string>) =>
  [...new Set([...Object.keys(a), ...Object.keys(b)])].filter((n) => a[n] !== b[n]).sort();

// deno-lint-ignore no-explicit-any
const shFooterClasses = (el: any): string[] =>
  [...el.querySelectorAll(".dialog-footer > button")].map((b: { className: string }) => b.className);

const shTouched = (m: Mounted) => m.store.calls.map((c) => `${c.op} ${c.table}`);

Deno.test({
  name: "accept-sheet-one-generator: three names, and the markup carries the difference",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("sheet");
    await m.settle();
    const surface = (key: string) => m.one(`#dialog-${key}`);
    const right = shFoldKey(surface("panel"), "panel");
    const left = shFoldKey(surface("nav"), "nav");
    const bottom = shFoldKey(surface("drawer"), "drawer");
    const alert = shFoldKey(surface("confirm"), "confirm");

    // The sheet, its mirror and the drawer, folded together: one attribute
    // differs, which is the whole of what #Sheet and #Drawer are.
    for (const [name, other] of [["the left sheet", left], ["the drawer", bottom]] as const) {
      assert(
        JSON.stringify(shDifferingNames(right, other)) === JSON.stringify(["data-edge"]),
        `${name} differs from the right sheet by ${shDifferingNames(right, other)}`,
      );
    }
    assert(
      JSON.stringify([right, left, bottom].map((s) => s["data-edge"])) === JSON.stringify(["right", "left", "bottom"]),
      "the three edges are three values of one attribute",
    );

    // The alert dialog, both directions: what it adds, and what it drops.
    const adds = [
      ...Object.keys(alert).filter((n) => !(n in right)),
      ...shFooterClasses(surface("confirm"))
        .filter((c) => !shFooterClasses(surface("panel")).includes(c))
        .map((c) => `button.${c}`),
    ];
    assert(
      JSON.stringify(adds) === JSON.stringify(["role", "button.dialog-ask"]),
      `the alert dialog adds ${JSON.stringify(adds)}`,
    );
    assert(
      JSON.stringify(Object.keys(right).filter((n) => !(n in alert))) === JSON.stringify(["data-edge"]),
      "and drops only the edge it does not have",
    );
    // One wrapper tag across all four, because they are one component: the
    // catalog's three names live in CUE, and the DOM says dialog.
    assert(m.all("omnishell--dialog").length === 4, "four instances of one tag");
    await m.stop();
  },
});

Deno.test({
  name: "accept-sheet-dismissal: openness is two attributes, the answer included",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("sheet");
    await m.settle();
    assert(
      JSON.stringify(m.all("[command]").map((el) => el.getAttribute("command"))) ===
        JSON.stringify([
          "show-modal",
          "close",
          "show-modal",
          "close",
          "show-modal",
          "close",
          "show-modal",
          "close",
          "close",
        ]),
      "every surface is opened and closed by the modal command pair, and both of the alert dialog's answers close",
    );
    for (const el of m.all("[commandfor]")) {
      assert(
        m.all(`#${el.getAttribute("commandfor")}`).length === 1,
        `commandfor="${el.getAttribute("commandfor")}" resolves on this screen`,
      );
    }
    // The element states its own modality, and a modal invoker has no expanded
    // state to report: either attribute here would be a second spelling.
    for (const attr of ["[aria-modal]", "[aria-expanded]"]) {
      assert(m.all(attr).length === 0, `nothing on the screen writes ${attr}`);
    }
    await m.stop();
  },
});

Deno.test({
  name: "accept-sheet-alert-contract: the promise is the role, the description and where focus opens",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("sheet");
    await m.settle();
    const surfaces = m.all(".dialog");
    assert(surfaces.length === 4, `four surfaces, got ${surfaces.length}`);
    const alerts = surfaces.filter((s) => s.getAttribute("role") === "alertdialog");
    assert(alerts.length === 1, "one surface asks a question, so one carries the role");
    // role="dialog" is the UA's on <dialog>; only the promise is written.
    for (const s of surfaces) {
      const role = s.getAttribute("role");
      assert(role === null || role === "alertdialog", `a surface writes role="${role}"`);
    }
    // Required for an alert dialog, advisable for a dialog, and met by all four
    // because the generator never made a description optional.
    for (const s of surfaces) {
      for (const rel of ["aria-labelledby", "aria-describedby"]) {
        const target = m.all(`#${s.getAttribute(rel)}`);
        assert(target.length === 1, `${s.getAttribute("id")}'s ${rel} points at an element that exists`);
        assert(textOf(target[0]).length > 0, `${s.getAttribute("id")}'s ${rel} points at something said`);
      }
    }
    const alert = alerts[0];
    const focused = [...alert.querySelectorAll("[autofocus]")];
    assert(focused.length === 1, "one control opens with focus");
    assert(textOf(focused[0]) === "Cancel", `focus opens on ${focused[0].textContent}`);
    // The refusal is first and keeps the focus; the answer is second and takes
    // neither, which is the deliberate half the platform does leave to markup.
    assert(
      JSON.stringify(shFooterClasses(alert)) === JSON.stringify(["dialog-dismiss", "dialog-ask"]),
      "the refusal precedes the answer",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-sheet-no-state: asking a question is not holding one",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("sheet");
    await m.settle();
    const html = await read("shell/screens/sheet.html");
    for (const attr of ["data-live", "data-filter", "data-empty-row", "data-machine"]) {
      assert(m.all(`[${attr}]`).length === 0, `the screen mounts no ${attr}`);
    }
    assert(!/data-on-[a-z]|data-handler/.test(html), "the markup binds no Jessie");
    assert(shTouched(m).length === 0, `nothing on the screen reaches the store, got ${shTouched(m).join(", ")}`);
    const shell = await read("shell/shell.yaml");
    assert(/screen: sheet[\s\S]{0,200}handlers: \[\]/.test(shell), "the emitted route lists no handler module");
    await m.stop();
  },
});

Deno.test({
  name: "accept-sheet-motion: every edge arrives instantly when the tokens are zero",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const css = (await read("shell/screens/sheet.css")).replace(/\/\*[\s\S]*?\*\//g, "");
    // A literal duration outlives the reduced-motion block, which reaches the
    // screen only by zeroing the tokens — so the screen must not fork it either.
    const literals = css.match(/(?<![-\w.])\d+(?:\.\d+)?m?s(?![-\w])/g) ?? [];
    assert(literals.length === 0, `every duration is a token here, got ${literals}`);
    assert(!/prefers-reduced-motion/.test(css), "the collapse is the shared layer's, not a second copy");
    assert(
      /transition:[^;]*translate\s+var\(--motion-base\)/.test(css),
      "the travel is the design system's own duration",
    );
    // The resting position and the opening frame are the same declaration
    // twice: without the second one an edge surface is simply there.
    const [resting, starting = ""] = css.split("@starting-style");
    const travels = (chunk: string) =>
      [...chunk.matchAll(/translate:\s*([^;]+);/g)].map((t) => t[1].trim()).filter((v) => v !== "0 0").sort();
    assert(travels(resting).length === 4, `four surfaces rest off-position, got ${travels(resting)}`);
    assert(
      JSON.stringify(travels(starting)) === JSON.stringify(travels(resting)),
      `the opening frames restate the resting positions, got ${travels(starting)}`,
    );
  },
});
// The menu screen: three machine regions over two collections, two of them
// siblings pinning different ids on one.

/** Both collections take the `tab` path, so a visit opens on nothing and the
 * fallback rows are synthesized rather than stored. */
const menuScreen = () =>
  screen("menu", {
    menu_option_demo: [],
    menu_profile_demo: [],
    menu_go_demo: [],
    menubar_demo: [],
    context_menu_demo: [],
  });

/** The shape the menu tests walk: linkedom's nodes, narrowed to what a claim
 * about the accessibility tree actually reads. */
type MenuNode = {
  tagName: string;
  id: string;
  children: MenuNode[];
  readonly textContent: string | null;
  getAttribute(name: string): string | null;
  hasAttribute(name: string): boolean;
  parentElement: MenuNode | null;
  closest(selector: string): MenuNode | null;
  querySelector(selector: string): MenuNode | null;
  querySelectorAll(selector: string): MenuNode[];
};

const menuAll = (m: Mounted, selector: string) => m.all(selector) as unknown as MenuNode[];

/** Every element under `root` that reaches the accessibility tree: an
 * aria-hidden node takes its whole subtree with it, which is what lets a
 * visible group heading sit inside a menu at all. */
const menuInTheTree = (root: MenuNode): MenuNode[] => {
  const out: MenuNode[] = [];
  const walk = (el: MenuNode) => {
    for (const child of el.children) {
      if (child.getAttribute("aria-hidden") === "true") continue;
      out.push(child);
      walk(child);
    }
  };
  walk(root);
  return out;
};

/** The roles a menu's tree admits. A node reaching an open menu carrying
 * anything else is a stranger, whatever it looks like. */
const MENU_ROLES = new Set(["menuitem", "menuitemcheckbox", "menuitemradio", "group", "separator"]);

Deno.test({
  name: "accept-menu-items: three item kinds, links that resolve, and no region inside a region",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await menuScreen();
    await m.settle();

    for (const role of ["menuitem", "menuitemcheckbox", "menuitemradio"]) {
      assert(m.all(`[role="${role}"]`).length > 0, `the screen carries a ${role}`);
    }

    // Every plain item is an anchor at a route this app serves: a menu item
    // invokes a command, and a navigation is the only command with no module
    // behind it.
    const routes = [...(await read("shell/shell.yaml")).matchAll(/^\s*-?\s*path: (\S+)/gm)].map((x) => x[1]);
    const links = menuAll(m, '[role="menuitem"]').filter((el) => el.tagName === "A");
    assert(links.length === 9, `nine plain items across the three containers, got ${links.length}`);
    for (const a of links) {
      const href = a.getAttribute("href")!;
      assert(routes.includes(href), `${href} is a route this app serves, of ${routes.join(" ")}`);
    }

    // A machine binds one row, and a region nested inside a singleton region is
    // never hydrated — so every stateful item stands beside its siblings rather
    // than under the surface as a region of its own.
    const regions = menuAll(m, "[data-live]");
    assert(
      regions.length === 9,
      `four surfaces, the bar, the context menu's own row, and the readout panes, got ${regions.length}`,
    );
    for (const region of regions) {
      assert(
        region.parentElement?.closest("[data-live]") == null,
        `${region.getAttribute("data-live")} is nested inside another region`,
      );
    }

    m.fire(links[0] as unknown as El);
    await m.settle();
    assert(writes(m).length === 0, `a link's click wrote ${JSON.stringify(writes(m))}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-menu-check: the binary chart under menuitemcheckbox, two items over two columns",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await menuScreen();
    await m.settle();
    const aria = (id: string) => m.one(`#${id}`).getAttribute("aria-checked");
    const col = (name: string) => only(m.rows("menu_option_demo"), "the surface's row")[`chk_${name}`];
    // Every write that carried this item's column, the first included: a chart
    // whose row does not exist yet states the whole synthesized row, so the
    // opening value rides in with every other chart's.
    const wroteTo = (name: string) =>
      writes(m).filter((c) => c.table === "menu_option_demo" && c.row?.[`chk_${name}`] !== undefined);

    assert(aria("mi-bookmarks") === "false" && aria("mi-urls") === "false", "both items open unchecked");

    m.fire("#mi-bookmarks");
    await m.settle();
    // The first leg of the round trip, read off the control rather than off the
    // written payload: a write recorder carrying no values cannot otherwise say
    // the chart passed through `true` on its way back to `false`.
    assert(aria("mi-bookmarks") === "true", `the first click left the item on ${aria("mi-bookmarks")}`);

    m.fire("#mi-bookmarks");
    await m.settle();
    m.fire("#mi-urls");
    await m.settle();

    assert(
      JSON.stringify(wroteTo("bookmarks").map((c) => c.row?.chk_bookmarks)) === JSON.stringify(["true", "false"]),
      `two clicks state the item and unstate it, got ${JSON.stringify(wroteTo("bookmarks"))}`,
    );
    assert(col("bookmarks") === "false", `the round trip came back as ${col("bookmarks")}`);
    assert(
      JSON.stringify(wroteTo("urls").map((c) => c.row?.chk_urls)) === JSON.stringify(["false", "true"]),
      `the second item's column rides in unset and then states itself, got ${JSON.stringify(wroteTo("urls"))}`,
    );
    assert(col("urls") === "true", `the second item landed on ${col("urls")}`);
    // THE CASE THIS PAIR IS HERE FOR, restated for one row: the two charts are
    // byte-identical but for the trigger id and both run on the surface's
    // region, so every write wakes both. A COLUMN each is what says each owns
    // its own — and parallelLint is what keeps them from sharing one.
    const rows = m.rows("menu_option_demo");
    assert(rows.length === 1, `one surface, ${rows.length} row(s): ${JSON.stringify(rows)}`);
    assert(aria("mi-bookmarks") === "false" && aria("mi-urls") === "true", "each item's ARIA is its own column's");
    await m.stop();
  },
});

Deno.test({
  name: "accept-menu-radio: one profile chosen, every other unchosen, and no deselect",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await menuScreen();
    await m.settle();
    const options = () => menuAll(m, '[role="menuitemradio"]');
    const checked = () => options().map((o) => o.getAttribute("aria-checked"));
    assert(
      options().map((o) => o.id).join(",") === "mi-profile-andy,mi-profile-benoit,mi-profile-luis",
      `ids are keyed and part-slotted, got ${options().map((o) => o.id).join(",")}`,
    );
    assert(checked().join(",") === "true,false,false", "the machine's context chooses the first option");

    m.fire("#mi-profile-benoit");
    await m.settle();
    assert(checked().join(",") === "false,true,false", `one chosen, the others not, got ${checked()}`);
    const row = only(m.rows("menu_profile_demo"), "after choosing benoit");
    assert(
      row.profile === "benoit" && row.chk_andy === "false" && row.chk_benoit === "true" &&
        row.chk_luis === "false",
      `one stated row moves the field and every aria-checked, got ${JSON.stringify(row)}`,
    );
    assert(writes(m).length === 1, `one choice, ${writes(m).length} writes: ${JSON.stringify(writes(m))}`);

    // A radiogroup has no deselect: no arrow leaves a state for itself.
    m.fire("#mi-profile-benoit");
    await m.settle();
    assert(writes(m).length === 1, `the chosen item's click wrote ${JSON.stringify(writes(m))}`);
    assert(m.rows("menu_profile_demo").length === 1, "a stated row is one row");
    await m.stop();
  },
});

Deno.test({
  name: "accept-menu-tree: only items, groups and separators reach either menu",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await menuScreen();
    await m.settle();

    const menus = menuAll(m, '[role="menu"]');
    assert(menus.length === 4, `one dropdown, two bar menus and the context menu, got ${menus.length}`);
    for (const menu of menus) {
      // A menu's name is the control that opens it — except the one no control
      // opens. A right-click has no invoker, so the context menu has no
      // trigger's words to borrow and carries a name of its own; borrowing the
      // target's would name the menu after a whole panel.
      const invoked = menu.getAttribute("aria-labelledby") !== null;
      if (invoked) {
        // Each names its OWN trigger: an ID reference resolving to a duplicate
        // would name whichever the document reached first.
        const named = menuAll(m, `#${menu.getAttribute("aria-labelledby")}`);
        assert(named.length === 1, `${menu.id} is named by one trigger that exists, found ${named.length}`);
        const trigger = named[0];
        assert(trigger.getAttribute("aria-haspopup") === "menu", `${menu.id}'s trigger says what it opens`);
        assert(trigger.getAttribute("commandfor") === menu.id, `${menu.id}'s trigger commands it and no other`);
      } else {
        assert((menu.getAttribute("aria-label") ?? "").length > 0, `${menu.id} is named by something`);
        assert(
          menuAll(m, `[commandfor="${menu.id}"]`).length === 0,
          `${menu.id} is opened by no invoker, which is why it names itself`,
        );
      }

      for (const el of menuInTheTree(menu)) {
        const role = el.getAttribute("role");
        assert(
          role !== null && MENU_ROLES.has(role),
          `<${el.tagName.toLowerCase()}> reaches ${menu.id}'s tree carrying role ${role}`,
        );
      }
    }

    // The heading is the group's name and not a node in it: aria-labelledby
    // reads a hidden target, which is what lets one string do both jobs.
    const groups = menuAll(m, '[role="group"]');
    assert(groups.length === 5, `five groups across the three containers, got ${groups.length}`);
    for (const group of groups) {
      const named = menuAll(m, `#${group.getAttribute("aria-labelledby")}`);
      assert(
        named.length === 1,
        `${group.getAttribute("aria-labelledby")} names one element that exists, found ${named.length}`,
      );
      const label = named[0];
      assert(label.getAttribute("aria-hidden") === "true", "the heading is out of the tree it names");
      assert(textOf(label).length > 0, "the heading a reader sees is the name a reader hears");
    }

    // Name from content: a tick left in the tree would join its item's name.
    for (const item of menuAll(m, "[aria-checked]")) {
      const tick = item.querySelector(".menu-tick");
      assert(tick !== null && tick.getAttribute("aria-hidden") === "true", `${item.id}'s tick is out of the tree`);
      assert(textOf(item).length > 0, `${item.id} is named by its own label`);
    }

    const bar = m.one('[role="menubar"]') as unknown as MenuNode;
    assert(bar.getAttribute("aria-label") === "Menubar", 'an unnamed bar is announced as "menu bar" and no more');
    for (const child of bar.children) {
      assert(
        child.getAttribute("role") === "menuitem",
        `the bar holds menuitems alone, found role ${child.getAttribute("role")}`,
      );
    }
    // Which is exactly why both of its surfaces stand outside it.
    assert(bar.querySelector('[role="menu"]') === null, "no menu sits inside the bar");
    assert(
      m.all('[role="separator"]').length === 1,
      "one separator, drawn between the dropdown's two groups and at no edge",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-menu-keyboard: every item its own tab stop, and nothing claimed that is not kept",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await menuScreen();
    await m.settle();

    // Two kinds of tab stop, and the difference is APG's. A menubar is given
    // ONE, so the bar's triggers are a roving set: the current one carries 0
    // and the other -1. Every item INSIDE a surface keeps its own, so no item
    // carries a tabindex at all and Tab reaches all of them — the caret there
    // is data-cur, which owns no tab order.
    //
    // The third is the context menu's target: a keyboard reader raises that
    // menu with Shift+F10 or the Menu key, both of which fire contextmenu on
    // the FOCUSED element, and an unfocusable panel would have a menu only a
    // mouse could open.
    const stops = m.all("[tabindex]") as unknown as El[];
    assert(
      JSON.stringify(stops.map((el) => `${el.getAttribute("id")}=${el.getAttribute("tabindex")}`)) ===
        JSON.stringify(["menu-view-trigger=0", "menu-go-trigger=-1", "menu-ctx-target=0"]),
      `one tab stop on the bar and one on the context target, got ${
        stops.map((el) => `${el.getAttribute("id")}=${el.getAttribute("tabindex")}`).join(", ")
      }`,
    );
    assert(
      menuAll(m, '[role="menuitem"],[role="menuitemcheckbox"],[role="menuitemradio"]')
        .filter((el) => el.closest(".menu-surface") !== null)
        .every((el) => !el.hasAttribute("tabindex")),
      "no item inside a surface leaves the Tab sequence",
    );
    // The UA writes a popover invoker's expandedness, and a hand-written one
    // would be a second spelling of a fact the browser already states.
    assert(m.all("[aria-expanded]").length === 0, "no aria-expanded is written");

    const items = ["menuitem", "menuitemcheckbox", "menuitemradio"]
      .flatMap((role) => menuAll(m, `[role="${role}"]`));
    assert(
      items.length === 16,
      `nine links, two bar triggers, two checkbox items and three radio items, got ${items.length}`,
    );
    for (const el of items) {
      assert(
        el.tagName === "A" ? el.hasAttribute("href") : el.getAttribute("type") === "button",
        `${el.id || textOf(el)} is a real link or a real button, so Space and Enter invoke it`,
      );
    }
    // A shortcut is expressible now — a guard is a module and a module can test
    // any key — but a CHORD is not in the walk's key set, and an item
    // advertising one whose chart draws no arrow would still overclaim. The
    // prose pane says so and names the glyph, so the claim is about what the
    // items carry rather than about the screen's own bytes.
    for (const el of items) {
      assert(!/⌘|⇧|Ctrl\+|Alt\+/.test(textOf(el)), `${el.id || textOf(el)} advertises a key it cannot answer`);
    }
    assert(m.all("[class*=shortcut]").length === 0, "no item carries a shortcut slot at all");
    await m.stop();
  },
});
// One collection, three regions over the same pinned row — the editing
// singleton, the readout singleton, and the list whose only item is the
// delete. The store honours each region's filter, or the list would answer for
// a row it does not hold and the delete would render before anything wrote one.
const formScreen = () => screen("form", { form_demo: [] });

/** A keystroke: the value the control now holds, and the event the form counts
 * edits by — the only thing that clears a refusal. */
const formType = (m: Mounted, selector: string, value: string) => {
  m.set(selector, "value", value);
  m.fire(selector, "input");
};

const formSave = async (m: Mounted, handle: string, bio: string) => {
  formType(m, "#form-handle", handle);
  formType(m, "#form-bio", bio);
  m.fire(".form-edit", "submit");
  // The success flash is a 600ms wait on the table's clock; settle drives it
  // out, so what is read after this is the base state and not the flash.
  await m.settle();
};

const formState = (m: Mounted) => m.screen.getAttribute("data-state");
const formDropButtons = (m: Mounted) => m.all(".form-drop button").length;

Deno.test({
  name: "accept-form-commits: a submit the gate admits states one row, and the readout follows",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await formScreen();
    await m.settle();

    assert(
      textOf(m.one(".row-readout")) === 'id: the · handle: "" · bio: ""',
      "before a save the readout stands on the region's own empty row",
    );

    await formSave(m, "ada_lovelace", "Wrote the first algorithm.");

    // The store call carries no payload here, so the row the save stated is
    // read back off the collection instead.
    assert(
      JSON.stringify(writes(m)) === JSON.stringify([{
        op: "create",
        table: "form_demo",
        id: "the",
        row: { id: "the", handle: "ada_lovelace", bio: "Wrote the first algorithm." },
      }]),
      `one save states one row, keyed by the form's hidden id, got ${JSON.stringify(writes(m))}`,
    );
    assert(m.rows("form_demo").length === 1, "a stated row is one row");
    assert(
      JSON.stringify(only(m.rows("form_demo"), "after one save")) ===
        JSON.stringify({ id: "the", handle: "ada_lovelace", bio: "Wrote the first algorithm." }),
      `the row is the form's three fields and nothing else, got ${JSON.stringify(m.rows("form_demo"))}`,
    );
    assert(
      textOf(m.one(".row-readout")) === 'id: the · handle: "ada_lovelace" · bio: "Wrote the first algorithm."',
      `the readout followed the row the form wrote, got ${textOf(m.one(".row-readout"))}`,
    );
    assert(formState(m) === "populated", "and the screen came to rest on the state the row puts it in");
    assert(m.all("omnishell--form").length === 1, "the component tag survives as an inert wrapper");
    await m.stop();
  },
});

Deno.test({
  name: "accept-form-refuses: the generated pattern refuses, and only a keystroke clears it",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await formScreen();
    await m.settle();

    assert(m.one(".invalid").hasAttribute("hidden"), "the message is hidden until something is refused");
    assert(m.one(".invalid").getAttribute("role") === "alert", "and it is the live region that carries it there");

    // A row first, so the refusal below is measured against a store that has
    // something to lose: a refused submit must leave it exactly as it was.
    await formSave(m, "ada_lovelace", "Wrote the first algorithm.");

    formType(m, "#form-handle", "Ada Lovelace");
    m.fire(".form-edit", "submit");
    await m.settle();

    assert(writes(m).length === 1, `a handle outside the grammar reached the store: ${JSON.stringify(writes(m))}`);
    assert(
      only(m.rows("form_demo"), "after a refused submit").handle === "ada_lovelace",
      "and the row it would have overwritten is untouched",
    );
    assert(formState(m) === "validation-error", "the refusal is a screen state");
    assert(!m.one(".invalid").hasAttribute("hidden"), "and the message says which handles are admitted");
    assert(
      m.all(".invalid").length === 1 && m.all(".form-edit > .invalid").length === 1,
      "the refusal belongs to the editing form: the delete carries no control to refuse",
    );

    formType(m, "#form-handle", "ada_lovelacee");
    await m.settle();

    assert(formState(m) === "populated", "a keystroke hands the screen back");
    assert(m.one(".invalid").hasAttribute("hidden"), "and hides the message with it");
    await m.stop();
  },
});

Deno.test({
  name: "accept-form-defaults: each control binds its default value, which is where a reset lands",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await formScreen();
    await m.settle();
    const html = await read("shell/screens/form.html");

    // The direction this drifts in silently: one data-value on a labelled
    // control and the shell's reset would blank it while the row still held
    // the value. Only the hidden id may carry one — it is resolved at submit
    // and is not a control a reset can empty.
    for (const el of m.all("[data-value]")) {
      assert(
        el.getAttribute("type") === "hidden",
        `${(el as unknown as { tagName: string }).tagName} binds data-value; a control's default is what a reset returns to`,
      );
    }
    assert(/<input class="field-control"[^>]*value="\{handle\}"/.test(html), "the input binds its value attribute");
    assert(/<textarea[^>]*data-text="\{bio\}"/.test(html), "the textarea binds its own text");

    await formSave(m, "ada_lovelace", "Wrote the first algorithm.");

    const handle = m.one("#form-handle") as unknown as { value: string };
    const bio = m.one("#form-bio") as unknown as { value: string };
    assert(
      handle.value === "ada_lovelace" && bio.value === "Wrote the first algorithm.",
      `after the shell's reset both controls hold the row, got ${handle.value} / ${bio.value}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-form-labelled: named, described, and honest about the attribute it cannot write",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await formScreen();
    await m.settle();

    for (const control of m.all("input:not([type=hidden]), textarea")) {
      const id = control.getAttribute("id");
      assert(
        id !== null && m.all(`label[for="${id}"]`).length === 1,
        `${(control as unknown as { tagName: string }).tagName} is not named by a label that resolves to it`,
      );
      const described = control.getAttribute("aria-describedby");
      const hint = described === null ? [] : m.all(`#${described}`);
      assert(hint.length === 1, `${id} is described by ${described}, which is on no element`);
      assert(
        !hint[0].hasAttribute("hidden"),
        `${id}'s description is hidden: accname does not skip a hidden node a description references`,
      );
    }
    assert(m.all('[role="alert"]').length === 1, "one assertive live region, and it is the refusal");
    // Read off the tree rather than the file: the closing pane names both
    // attributes in the prose that explains why neither is written.
    assert(
      m.all("[aria-invalid]").length === 0,
      "no aria-invalid is written: the verdict is no column and the invalid event does not bubble",
    );
    assert(
      m.all("[aria-errormessage]").length === 0,
      "and nothing associates the message with the field either",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-form-clears: the delete and the row it acts on arrive and leave together",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await formScreen();
    await m.settle();
    const states: (string | null)[] = [];
    const buttons: number[] = [];

    states.push(formState(m));
    buttons.push(formDropButtons(m));

    await formSave(m, "ada_lovelace", "Wrote the first algorithm.");
    states.push(formState(m));
    buttons.push(formDropButtons(m));

    m.fire(".form-drop", "submit");
    await m.settle();
    states.push(formState(m));
    buttons.push(formDropButtons(m));

    assert(
      JSON.stringify(buttons) === JSON.stringify([0, 1, 0]),
      `no button before the row, one with it, none after, got ${JSON.stringify(buttons)}`,
    );
    assert(m.rows("form_demo").length === 0, "the delete took the row away");
    assert(
      JSON.stringify(writes(m).map((w) => [w.op, w.table, w.id])) ===
        JSON.stringify([["create", "form_demo", "the"], ["remove", "form_demo", "the"]]),
      `the row arrives and leaves once each, got ${JSON.stringify(writes(m))}`,
    );
    assert(
      JSON.stringify(states) === JSON.stringify(["empty", "populated", "empty"]),
      `the list region's own count is the screen's state, got ${JSON.stringify(states)}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-form-declaration: the printed form is the form in the markup, both ways",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await formScreen();
    await m.settle();
    const html = await read("shell/screens/form.html");

    const declared = JSON.parse(m.one(".form-json").textContent as string) as {
      id: string;
      fields: { name: string; control: string; required?: boolean; maxLength?: number }[];
    };
    const edit = m.one(".form-edit");
    assert(declared.id === edit.getAttribute("data-form"), "the pane prints the form the stage mounts");

    const controls = [...edit.querySelectorAll("[name]")] as unknown as {
      getAttribute(n: string): string | null;
      tagName: string;
    }[];
    const byName = new Map(controls.map((c) => [c.getAttribute("name")!, c]));
    for (const field of declared.fields) {
      const control = byName.get(field.name);
      assert(control !== undefined, `the declaration names ${field.name}, which is no control on the screen`);
      const kind = control!.tagName === "TEXTAREA" ? "textarea" : control!.getAttribute("type") ?? "text";
      assert(kind === field.control, `${field.name} is declared ${field.control} and emitted ${kind}`);
      if (field.maxLength !== undefined) {
        assert(
          control!.getAttribute("maxlength") === String(field.maxLength),
          `${field.name}'s length is declared once and emitted twice; the two disagree`,
        );
      }
      assert(
        (control!.getAttribute("required") !== null) === (field.required === true),
        `${field.name}'s requiredness disagrees with the control`,
      );
    }
    for (const name of byName.keys()) {
      assert(
        declared.fields.some((f) => f.name === name),
        `${name} is a control the declaration does not carry`,
      );
    }
    assert(!/data-machine/.test(html), "the screen runs no machine — the writes are the two forms'");
    assert(!/data-on-[a-z]|data-handler/.test(html), "the markup binds no Jessie");
    const shell = await read("shell/shell.yaml");
    assert(/screen: form[\s\S]{0,200}handlers: \[\]/.test(shell), "the emitted route lists no handler module");
    await m.stop();
  },
});
// /table and /data-table: the two screens whose content IS a collection.

/** table_row and table_query are `tab` collections with no seed, so the screen
 * opens on nothing and every row below is one the test minted. */
const tblTables = (): Record<string, Row[]> => ({ table_query: [], table_row: [] });

/** The rendered rows, whitespace collapsed: a `<tr>`'s cells are separate
 * elements, so its text carries the markup's own indentation. */
const tblShown = (m: Mounted): string[] => m.all(".tbl-body tr").map((tr) => (tr.textContent ?? "").trim().replace(/\s+/g, " "));

const TBL_THREE_ROWS = [
  { id: "INV-001", payer: "Ada Lovelace", status: "Paid", amount: "250.00" },
  { id: "INV-002", payer: "Grace Hopper", status: "Pending", amount: "150.00" },
  { id: "INV-003", payer: "Ada Byron", status: "Unpaid", amount: "80.00" },
];

/** The reader's gesture: fill the four controls the header declares and press
 * the form's own button. The form carries a submit button, so nothing is
 * submitted by the select's change. */
const tblMint = async (m: Mounted, row: { id: string; payer: string; status: string; amount: string }) => {
  m.set("#table-mint-id", "value", row.id);
  m.set("#table-mint-payer", "value", row.payer);
  m.set("#table-mint-amount", "value", row.amount);
  m.choose("#table-mint-status", row.status);
  (m.one(".tbl-mint") as unknown as { requestSubmit(): void }).requestSubmit();
  await m.settle();
};

const tblType = async (m: Mounted, value: string) => {
  const field = m.one("#table-filter");
  field.setAttribute("value", value);
  m.set(field, "value", value);
  m.fire(field, "input");
  await m.settle();
};

Deno.test({
  name: "accept-table-rows-are-rows: a minted row is a rendered row, and the columns are one declaration",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("table", tblTables());
    await m.settle();

    // The table stands before it has anything to show: a caption and a header
    // row are the table, and the note under it is what stands in for rows.
    assert(tblShown(m).length === 0, `a tab collection opens empty, got ${JSON.stringify(tblShown(m))}`);
    assert(m.all(".tbl-none").length === 1, "and the component says so rather than showing a blank box");
    const heads = m.all("thead th");
    assert(
      heads.length === 4 && heads.every((th) => th.getAttribute("scope") === "col"),
      `four column headers, each scoped to its column, got ${heads.length}`,
    );
    assert(m.all("caption").length === 1, "and a caption, which is where the order is stated");

    await tblMint(m, TBL_THREE_ROWS[0]);
    await tblMint(m, TBL_THREE_ROWS[1]);

    assert(
      JSON.stringify(tblShown(m)) ===
        JSON.stringify(["INV-001 Ada Lovelace Paid 250.00", "INV-002 Grace Hopper Pending 150.00"]),
      `two mints, two rendered rows, got ${JSON.stringify(tblShown(m))}`,
    );
    const bodyRows = m.all(".tbl-body tr");
    assert(
      bodyRows.every((tr) => tr.querySelectorAll('th[scope="row"]').length === 1 && tr.querySelectorAll("th, td").length === 4),
      "each row names itself with a row-scoped header and carries the header's four columns",
    );
    // One declaration behind three emissions: a column that reached the header
    // and not the form would let a reader mint a row the table cannot show.
    const named = m.all(".tbl-mint [name]").map((el) => el.getAttribute("name"));
    assert(
      JSON.stringify(named) === JSON.stringify(["id", "payer", "status", "amount"]),
      `the minting form's controls are the table's columns, got ${JSON.stringify(named)}`,
    );
    assert(m.all("omnishell--table").length === 1, "the component tag survives as an inert wrapper");
    await m.stop();
  },
});

Deno.test({
  name: "accept-table-filters: the region reads again under the enclosing row's query",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("table", tblTables());
    await m.settle();
    const html = await read("shell/screens/table.html");
    for (const row of TBL_THREE_ROWS) await tblMint(m, row);
    assert(tblShown(m).length === 3, `three rows before any filtering, got ${JSON.stringify(tblShown(m))}`);

    // Two matches is the assertion that matters, and it is where the arity
    // bites: a region whose template was swept away by its own first render
    // re-hydrates as a slot and throws on the second matching row.
    await tblType(m, "ada");
    assert(tblShown(m).length === 2, `two payers carry "ada", got ${JSON.stringify(tblShown(m))}`);
    // Case folds, because the op is ilike and not like.
    await tblType(m, "GRACE");
    assert(tblShown(m).length === 1, `ilike folds case, got ${JSON.stringify(tblShown(m))}`);
    await tblType(m, "zzz");
    assert(tblShown(m).length === 0, `no payer carries zzz, got ${JSON.stringify(tblShown(m))}`);
    assert(m.all(".tbl-none").length === 1, "and the note under the table is what a reader sees instead");
    await tblType(m, "");
    assert(tblShown(m).length === 3, `an empty pattern admits every row, got ${JSON.stringify(tblShown(m))}`);

    // The spelling that makes the four assertions above possible: the region
    // points at a template it does not contain, so no render can sweep it.
    const tbody = /<tbody[^>]*>[\s\S]*?<\/tbody>/.exec(html)![0];
    assert(/data-template="table-row"/.test(tbody), "the tbody references a named template");
    assert(!/<template/.test(tbody), "and holds none of its own, which is what survives the re-hydration");
    assert(
      /<template data-item data-name="table-row">/.test(html),
      "the template it names is on the screen, outside every region's children",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-table-no-sort: the order is the author's literal, and nothing on the screen can reach it",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("table", tblTables());
    await m.settle();
    const html = await read("shell/screens/table.html");

    const orders = [...html.matchAll(/data-order="([^"]*)"/g)].map((x) => x[1]);
    assert(orders.length === 1 && orders[0] === "id.asc", `one order clause, and it is a literal, got ${JSON.stringify(orders)}`);
    assert(
      orders.every((o) => !/[{}]/.test(o)),
      "no order interpolates: the interpreter reads data-order raw, so a placeholder would reach the store as a column name",
    );
    // The other half of the same fact: nothing in the header offers a sort,
    // because there would be nothing behind it.
    const head = m.one("thead");
    assert(
      head.querySelectorAll("button, a, input, select, [tabindex], [role], [aria-sort]").length === 0,
      "no column header is a control, and none claims aria-sort",
    );
    // And the chart's side: the only column any arrow writes is the query.
    const machines = [...html.matchAll(/data-machine='([^']*)'/g)]
      .map((x) => JSON.parse(x[1].replace(/&quot;/g, '"')));
    const assigned = machines.flatMap((
      chart: { states: Record<string, { on?: Record<string, { assign?: Record<string, unknown> }> }> },
    ) =>
      Object.values(chart.states).flatMap((s) =>
        Object.values(s.on ?? {}).flatMap((t) => Object.keys(t.assign ?? {}))
      )
    );
    assert(
      JSON.stringify(assigned) === JSON.stringify(["query"]),
      `a machine writes columns of its own row, and a region's order is not one, got ${JSON.stringify(assigned)}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-table-arrives: the clock states the query row, so the table stands before anyone types",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("table", tblTables());
    await m.settle();

    const query = m.rows("table_query");
    assert(query.length === 1, `one query row, stated by the chart itself, got ${JSON.stringify(query)}`);
    assert(query[0].state === "typing", `the clock's arrow came due, got ${query[0].state}`);
    assert(query[0].query === "", "and it states the whole opening world, the empty query included");
    // The frame is a list region over that row, so this is what the arrow
    // bought: /command's palette may wait for a keystroke, a table may not.
    assert(m.all(".tbl").length === 1, "the table is rendered from the row the arrow wrote");
    assert(
      m.one(".screen").getAttribute("data-state") === "populated",
      "and the screen has left the empty frame it opened in",
    );

    // The guarantee is the chart's, not the moment's: `typing` declares no
    // wait, so nothing re-arms and the screen is still.
    const before = writes(m).length;
    m.advance(60_000);
    await m.quiet();
    assert(writes(m).length === before, `the row is stated once, got ${writes(m).length - before} more writes`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-table-css-only: a scroll box is a named tab stop, and a ratio is a class",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("table", tblTables());
    await m.settle();
    const html = await read("shell/screens/table.html");

    const boxes = m.all(".scroll-area");
    assert(boxes.length === 2, `two scroll boxes: the table's and the standalone one, got ${boxes.length}`);
    assert(
      boxes.every((b) => b.getAttribute("tabindex") === "0" && b.getAttribute("role") === "region"),
      "each is a tab stop, or a keyboard reader has no way to move what is inside it",
    );
    assert(
      boxes.every((b) => {
        const ref = b.getAttribute("aria-labelledby");
        return ref === null ? (b.getAttribute("aria-label") ?? "") !== "" : textOf(m.one(`#${ref}`)) !== "";
      }),
      "and each is named — by a label of its own, or by the element already carrying the name",
    );
    assert(
      boxes.filter((b) => b.getAttribute("aria-labelledby") !== null).length === 1,
      "the table's box takes the caption it already has rather than a second spelling of it",
    );

    const ratios = m.all(".aspect");
    assert(ratios.length === 3, `three ratios, got ${ratios.length}`);
    assert(
      ratios.every((r) => /\baspect-(16-9|4-3|1-1)\b/.test(r.getAttribute("class") ?? "")),
      "each wears a shape the stylesheet measures",
    );
    assert(!/ style="/.test(html), "and no instance carries a length of its own: there is no inline style on the screen");
    await m.stop();
  },
});

/** data_row and data_cursor are seeded by shell.yaml, which mountApp reads —
 * stating them here would state a later world than the seed's. */
const dtScreen = () => screen("data-table");

const dtRows = (m: Mounted): El[] => m.all(".dt-body tr");
const dtIds = (m: Mounted) => dtRows(m).map((tr) => tr.getAttribute("id"));
const dtChosen = (m: Mounted) => dtRows(m).filter((tr) => tr.getAttribute("aria-selected") === "true");
const dtGrid = (m: Mounted) => m.one("#dt-grid");
const dtActive = (m: Mounted) => dtGrid(m).getAttribute("aria-activedescendant");
const dtCursorRow = (m: Mounted): Row => only(m.rows("data_cursor"), "the cursor collection");

/** An arrow pressed where the reader's focus actually is: the grid itself. */
const dtPress = async (m: Mounted, key: string) => {
  m.fire(dtGrid(m), "keydown", { key });
  await m.settle();
};

/** The same key with Ctrl held. The binding names it "Ctrl+End", and the DOM
 * says it in two fields — which is the whole of what a chord is here. */
const dtChord = async (m: Mounted, key: string) => {
  m.fire(dtGrid(m), "keydown", { key, ctrlKey: true });
  await m.settle();
};

/** Submit a form by id the way the key does, but resolved against what is
 * RENDERED. linkedom's getElementById reaches into `<template>` content, where
 * the browser's cannot — so a form the markup names by a literal id resolves to
 * the inert copy there and to the live one in a browser. Only the entry pair is
 * spelled with a literal id, and this is the seam. */
const dtSubmit = async (m: Mounted, id: string) => {
  (m.one(`#${id}`) as unknown as { requestSubmit(): void }).requestSubmit();
  await m.settle();
};
const dtPick = (m: Mounted, id: string) => dtSubmit(m, `dt-pick-${id}`);

const dtType = async (m: Mounted, value: string) => {
  const field = m.one("#dt-filter");
  field.setAttribute("value", value);
  m.set(field, "value", value);
  m.fire(field, "input");
  await m.settle();
};

Deno.test({
  name: "accept-data-table-seeded: the rows arrive with the program, and the chart is what that deletes",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await dtScreen();
    await m.settle();
    const html = await read("shell/screens/data-table.html");

    assert(
      m.rows("data_row").length === 8,
      `the emitted shell states the collection's opening world, got ${JSON.stringify(m.rows("data_row"))}`,
    );
    assert(dtIds(m).length === 8, `eight seeded rows are eight rendered rows, got ${JSON.stringify(dtIds(m))}`);
    // Nobody minted them, and that is checkable rather than claimed: no form on
    // the screen writes the collection the grid renders, and no write of the
    // mount's landed there either.
    assert(
      !/data-entity="data_row"/.test(html),
      "no form on the screen writes data_row, so the rows can only be the program's",
    );
    assert(
      writes(m).every((w) => w.table !== "data_row"),
      `and the mount wrote none of them, got ${JSON.stringify(writes(m))}`,
    );
    assert(m.all("omnishell--data-table").length === 1, "the component tag survives as an inert wrapper");

    // /table's chart carries a second state and an `after` whose whole job is
    // to write a row nothing else could. A seeded row deletes both.
    const machine = JSON.parse(/data-machine='([^']*)'/.exec(html)![1].replace(/&quot;/g, '"'));
    assert(
      Object.keys(machine.states).length === 1,
      `one state, because there is no arrival to draw, got ${JSON.stringify(Object.keys(machine.states))}`,
    );
    assert(!/"after"/.test(html), "and no wait is armed anywhere on the screen");
    const state = m.one(".screen").getAttribute("data-state");
    assert(state === "populated", `the screen opens populated rather than passing through empty, got ${state}`);

    const before = writes(m).length;
    m.advance(60_000);
    await m.quiet();
    assert(writes(m).length === before, `the screen is at rest, got ${writes(m).length - before} writes with nobody in it`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-data-table-chosen: choosing a row writes one column of one row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await dtScreen();
    await m.settle();
    const untouched = JSON.stringify(m.rows("data_row"));

    assert(dtActive(m) === "INV-1024", `the grid opens on the seeded cursor, got ${dtActive(m)}`);
    assert(
      dtChosen(m).length === 1 && dtChosen(m)[0].getAttribute("id") === "INV-1024",
      `exactly one row is marked, and it is the one the cursor names, got ${dtChosen(m).length}`,
    );

    await dtPick(m, "INV-1026");

    assert(dtCursorRow(m).cursor === "INV-1026", `one column moved, got ${JSON.stringify(dtCursorRow(m))}`);
    // What a derived column buys: the rows the grid renders are never written.
    // The sel_ spelling would have written a column per option on this one
    // gesture, and every one of them onto a row that is not the reader's.
    assert(JSON.stringify(m.rows("data_row")) === untouched, "and no row of the grid's own collection moved");
    assert(
      writes(m).every((w) => w.table === "data_cursor"),
      `every write lands on the cursor row, got ${JSON.stringify(writes(m))}`,
    );
    assert(
      dtChosen(m).length === 1 && dtChosen(m)[0].getAttribute("id") === "INV-1026",
      "the mark follows the column, because it IS that column compared against each row's own id",
    );
    assert(dtActive(m) === "INV-1026", `and so does the grid's active descendant, got ${dtActive(m)}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-data-table-walks: the arrow keys walk the neighbour the projection named",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await dtScreen();
    await m.settle();

    const walk: (string | null)[] = [];
    for (const key of ["ArrowDown", "ArrowDown", "ArrowUp", "ArrowUp", "ArrowUp"]) {
      await dtPress(m, key);
      walk.push(dtActive(m));
    }
    // The second press is the one the tablist spike could not make: nothing
    // moved focus, so the container still holds the gesture and its own row now
    // names the next row's form. The last two are the clamp — an end names
    // itself, so a gesture there writes what is already true.
    assert(
      JSON.stringify(walk) === JSON.stringify(["INV-1025", "INV-1026", "INV-1025", "INV-1024", "INV-1024"]),
      `down, down, up, up, up, got ${JSON.stringify(walk)}`,
    );
    assert(
      dtRows(m).every((tr) => tr.getAttribute("tabindex") === null),
      "no row is a tab stop of its own, so nothing ever had to move focus between them",
    );
    assert(dtGrid(m).getAttribute("tabindex") === "0", "the grid is the one tab stop, before and after");
    assert(
      m.all(".dt-pick").every((b) => b.getAttribute("tabindex") === "-1"),
      "and the pointer's control is out of the tab sequence, which is what keeps the grid to one stop",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-data-table-filters: a keystroke narrows the grid and clears the choice",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await dtScreen();
    await m.settle();
    await dtPick(m, "INV-1029");
    assert(dtActive(m) === "INV-1029", `a row outside the coming filter is chosen first, got ${dtActive(m)}`);

    const matches: number[] = [];
    await dtType(m, "ada");
    matches.push(dtIds(m).length);
    assert(
      JSON.stringify(dtIds(m)) === JSON.stringify(["INV-1024", "INV-1026"]),
      `what is left is the two payers carrying "ada", got ${JSON.stringify(dtIds(m))}`,
    );
    // The clearing is the assertion that matters: a cursor naming a row the
    // filter removed would name a form that is not on the screen, and the key
    // reaching for it would refuse rather than move.
    assert(dtCursorRow(m).cursor === "", `the choice is cleared by the same write, got ${JSON.stringify(dtCursorRow(m))}`);
    assert(dtChosen(m).length === 0, "so nothing is marked");
    assert(dtActive(m) === "", "and the grid names no active descendant");

    // The composition is what the empty cursor has to keep: the key still names
    // a form, and the form is on the screen, rendered by the entry region under
    // the same read the grid uses.
    assert(
      dtGrid(m).getAttribute("data-key") === '{"ArrowDown":"dt-next-","ArrowUp":"dt-prev-","Ctrl+Home":"dt-first-","Ctrl+End":"dt-last-"}',
      `the key names the entry pair, got ${dtGrid(m).getAttribute("data-key")}`,
    );
    assert(m.all("#dt-next-").length === 1, "and the entry pair is rendered, not merely named");
    await dtSubmit(m, "dt-next-");
    matches.push(dtIds(m).length);
    assert(dtActive(m) === "INV-1024", `entering writes the first row of what is left, got ${dtActive(m)}`);

    // And from there the key itself walks, because the cursor names a rendered
    // row again.
    await dtPress(m, "ArrowDown");
    assert(dtActive(m) === "INV-1026", `the next arrow steps within the filtered set, got ${dtActive(m)}`);

    await dtType(m, "");
    matches.push(dtIds(m).length);
    assert(
      JSON.stringify(matches) === JSON.stringify([2, 2, 8]),
      `narrowed, walked, widened, got ${JSON.stringify(matches)}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-data-table-none: a read that matches nothing takes the grid off the screen",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await dtScreen();
    await m.settle();
    const css = await read("shell/screens/data-table.css");
    await dtType(m, "zzzz");
    assert(dtIds(m).length === 0, `the filter matches nothing, got ${JSON.stringify(dtIds(m))}`);
    assert(dtCursorRow(m).cursor === "", `and the choice is cleared, got ${JSON.stringify(dtCursorRow(m))}`);

    // The entry pair is rendered by the same read as the rows, so with no
    // matches there is no pair — and the grid's data-key names it anyway,
    // because the id is the cursor row's and the cursor row is still there. An
    // arrow landing on the grid would then reach for a form that is not on the
    // screen, which the terminal refuses by throwing. What keeps it unreachable
    // is that a grid with no rows is not drawn, so it is not a tab stop.
    //
    // all(), not getElementById: linkedom's getElementById reaches into
    // <template> content and finds an inert copy the browser cannot.
    assert(m.all("#dt-next-").length === 0, "the entry pair goes with the rows that named it");
    assert(
      dtGrid(m).getAttribute("data-key") === '{"ArrowDown":"dt-next-","ArrowUp":"dt-prev-","Ctrl+Home":"dt-first-","Ctrl+End":"dt-last-"}',
      `while the key still names it, got ${dtGrid(m).getAttribute("data-key")}`,
    );
    assert(
      dtRows(m).length === 0 && textOf(m.one(".dt-body")) === "",
      "the region rendered nothing, whitespace included, which is what :empty needs",
    );
    assert(
      /\.dt-hold:has\(\.dt-body:empty\) \.scroll-area \{\s*display: none;/.test(css),
      "and the stylesheet takes the scroll area, the table and the tab stop with it",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-data-table-positions: a grid's row carries one ARIA state and no position",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await dtScreen();
    await m.settle();
    const html = await read("shell/screens/data-table.html");
    const ariaOn = () =>
      dtRows(m).flatMap((tr) =>
        [...(tr as unknown as { attributes: Iterable<{ name: string }> }).attributes].map((a) => a.name).filter((n) =>
          n.startsWith("aria-")
        )
      );

    assert(
      JSON.stringify([...new Set(ariaOn())]) === JSON.stringify(["aria-selected"]),
      `a row states which row is chosen and nothing else, got ${JSON.stringify([...new Set(ariaOn())])}`,
    );
    await dtType(m, "ada");
    assert(
      JSON.stringify([...new Set(ariaOn())]) === JSON.stringify(["aria-selected"]),
      "and the filter does not change that",
    );

    // The attribute, not the word: the closing pane names all four in prose,
    // which is where a refusal belongs. aria-rowindex/aria-rowcount count the
    // table's own rows, header included; aria-posinset/aria-setsize the
    // projection could answer, and ARIA 1.2 forbids them on a row descending
    // from a table or a grid — they are a treegrid's hierarchy.
    assert(
      !/\saria-(rowindex|rowcount|posinset|setsize|level)=/.test(html),
      "no positional attribute is written on any row of the grid",
    );
    // A sortable header is a control now, and aria-sort is the state it
    // carries — but it is still not a ROW's state, which is what this claim is
    // about. The header row is no row of the collection, so nothing the
    // projection answers reaches it.
    assert(
      m.all("tbody [aria-sort]").length === 0,
      "aria-sort belongs to a column header and never to a row of the grid",
    );
    await m.stop();
  },
});

/** A header's order command. The button is a real submit inside a real form;
 * this tier runs no default activation behaviour, so the form is asked
 * directly — the same thing a pointer does in a browser. */
const dtSort = (m: Mounted, key: string) =>
  (m.one(`#dt-sort-${key}`) as unknown as { requestSubmit(): void }).requestSubmit();

Deno.test({
  name: "accept-data-table-sorts: the header offers the orders the file states, and no others",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await dtScreen();
    await m.settle();
    const ids = () => dtRows(m).map((tr) => tr.getAttribute("id"));
    const opened = ids();
    assert(
      JSON.stringify(opened) === JSON.stringify([...opened].sort()),
      `the grid opens on the order its row names, got ${JSON.stringify(opened)}`,
    );

    // Pressing a header's command states the order, and the grid reads again
    // under it. The row holds a KEY; the clause it selects is in the markup.
    dtSort(m, "amount-desc");
    await m.settle();
    // `amount` is a text column, so its order is the store's own lexical one —
    // the clause the map names, not a numeric reading of it. What is asserted
    // is that the grid re-read UNDER that clause, which is the claim; whether a
    // money column should be text is DataRow's business and not this test's.
    const byAmount = dtRows(m).map((tr) => textOf(tr.querySelectorAll("td.dt-num")[0]));
    assert(
      JSON.stringify(byAmount) === JSON.stringify([...byAmount].sort().reverse()),
      `the grid re-read in the order the key named, got ${JSON.stringify(byAmount)}`,
    );
    assert(
      m.rows("data_cursor")[0].sort === "amount_desc",
      `the row holds the key and not the clause, got ${JSON.stringify(m.rows("data_cursor")[0].sort)}`,
    );

    // aria-sort follows, on that header alone: one order is one fact, so the
    // other sortable column has to say it is not the one in force.
    const sorted = (col: string) =>
      (m.one(`thead th[aria-sort]:nth-of-type(${col})`) as unknown as El)?.getAttribute("aria-sort");
    const heads = m.all("thead [aria-sort]") as unknown as El[];
    assert(heads.length === 2, `two sortable headers, got ${heads.length}`);
    assert(
      JSON.stringify(heads.map((h) => h.getAttribute("aria-sort"))) === JSON.stringify(["none", "descending"]),
      `exactly the column in force is marked, got ${JSON.stringify(heads.map((h) => h.getAttribute("aria-sort")))}`,
    );

    // Pressing the same command again states the same row: two commands per
    // column rather than one toggle, so nothing here has to know which order it
    // is already in.
    dtSort(m, "amount-desc");
    await m.settle();
    assert(m.rows("data_cursor")[0].sort === "amount_desc", "the same command states the same order");

    // Every order the grid can be read in is in the file, and every one the
    // file states is reachable from a header: the map and the buttons are one
    // declaration, so neither can carry a key the other does not.
    const html = await read("shell/screens/data-table.html");
    const map = JSON.parse(html.match(/data-order='([^']+)'/)![1]) as { of: Record<string, string> };
    const commands = [...html.matchAll(/id="dt-sort-([a-z_]+-[a-z]+)"/g)].map((x) => x[1].replace(/-(asc|desc)$/, "_$1"));
    assert(
      JSON.stringify(Object.keys(map.of).sort()) === JSON.stringify([...new Set(commands)].sort()),
      `the map's keys and the header's commands are one set, got ${JSON.stringify(Object.keys(map.of))} and ${
        JSON.stringify(commands)
      }`,
    );
    await m.stop();
  },
});
// ── navigation ──────────────────────────────────────────────────────────────

/** The rail's collections: nav_rail_item and nav_state are shell.yaml's seed,
 * so only the disclosure's own collection is stated here — a tab collection
 * that opens the visit empty. */
const navTables = (): Record<string, Row[]> => ({ nav_sidebar_demo: [] });

const navScreen = () => screen("navigation", navTables());

/** The links of one rail, in the order the region rendered them. */
const navRailLinks = (m: Mounted, rail: string): El[] => m.all(`#${rail} .sb-link`);

/** A chart with its instance names erased: the field's name and the id every
 * arrow is narrowed to are what one component calls its own, and what is left
 * is the shape. */
const navCanonicalChart = (json: string) => {
  const m = JSON.parse(json.replace(/&quot;/g, '"')) as {
    field: string;
    initial: string;
    states: Record<string, { on?: Record<string, unknown> }>;
  };
  // Keys sorted, because two components may declare the same states in either
  // order and a chart is a set of them rather than a sequence.
  const states: Record<string, unknown> = {};
  for (const name of Object.keys(m.states).sort()) {
    const on: Record<string, unknown> = {};
    for (const key of Object.keys(m.states[name].on ?? {}).sort()) {
      on[key.replace(/@.*$/, "@T")] = (m.states[name].on ?? {})[key];
    }
    states[name] = { on };
  }
  return { field: "F", initial: m.initial, states };
};

Deno.test({
  name: "accept-navigation-items-are-rows: five seeded rows, read under a literal order, written by nobody",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await navScreen();
    await m.settle();

    const links = navRailLinks(m, "nav-rail-board");
    assert(links.length === 5, `the rail renders one item per row, got ${links.length}`);
    assert(
      JSON.stringify(links.map((a) => a.textContent)) ===
        JSON.stringify(["Switch", "Tabs", "Menu", "Navigation", "Table"]),
      `the order is the literal the region declares, got ${JSON.stringify(links.map((a) => a.textContent))}`,
    );
    // The item set is DATA, which is the whole point: every other item set in
    // this catalog is a CUE-time list a machine's states were built from.
    assert(
      JSON.stringify(links.map((a) => a.getAttribute("href"))) ===
        JSON.stringify(["/switch", "/tabs", "/menu", "/navigation", "/table"]),
      `each address is composed from its own row's route, got ${JSON.stringify(links.map((a) => a.getAttribute("href")))}`,
    );
    // A seed is the program stating the collection's initial world, not a
    // gesture: hydration adds nothing to it.
    assert(writes(m).length === 0, `hydration wrote ${JSON.stringify(writes(m))}`);
    assert(navRailLinks(m, "nav-rail-drawer").length === 5, "and the drawer's rail is the same five rows");
    assert(m.all("omnishell--sidebar").length > 0, "the component tag survives as an inert wrapper");
    await m.stop();
  },
});

Deno.test({
  name: "accept-navigation-current-derived: one link is the current page, off a column no row carries",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await navScreen();
    await m.settle();
    const html = await read("shell/screens/navigation.html");

    for (const rail of ["nav-rail-board", "nav-rail-drawer"]) {
      const marked = navRailLinks(m, rail).filter((a) => a.getAttribute("aria-current") === "true");
      assert(marked.length === 1, `${rail} marks exactly one item, got ${marked.length}`);
      assert(
        marked[0].getAttribute("href") === "/navigation",
        `${rail} marks ${marked[0].getAttribute("href")}, not the route the enclosing row names`,
      );
    }
    // The attribute holds the projection's answer rather than an unresolved
    // placeholder, which is the proof the region bound at all: a rendered
    // string can be byte-identical to its bound result and prove nothing, but
    // "true"/"false" is not what the markup carries.
    assert(
      /aria-current="\{current\}"/.test(html),
      "the markup binds the derived column rather than writing a value",
    );

    // No stored row carries it. A projection refuses a derived name a column
    // already has, so this is also what keeps the merge unambiguous.
    const stored = m.rows("nav_rail_item").filter((r) => "current" in r);
    assert(stored.length === 0, `a derived column reached the store: ${JSON.stringify(stored)}`);

    // And the chart's side: the only column any arrow on the screen writes is
    // the disclosure's own field, so nothing here can move a derived answer.
    const machines = [...html.matchAll(/data-machine='([^']*)'/g)]
      .map((mm) => JSON.parse(mm[1].replace(/&quot;/g, '"')));
    const assigned = machines.flatMap((
      mm: { field: string; states: Record<string, { on?: Record<string, { assign?: Record<string, unknown> }> }> },
    ) => [
      mm.field,
      ...Object.values(mm.states).flatMap((s) =>
        Object.values(s.on ?? {}).flatMap((t) => Object.keys(t?.assign ?? {}))
      ),
    ]);
    assert(
      JSON.stringify([...new Set(assigned)]) === JSON.stringify(["open"]),
      `the arrows write ${JSON.stringify([...new Set(assigned)])}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-navigation-collapse: one arrow, narrowed to its own button, over the element it names",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await navScreen();
    await m.settle();
    const toggle = m.one("#nav-toggle-board");

    assert(toggle.getAttribute("aria-expanded") === "true", "a rail opens expanded");
    assert(
      toggle.getAttribute("aria-controls") === "nav-rail-board",
      `the control names ${toggle.getAttribute("aria-controls")}, not the rail beside it`,
    );

    m.fire(toggle);
    await m.settle();
    assert(toggle.getAttribute("aria-expanded") === "false", "the first press collapses");
    m.fire(toggle);
    await m.settle();
    assert(toggle.getAttribute("aria-expanded") === "true", "and the second is the way back");

    const row = m.rows("nav_sidebar_demo");
    assert(row.length === 1, `two presses, one row, got ${JSON.stringify(row)}`);
    assert(row[0].id === "the" && row[0].open === "true", `the row reads ${JSON.stringify(row[0])}`);

    // The rail is the control's SIBLING, so a click inside it reaches no
    // region carrying a machine — the arrow is narrowed to the button's id and
    // there is no ancestor between the two that a bare click could fire from.
    const before = writes(m).length;
    m.fire(navRailLinks(m, "nav-rail-board")[0]);
    await m.settle();
    assert(
      writes(m).length === before,
      `a click in the rail wrote ${JSON.stringify(writes(m).slice(before))}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-navigation-one-machine: one chart, and it is the collapsible's with a different opening state",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await navScreen();
    await m.settle();
    const html = await read("shell/screens/navigation.html");

    const charts = [...html.matchAll(/data-machine='([^']*)'/g)].map((mm) => mm[1]);
    assert(charts.length === 1, `one chart on the screen, got ${charts.length}`);

    const checkbox = await read("shell/screens/checkbox.html");
    const collapsible = [...checkbox.matchAll(/data-machine='([^']*)'/g)]
      .map((mm) => mm[1])
      .filter((j) => JSON.parse(j.replace(/&quot;/g, '"')).field === "open");
    assert(collapsible.length === 1, `one collapsible chart to compare against, got ${collapsible.length}`);

    const mine = navCanonicalChart(charts[0]) as unknown as Record<string, unknown>;
    const theirs = navCanonicalChart(collapsible[0]) as unknown as Record<string, unknown>;
    const differs = Object.keys(mine).filter((k) => JSON.stringify(mine[k]) !== JSON.stringify(theirs[k]));
    // Which state it opens in is the whole difference: a sidebar arrives
    // expanded and a collapsible arrives closed. The states, the arrows and
    // the narrowing are one generator's.
    assert(
      JSON.stringify(differs) === JSON.stringify(["initial"]),
      `the two charts differ in ${JSON.stringify(differs)}`,
    );
    assert(
      mine.initial === "true" && theirs.initial === "false",
      `the openers read ${mine.initial} and ${theirs.initial}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-navigation-composition: the menubar and the sheet generators, with every link a route this app serves",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await navScreen();
    await m.settle();

    assert(m.all('[role="menuitem"][href]').length === 6, "six menu items, each a link");
    assert(
      navRailLinks(m, "nav-rail-board").length + navRailLinks(m, "nav-rail-drawer").length === 10,
      "two rails, five rows each",
    );

    // Every href on the screen, the prose's included, resolves to a route the
    // app actually serves — the menu screen's check, over a screen whose whole
    // subject is navigation.
    const shell = await read("shell/shell.yaml");
    const paths = new Set([...shell.matchAll(/path: (\S+)/g)].map((mm) => mm[1]));
    const dead = m.all("a[href]")
      .map((a) => a.getAttribute("href")!)
      .filter((h) => h.startsWith("/"))
      .filter((h) => !paths.has(h));
    assert(dead.length === 0, `links to routes that do not exist: ${JSON.stringify(dead)}`);

    // The bar is inside a named landmark, so a name of its own would be the
    // same string in the tree twice.
    const bar = m.one('[role="menubar"]');
    assert(bar.getAttribute("aria-label") === null, `the bar named itself "${bar.getAttribute("aria-label")}"`);
    assert(
      m.one(".navmenu").getAttribute("aria-label") === "Main",
      "and the landmark around it carries the name",
    );
    // Two nav landmarks over one collection, named apart: a reader meeting two
    // regions called the same thing cannot tell which one they are in.
    const navNames = m.all("nav[aria-label]").map((n) => n.getAttribute("aria-label"));
    assert(new Set(navNames).size === navNames.length, `two landmarks share a name: ${JSON.stringify(navNames)}`);

    // Nothing restates what the element already says: the drawer is a modal
    // <dialog>, so aria-modal is the UA's, and a modal invoker has no
    // aria-expanded to supply.
    assert(
      m.all("[aria-modal], [aria-expanded]:not(.sb-toggle)").length === 0,
      "no hand-written aria-modal, and the only aria-expanded is the disclosure's own bound one",
    );
    const commanded = m.all("[commandfor]");
    assert(commanded.length === 4, `two menu triggers, the drawer's trigger and its dismiss, got ${commanded.length}`);
    assert(
      commanded.every((el) => m.all(`#${el.getAttribute("commandfor")}`).length > 0),
      "every commandfor resolves on the screen",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-navigation-keyboard: every stop is the platform's own, and the deferral is an absence",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await navScreen();
    await m.settle();

    // A roving tabstop is a tabindex the arrows move, and neither ships: a
    // tabindex="-1" without them would strand every trigger but one. Counted
    // off the tree rather than the source, because the prose beside the
    // components names all three of these attributes.
    assert(
      m.all("[tabindex]").every((el) => el.getAttribute("tabindex") === "0"),
      "no partial tabindex is emitted: the deferral is an absence, not a stranded stop",
    );
    assert(m.all("[aria-activedescendant]").length === 0, "and no virtual focus is claimed");
    assert(
      m.all("[data-key]").length === 0,
      "and no key binding stands in for the tabstop the bar does not have",
    );

    // The only tabindex on the screen is a scroll box's, and a scroll box that
    // takes one must also be named or a keyboard reader lands somewhere that
    // announces nothing — /select's review finding, generalized by decision-33.
    const boxes = m.all("[tabindex]");
    assert(boxes.length === 2, `the two prose tables scroll, and both are stops, got ${boxes.length}`);
    assert(
      boxes.every((b) =>
        b.getAttribute("role") === "region" &&
        m.all(`#${b.getAttribute("aria-labelledby")}`).length > 0
      ),
      "each names itself off a heading that is on the screen",
    );

    // What that leaves is every affordance reachable on its own: two bar
    // triggers, six items, the collapse, the drawer's trigger and dismiss, and
    // ten rail links.
    const stops = m.all("a[href], button");
    assert(stops.length >= 21, `every affordance keeps its own tab stop, counted ${stops.length}`);
    assert(
      m.all('button[type="button"]').length === m.all("button").length,
      "every button states its type, so none of them submits anything",
    );
    await m.stop();
  },
});

// ── popover ─────────────────────────────────────────────────────────────────

/** The screen declares no data-live, so it names no collection of its own —
 * shell.yaml's seed is the whole store, and nothing on the screen reads it. */
const popScreen = () => screen("popover");

/** The screen's stylesheet with its comments gone, so a property named in
 * prose is never mistaken for one declared. */
const popCss = async () => (await read("shell/screens/popover.css")).replace(/\/\*[\s\S]*?\*\//g, "");

Deno.test({
  name: "accept-popover-platform: openness is two attributes, and the UA's ARIA is written nowhere",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await popScreen();
    await m.settle();
    const surfaces = m.all(".pop-surface");
    assert(surfaces.length === 7, `seven surfaces, got ${surfaces.length}`);
    for (const el of m.all("[commandfor]")) {
      assert(
        m.all(`#${el.getAttribute("commandfor")}`).length > 0,
        `commandfor="${el.getAttribute("commandfor")}" resolves on this screen`,
      );
    }
    assert(
      JSON.stringify(m.all("[command]").map((el) => el.getAttribute("command"))) ===
        JSON.stringify([
          "toggle-popover",
          "toggle-popover",
          "toggle-popover",
          "toggle-popover",
          "toggle-popover",
          "toggle-popover",
          "toggle-popover",
          "hide-popover",
        ]),
      "every trigger toggles, and the one dismiss on the screen hides",
    );
    assert(
      JSON.stringify([...new Set(surfaces.map((s) => s.getAttribute("popover")))].sort()) ===
        JSON.stringify(["auto", "manual"]),
      "the attribute carries one of the two values this screen renders, spelled out",
    );
    // A hand-written one would be a second spelling of what the UA states for a
    // popover invoker; aria-haspopup would promise a kind of popup this surface
    // does not claim to be.
    for (const attr of ["[aria-expanded]", "[aria-haspopup]"]) {
      assert(m.all(attr).length === 0, `nothing on the screen writes ${attr}`);
    }
    for (const s of surfaces) {
      assert(!s.hasAttribute("role"), `a surface claims role="${s.getAttribute("role")}" it does not meet`);
    }
    // The only tabindex on a screen with no state is a scroll box's, and a box
    // that takes one must be named or a keyboard reader lands in a region that
    // announces nothing — decision-33's rule, which /select's review found.
    const boxes = m.all("[tabindex]");
    assert(boxes.length === 2, `the two prose tables scroll, and both are stops, got ${boxes.length}`);
    assert(
      boxes.every((b) =>
        b.getAttribute("tabindex") === "0" && b.getAttribute("role") === "region" &&
        m.all(`#${b.getAttribute("aria-labelledby")}`).length > 0
      ),
      "each names itself off a heading that is on the screen",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-popover-anchored: each surface is placed against its own trigger, and nothing stacks",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await popScreen();
    await m.settle();
    const css = await popCss();
    const names = new Map(
      [...css.matchAll(/#([\w-]+)\s*\{[^}]*?anchor-name:\s*(--[\w-]+)/g)].map((mm) => [mm[1], mm[2]]),
    );
    const anchors = new Map(
      [...css.matchAll(/#([\w-]+)\s*\{[^}]*?position-anchor:\s*(--[\w-]+)/g)].map((mm) => [mm[1], mm[2]]),
    );
    for (const surface of m.all(".pop-surface")) {
      const id = surface.getAttribute("id")!;
      // One trigger per surface: two would make "its own trigger" ambiguous.
      const trigger = m.one(`[commandfor="${id}"].pop-trigger`);
      const used = anchors.get(id);
      assert(used !== undefined, `${id} declares no position-anchor, so it would open centred in the viewport`);
      assert(
        names.get(trigger.getAttribute("id")!) === used,
        `${id} anchors to ${used}, which its own trigger does not name`,
      );
    }
    // The other direction: a renamed trigger leaves its surface centred with
    // nothing failing, so the names are folded back through the surfaces.
    const consumed = new Set(anchors.values());
    for (const [id, name] of names) {
      assert(consumed.has(name), `${id} declares ${name} and no surface anchors to it`);
      assert(m.all(`#${id}`).length > 0, `${id} is named in the stylesheet and is on no screen element`);
    }
    assert(!/z-index/.test(css), "the top layer is what leaves this screen with no stacking to declare");
    await m.stop();
  },
});

Deno.test({
  name: "accept-popover-placement: the printed table is the stylesheet, folded both ways",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await popScreen();
    await m.settle();
    const css = await popCss();
    const rules = new Map(
      [...css.matchAll(/\.pop-surface\[data-place="([\w-]+)"\]\s*\{([^}]*)\}/g)].map((mm) => [mm[1], mm[2]]),
    );
    const rows = new Map(
      m.all(".placement-table tbody tr").map((tr) => [
        tr.getAttribute("data-place")!,
        [...tr.querySelectorAll("td")].map((td) => textOf(td)),
      ]),
    );
    assert(rows.size === 4, `the table prints the whole vocabulary, got ${rows.size} rows`);

    const onScreen = new Set(m.all(".pop-surface[data-place]").map((s) => s.getAttribute("data-place")!));
    for (const place of onScreen) {
      assert(rules.has(place), `a surface asks for ${place} and the stylesheet has no rule for it`);
      assert(rows.has(place), `a surface asks for ${place} and the table does not list it`);
    }
    for (const place of rules.keys()) {
      assert(rows.has(place), `the stylesheet places ${place} and the table does not list it`);
    }
    for (const [place, decls] of rules) {
      const area = /position-area:\s*([\w-]+)/.exec(decls)?.[1];
      const fallback = /position-try-fallbacks:\s*([\w-]+)/.exec(decls)?.[1];
      assert(area === place, `${place}'s rule declares position-area: ${area}`);
      // The mirror on the axis the place sits on, which the component derives
      // from the place's own name rather than carrying beside it.
      assert(
        fallback === `flip-${place.split("-")[0]}`,
        `${place} falls back to ${fallback}, which is not its own axis`,
      );
      const [, printedArea, printedFallback] = rows.get(place)!;
      assert(printedArea === `position-area: ${area}`, `the table prints "${printedArea}" for ${place}`);
      assert(printedFallback === fallback, `the table prints "${printedFallback}" as ${place}'s fallback`);
    }
    await m.stop();
  },
});

Deno.test({
  name: "accept-popover-manual: the withdrawal is one value, and it forces the way out",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await popScreen();
    await m.settle();
    const surfaces = m.all(".pop-surface");
    const manual = surfaces.filter((s) => s.getAttribute("popover") === "manual");
    assert(manual.length === 1, `one surface withdraws the contract, got ${manual.length}`);
    for (const s of manual) {
      assert(
        s.querySelectorAll(".pop-dismiss").length > 0,
        `${s.getAttribute("id")} is manual and carries no dismiss, so nothing on the page could close it`,
      );
    }
    // The other direction: light dismiss and Escape are the two the element
    // already supplies, so a button restating them would be the third.
    for (const s of surfaces.filter((s) => s.getAttribute("popover") === "auto")) {
      assert(
        s.querySelectorAll(".pop-dismiss").length === 0,
        `${s.getAttribute("id")} is auto and carries a dismiss the element already is`,
      );
    }
    const dismiss = manual[0].querySelectorAll(".pop-dismiss")[0];
    assert(
      dismiss.getAttribute("command") === "hide-popover" &&
        dismiss.getAttribute("commandfor") === manual[0].getAttribute("id"),
      "and the way out is the same invoker grammar the trigger uses",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-popover-no-state: openness is not state anyone here holds",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await popScreen();
    await m.settle();
    const html = await read("shell/screens/popover.html");
    for (const attr of ["data-live", "data-filter", "data-empty-row", "data-machine"]) {
      assert(m.all(`[${attr}]`).length === 0, `the screen mounts no ${attr}`);
    }
    assert(!/data-on-[a-z]|data-handler/.test(html), "the markup binds no Jessie");
    // Every store call the mount made, reads included: a screen holding no
    // state never opens a table at all.
    assert(
      m.store.calls.length === 0,
      `nothing on the screen reaches the store, got ${m.store.calls.map((c) => `${c.op} ${c.table}`).join(", ")}`,
    );
    const shell = await read("shell/shell.yaml");
    assert(/screen: popover[\s\S]{0,200}handlers: \[\]/.test(shell), "the emitted route lists no handler module");
    assert(m.all("omnishell--popover").length === 7, "seven instances of one tag");
    await m.stop();
  },
});
// The calendar screen, and the cases that never mount anything: claims about
// the emitted tree itself — the markup, the stylesheets, the route list and the
// interpreter's own source.

/** The emitted markup is the artefact these cases are about, so it is read as
 * text. A DOM parser here would be a second reader of the same bytes, and the
 * one thing it could add — hydration — is exactly what a claim about what was
 * EMITTED must not have. */
// deno-lint-ignore no-explicit-any
type StChart = any;

/** Every `data-machine` chart a screen carries, in document order. The
 * attribute is single-quoted because its value is JSON, which is what makes
 * lifting it out of the text exact — and a region may state a LIST of charts,
 * which is several, so the flattening is what keeps "every chart" true. */
const stCharts = (html: string): StChart[] =>
  [...html.matchAll(/data-machine='([^']*)'/g)].flatMap((m) => {
    const parsed: unknown = JSON.parse(m[1]);
    return (Array.isArray(parsed) ? parsed : [parsed]) as StChart[];
  });

/** The ids of the elements carrying `role`, in document order. Anchored on the
 * tag: `[^>]*` cannot cross a `>`, so the same string printed as prose inside a
 * `<code>` is not an element and does not answer. */
const stIdsOfRole = (html: string, role: string): string[] =>
  [...html.matchAll(new RegExp(`<[^>]*\\srole="${role}"[^>]*>`, "g"))]
    .map((tag) => /\sid="([^"]*)"/.exec(tag[0])?.[1] ?? "");

/** The event key of a binary machine's one arrow, split back into the trigger
 * id it is narrowed to — undefined where the key is the bare event type,
 * which is the switch, whose region IS its affordance and carries no id. */
const stTriggerOf = (machine: { states: Record<string, { on: Record<string, unknown> }> }) => {
  const keys = new Set(Object.values(machine.states).flatMap((s) => Object.keys(s.on)));
  if (keys.size !== 1) throw new Error(`expected one event key, got ${[...keys]}`);
  return [...keys][0].split("@")[1];
};

/** A binary chart with everything a component chooses erased: the field name,
 * the trigger id, and whether the key is narrowed to that trigger at all. */
const stBinaryChart = (machine: { field: string }, trigger?: string) => {
  const narrowed = JSON.stringify(machine);
  const bare = trigger === undefined ? narrowed : narrowed.replaceAll(`click@${trigger}`, "click");
  return bare.replaceAll(machine.field, "F");
};

/** The chart with every name it carries replaced by the option's index: the
 * ids, the state names and the derived columns are the skin, and what is left
 * is what the shared generator drew. */
type Arrowish = { target: string; assign: Record<string, string>; guard?: unknown };

const stBySlot = (m: StChart, ids: string[]) => {
  const names: string[] = Object.keys(m.states);
  const cols: string[] = Object.keys(m.context);
  const at = (name: string) => names.indexOf(name);
  const set = (assign: Record<string, string>) => cols.map((c) => assign[c]);
  return JSON.stringify({
    initial: at(m.initial),
    context: set(m.context),
    // An ordered candidate list flattens in its own order: which arrow a key
    // selects is the guard's, and the guard is part of the shape two skins have
    // to agree on — a copied generator drifts in the key as easily as in the
    // target.
    states: names.map((s) =>
      Object.entries(
        m.states[s].on as Record<
          string,
          Arrowish | Arrowish[]
        >,
      ).flatMap(([key, value]) =>
        (Array.isArray(value) ? value : [value]).map((t) => ({
          event: `${key.split("@")[0]}@${ids.indexOf(key.split("@")[1])}`,
          guard: t.guard === undefined ? null : JSON.stringify(t.guard),
          target: at(t.target),
          assign: set(t.assign),
        }))
      )
    ),
  });
};

Deno.test({
  name: "accept-zero-js: no handler module on any route, and no Jessie in any screen",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    let screens = 0;
    for await (const f of Deno.readDir(new URL("shell/screens", APP))) {
      if (!f.isFile || !f.name.endsWith(".html")) continue;
      const html = await read(`shell/screens/${f.name}`);
      assert(!/data-on-[a-z]|data-handler|<script/i.test(html), `${f.name} binds no Jessie and carries no script`);
      screens++;
    }
    assert(screens >= 9, `every emitted screen is covered, saw ${screens}`);
    // The route list is the other half: a screen with clean markup could still
    // be handed a module by its route.
    const shell = await read("shell/shell.yaml");
    const routes = [...shell.matchAll(/screen: (\S+)/g)].map((m) => m[1]);
    assert(routes.length >= 9, `every emitted route is covered, saw ${routes.length}`);
    // A module may exist, but only as a leaf a chart names: the screen that
    // lists one must carry its basename inside a data-machine. That is what
    // keeps behaviour data even where a value has to be computed.
    for (const name of routes) {
      // An empty list emits inline and a populated one as a block, so the
      // space after the colon is the flow form's and not the key's.
      const block = new RegExp(`screen: ${name}\\b[\\s\\S]{0,400}?handlers:( \\[\\]| \\[[\\s\\S]*?\\]|\\n(?: *- \\S+\\n)+)`)
        .exec(shell);
      assert(block !== null, `the ${name} route declares a handler list`);
      const mods = [...block![1].matchAll(/([\w.-]+\.js)/g)].map((m) => m[1]);
      if (mods.length === 0) continue;
      const html = await read(`shell/screens/${name}.html`);
      const charts = [...html.matchAll(/data-machine='([^']*)'/g)].map((m) => m[1]).join(" ");
      for (const mod of mods) {
        assert(
          charts.includes(mod.replace(/\.js$/, "")),
          `the ${name} route lists ${mod}, which no chart on that screen names`,
        );
      }
    }
  },
});

Deno.test({
  name: "accept-primitives-tokens-only: the screen paints with token names alone",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const css = (await read("shell/screens/primitives.css")).replace(/\/\*[\s\S]*?\*\//g, "");
    // A literal has no dark twin, so it forks the appearance the moment it is
    // written; the eight colour tokens are each already one light-dark() pair.
    const literals = css.match(
      /#[0-9a-f]{3,8}\b|\b(?:rgba?|hsla?|hwb|lab|lch|oklab|oklch|color-mix)\(|(?<![-\w])(?:white|black|red|green|blue|grey|gray|silver|orange|yellow|purple)(?![-\w])/gi,
    ) ?? [];
    assert(literals.length === 0, `no literal colour on the screen where the tokens are on trial, got ${literals}`);
  },
});

Deno.test({
  name: "accept-way-back: the catalog is the only index, and every other screen carries the link back",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const shell = await read("shell/shell.yaml");
    // One route on the strip means the terminal draws none (shell.js filters
    // on nav.strip and only builds a <nav> above one route), so the link each
    // screen carries is the whole of the way back — decision-28.
    const routes = [...shell.matchAll(/^  - path: (\S+)\n(?:(?!^  - path:)[\s\S])*/gm)];
    const strip = routes.filter((r) => !/\n      strip: false\n/.test(r[0])).map((r) => r[1]);
    assert(
      JSON.stringify(strip) === JSON.stringify(["/"]),
      `the catalog alone is on the strip, got ${JSON.stringify(strip)}`,
    );
    const htmls = [...shell.matchAll(/^      html: (shell\/screens\/\S+)$/gm)].map((m) => m[1]);
    assert(htmls.length === routes.length, "every route names its emitted markup");
    for (const rel of htmls) {
      if (rel.endsWith("/catalog.html")) continue;
      const markup = await read(rel);
      assert(
        /<a class="up" data-route="catalog">/.test(markup),
        `${rel} is a dead end: no way back to the catalog`,
      );
    }
  },
});

Deno.test({
  name: "accept-combobox-boundary: no machine, no module, and the chart it declines printed beside the wall that stands",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const html = await read("shell/screens/combobox.html");
    assert(!/data-machine/.test(html), "the screen runs no machine — the write is the form's");
    assert(!/data-on-[a-z]|data-handler/.test(html), "the markup binds no Jessie");
    assert(
      (html.match(/<dt>/g) ?? []).length === 1,
      "the boundary pane names one wall, which is how many stand",
    );
    // The chart the screen declines is unified with #Machine in the source, so
    // what is printed is a chart the vocabulary admits — the refusal is the
    // column's shape, not the leaf's existence.
    assert(
      /"type": "event"/.test(html) && /"field": "value"/.test(html),
      "and prints the chart it declines, in the leaf grammar the terminal executes",
    );
    const shell = await read("shell/shell.yaml");
    assert(/screen: combobox[\s\S]{0,200}handlers: \[\]/.test(shell), "the emitted route lists no handler module");
  },
});

Deno.test({
  name: "accept-radio-group-one-machine: the radio group's chart and the toggle group's are one chart",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const canonical = (html: string) => {
      const charts = stCharts(html);
      assert(charts.length === 1, `one chart per traversal screen, got ${charts.length}`);
      const ids = stIdsOfRole(html, "radio");
      const m = charts[0];
      const names: string[] = Object.keys(m.states);
      const cols: string[] = Object.keys(m.context);
      assert(
        names.length === ids.length && names.every((n, i) => ids[i].endsWith(n)),
        `the option buttons and the states are the same list in the same order: ${ids} vs ${names}`,
      );
      assert(
        cols.every((c, i) => c.endsWith(names[i % names.length])),
        `one derived column per option, in the options' order: ${cols}`,
      );
      return stBySlot(m, ids);
    };

    const radio = canonical(await read("shell/screens/radio-group.html"));
    const toggle = canonical(await read("shell/screens/toggle-group.html"));
    assert(
      radio === toggle,
      `two skins, one chart — a copied generator would drift:\n${radio}\n${toggle}`,
    );
    // Six clicks and six focusins — one each per (state, other option) — and
    // sixteen key moves: from each of three states, Right, Down, Left and Up,
    // plus the one of Home and End that does not name the state it leaves.
    assert(
      (JSON.parse(radio).states as unknown[][]).flat().length === 28,
      "three options, twenty-eight arrows, and none from a state to itself",
    );
  },
});

Deno.test({
  name: "accept-pagination-inventory: the printed census is the emitted charts counted",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const html = await read("shell/screens/pagination.html");

    const charts = stCharts(html);
    assert(charts.length === 2, `the screen carries both traversals, got ${charts.length}`);
    const measured = charts.map((m) => {
      const states = Object.values(m.states) as { on: Record<string, unknown> }[];
      const positions = states.length;
      const arrows = states.reduce((n, s) => n + Object.keys(s.on).length, 0);
      const absolute = positions * (positions - 1);
      return [positions, absolute, arrows - absolute, arrows, Object.keys(m.context).length];
    });

    const table = /<table class="inventory">([\s\S]*?)<\/table>/.exec(html);
    assert(table !== null, "the screen prints the census it is checked against");
    const printed = [...table![1].matchAll(/<tr\b[\s\S]*?<\/tr>/g)]
      .slice(1)
      .map((tr) => [...tr[0].matchAll(/<td\b[^>]*>([\s\S]*?)<\/td>/g)].map((td) => Number(td[1])));
    assert(printed.length === 5, `five rows are counted, got ${printed.length}`);
    for (const [row, cells] of printed.entries()) {
      for (const [col, cell] of cells.entries()) {
        assert(
          cell === measured[col][row],
          `inventory row ${row} column ${col} prints ${cell}, the chart says ${measured[col][row]}`,
        );
      }
    }
    // A step's arrow is an arrow to a neighbour, so the two ends are the only
    // states missing one: the count is 2*(positions-1) and nothing else.
    for (const [positions, , step] of measured) {
      assert(step === 2 * (positions - 1), `${positions} positions carry ${step} step arrows`);
    }

    // What a projection costs, and what aria-current saves.
    const css = await read("shell/screens/pagination.css");
    assert(
      (css.match(/\[data-state="s\d"\] \[data-slide="s\d"\]/g) ?? []).length === measured[1][0],
      "one projection rule per slide",
    );
    assert(
      !/data-state="p\d"/.test(css),
      "and none per page, because aria-current is the styling hook there",
    );
  },
});

Deno.test({
  name: "accept-select-trade: no machine, no module, and the comparison printed in both directions",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const html = await read("shell/screens/select.html");
    assert(!/data-machine/.test(html), "the screen runs no machine — the writes are the two forms'");
    assert(!/data-on-[a-z]|data-handler/.test(html), "the markup binds no Jessie");
    assert(
      (html.match(/<tr><th scope="row">/g) ?? []).length === 7,
      "the trade names seven things at stake, each with both controls' answer",
    );
    assert(
      (html.match(/<dt>/g) ?? []).length === 3,
      "and three walls neither control clears today",
    );
    assert(
      /<option value="" disabled selected>/.test(html),
      "the prompt is disabled, which is why no `required` is emitted on the select",
    );
    const shell = await read("shell/shell.yaml");
    assert(/screen: select[\s\S]{0,200}handlers: \[\]/.test(shell), "the emitted route lists no handler module");
  },
});

Deno.test({
  name: "accept-menu-one-chart: the screen adds two roles and no chart",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const menu = await read("shell/screens/menu.html");
    const machines = stCharts(menu);

    // The two checkbox items, erased down to what the shared generator drew:
    // the field name and the trigger the arrow is narrowed to are the skin.
    const binaries = machines.filter((m) => m.field.startsWith("chk_")).map((m) => stBinaryChart(m, stTriggerOf(m)));
    assert(binaries.length === 2, `two checkbox items, ${binaries.length} binary chart(s)`);
    assert(
      new Set(binaries).size === 1,
      `two items, one chart — a copied generator would drift:\n${binaries.join("\n")}`,
    );
    // And it is the chart the catalog already runs, not a sixth copy of it.
    // Both switch regions carry a byte-identical chart, so which one answers
    // here is not a choice the assertion has to make.
    const switches = stCharts(await read("shell/screens/switch.html"));
    assert(new Set(switches.map((s) => JSON.stringify(s))).size === 1, "the switch screen runs one chart twice");
    const sw = switches[0];
    assert(
      binaries[0] === stBinaryChart(sw, stTriggerOf(sw)),
      `the menu's checkbox item runs the switch's chart:\n${binaries[0]}\n${stBinaryChart(sw, stTriggerOf(sw))}`,
    );

    const mine = stBySlot(
      machines.find((m) => m.field === "profile")!,
      stIdsOfRole(menu, "menuitemradio"),
    );
    const rg = await read("shell/screens/radio-group.html");
    // Apart from what the radio group's skin turns on: the arrows that move a
    // tabstop, and the focusin that keeps the column standing where the reader
    // is. A menu's arrows cross every item, not the radio subset, so this set
    // does not rove and a partial keyboard would be worse than none — which
    // leaves the click arrows as what the two skins must still agree on, and a
    // copied generator as what would drift.
    const clicksOnly = (m: StChart) => ({
      ...m,
      context: Object.fromEntries(
        Object.entries(m.context).filter(([key]) => !key.startsWith("tab_")),
      ),
      states: Object.fromEntries(
        Object.entries(m.states).map(([name, st]) => [name, {
          ...st,
          on: Object.fromEntries(
            Object.entries(st.on ?? {})
              .filter(([key]) => !/^(keydown|focusin)@/.test(key))
              .map(([key, val]) => [
                key,
                (Array.isArray(val) ? val : [val]).map((v) => ({
                  ...v,
                  assign: Object.fromEntries(
                    Object.entries((v as Arrowish).assign ?? {}).filter(([k]) => !k.startsWith("tab_")),
                  ),
                })),
              ]),
          ),
        }]),
      ),
    });
    const theirs = stBySlot(clicksOnly(stCharts(rg)[0]) as never, stIdsOfRole(rg, "radio"));
    assert(mine === theirs, `menuitemradio and radio run one chart:\n${mine}\n${theirs}`);
  },
});

Deno.test({
  name: "accept-menu-cancels-context: the right-click opens the app's menu and shuts the UA's",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await menuScreen();
    await m.settle();
    const target = m.one("#menu-ctx-target");
    const surface = m.one("#menu-ctx");
    assert(surface.hasAttribute("popover"), "the menu surface is a popover");

    boxOf(target, { left: 0, top: 0, width: 200, height: 100 });
    const ev = m.fire(target, "contextmenu", { cancelable: true, clientX: 50, clientY: 25 });
    await m.settle();

    // Both halves of the one sentence: the arrow fired AND the browser's own
    // menu never got its turn. Either alone is the bug this component was
    // held back for — an app menu beside the UA's, or a cancel with nothing
    // behind it.
    assert(ev.defaultPrevented, "the arrow cancelled the event it answered");
    const row = only(m.rows("context_menu_demo"), "after the right-click");
    assert(
      row.id === "the" && row.open === "true" && row.x === 250 && row.y === 250,
      `one row states openness and the point, got ${JSON.stringify(row)}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-menu-context-narrowed: the cancel is the arrow's, not the type's",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await menuScreen();
    await m.settle();

    // A right-click where no arrow is narrowed. Cancelling by TYPE would make
    // a whole region inert for one arrow inside it, taking the platform's own
    // menu from a reader this app has nothing to offer.
    const elsewhere = m.one("#menu-open-trigger");
    boxOf(elsewhere, { left: 0, top: 0, width: 100, height: 40 });
    const away = m.fire(elsewhere, "contextmenu", { cancelable: true, clientX: 10, clientY: 10 });
    await m.settle();
    assert(!away.defaultPrevented, "an unnamed affordance keeps the browser's menu");
    assert(m.rows("context_menu_demo").length === 0, "and writes nothing");

    await m.stop();
  },
});

Deno.test({
  name: "accept-menu-context-point: the placement is two shares of the target's own box",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const target = (m: Mounted) => m.one("#menu-ctx-target");

    // The same relative point in two boxes of different pixel sizes has to
    // reach the row as the same pair. That is the whole reason the frame is
    // the element rather than the viewport: nothing has to be pinned for a
    // replay to put the surface where the reporter saw it.
    for (const box of [{ left: 0, top: 0, width: 200, height: 100 }, { left: 40, top: 12, width: 800, height: 400 }]) {
      const m = await menuScreen();
      await m.settle();
      boxOf(target(m), box);
      m.fire(target(m), "contextmenu", {
        cancelable: true,
        clientX: box.left + box.width * 0.75,
        clientY: box.top + box.height * 0.25,
      });
      await m.settle();
      const row = only(m.rows("context_menu_demo"), `after the right-click at ${box.width}x${box.height}`);
      assert(row.x === 750 && row.y === 250, `parts per thousand of the box, got ${row.x} / ${row.y}`);
      await m.stop();
    }

    // And no length is stored: every column of the row is either the state or
    // one of the two shares, so there is no pixel anywhere to go stale.
    const m = await menuScreen();
    await m.settle();
    boxOf(target(m), { left: 0, top: 0, width: 200, height: 100 });
    m.fire(target(m), "contextmenu", { cancelable: true, clientX: 100, clientY: 50 });
    await m.settle();
    const row = only(m.rows("context_menu_demo"), "the whole row");
    // The state, the point, and the caret its surface walks — three charts on
    // one region, each holding its own columns of the one row.
    assert(
      JSON.stringify(Object.keys(row).sort()) === JSON.stringify(
        ["caret", "cur_overlays", "cur_popover", "cur_sheet", "id", "open", "prefix", "x", "y"],
      ),
      `the row is the state, the point and the caret, got ${JSON.stringify(Object.keys(row).sort())}`,
    );
    const css = await read("shell/screens/menu.css");
    assert(
      /--ctx-x\)\s*\/\s*1000\s*\*\s*anchor-size\(width\)/.test(css) &&
        /--ctx-y\)\s*\/\s*1000\s*\*\s*anchor-size\(height\)/.test(css),
      "the stylesheet is what multiplies the shares back out against the anchor",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-menu-context-dismissal: openness is a column, closing is the platform's",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const html = await read("shell/screens/menu.html");
    assert(
      !html.includes("data-open="),
      "no surface uses legacy data-open",
    );
    assert(
      /<div class="menu-surface ctx-surface"[^>]*\spopover/.test(html),
      "the context surface is a native popover",
    );

    // Closing is the element's own: an auto popover light-dismisses and answers
    // Escape. An arrow back to "false" would be a second spelling of a
    // dismissal the platform already performs, and the two would disagree the
    // moment a reader pressed Escape.
    const charts = stCharts(html);
    const ctx = charts.find((c) => c.field === "open");
    assert(ctx !== undefined, "the context menu runs a chart");
    const targets = Object.values(ctx!.states)
      .flatMap((s) => Object.values((s as { on?: Record<string, unknown> }).on ?? {}))
      .flat()
      .map((t) => (t as { target?: string }).target);
    assert(
      targets.every((t) => t === "true"),
      `no arrow closes the menu — that is the UA's, got ${JSON.stringify(targets)}`,
    );
    assert(
      /id="menu-ctx"[^>]*\spopover(\s|>)/.test(html),
      'the surface is an auto popover, which is what supplies light dismiss and Escape',
    );
  },
});

Deno.test({
  name: "accept-menu-context-one-surface: a third container, one more surface, no way back",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const html = await read("shell/screens/menu.html");

    // Four surfaces for four containers — the dropdown, the bar's two menus,
    // and this one — every one of them the same generator's output. A context
    // menu that had grown its own markup would show up here as a shape the
    // pattern does not match.
    const surfaces = [...html.matchAll(/<div class="menu-surface[^"]*" id="([^"]+)" popover role="menu"/g)]
      .map((mt) => mt[1]);
    assert(
      JSON.stringify(surfaces) === JSON.stringify(["menu-open", "menu-view", "menu-go", "menu-ctx"]),
      `one generated surface per container, got ${JSON.stringify(surfaces)}`,
    );

    // And the chart draws no arrow home. Closing is the auto popover's — light
    // dismiss and Escape — so a target of "false" anywhere here would be a
    // second spelling of it, and the two would disagree the first time a reader
    // pressed Escape and the row still said open.
    const ctx = stCharts(html).find((c) => c.field === "open");
    assert(ctx !== undefined, "the context menu runs a chart");
    const arrows = Object.entries(ctx!.states).flatMap(([from, s]) =>
      Object.entries((s as { on?: Record<string, unknown> }).on ?? {}).flatMap(([key, v]) =>
        (Array.isArray(v) ? v : [v]).map((t) => ({
          from,
          key,
          to: typeof t === "string" ? t : (t as { target?: string }).target,
        }))
      )
    );
    assert(arrows.length === 2, `one arrow per state, got ${JSON.stringify(arrows)}`);
    assert(
      arrows.every((a) => a.to === "true"),
      `every arrow lands on true — the way back is the platform's, got ${JSON.stringify(arrows)}`,
    );
    assert(
      arrows.every((a) => a.key === "contextmenu@menu-ctx-target"),
      `and every one is narrowed to the target, got ${JSON.stringify(arrows.map((a) => a.key))}`,
    );
  },
});

// Both of the calendar's collections are seeded in shell.yaml, so a mount takes
// no tables of its own: the rows the screen opens on are the ones the visit
// brings.
const calScreen = () => screen("calendar");

/** The month-calendar instance. `dp-` is the date picker beside it, running the
 * same generator over its own row, and every selector here is pinned to `cal-`
 * so a claim about one instance cannot be answered by the other. */
const calCells = (m: Mounted) => m.all('#cal-grid [role="gridcell"]');
const calIds = (m: Mounted) => calCells(m).map((c) => String(c.getAttribute("id")));
const calRow = (m: Mounted): Row => only(m.rows("calendar_demo").filter((r) => r.id === "the"), "the month calendar's row");
const calActive = (m: Mounted) => m.one("#cal-grid").getAttribute("aria-activedescendant");
/** Nothing on the screen writes a cell, so this is a count that must stay zero
 * rather than a sequence. */
const calCellWrites = (m: Mounted) => writes(m).filter((c) => c.table === "calendar_cell").length;

const calClick = async (m: Mounted, id: string) => {
  m.fire(`#${id}`, "click");
  await m.settle();
};

/** An arrow pressed where the reader's focus actually is: the grid itself. */
const calPress = async (m: Mounted, key: string) => {
  m.fire("#cal-grid", "keydown", { key });
  await m.settle();
};

Deno.test({
  name: "accept-calendar-steps: one arrow, one leaf, three columns and a re-read grid",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await calScreen();
    await m.settle();
    assert(calRow(m).month === "2026-09", `the seeded row opens on September, got ${calRow(m).month}`);
    assert(writes(m).length === 0, `hydration wrote ${JSON.stringify(writes(m))}`);

    await calClick(m, "cal-next");
    const row = calRow(m);
    assert(
      row.month === "2026-10" && row.label === "October 2026" && row.active === "2026-10-p15",
      `three columns out of one leaf, got ${JSON.stringify(row)}`,
    );
    // The caret paged with the month; the chosen date did not. `active` and
    // `value` answer two different ARIA states, so a month step that moved both
    // would be a date picker whose committed value moves when you page it.
    assert(row.value === "2026-09-p15", `and the chosen date stayed where it was, got ${row.value}`);
    assert(writes(m).length === 1, `three assigns and a field write are one stated row, got ${writes(m).length}`);

    // The grid's regions interpolate that column into their own filter, so the
    // month step IS the re-read: nothing else told them to move.
    const grids = new Set(calIds(m).map((id) => id.slice("cal-cell-".length, -4)));
    assert(
      JSON.stringify([...grids]) === JSON.stringify(["2026-10"]),
      `the grid follows the column the leaf wrote, got ${JSON.stringify([...grids])}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-calendar-clamps: an arrow at the window's end names the month it is already on",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await calScreen();
    await m.settle();
    const seen: string[] = [];
    for (let step = 0; step < 3; step++) {
      await calClick(m, "cal-next");
      seen.push(String(calRow(m).month));
    }
    assert(
      JSON.stringify(seen) === JSON.stringify(["2026-10", "2026-11", "2026-11"]),
      `the third step is the clamp, got ${JSON.stringify(seen)}`,
    );
    // What the clamp buys: a grid that is still a grid. An unclamped step would
    // have named a month the program never seeded.
    assert(calCells(m).length === 42, `the last grid is still forty-two cells, got ${calCells(m).length}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-calendar-projection: every ARIA state a cell carries is a projected answer",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await calScreen();
    await m.settle();

    const selected = calCells(m).filter((c) => c.getAttribute("aria-selected") === "true");
    assert(selected.length === 1, `exactly one cell is selected, got ${selected.length}`);
    assert(
      selected[0].getAttribute("id") === "cal-cell-2026-09-p15",
      `and it is the one the row names, got ${selected[0].getAttribute("id")}`,
    );

    // September 2026 starts on a Tuesday and runs thirty days, so two cells
    // before it and ten after belong to the months either side.
    const outside = calCells(m).filter((c) => c.getAttribute("data-inmonth") === "false");
    assert(outside.length === 12, `twelve outside days in September's grid, got ${outside.length}`);

    // The grid's first week of days: aria-rowindex 1 is the weekday header,
    // which is not a region and holds no cell.
    const week = m.one('#cal-grid [role="row"][data-live="calendar_cell"][aria-rowindex="2"]');
    const colindexes = [...week.querySelectorAll('[role="gridcell"]')]
      .map((c) => c.getAttribute("aria-colindex"));
    assert(
      JSON.stringify(colindexes) === JSON.stringify(["1", "2", "3", "4", "5", "6", "7"]),
      `a week is seven full columns, got ${JSON.stringify(colindexes)}`,
    );

    // The other half of the same fact: none of those answers is a column
    // anybody stored, so nothing keeps them true.
    const stored = new Set(m.rows("calendar_cell").flatMap((c) => Object.keys(c)));
    assert(
      ["sel", "inmonth", "colindex", "fwd", "back"].every((d) => !stored.has(d)),
      `no projected name is a stored column, saw ${JSON.stringify([...stored])}`,
    );
    await m.stop();
  },
});

Deno.test({
  name:
    "accept-calendar-keyboard / accept-calendar-lanes / accept-calendar-ends: the arrows walk each lane, and each lane ends where its own column does",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await calScreen();
    await m.settle();
    assert(calActive(m) === "cal-cell-2026-09-p15", `the grid opens naming the row's cell, got ${calActive(m)}`);

    const walk: string[] = [];
    // Right by one square, down by a week, and back the way it came.
    for (const key of ["ArrowRight", "ArrowDown", "ArrowUp", "ArrowLeft"]) {
      await calPress(m, key);
      walk.push(String(calRow(m).active));
    }
    assert(
      JSON.stringify(walk) === JSON.stringify(["2026-09-p16", "2026-09-p23", "2026-09-p16", "2026-09-p15"]),
      `the walk is the projection's neighbours in two orders, got ${JSON.stringify(walk)}`,
    );

    // Home and End are the WEEK's ends, which is what a date grid means by
    // them: the two clauses are partitioned by the same column the rows are
    // grouped into, so the answer moves with the caret rather than naming the
    // grid's own corners. p15 sits in w3, which spans p15..p21.
    await calPress(m, "Home");
    assert(calRow(m).active === "2026-09-p15", `Home is the first day of the week, got ${calRow(m).active}`);
    await calPress(m, "End");
    assert(calRow(m).active === "2026-09-p21", `End is the last day of the week, got ${calRow(m).active}`);
    await calPress(m, "Home");
    assert(calRow(m).active === "2026-09-p15", `and back, got ${calRow(m).active}`);

    // The vertical lane is partitioned, so its ends are the weekday column's
    // and not the reading order's. p15 is a Monday: five ArrowDowns reach the
    // foot of that column (p36) and the sixth names it again. Unpartitioned,
    // the column-major `next` would have handed over the HEAD OF THE NEXT
    // COLUMN — a caret that walks down a Monday and arrives on a Tuesday.
    for (let i = 0; i < 5; i++) await calPress(m, "ArrowDown");
    assert(calRow(m).active === "2026-09-p36", `five weeks down the column, got ${calRow(m).active}`);
    await calPress(m, "ArrowDown");
    assert(
      calRow(m).active === "2026-09-p36",
      `the foot of a weekday column names itself, got ${calRow(m).active}`,
    );
    await calPress(m, "ArrowUp");
    assert(calRow(m).active === "2026-09-p29", `and the way back is the same lane, got ${calRow(m).active}`);
    for (let i = 0; i < 5; i++) await calPress(m, "ArrowUp");
    assert(calRow(m).active === "2026-09-p01", `the head of the column is its other end, got ${calRow(m).active}`);
    await calPress(m, "ArrowUp");
    assert(calRow(m).active === "2026-09-p01", `which names itself too, got ${calRow(m).active}`);

    // Horizontally the month is continuous, so a week's end is NOT an end: the
    // last day of one week is the day before the first of the next, and only
    // the grid's own ends name themselves. That is the same projection with no
    // partition on it, which is the distinction the two lanes exist to draw.
    (m.one("#cal-cell-2026-09-p07 form") as unknown as { requestSubmit(): void }).requestSubmit();
    await m.settle();
    await calPress(m, "ArrowRight");
    assert(
      calRow(m).active === "2026-09-p08",
      `across a week boundary the days run on, got ${calRow(m).active}`,
    );
    (m.one("#cal-cell-2026-09-p15 form") as unknown as { requestSubmit(): void }).requestSubmit();
    await m.settle();
    assert(
      calActive(m) === "cal-cell-2026-09-p15",
      `and the grid's virtual focus followed the column, got ${calActive(m)}`,
    );
    // An arrow moves the caret and nothing else: `value` is what aria-selected
    // marks and what the readout prints, and no key writes it.
    assert(calRow(m).value === "2026-09-p15", `a walk chooses no date, got ${calRow(m).value}`);
    // A pick is the one gesture that writes both, because choosing a date is
    // also standing on it.
    (m.one("#cal-cell-2026-09-p20 form") as unknown as { requestSubmit(): void }).requestSubmit();
    await m.settle();
    assert(calRow(m).value === "2026-09-p20", `the pick states the chosen date, got ${calRow(m).value}`);
    assert(calRow(m).active === "2026-09-p20", `and the caret goes with it, got ${calRow(m).active}`);
    assert(
      m.all('#cal-grid [aria-selected="true"]').map((c) => c.getAttribute("id")).join() === "cal-cell-2026-09-p20",
      "so exactly the picked cell is marked",
    );

    // The whole grid is one tab stop: nothing inside it takes focus, so no
    // arrow has to move any. A day cell is a native <button>, focusable with no
    // attribute at all, so counting explicit tabindex attributes would state
    // this claim without measuring it — the candidates are counted by tag.
    const days = m.all("#cal-grid button");
    assert(days.length === 42, `the grid's focus candidates are its day cells, got ${days.length}`);
    assert(
      days.every((el) => el.getAttribute("tabindex") === "-1"),
      "nothing inside the grid is a tab stop of its own",
    );
    assert(
      m.all("#cal-grid a").length === 0 && m.all("#cal-grid select").length === 0 &&
        m.all("#cal-grid input").every((el) => el.getAttribute("type") === "hidden"),
      "and a day cell is the only focusable kind the grid holds",
    );
    assert(calCells(m).length === 42, "the walk moved no read");
    assert(calCellWrites(m) === 0, `a walk writes one column and touches no cell row, got ${calCellWrites(m)}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-calendar-seeded: the rows arrive with the visit and nothing on the screen writes a cell",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await calScreen();
    await m.settle();
    // The visit's own rows, read where the screen reads them: mountApp fills
    // the store from shell.yaml's `seed:`, and nothing here has written since.
    const cellRows = m.rows("calendar_cell");
    const demoRows = m.rows("calendar_demo");
    assert(cellRows.length === 210, `five grids of forty-two, got ${cellRows.length}`);
    assert(demoRows.length === 2, `one calendar row per instance, got ${demoRows.length}`);
    const grids = new Set(cellRows.map((c) => c.grid));
    assert(grids.size === 5, `five seeded grids, got ${grids.size}`);
    for (const g of grids) {
      const n = cellRows.filter((c) => c.grid === g).length;
      assert(n === 42, `${g} is six weeks of seven, got ${n}`);
    }
    const html = await read("shell/screens/calendar.html");
    // The seeded calendar row is the machine's own initial world, which is why
    // no region on the screen carries a data-empty-row and no arrow states one.
    // Anchored on the attribute position: the pane below the grid names both
    // of these in prose, and a bare substring would match the sentence.
    assert(!/\sdata-empty-row=/.test(html), "nothing restates the initial world the seed already wrote");
    for (const chart of stCharts(html)) {
      assert(Object.keys(chart.states).length === 1, "one state: a calendar branches on nothing");
      // Column by column: a row is its columns and their values, and the
      // order the store happens to hold them in is not one of the facts.
      const isRow = (row: Record<string, unknown>) => {
        const world: Record<string, unknown> = { id: row.id, ...chart.context, state: chart.initial };
        const cols = Object.keys(row);
        return cols.length === Object.keys(world).length && cols.every((c) => row[c] === world[c]);
      };
      assert(
        demoRows.some(isRow),
        `each chart's initial world is a seeded row, got ${JSON.stringify(chart.context)}`,
      );
    }
    // Every form on the screen writes the calendar row; none writes a cell.
    const entities = [...html.matchAll(/data-entity="([^"]*)"/g)].map((m) => m[1]);
    assert(
      entities.length === 14,
      `seven forms per instance — four across (both arrows, both ends of the week), two down, one month step — got ${entities.length}`,
    );
    assert(
      entities.every((e) => e === "calendar_demo"),
      `nothing on the screen writes a cell, got ${JSON.stringify([...new Set(entities)])}`,
    );
    assert(writes(m).length === 0, `the visit itself wrote ${JSON.stringify(writes(m))}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-calendar-no-today: no day is today, and the module is reachable only as a leaf",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const html = await read("shell/screens/calendar.html");
    // Anchored on the attribute position: the closing pane names this one in
    // prose, and a bare substring would match the sentence saying it is absent.
    assert(!/\saria-current=/.test(html), "no day is marked today: a leaf's compartment endows no clock");
    assert(!/data-on-[a-z]|data-handler|<script/i.test(html), "the module is not reachable as a DOM handler");
    const charts = [...html.matchAll(/data-machine='([^']*)'/g)].map((m) => m[1]);
    assert(charts.length === 2, `one chart per instance, got ${charts.length}`);
    assert(
      charts.every((c) => c.includes('"type":"month-step"')),
      "every chart on the screen names the module the route lists",
    );
    const shell = await read("shell/shell.yaml");
    const block = /screen: calendar\b[\s\S]{0,400}?handlers:\n((?: *- \S+\n)+)/.exec(shell);
    assert(block !== null, "the route declares its handler list");
    assert(
      block![1].trim() === "- shell/handlers/month-step.js",
      `one module on the route, got ${JSON.stringify(block![1])}`,
    );
  },
});

Deno.test({
  name: "accept-accordion-walk: the arrows move a caret and leave the tab order alone",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("accordion", ACC_TABLES());
    await m.settle();

    // The contract this pattern is held to: every header stays in the Tab
    // sequence, so the terminal stamps no tabindex on any of them. A roving
    // tabstop would take two of the three out of a sequence APG puts them in.
    assert(
      JSON.stringify(accTabindex(m, "faq")) === JSON.stringify([null, null, null]),
      `no header leaves the Tab sequence, got ${JSON.stringify(accTabindex(m, "faq"))}`,
    );
    assert(
      JSON.stringify(accCaret(m, "faq")) === JSON.stringify(["true", "false", "false"]),
      "the caret's context seats it on the first header",
    );

    await accPress(m, "acc-faq-trigger-shipping", "ArrowDown");
    assert(
      JSON.stringify(accCaret(m, "faq")) === JSON.stringify(["false", "true", "false"]),
      "Down walks to the next header",
    );
    // The other chart did not move, though both narrow their arrows to these
    // same three buttons: an arrow key opens nothing.
    assert(
      JSON.stringify(accExpanded(m, "faq")) === JSON.stringify(["false", "false", "false"]),
      "walking the headers opens none of them",
    );
    assert(m.one(ACC_SINGLE).getAttribute("data-state") === "none", "and the group is still closed");

    await accPress(m, "acc-faq-trigger-returns", "End");
    assert(
      JSON.stringify(accCaret(m, "faq")) === JSON.stringify(["false", "false", "true"]),
      "End names the last header",
    );
    // Vertical only: a header list gives a reader no reason to press Right, so
    // the chart draws no arrow for it and the key does nothing.
    await accPress(m, "acc-faq-trigger-support", "ArrowRight");
    assert(
      JSON.stringify(accCaret(m, "faq")) === JSON.stringify(["false", "false", "true"]),
      "Right is not this pattern's axis and moves nothing",
    );

    // Space and Enter are the button's own, and a click opens the header the
    // caret is on — the two charts answering one gesture, each in its own
    // columns.
    await accClick(m, "acc-faq-trigger-support");
    assert(
      JSON.stringify(accExpanded(m, "faq")) === JSON.stringify(["false", "false", "true"]),
      "the header the caret reached opens on a press",
    );
    assert(
      JSON.stringify(accCaret(m, "faq")) === JSON.stringify(["false", "false", "true"]),
      "and the caret stayed where it was",
    );
    assert(m.rows("accordion_single_demo").length === 1, "two charts, one row");
    await m.stop();
  },
});

/** The dropdown's six items in document order, and where the caret says it is. */
const openCaret = (m: Mounted) =>
  ["mi-open-switch", "mi-open-checkbox", "mi-open-radio-group", "mi-profile-andy", "mi-profile-benoit", "mi-profile-luis"]
    .map((id) => m.one(`#${id}`).getAttribute("data-cur"));

const openTabindex = (m: Mounted) =>
  ["mi-open-switch", "mi-profile-luis"].map((id) => m.one(`#${id}`).getAttribute("tabindex"));

const openPress = async (m: Mounted, id: string, key: string) => {
  m.fire(`#${id}`, "keydown", { key });
  await m.settle();
};

/** A keystroke whose buffer is about to be read. `settle` DRIVES the clock, so
 * it runs the one-second timer that clears the buffer — the thing under test
 * would be gone before the assertion saw it. */
const openType = async (m: Mounted, id: string, key: string) => {
  m.fire(`#${id}`, "keydown", { key });
  await m.quiet();
};

Deno.test({
  name: "accept-menu-walk: the arrows walk every item kind, and the letters jump",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await menuScreen();
    await m.settle();

    // No tabindex anywhere: every item keeps its own tab stop, which is the
    // reading decision-12 gives an accordion and not the one a tablist takes.
    assert(
      JSON.stringify(openTabindex(m)) === JSON.stringify([null, null]),
      `no item leaves the Tab sequence, got ${JSON.stringify(openTabindex(m))}`,
    );
    assert(
      JSON.stringify(openCaret(m)) === JSON.stringify(["true", "false", "false", "false", "false", "false"]),
      "the caret's context seats it on the first item",
    );

    // Down crosses from a link to a link, and then from a link to a radio item:
    // the caret's set is the surface's, so an item's kind is not its business.
    await openPress(m, "mi-open-switch", "ArrowDown");
    assert(openCaret(m)[1] === "true", "Down walks to the next item");
    await openPress(m, "mi-open-checkbox", "ArrowDown");
    await openPress(m, "mi-open-radio-group", "ArrowDown");
    assert(openCaret(m)[3] === "true", "and crosses from a link to a radio item");

    // End names the last, and Right moves nothing: a menu is vertical.
    await openPress(m, "mi-profile-andy", "End");
    assert(openCaret(m)[5] === "true", "End names the last item");
    await openPress(m, "mi-profile-luis", "ArrowRight");
    assert(openCaret(m)[5] === "true", "Right is not this pattern's axis");

    // Typing jumps, and the letters are the arrow's guard rather than a module
    // choosing a destination: every item the prefix could reach has its own.
    await openType(m, "mi-profile-luis", "b");
    assert(openCaret(m)[4] === "true", "a letter jumps to the item it names");
    assert(only(m.rows("menu_profile_demo"), "the surface's row").prefix === "b", "and lands in the buffer");

    // A second letter reads as one word: "be" still names Benoit, so the caret
    // stays rather than jumping to whatever "e" alone would have named.
    await openType(m, "mi-profile-benoit", "e");
    assert(openCaret(m)[4] === "true", "the buffer is a word, not a letter");

    // A second after the last keystroke the buffer clears, and the caret does
    // not move with it: the timer names no target.
    m.advance(1200);
    await m.settle();
    assert(only(m.rows("menu_profile_demo"), "the surface's row").prefix === "", "the buffer clears");
    assert(openCaret(m)[4] === "true", "and clearing it moves nobody");
    assert(m.rows("menu_profile_demo").length === 1, "one row for the whole surface");
    await m.stop();
  },
});

Deno.test({
  name: "accept-data-table-ends: the chord names the grid's ends, and the bare key names nothing",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await dtScreen();
    await m.settle();

    await dtPress(m, "ArrowDown");
    const first = dtIds(m)[0];
    const last = dtIds(m)[dtIds(m).length - 1];

    await dtChord(m, "End");
    assert(dtCursorRow(m).cursor === last, `Ctrl+End names the last row, got ${dtCursorRow(m).cursor}`);
    assert(dtActive(m) === last, "and the grid says so where a reader hears it");

    await dtChord(m, "Home");
    assert(dtCursorRow(m).cursor === first, `Ctrl+Home names the first, got ${dtCursorRow(m).cursor}`);

    // APG's own split, and the reason the chord is the chord: in a grid the
    // BARE key moves within a row. This grid's caret is a row and its cells are
    // static text, so there is nothing to move within — and a binding that
    // answered the bare key would claim a movement the widget does not have.
    await dtChord(m, "End");
    await dtPress(m, "Home");
    assert(
      dtCursorRow(m).cursor === last,
      `the bare key moves nothing, got ${dtCursorRow(m).cursor}`,
    );
    await m.stop();
  },
});

// -- input-otp ---------------------------------------------------------------

const otpScreen = () => screen("input-otp", { otp_demo: [] });
const otpRow = (m: Mounted): Row => only(m.rows("otp_demo"), "the code row");
/** A keystroke, or a paste, as the reader makes it: the control is showing the
 * whole value when `input` fires, which is the only thing the arrows read. */
const otpType = async (m: Mounted, value: string) => {
  m.set("#otp-code", "value", value);
  m.fire("#otp-code", "input");
  await m.settle();
};

Deno.test({
  name: "accept-otp-one-control: a pasted code is one event, and no slot is an input of its own",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await otpScreen();
    await m.settle();
    // The claim the six-box shape cannot make. One control means the paste is
    // the platform's, and the boxes under it are a background.
    assert(m.all(".otp input").length === 1, `the field is one control, saw ${m.all(".otp input").length}`);
    assert(
      (m.one("#otp-code") as El).getAttribute("autocomplete") === "one-time-code",
      "the control the platform fills is the control that holds the code",
    );

    await otpType(m, "148203");
    const wrote = writes(m).filter((w) => w.table === "otp_demo");
    assert(wrote.length === 1, `one paste, one write, got ${JSON.stringify(wrote.map((w) => w.row?.code))}`);
    assert(otpRow(m).code === "148203", `the row holds ${JSON.stringify(otpRow(m).code)}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-otp-complete: the last digit completes the code, and the column it wrote is what makes the button pressable",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await otpScreen();
    await m.settle();
    await otpType(m, "14820");
    assert(otpRow(m).state === "typing", `five digits left the row at ${JSON.stringify(otpRow(m).state)}`);
    // Not a guard on the click: the button cannot be pressed because a column
    // says so, and the same arrow wrote both facts.
    assert(
      (m.one("#otp-verify") as El).getAttribute("disabled") !== null,
      "an incomplete code leaves the verify button pressable",
    );

    await otpType(m, "148203");
    assert(otpRow(m).state === "complete", `six digits left the row at ${JSON.stringify(otpRow(m).state)}`);
    assert((m.one("#otp-verify") as El).getAttribute("disabled") === null, "a complete code leaves the button disabled");

    m.fire("#otp-verify", "click");
    await m.settle();
    assert(otpRow(m).state === "verified", `the verify click left the row at ${JSON.stringify(otpRow(m).state)}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-otp-refused: a keystroke no code can hold is written and marked, and half a code is marked neither",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await otpScreen();
    await m.settle();
    await otpType(m, "148x");
    // Written, not swallowed: an arrow that declined to write would leave the
    // control showing text the row has not got, and no delta to correct it.
    assert(otpRow(m).code === "148x", `the refused keystroke left ${JSON.stringify(otpRow(m).code)}`);
    assert(otpRow(m).invalid === "true", `the row reads invalid ${JSON.stringify(otpRow(m).invalid)}`);
    assert(
      (m.one("#otp-code") as El).getAttribute("aria-invalid") === "true",
      "the attribute a reader hears is the column",
    );

    await otpType(m, "1482");
    assert(otpRow(m).invalid === "false", `a code half typed reads invalid ${JSON.stringify(otpRow(m).invalid)}`);
    await m.stop();
  },
});

// -- hover-card --------------------------------------------------------------

const hcScreen = () => screen("hover-card");
/** The terminal's clock, which is where the open and the grace both live. */
const hcAfter = async (m: Mounted, ms: number) => {
  m.advance(ms);
  await m.quiet();
};
const hcOpen = (m: Mounted, id: string) => (m.one(`#${id}`) as El).getAttribute("data-popover-open") !== null;

Deno.test({
  name: "accept-hover-card-reachable: the card's link is next in the document, and the card survives the reader arriving on it",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await hcScreen();
    await m.settle();
    // Document order is the whole mechanism: sequential focus navigation walks
    // an open popover in tree order, so nothing here stamps a tabindex.
    const html = await read("shell/screens/hover-card.html");
    const trigger = html.indexOf('id="hc-open-profile"');
    const surface = html.indexOf('id="hc-profile"');
    assert(trigger !== -1 && surface > trigger, "the surface follows its trigger in the document");
    assert(m.all("[tabindex]").length === 0, "nothing on the screen stamps a tab order");
    assert(
      m.one("#hc-open-profile").getAttribute("popovertarget") === "hc-profile",
      "the trigger targets the card",
    );
    assert(
      m.one("#hc-profile").getAttribute("popover") === "auto",
      "the surface is an auto popover",
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-hover-card-aria: what is inside a surface decides its ARIA, and the tip is the other answer",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await hcScreen();
    await m.settle();
    for (const surface of m.all(".hc-surface")) {
      assert(!surface.hasAttribute("role"), "a card claims no role its content contradicts");
    }
    for (const trigger of m.all(".hc-trigger")) {
      assert(!trigger.hasAttribute("aria-describedby"), "a card is a structure, and a description is a string");
    }
    // The contrast, read off the other screen rather than asserted twice: one
    // gesture, two surfaces, opposite answers.
    const tips = await read("shell/screens/overlays.html");
    assert(/role="tooltip"/.test(tips), "the hover tip still carries the role this one refuses");
    await m.stop();
  },
});

Deno.test({
  name: "accept-hover-card-no-state: openness is nobody's row, counted rather than claimed",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await hcScreen();
    await m.settle();
    for (const attr of ["data-live", "data-filter", "data-empty-row", "data-machine"]) {
      assert(m.all(`[${attr}]`).length === 0, `the screen mounts no ${attr}`);
    }
    const html = await read("shell/screens/hover-card.html");
    assert(!/data-on-[a-z]|data-handler/.test(html), "the markup binds no Jessie");
    assert(!html.includes("data-interest="), "no element uses legacy data-interest");
    assert(
      m.store.calls.length === 0,
      `nothing reaches the store, got ${m.store.calls.map((c) => `${c.op} ${c.table}`).join(", ")}`,
    );
    await m.stop();
  },
});

// -- chart -------------------------------------------------------------------

const chScreen = () => screen("chart");
/** The component's own expansion, without the panes of prose around it: the
 * screen argues about calc() and carries the way-back arrow's svg, and neither
 * is the chart. */
const chartMarkup = async () => {
  const html = await read("shell/screens/chart.html");
  return html.slice(html.indexOf("<omnishell--bar-chart>"), html.indexOf("</omnishell--bar-chart>"));
};
const chBars = (m: Mounted): El[] => m.all(".chart-bar");
const chCursor = (m: Mounted): Row => only(m.rows("chart_cursor"), "the caret collection");
/** An arrow pressed where the reader's focus is: the bar that holds the tab
 * stop, whose keydown reaches the plot the binding is on. */
const chPress = async (m: Mounted, key: string) => {
  m.fire(m.one('.chart-bar[tabindex="0"]'), "keydown", { key });
  await m.settle();
};

Deno.test({
  name: "accept-chart-geometry: a length is calc() over a bound value and a bound domain, and the domain is the program's",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await chScreen();
    await m.settle();
    const bars = chBars(m);
    assert(bars.length === 6, `the seed draws six bars, got ${bars.length}`);
    // Each bar carries its own row's number and nothing else: what a length is
    // against lives once, on the frame they inherit it through.
    const drawn = bars.map((b) => Number(/--v:\s*(\d+)/.exec(b.getAttribute("style") ?? "")?.[1]));
    const stored = m.rows("chart_point").map((r) => Number(r.value));
    assert(JSON.stringify(drawn) === JSON.stringify(stored), `the bars draw ${drawn} over rows ${stored}`);

    const frame = m.one(".chart-frame").getAttribute("style") ?? "";
    const domain = Number(/--chart-max:\s*(\d+)/.exec(frame)?.[1]);
    // The claim that makes the scale trustworthy: it is the max of the same
    // list the rows come from, computed where that list is stated.
    assert(domain === Math.max(...stored), `the domain is ${domain} over rows topping out at ${Math.max(...stored)}`);

    // The division is the stylesheet's, and the markup has no arithmetic to be
    // wrong: a screen that computed a width would have to recompute it. Read
    // off the component's own expansion, since the panes around it are prose
    // ABOUT the calc and would answer for it.
    const css = await read("shell/screens/chart.css");
    assert(!/calc\(/.test(await chartMarkup()), "the markup does no arithmetic");
    assert(/calc\(var\(--v\)\s*\/\s*var\(--chart-max\)/.test(css), "the length is calc over the two bound numbers");
    await m.stop();
  },
});

Deno.test({
  name: "accept-chart-caret: one tab stop, four keys and a click, all writing one column",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await chScreen();
    await m.settle();
    assert(chCursor(m).active === "mar", `the seeded caret opens on ${JSON.stringify(chCursor(m).active)}`);
    // One tab stop for the whole plot, which is what a composite whose arrows
    // move a selection gets — and it is on the bar the caret names.
    const stops = chBars(m).filter((b) => b.getAttribute("tabindex") === "0");
    assert(stops.length === 1, `the plot is one tab stop, saw ${stops.length}`);
    assert(stops[0].getAttribute("id") === "chart-bar-mar", `the stop is on ${stops[0].getAttribute("id")}`);
    assert(stops[0].getAttribute("aria-current") === "true", "the tab stop and the fill are one answer");

    await chPress(m, "ArrowDown");
    assert(chCursor(m).active === "apr", `Down left the caret on ${JSON.stringify(chCursor(m).active)}`);
    await chPress(m, "Home");
    assert(chCursor(m).active === "jan", `Home left the caret on ${JSON.stringify(chCursor(m).active)}`);
    await chPress(m, "End");
    assert(chCursor(m).active === "jun", `End left the caret on ${JSON.stringify(chCursor(m).active)}`);

    // The pointer writes the column the keys write: the bar IS a submit button,
    // so there is no second way to be current. Submitted rather than clicked:
    // linkedom models no implicit submission from a submit button, so a click
    // would assert the host's gap and not the screen's wiring.
    (m.one("#chart-pick-feb") as any).requestSubmit();
    await m.settle();
    assert(chCursor(m).active === "feb", `the click left the caret on ${JSON.stringify(chCursor(m).active)}`);
    assert(
      writes(m).every((w) => w.table === "chart_cursor"),
      `the caret is the only thing written, got ${JSON.stringify(writes(m).map((w) => w.table))}`,
    );
    // And the readout follows it, which is what the tooltip is here.
    assert(textOf(m.one(".chart-read")).includes("305"), `the readout reads ${textOf(m.one(".chart-read"))}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-chart-is-a-table: the picture is the data it draws",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await chScreen();
    await m.settle();
    const heads = m.all('.chart-plot th[scope="row"]');
    assert(heads.length === 6, `a row header per category, got ${heads.length}`);
    assert(
      JSON.stringify(m.texts('.chart-plot th[scope="row"]')) ===
        JSON.stringify(["January", "February", "March", "April", "May", "June"]),
      "the categories are the rows' own labels, in the order the plot is read in",
    );
    // What is seen is inside what is said (2.5.3): the number on the bar is
    // part of the name a reader hears.
    for (const bar of chBars(m)) {
      const name = bar.getAttribute("aria-label") ?? "";
      assert(name.includes(textOf(bar)), `"${name}" carries the number it draws (${textOf(bar)})`);
      assert(/ visitors$/.test(name), `"${name}" says what the number counts`);
    }
    // No second copy of the numbers to keep in step. The line IS a second
    // picture and it is not a second copy: it draws the same rows, carries no
    // text of its own, and says so — a reader hears the table and the line is
    // decoration over it.
    const line = m.one(".chart-line")
    assert(line.getAttribute("aria-hidden") === "true", "the line is decoration over the table, and says so")
    assert(textOf(line) === "", `the line states no number of its own, got ${JSON.stringify(textOf(line))}`)
    assert(m.all(".chart-seg").length === 6, `a segment per row, got ${m.all(".chart-seg").length}`)
    // Every segment reaches from its own row to the next one's value, which is
    // the one thing a bar does not need and the whole of what the line costs.
    const rows = m.rows("chart_point")
    assert(
      JSON.stringify((m.all(".chart-seg") as El[]).map((el) => el.getAttribute("style"))) ===
        JSON.stringify(rows.map((r) => `--v: ${r.value}; --n: ${r.nxt_value}`)),
      "each segment is bound from its own row, neighbour included",
    )
    assert(String(rows[5].nxt_value) === String(rows[5].value), "the last point's neighbour is itself");
    await m.stop();
  },
});

// -- atoms -------------------------------------------------------------------

const atScreen = () => screen("atoms");

Deno.test({
  name: "accept-atoms-skins: four components with nothing to hold, and the screen says what holds it instead",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await atScreen();
    await m.settle();
    for (const attr of ["data-live", "data-filter", "data-empty-row", "data-machine", "data-project"]) {
      assert(m.all(`[${attr}]`).length === 0, `the screen mounts no ${attr}`);
    }
    const html = await read("shell/screens/atoms.html");
    assert(!/data-on-[a-z]|data-handler/.test(html), "the markup binds no Jessie");
    assert(
      m.store.calls.length === 0,
      `nothing reaches the store, got ${m.store.calls.map((c) => `${c.op} ${c.table}`).join(", ")}`,
    );
    const shell = await read("shell/shell.yaml");
    assert(/screen: atoms[\s\S]{0,200}handlers: \[\]/.test(shell), "the emitted route lists no handler module");

    // The dark twin by construction rather than by review: a colour this
    // stylesheet declared would be one the appearance switch cannot reach.
    const css = await read("shell/screens/atoms.css");
    const literals = css.match(/#[0-9a-fA-F]{3,8}\b|\brgba?\(|\bhsla?\(/g) ?? [];
    assert(literals.length === 0, `the stylesheet names tokens and nothing else, got ${literals.join(", ")}`);
    await m.stop();
  },
});

Deno.test({
  name: "accept-atoms-reduced-motion: the spinner carries the wait, and the ring is what the media query takes",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await atScreen();
    await m.settle();
    const spinners = m.all(".spinner");
    assert(spinners.length === 3, `three specimens, got ${spinners.length}`);
    for (const s of spinners) {
      assert(s.getAttribute("role") === "status", "each carries the role that announces a wait");
      assert(textOf(s) !== "", "and a label under it, which is what survives the collapse");
    }
    // The rings are aria-hidden, so what a reader hears is the label alone —
    // three specimens of one wait, not three waits.
    assert(
      m.all(".spinner-ring").every((r) => r.getAttribute("aria-hidden") === "true"),
      "the ring is decoration and says so",
    );
    const css = await read("shell/screens/atoms.css");
    assert(
      /@media \(prefers-reduced-motion: reduce\)[\s\S]*animation: none/.test(css),
      "and the rule that takes the spin away is in the screen's own stylesheet",
    );
    // What spins is a pseudo-element, so the box around it does not move: a
    // rotating square's bounding box changes with the angle, and the visual
    // battery settles by fingerprinting geometry — an element that never stops
    // moving leaves a whole route measured while it moves.
    assert(
      /\.spinner-ring::after \{[^}]*animation: atoms-spin/.test(css),
      "and the animation is on a pseudo-element, which the settle fingerprint does not walk",
    );
    await m.stop();
  },
});

// -- composition -------------------------------------------------------------

const cpScreen = () => screen("composition", { composition_demo: [] });
const cpRow = (m: Mounted): Row => only(m.rows("composition_demo"), "the screen's one row");

Deno.test({
  name: "accept-composition-relationships: each arrangement keeps the one relationship it is",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cpScreen();
    await m.settle();

    // Item: a row that goes somewhere is a link, and a row that does not is
    // not a link with no href — a control a keyboard cannot reach and a reader
    // is told about anyway.
    const items = m.all(".item");
    assert(items.length === 4, `four item specimens, got ${items.length}`);
    const links = items.filter((el) => (el as unknown as { localName: string }).localName === "a");
    assert(links.length === 1, `one of them goes somewhere, got ${links.length}`);
    assert(links.every((el) => (el.getAttribute("href") ?? "") !== ""), "and it has a destination");

    // Button group: a shared border over independent ACTIONS, so none of them
    // wears the ARIA of a choice.
    const actions = m.all(".bg-button");
    assert(actions.length === 3, `three actions, got ${actions.length}`);
    assert(
      actions.every((b) => b.getAttribute("aria-checked") === null && b.getAttribute("tabindex") === null),
      "a group of actions is not a choice: no aria-checked, and no roving tab stop",
    );
    assert(m.one(".bg").getAttribute("role") === "group", "and the group says what it is");

    // Field is the form screen's, and this catalog declares it once.
    const here = await read("shell/screens/composition.html");
    assert(!/class="field"/.test(here), "the composition screen declares no Field of its own");
    assert(/class="field"/.test(await read("shell/screens/form.html")), "because the form screen already has one");

    // And the two that act, act.
    m.set("#ig-search", "value", "trash");
    m.fire("#ig-search", "input");
    await m.settle();
    assert(cpRow(m).query === "trash", `the input group's control writes, got ${JSON.stringify(cpRow(m).query)}`);
    m.fire("#bg-share", "click");
    await m.settle();
    assert(cpRow(m).last === "Share", `each action states its own literal, got ${JSON.stringify(cpRow(m).last)}`);
    m.fire("#ig-search-clear", "click");
    await m.settle();
    assert(cpRow(m).query === "", "and the addon inside the box is a button like any other");
    await m.stop();
  },
});

Deno.test({
  name: "accept-composition-logical: direction is an attribute, so every edge the screen states is a logical one",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await cpScreen();
    await m.settle();
    assert(m.all('[dir="rtl"]').length === 1, "one frame asks for the other direction");

    // A rule naming a physical edge is a rule that attribute cannot reach.
    // `left`/`right` as VALUES (text-align, float) are the same hazard, which
    // is why the scan reads properties and values alike.
    const css = await read("shell/screens/composition.css");
    const physical = css.match(
      /(?:padding|margin|border|inset)-(?:left|right)\b|(?:^|[\s;{])(?:left|right)\s*:|text-align:\s*(?:left|right)\b/gm,
    ) ?? [];
    assert(physical.length === 0, `every edge is logical, got ${physical.join(", ")}`);
    await m.stop();
  },
});

// -- chat --------------------------------------------------------------------

// The composer stamps {now}, and a held clock stamps it only from an epoch —
// EPOCH above is that instant, and the transcript's order is that stamp.
// No tables: both collections are the program's, so the harness seeds them the
// way the terminal does on a first visit.
const chScreenChat = () => screen("chat");
const chatRows = (m: Mounted) => m.all(".chat-scroller .chat-row");
const chatKinds = (m: Mounted) => chatRows(m).map((el) => el.getAttribute("data-kind"));

Deno.test({
  name: "accept-chat-kinds: one region over three kinds, and the kind is a column",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await chScreenChat();
    await m.settle();
    assert(chatRows(m).length === 6, `the seed states six rows, got ${chatRows(m).length}`);
    // One region, ordered newest-first, because the box it fills is reversed.
    assert(m.all(".chat-scroller").length === 1, "one region carries every kind");
    assert(
      JSON.stringify(chatKinds(m)) ===
        JSON.stringify(["message", "file", "marker", "message", "message", "message"]),
      `newest first, kinds in order: ${JSON.stringify(chatKinds(m))}`,
    );

    // A marker is a row nobody said: no seat, and nothing that belongs to one.
    const marker = chatRows(m).filter((el) => el.getAttribute("data-kind") === "marker");
    assert(marker.length === 1, "one marker among them");
    assert(marker[0].getAttribute("data-seat") === "none", "and it takes no side");

    // The seat decides the side, which is what makes a transcript followable —
    // two bubbles differing only in colour is one nobody can read.
    const seats = chatRows(m).map((el) => el.getAttribute("data-seat"));
    assert(seats.includes("you") && seats.includes("them"), "both sides are in the seed");
    // The attachment's state is a column like any other.
    const file = chatRows(m).filter((el) => el.getAttribute("data-kind") === "file")[0];
    assert(file.getAttribute("data-state") === "uploading", "the file carries a state a message has not");
    await m.stop();
  },
});

Deno.test({
  name: "accept-chat-grows: the composer states every column, and the live edge is a layout",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await chScreenChat();
    await m.settle();

    m.set("#chat-say", "value", "And the walk is silent on every app.");
    m.fire("#chat-send", "submit");
    await m.settle();

    assert(chatRows(m).length === 7, `the transcript grew, got ${chatRows(m).length}`);
    const wrote = writes(m).filter((w) => w.table === "chat_row");
    assert(wrote.length === 1, `one create, got ${wrote.length}`);
    // Every column stated: a row half stated is one the bindings read as blank.
    const row = wrote[0].row ?? {};
    assert(
      JSON.stringify(Object.keys(row).sort()) ===
        JSON.stringify(["at", "body", "id", "initials", "kind", "note", "seat", "state", "when", "who"]),
      `the create states every column, got ${JSON.stringify(Object.keys(row).sort())}`,
    );
    // The terminal's clock, which the mount has been advancing since the screen
    // opened — so the stamp is after the epoch rather than equal to it.
    assert(String(row.at) > EPOCH, `at is the terminal's clock, got ${row.at}`);
    // Newest first in the DOM, because the box is reversed: the row the reader
    // just sent is the first child, and nothing measured a scroll to put it
    // there.
    assert(
      textOf(chatRows(m)[0]).includes("silent on every app"),
      `the newest row is the first child, got ${textOf(chatRows(m)[0])}`,
    );
    const css = await read("shell/screens/chat.css");
    assert(/flex-direction: column-reverse/.test(css), "and the live edge is the layout's");
    const html = await read("shell/screens/chat.html");
    assert(!/data-on-[a-z]|data-handler/.test(html), "nothing on this screen listens for anything");
    await m.stop();
  },
});

// -- questionnaire -----------------------------------------------------------

const qzScreen = () => screen("questionnaire", { quiz_demo: [] });
const qzRow = (m: Mounted): Row => only(m.rows("quiz_demo"), "the questionnaire's row");
const qzStep = (m: Mounted) => m.one(".quiz").getAttribute("data-state");
const qzNextBlocked = (m: Mounted) => m.one("#quiz-next").getAttribute("disabled") !== null;
const qzClick = async (m: Mounted, id: string) => {
  m.fire(`#${id}`, "click");
  await m.settle();
};

Deno.test({
  name: "accept-quiz-steps: the steps are the chart's states, and Back does not ask twice",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await qzScreen();
    await m.settle();
    assert(qzStep(m) === "one", `it opens on the first question, got ${qzStep(m)}`);
    assert(qzNextBlocked(m), "and Next is blocked until the question is answered");

    await qzClick(m, "quiz-one-chart");
    assert(qzRow(m).a_shape === "Markup, tokens and a chart", `the answer is a column, got ${JSON.stringify(qzRow(m))}`);
    // The option's own attribute speaks true and false, which is what
    // aria-pressed is for — the answer's words are the other column.
    assert(
      m.one("#quiz-one-chart").getAttribute("aria-pressed") === "true" &&
        m.one("#quiz-one-markup").getAttribute("aria-pressed") === "false",
      "one option pressed, the others not",
    );
    assert(!qzNextBlocked(m), "and the block the same arrow lifted is gone");

    await qzClick(m, "quiz-next");
    assert(qzStep(m) === "two", `Next left an answered step, got ${qzStep(m)}`);
    assert(qzNextBlocked(m), "and the next question has its own block");

    // Back and forward again: the claim the leaf exists for.
    await qzClick(m, "quiz-two-row");
    await qzClick(m, "quiz-back");
    assert(qzStep(m) === "one", `Back went back, got ${qzStep(m)}`);
    assert(!qzNextBlocked(m), "and the question already answered is not asked again");
    await qzClick(m, "quiz-next");
    assert(qzStep(m) === "two" && !qzNextBlocked(m), "coming forward finds its own answer standing");

    assert(m.rows("quiz_demo").length === 1, "every one of those was one row");
    await m.stop();
  },
});

Deno.test({
  name: "accept-quiz-skip: skip is the arrow with no block on it, and it answers",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await qzScreen();
    await m.settle();
    await qzClick(m, "quiz-one-chart");
    await qzClick(m, "quiz-next");
    assert(qzStep(m) === "two" && qzNextBlocked(m), "the second question is unanswered");

    // Skippable is a fact about the step, and the chart is where it is stated:
    // this arrow exists on the second question and on neither of the others.
    await qzClick(m, "quiz-skip");
    assert(qzStep(m) === "three", `skip went on, got ${qzStep(m)}`);
    assert(qzRow(m).a_state === "Skipped", `and answered it, got ${JSON.stringify(qzRow(m).a_state)}`);

    // The freeform step: typed text is a column, and the block follows the
    // value the keystroke carried rather than the one the row still holds.
    assert(qzNextBlocked(m), "the freeform step opens blocked");
    m.set("#quiz-note", "value", "Nothing — it is already the smallest one.");
    m.fire("#quiz-note", "input");
    await m.settle();
    assert(!qzNextBlocked(m), "and a keystroke lifts it on the keystroke, not a beat later");

    await qzClick(m, "quiz-next");
    assert(qzStep(m) === "done", "the last Next reaches the end");
    await qzClick(m, "quiz-again");
    assert(qzStep(m) === "one", "and the restart is a row stated");
    assert(
      qzRow(m).a_shape === "" && qzRow(m).a_state === "" && qzRow(m).a_note === "",
      `which clears every answer, got ${JSON.stringify(qzRow(m))}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "accept-catalog-links: the index links every route, and every link is a route",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("catalog");
    await m.settle();
    // The claim this acceptance makes is about DRIFT: a screen the program
    // declares and the index does not name is one nothing on the site reaches,
    // and a card pointing at a route that is gone is a dead end. Both are
    // invisible to every other test here, because each of those mounts the
    // screen it is about by name.
    const routes = [...(await read("shell/shell.yaml")).matchAll(/^  - path: (\S+)/gm)].map((r) => r[1]);
    const links = m.all(".entry").map((a) => a.getAttribute("href") ?? "");
    assert(routes.length > 1, `the program declares routes, got ${routes.length}`);
    assert(
      routes.filter((r) => r !== "/" && !links.includes(r)).length === 0,
      `every route but the index is linked; missing ${JSON.stringify(routes.filter((r) => r !== "/" && !links.includes(r)))}`,
    );
    assert(
      links.filter((l) => !routes.includes(l)).length === 0,
      `every link is a route; dangling ${JSON.stringify(links.filter((l) => !routes.includes(l)))}`,
    );
    // And no entry renders a control that does nothing: the index is links.
    assert(m.all("button").length === 0, "the index holds no control, only its links");
    await m.stop();
  },
});
