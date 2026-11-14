# Version rules and current counter

User rule, effective 2026-11-12. This replaces the earlier rule that every version bump required a separate explicit request.

- Five separate single-entry addition requests earn one +0.1 version bump when the fifth is completed. Here, a separate chat means a separate user addition request/message, not a tool call or assistant reply.
- A batch request adding multiple requested animals earns exactly one +0.1 version bump for that batch, regardless of batch size. Supporting taxonomy nodes (families, orders, etc.) do not turn a single-animal request into a batch.
- An already-present entry does not count again. Styling, search fixes and other non-addition edits do not advance this counter. An explicit version request still takes precedence.
- Start a fresh single-entry counter after a version bump. Persist this ledger after each completed addition so later chats can continue it.
- Keep both badges and changelogs synchronized; follow the existing verify, commit, version-tag and GitHub Pages publishing workflow.

## Current state

- Current version: **v5.8**
- Pending separate single-entry requests: **0 / 5**
- Next automatic single-entry version bump: **v5.9**, after five more qualifying requests. A batch request can trigger it sooner.

## Completed release — v5.8

The batch request on 2026-11-14 added Elginia, Hypsognathus (requested as Hypsognattus), Amargasaurus and Dilophosaurus. Coelacanths were already present as Latimeria and were not duplicated. The batch triggered exactly one version bump and reset the pending counter. The preceding separate addition is retained below for history.

| Count | Added entry | Request date |
|---|---|---|
| 1 | Borealopelta (its supporting family counts with it) | 2026-11-12 |

## Completed cycle — v5.7

The following five separate addition requests completed the v5.7 cycle; this ledger is retained for history.

| Count | Added entry | Request date |
|---|---|---|
| 1 | Nigersaurus (explicitly counted by the user; its supporting family counts with it) | 2026-11-12 |
| 2 | Utahraptor | 2026-11-12 |
| 3 | Sarcosuchus (its supporting family counts with it) | 2026-11-12 |
| 4 | Mesopithecus | 2026-11-12 |
| 5 | Ichthyornis (its supporting family and order count with it) | 2026-11-12 |
