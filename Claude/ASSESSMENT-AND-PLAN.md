# Assessment and plan after CTC round 1

Written to be read on its own. `experiments/registry.csv` has the per-patch
state, `experiments/DECISIONS.md` the full reasoning; this is the summary and
the argument.

---

## Bottom line

Of ten patches, **one is ready to adopt, one is worth one more attempt, and
eight should be dropped.** The whole value of the effort now rests on a single
patch, i06, which needs a 28% BD-rate reduction on Class A2 to clear the bar. I
have reworked it and the rework is in `patches/`, but whether it clears the bar
is a hypothesis, not a result.

The second, less comfortable conclusion is that my round-1 screening was not
good enough to justify the CTC round it triggered, and the process changes in
this repo matter more than any individual patch in it.

---

## 1. Where each patch stands

Judged by the Complexity-to-Efficiency ratio (speedup% / BD-rate%), bar of 20 at
Speed 4. Anchor `d6b40b7893`, Class A1 (17f 4K) and A2 (33f 4K).

| Patch | A1 speed / BD | A1 ratio | A2 speed / BD | A2 ratio | Verdict |
|---|---|---|---|---|---|
| **i09** tx-partition stationarity | +2.60% / +0.11% | **23.6** | +2.27% / +0.09% | **25.2** | **PROMOTE** |
| **i06** orientation part pruning | +14.00% / +0.75% | 18.7 | +18.52% / +1.29% | 14.4 | **IMPROVE** |
| i01 tx-type saturation exit | +4.27% / +1.22% | 3.5 | +5.05% / +0.88% | 5.7 | discard |
| i07 RD-density termination | +0.22% / +0.30% | 0.7 | +2.84% / +0.76% | 3.7 | discard |
| i08 DRL dispersion budget | −0.45% / +0.04% | — | +0.91% / −0.01% | — | discard |
| i04 sub-pel curvature gate | −1.31% / +0.11% | — | +0.05% / −0.03% | — | discard |
| i10 adaptive ME range | −0.14% / −0.04% | — | −0.71% / −0.20% | — | discard |
| i02 IST sparse restore | −2.34% / **0.00%** | — | +0.41%¹ / 0.00% | — | discard |
| i03 PMC arena alloc | −2.50% / **0.00%** | — | +0.07%¹ / 0.00% | — | discard |
| i05 full-pel memo | −1.39% / **0.00%** | — | −1.01%¹ / 0.00% | — | discard |

¹ partial run (~89%).

**i09 is finished work.** It clears the bar on both classes. Scope it to
Speed 4 — A2's 25.2 would also meet the Speed-3 bar of 25, but A1's 23.6 would
not, and the bar must hold on both.

**On i08 and i04's "∞ ratio" on A2:** those come from BD-rates of −0.01% and
−0.03%, which is a rounding artifact dividing a near-zero speedup by a near-zero
quality change. They are not win-wins. Both are slower on A1, which is the real
signal.

---

## 2. The result that should decide the next round

Not any single row above — the combination arithmetic.

All ten patches together give **+20.34% / +2.50% BD (ratio 8.1)** on A1 and
**+24.00% / +3.45% (7.0)** on A2. Back i06 out of those numbers (speedups
compound multiplicatively, BD-rate adds):

```
the other nine, A1:   ~7.4% speed for ~1.75% BD   →  ratio ~4.2
the other nine, A2:   ~6.7% speed for ~2.16% BD   →  ratio ~3.1
```

**Nine patches are collectively buying about a third of i06's speedup at more
than twice its quality cost.** The all-10 arm is i06 plus ballast, and its poor
ratio says nothing about i06 itself. Running all-10 again would spend a CTC slot
re-measuring that dilution.

One finding from those runs is worth keeping: the speedup **rises at slower
presets** — +30.74% at Speed 2 against +20.34% at Speed 4 on A1, for essentially
unchanged BD-rate. These heuristics prune redundancy that only exists in deeper
searches. The bars rise faster than the ratio does, so it does not rescue the
set, but it is the right place to aim future pruning work.

---

## 3. i06: diagnosis, and why the rework is not just a weaker knob

i06 is the only patch with real magnitude. To clear the bar at unchanged speed:

```
A2:  BD 1.29% → 0.926%   (−28%)     ← binding
A1:  BD 0.75% → 0.700%   (−6.7%)
```

The diagnostic that shaped the fix: **A2 scored worse than A1 while pruning
more.** Uniform over-pruning would have cost both classes roughly alike. A
longer 33-frame GOP suffering disproportionately is instead the signature of a
bad partition choice *persisting*, because later frames predict from it. That
points the fix at *which frames* get pruned, not at how hard.

So `patches/0006b-orientation-pruning-frame-aware.patch` makes two targeted
changes rather than turning the threshold down:

1. **Absolute variance floor.** The orientation test was a pure ratio:
   `var_cols * anisotropy < var_rows`. On a flat block both variances are
   single digits and the ratio is noise, so `var_rows=8, var_cols=1` triggered a
   prune on no evidence at all. Flat blocks settle on `PARTITION_NONE` quickly
   regardless, so refusing to prune them should return BD-rate at very little
   speed cost. I expect the best return of the two.
2. **Frame-aware evidence bar.** Pruning disabled on key frames and the top ARF
   layer, doubled in strictness one layer below, unchanged on the leaf frames
   nothing predicts from.

