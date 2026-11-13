# Version rules and current counter

User rule, effective 2026-11-12. This replaces the earlier rule that every version bump required a separate explicit request.

- Five separate single-entry addition requests earn one +0.1 version bump when the fifth is completed. Here, a separate chat means a separate user addition request/message, not a tool call or assistant reply.
- A batch request adding multiple requested animals earns exactly one +0.1 version bump for that batch, regardless of batch size. Supporting taxonomy nodes (families, orders, etc.) do not turn a single-animal request into a batch.
- An already-present entry does not count again. Styling, search fixes and other non-addition edits do not advance this counter. An explicit version request still takes precedence.
- Start a fresh single-entry counter after a version bump. Persist this ledger after each completed addition so later chats can continue it.
- Keep both badges and changelogs synchronized; follow the existing verify, commit, version-tag and GitHub Pages publishing workflow.

## Current state

- Current version: **v5.6**
- Pending separate single-entry requests: **2 / 5**
- Next automatic single-entry version bump: **v5.7**, after three more qualifying requests. A batch request can trigger it sooner.

| Count | Added entry | Request date |
|---|---|---|
| 1 | Nigersaurus (explicitly counted by the user; its supporting family counts with it) | 2026-11-12 |
| 2 | Utahraptor | 2026-11-12 |
