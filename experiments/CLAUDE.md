# Orientation for a future session

You are almost certainly a fresh Claude session with no memory of this work.
This repo is the handover. Read in this order and you will be current in about a
minute.

1. `../README.md` — what this repo is, and the base-drift hazard.
2. `registry.csv` — where every patch stands, across every tier. Start here.
3. `DECISIONS.md` — why patches were killed or kept. Read the top entry first.
4. `README.md` — the tiered protocol and the reasoning behind it.

## First command of any session

    bin/check-rot.sh /path/to/avm-checkout

If it reports the base moved, **every number in `registry.csv` is stale** until
Tier 0 and Tier 1 are re-run on the new base. A patch that still applies cleanly
has not been shown to still be correct — see the worked example in the top-level
README, where an upstream commit added 187 lines to a file two patches modify
and all ten still reported `APPLIES`.

## Ground truth you must not re-derive or re-litigate

- Patches in `patches/` are standalone diffs against the SHA in `BASE`. The AVM
  source is not vendored here; you need a separate checkout.
- Round-1 timings in `reports/measurements-*.csv` are wall clock on a shared
  host with a **2.4% noise floor and a 3.5% minimum detectable effect**. Six of
  the ten reported speedups are below that floor and are non-measurements. Do
  not quote them as speedups. Run `experiments/bin/screen_timing.py` on those
  CSVs if you want to see it yourself.
- The two round-1 datasets **contradict each other** on seven of ten patches.
  Only i06 is stable across both designs.
- Round 1 was measured on 416x240, 4 frames, `--cpu-used=4`. The CTC target is
  A1 (4K) + A2 RA, 17/33 frames, QPs 110/135/160/185/210/235. Assume nothing
  transfers between those regimes until measured.
- i02, i03 and i05 are proven bit-exact **on the tested configuration only**
  (416x240, 6 frames, cpu-used=3, QP 110/185). That is not universal proof; a
  cache-key bug in a path that config never reaches would not have been caught.
  Re-running Tier 0 on a 4K clip at the CTC preset is cheap and still owed.
- The user runs CTC themselves; a round costs hours to a day. Your job is to
  make sure every CTC slot answers a question nothing cheaper could have.

## The one rule

Before proposing that any patch go to a CTC round, check it cleared the cheaper
tiers. A patch whose speedup has never been resolved above the noise floor must
not consume a CTC slot — fix the measurement first (Tier 1, `perf stat -e
instructions`), because CTC measures quality and cannot rescue an inconclusive
timing result.

## When results arrive

1. Write the numbers into `registry.csv`, and confirm `BASE` matches the SHA
   they were measured on.
2. Append a dated entry to `DECISIONS.md`: what was killed, kept, and why.
3. Report **per-sequence spread**, not just the mean. A good average hiding one
   bad sequence is a regression risk, not a win.
4. Commit. This repo is the only thing that survives you.