It builds and encodes. Both thresholds (`PART_PROFILE_MIN_VAR = 64`, the
layer-depth cutoffs) are first principled guesses and want a sweep.

**A weakness I have not fixed.** The profile is measured on the **source** only.
For inter blocks it is the *residual* that determines whether a cut pays, and a
strongly structured block that is well predicted has a flat residual. That makes
the heuristic weakest exactly where A2 spends most of its frames. Gating on a
prediction-aware signal is the deeper fix; the two changes above are the cheap
ones. If 0006b falls short, that is where I would go next rather than continuing
to tune thresholds.

---

## 4. What I got wrong, and what changed because of it

This matters more than any single patch, so I would rather state it plainly than
bury it.

**The round-1 screening could not resolve the effects it reported.** Wall clock,
shared host, 5 reps, one 416x240 clip, 4 frames, `--cpu-used=4`:

```
noise floor            2.38% (1σ)
min detectable effect  3.47% (95%, n=5)
```

Six of the ten "speedups" I reported — i02 1.3%, i03 1.2%, i04 0.5%, i05 1.2%,
i08 1.9%, i10 2.1% — were **below the smallest effect that design could
resolve.** They were not small wins; they were non-measurements. My two datasets
also contradicted each other on seven of ten patches. CTC has now confirmed the
pessimistic reading: i04 and i10 are slowdowns, and the three bit-exact patches
are slower at 4K.

Three changes came out of that, all in this repo:

- **`experiments/bin/screen_timing.py`** reports a 95% CI and the minimum
  detectable effect, and refuses to call a sub-noise difference a win.
- **`experiments/bin/bitexact.sh`** proves a reuse-class patch changes no encode
  decision. It called i02/i03/i05's **0.00% BD-rate correctly, in 25 minutes,
  before the CTC round returned.** That is the tier working as intended.
- **`experiments/README.md`** sets the ordering: prove what can be proven,
  measure cost deterministically, measure decision regret, and only then spend a
  CTC slot on a question nothing cheaper can answer.

**Why the bit-exact three failed is a systematic lesson, not three accidents.**
All were designed against 416x240 intuitions about what is expensive, and 4K
inverts them: i05 pays a memo lookup on every call and the MV field is too
diverse for the hit rate to repay it; i03 replaced many small allocations that
fit in cache with one large arena that does not; i02's sparse-restore
bookkeeping loses to a bulk clear once blocks are large and dense. **Future
ideas should be sanity-checked at 4K before they are written, not after.**

---

## 5. What I recommend for the next round

Three arms, not ten:

| Arm | Purpose |
|---|---|
| **i09 alone, Speed 3** | Confirm the promote. A2 already meets the Speed-3 bar; this checks whether A1 does. If yes its scope widens. |
| **i06b alone, Speed 4** | The whole question. Did the two changes buy the 28% A2 BD reduction, and at what speed cost? |
| **i06b + i09, Speed 4** | The realistic shipping combination. Estimated from round 1 at ~18.9 (A1) / ~14.8 (A2) with the *old* i06. |

Do **not** re-run all-10. Its result is already explained.

Two things to check before the run:

- **Confirm the base.** Your anchor was `d6b40b7893`, but `av2-enc` has since
  taken *"Implement non-RD partition evaluation for real-time mode (#5236)"*,
  which adds 187 lines to `av2/encoder/partition_search.c` — the file i06 and
  i06b patch. The patches still *apply*, which is not the same as still being
  correct. Run `bin/check-rot.sh` and re-run `experiments/bin/bitexact.sh` on
  the new base before comparing to these numbers.
- **Report per-sequence BD-rate spread**, not just the class mean. A good
  average hiding one bad sequence is a regression risk.

---

## 6. Honest expected value

I would rather set expectations correctly than sound confident.

- **i09 is real and small.** ~2.3–2.6%. It will not change anyone's day, but it
  passes and it is done.
- **i06b is the whole enterprise.** If it clears the bar you have a 14–18%
  Speed-4 feature, which is significant. If it lands short — say ratio 17 — the
  choice is a deeper prediction-aware rework or dropping it.
- **My prior is genuinely uncertain,** maybe even odds. The variance floor
  targets prunes made on no evidence, which should be nearly free; the frame
  gate targets propagation, which the A1/A2 gap supports. But I inferred that
  mechanism from two data points, and the honest test is the run.

The broader read: ten speculative heuristics produced one pass and one
near-miss. That hit rate is not unusual for this kind of work, and it is exactly
why the cheap tiers matter — the goal is to spend CTC slots only on candidates
that have already survived something cheaper.

---

## 7. What I can build next

In rough order of value:

1. **Threshold sweep for 0006b.** Measure prune rate and decision regret per
   setting locally, so the operating point is chosen before the CTC slot rather
   than one guess per round. Most useful thing I can do right now.
2. **Tier-2 decision-regret instrumentation.** Run the full baseline search so
   the bitstream is unchanged, while recording what the heuristic *would* have
   chosen. Gives `Σregret/ΣRD` and `skipped/total` per decision site with zero
   run-to-run variance, one encode per (clip, QP). A cheap necessary condition:
   high regret kills a patch outright, low regret still needs CTC.
3. **Tier-1 instruction counting on your server.** `perf` is absent in my
   container but your framework already has `use_perf_util: true`. This is what
   should have caught the six non-measurements.
4. **Prediction-aware i06**, if 0006b lands short.

Say which and I will start.
