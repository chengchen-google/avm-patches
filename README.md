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
`experiments/DECISIONS.md` for the reasoning behind every kill and keep. The
short version as of the last update:

- **i02, i03, i05** — proven bit-exact; zero quality risk, no CTC round needed.
  Their *speed* remains unquantified and is the open question.
- **i06** — the only patch with a speedup that is unambiguous across both
  round-1 measurement designs, and, being partition pruning, the one with the
  most BD-rate risk at 4K.
- **i01, i07, i09** — real but under the 5% bar.
- **i04, i08, i10** — never resolved above the measurement noise floor; i04 may
  in fact be a slowdown.

## Protocol

`experiments/README.md` describes the tiered funnel: prove what can be proven
(bit-exactness), measure cost deterministically (instruction counts), measure
decision regret without changing the bitstream, and only then spend a CTC round.
The point of the ordering is that a CTC slot costs about a day and should only
ever answer a question nothing cheaper could.
