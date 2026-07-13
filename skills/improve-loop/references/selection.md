# Candidate selection

Rank evidence-backed candidates with four separate dimensions:

- **Impact**: concrete product, correctness, operational, or maintenance gain.
- **Leverage**: how many callers or future changes benefit.
- **Depth**: whether behavior and knowledge move behind a smaller Interface.
- **Confidence**: strength of repository evidence and proof feasibility.

Use readiness, migration risk, dependencies, and oversize as tags rather than
inventing a numeric score. Recommend the strongest order plainly.

Maintain one selected wave and one candidate queue. Do not pre-write a fixed
campaign. A candidate becomes a plan only when selected for the next wave. After
land or reject, use the new evidence to reorder, split, remove, or add candidates.

Before planning a wave, tag every selected candidate with:

- dependency edges and required integration order;
- likely file and production-owner overlap;
- shared resources: schema/migrations, package entrypoints, test databases,
  ports, browser lanes, generated artifacts, release notes, and program state;
- proof cost and whether it can run in an isolated disposable runtime.

Prefer two high-value candidates with minimal overlap over three candidates that
share an owner or gate. Admit a third writer only when the dependency and overlap
matrix proves it independent. Keep `LOOP.md` and plan status edits host-owned.

Prefer a slice that:

- changes one production owner or invariant;
- has a deletion or consolidation result;
- can be proven through a public Interface or real Seam;
- fits one implementation and one review budget;
- does not require an unresolved business decision.

Reject or split candidates that combine unrelated tactical fixes, general
redesign, and workflow maintenance.
