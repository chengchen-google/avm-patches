# avm-patches

Experimental AV2 encoder speed-up work: the patch series, the measurement
protocol, and the results ledger. The AVM source itself is **not** vendored
here — this repo carries only what is ours, applied on top of a pinned upstream
commit.

    BASE          the av2-enc commit this series is verified against
    patches/      the series, one standalone patch per idea
    experiments/  protocol, tooling, and the results ledger
    reports/      per-round write-ups and raw measurement CSVs
    bin/          repo-level tooling (base sync / rot check)

## Why this repo is separate from the AVM tree

- The work is exploratory and most of it will be discarded. Keeping it out of a
  fork of the codec means nothing half-verified ever looks like a claim against
  the official tree.
- It stays small and clones in seconds, so a fresh session or a fresh machine is
  productive immediately.
- It makes the **ledger** the primary artifact rather than the code. Given that
  round 1 produced ten patches of which six had never been measured above the
  noise floor, the durable value here is the record of what was tested, what was
  retracted, and why — not the diffs.
- Patches are the natural unit for eventual upstreaming, so the series stays in
  the shape it would need to be submitted in.

## Working layout

This repo is used alongside an ordinary AVM checkout; it does not replace one.

    ~/work/avm            # clone of AOMediaCodec/avm, kept on av2-enc
    ~/work/avm-patches    # this repo

Apply the series onto a clean checkout at the pinned base, build, measure.

## The one real hazard: base drift

`av2-enc` moves. A patch series against a moving head decays in two distinct
ways, and only the first is easy to see:

1. **Textual rot** — the patch no longer applies. Loud, obvious, cheap to fix.
2. **Semantic rot** — the patch still applies cleanly but no longer means what
   it meant. Silent, and it invalidates measurements without any error.

The second is the dangerous one. A concrete instance already happened in this
series: upstream moved `a341351 → 425711f`, one commit, *"Implement non-RD
partition evaluation for real-time mode (#5236)"*, which added 187 lines to
`av2/encoder/partition_search.c`. Patches 0006 and 0007 modify that same file.
All ten patches still applied cleanly — the new code landed in regions they do
not touch textually. But 0006 and 0007 prune partition search, so if the new
real-time path bypasses the hook they attach to they now silently do nothing on
it, and if it routes through that hook they now silently prune a search they
were never measured against. `APPLIES` was true and told us nothing.

The rules that follow from this:

- **`BASE` is pinned and tracked.** Every number in `experiments/registry.csv`
  is valid only against the SHA in `BASE`.
- **`bin/check-rot.sh` runs before every round.** It reports applicability *and*
  prints the set of files that both upstream and this series touched, which is
  exactly where a clean apply is least trustworthy.
- **A base change invalidates measurements until re-verified.** Re-run Tier 0
  (bit-exactness, minutes) and Tier 1 (instruction counts) on the new base
  before quoting any previously recorded figure. This is affordable precisely
  because those tiers are cheap; that is what they are for.

## Current state

See `experiments/registry.csv` for per-patch status and
`experiments/DECISIONS.md` for the reasoning behind every kill and keep.
CTC round 1 (anchor `d6b40b7893`, Class A1 17f 4K and A2 33f 4K) is in, and
judged against the Complexity-to-Efficiency bar of speedup% / BD-rate%
(>=20 at Speed 4):

- **i09 — PROMOTE.** +2.60%/+0.11% on A1 (ratio 23.6), +2.27%/+0.09% on A2
  (25.2). The only patch clearing the bar on both classes.
- **i06 — IMPROVE.** +14.00%/+0.75% on A1 (18.7), +18.52%/+1.29% on A2 (14.4).
  The only patch with real magnitude, and it fails close on A1. A2 binds: it
  needs BD 1.29% -> 0.926% at unchanged speed. Reworked as
  `patches/0006b-orientation-pruning-frame-aware.patch`.
- **i01, i04, i07, i08, i10 — DISCARD.** BD cost far over the bar, or no
  speedup at all; i04 and i10 are slowdowns on 4K.
- **i02, i03, i05 — DISCARD.** CTC confirms exactly +0.00% BD on every metric,
  so the Tier-0 bit-exactness result was right and cost 25 minutes rather than
  a CTC slot. But all three are *slower* at 4K. Zero risk and zero benefit is
  not a feature.

The result that should shape the next round is the combination arithmetic. All
ten together give +20.34%/+2.50% (8.1) on A1. Backing i06 out — speedups
compound, BD-rate adds — leaves the other nine contributing ~7.4% speed for
~1.75% BD, a ratio of ~4.2. Nine patches buy a third of i06's speedup at twice
its quality cost. **The next round should test i06b+i09, not all-10.**

## Protocol

`experiments/README.md` describes the tiered funnel: prove what can be proven
(bit-exactness), measure cost deterministically (instruction counts), measure
decision regret without changing the bitstream, and only then spend a CTC round.
The point of the ordering is that a CTC slot costs about a day and should only
ever answer a question nothing cheaper could.
