---
bc-version: [all]
domain: ui
keywords: [usagecategory, applicationarea, searchable, page, tell-me, aw0006]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Make pages searchable with `UsageCategory` (UICop AW0006)

## Description

UICop AW0006 flags a page that declares `ApplicationArea` but leaves `UsageCategory` **unset**. The rule is satisfied when `UsageCategory` is *present* — its trigger is the missing property, not any particular value. A page surfaces in the Tell-Me search ("What do you want to do?") only when it carries both `ApplicationArea` and a real `UsageCategory` group (`Lists`, `Documents`, `Tasks`, `ReportsAndAnalysis`, `Administration`); `ApplicationArea` controls visibility for the user's experience, `UsageCategory` places the page in a search group. A list or card page shipped with no `UsageCategory` compiles but is effectively invisible to end users — and the analyzer warns.

Crucially, `UsageCategory = None` is a *value*, not an omission: a page that is opened only as a lookup (via `RunModal`/lookup from another object) and is deliberately not in Tell-Me should set `UsageCategory = None` explicitly. That satisfies AW0006 and documents intent. The warning is about the *absent* property, so `None` is the correct answer for a non-searchable page — not a workaround.

LLMs routinely scaffold pages with neither property, because a minimal page compiles without them — the gap only shows up as an analyzer warning and as a page nobody can find.

## Best Practice

Set `UsageCategory` on every page that declares `ApplicationArea`, choosing by intent:

- **Searchable pages** (meant to be opened directly): a real group matching the page's role — `Lists` for list pages, `Documents` for card/document pages, `Administration` for setup. Pair with `ApplicationArea = All;` (the pragmatic default for per-tenant/ISV apps that do not manage application-area profiles).
- **Lookup-only pages** (opened via `RunModal`/lookup, never from Tell-Me): `UsageCategory = None;` explicitly, ideally with a short comment naming who opens it. This is the correct, intentional choice — not a way to dodge the rule.

Set the properties in the page's property block, not on individual fields.

See sample: `make-pages-searchable-with-usagecategory-uicop-aw0006.good.al`.

## Anti Pattern

Shipping a page that declares `ApplicationArea` but omits `UsageCategory` entirely — the property is absent, the page never appears in Tell-Me, and AW0006 warns. The fix is to set `UsageCategory`: a real group for a searchable page, or `None` for a deliberately non-searchable lookup page. Do **not** read this rule as "always pick a real category": forcing a searchable category onto a lookup-only page pollutes Tell-Me with pages users cannot meaningfully use.

See sample: `make-pages-searchable-with-usagecategory-uicop-aw0006.bad.al`.

See sample: `make-pages-searchable-with-usagecategory-uicop-aw0006.bad.al`.
