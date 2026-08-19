# AV2 expanded standalone speed-patch report

**[Validated] Anchor:** `fe1bfdee5427ea2e01149c5ebce904084a93ba79`  
**[Validated] Evidence snapshot:** `avm-patches` commit `d2b5df05ee8a547730a2ff6aa69c29369649465d`  
**[Implemented] Scope:** 14 standalone patches; no combined multi-feature patch is included  
**[Decision] Revised screen:** a repeatable speedup of roughly 2% is useful; 5% is no longer a hard cutoff  
**[Decision] Date:** 2026-08-18

## Claim labels

- **[Measured]** is copied from the supplied A1/A2 CTC or Cloud EDA reports.
- **[User result]** records a result or selection stated by the user when the exact table was not present locally.
- **[Derived]** is arithmetic or follows directly from inspected code.
- **[Implemented]** describes an accompanying patch.
- **[Validated]** describes an application, compile, build, or smoke check; it is not a performance result.
- **[Decision]** is the selection rule used for this package.
- **[Unknown]** identifies information that the available evidence does not establish.
- **[猜测]** is an unmeasured prediction.

## Revised decision

- **[Decision]** The old 5% cutoff was too coarse for mature encoder work because it discarded independently useful 2–4% changes.
- **[Decision]** A1 and A2 remain separate acceptance checks; an average does not hide a slower or materially lossy class.
- **[Decision]** “No loss” is interpreted strictly in the result tables: measured coding gains and values rounded around zero are separated from patches with a small positive BD-rate cost.
- **[Decision]** Previously accepted small-loss efficiency patches are retained, but they are not relabeled as lossless.
- **[Implemented]** Every patch in this package applies directly to the clean anchor.
- **[Implemented]** No patch requires another patch.
- **[Decision]** `P05` and `P13` are alternative transform-stationarity policies and must not be stacked.
- **[Decision]** The evaluated R3-04 arm formerly packaged as `P07` has been removed.
- **[Unknown]** The unevaluated patches do not yet have A1/A2 timing or BD-rate results.

## Evaluation-status audit

- **[Measured]** `P01`–`P04` have exact-anchor A1/A2 CTC results.
- **[Measured]** The original 0009b policy underlying `P05` has A1/A2 CTC results.
- **[User result]** `P06` was evaluated by the user and selected over 0006f.
- **[Measured]** R3-04, formerly `P07`, measured A1 `+1.80% / +0.22%` and A2 `+2.09% / -0.05%`.
- **[Decision]** R3-04 fails the current class-by-class “roughly 2% without loss” screen because A1 is below 2% and has positive YUV BD-rate.
- **[Implemented]** R3-04/`P07` is therefore absent from this revision.
- **[Measured]** `P08` has proxy work-counter evidence but no full A1/A2 CTC result for its all-context policy.
- **[Unknown]** `P09`–`P15` do not have full A1/A2 results for the exact policies in those patch files; measured parent features or endpoint policies are not equivalent to evaluating the patches themselves.

## Patch index

| ID | Preset | Mechanism | Evidence status | Speed / quality evidence | Disposition |
|---|---:|---|---|---|---|
| `P01` | 3 | TX-statistics pruning level 1 | **[Measured]** Exact-anchor CTC | **[Measured]** A1 `+6.55% / +0.15%`; A2 `+5.68% / +0.22%` | **[Decision]** Retain as a measured small-loss speed patch |
| `P02` | 3 | DC-block predictor level 1 | **[Measured]** Exact-anchor CTC | **[Measured]** A1 `+3.39% / -0.01%`; A2 `+2.76% / +0.01%` | **[Decision]** Highest-confidence revised-threshold patch |
| `P03` | 3 | Restore smooth intra modes | **[Measured]** Exact-anchor CTC | **[Measured]** A1 `+1.77% / -1.28%`; A2 `+0.72% / -0.88%` | **[Decision]** Retain as a measured Pareto repair despite sub-2% speed |
| `P04` | 2 | CCSO BO-first ordering | **[Measured]** Exact-anchor CTC | **[Measured]** A1 `+0.64% / -0.14%`; A2 `+1.61% / -0.10%` | **[Decision]** Retain as a measured Pareto repair despite sub-2% speed |
| `P05` | 4 | Lazy residual-stationarity pruning, fixed margin 2 | **[Measured]** Original 0009b CTC; **[Validated]** current port | **[Measured]** Original 0009b: A1 `+4.01% / +0.15%`; A2 `+3.57% / +0.07%` | **[Decision]** Retain as the measured stationarity operating point |
| `P06` | 4 | Size-graded orientation partition pruning, 0006e | **[User result]** Chosen over 0006f for the better tradeoff | **[Unknown]** Exact A1/A2 values were not present in the retrieved files | **[Decision]** Retain because it is the user-selected 0006 line |
| `P08` | 4 | Top-2 intra shortlist in all three applicable paths, R4-01 | **[Measured]** R3-04 parent; **[Measured]** proxy counters | **[Measured]** Versus R3-04 on Paris: TX-type calls `-3.29%`, TX RD evaluations `-1.98%`, byte-identical output | **[Decision]** Retain because the exact all-context policy is not yet disproven |
| `P09` | 2 | Frame-aware CCSO continuation tolerance | **[Measured]** Parent feature; **[Validated]** build/smoke | **[Measured]** Removing current CCSO early termination raises time to A1 `138.00%`, A2 `124.14%`; **[Unknown]** stronger-tolerance effect | **[Decision]** Retain current candidate |
| `P10` | 2 | Higher exhaustive-MV threshold on natural-content leaf frames | **[Measured]** Parent feature; **[Validated]** compile | **[Derived]** Current feature effect is A1 `5.43%`, A2 `8.02%` by the conventional denominator; **[Unknown]** incremental effect | **[Decision]** Retain current candidate |
| `P11` | 1 | Promote CCSO cost termination to Speed 1 | **[Measured]** Speed-2 parent feature; **[Validated]** compile | **[Derived]** Parent effect is A1 `27.54%`, A2 `19.45%`; **[Unknown]** Speed-1 effect | **[Decision]** Retain when Speed 1 is in scope |
| `P12` | 1 | Disable extended partitions only on natural-content leaf frames | **[Measured]** Speed-2 parent feature; **[Validated]** compile | **[Derived]** All-frame parent effect is A1 `15.80%`, A2 `18.65%`; **[Unknown]** guarded Speed-1 effect | **[Decision]** Retain when Speed 1 is in scope |
| `P13` | 4 | Margin 2 on reference layers, margin 1 on deeper leaf layers | **[Measured]** Two endpoint policies; **[Validated]** build | **[Measured]** Margin 2: `4.01%/3.57%`; margin 1: `4.40%/4.71%` on A1/A2; **[Unknown]** hybrid result | **[Decision]** Restored because both endpoints exceed the revised speed threshold |
| `P14` | 1 | Promote WienerNS zero-refinement to Speed 1 | **[Measured]** Speed-2 parent feature; **[Validated]** compile | **[Derived]** Parent effect is A1 `22.90%`, A2 `6.76%`, with reported losses `0.12%/0.08%`; **[Unknown]** Speed-1 effect | **[Decision]** Restored because only the old 5% prediction screen excluded it |
| `P15` | 1 | Promote the measured exhaustive-MV threshold to Speed 1 | **[Measured]** Speed-2 parent feature; **[Validated]** compile | **[Derived]** Parent effect is A1 `5.43%`, A2 `8.02%`, with reported losses `0.15%/0.09%`; **[Unknown]** Speed-1 effect | **[Decision]** Restored because only the old 5% prediction screen excluded it |

## What changed from the strict package

- **[Implemented]** `P13` is the previously rejected frame-aware transform-stationarity hybrid.
- **[Implemented]** `P14` is the previously rejected Speed-1 WienerNS promotion.
- **[Implemented]** `P15` is the previously rejected Speed-1 exhaustive-MV promotion.
- **[Implemented]** `P08` retains the unevaluated Round-4 all-context extension as a standalone candidate.
- **[Implemented]** The evaluated R3-04/`P07` patch has been removed.
- **[Implemented]** `P01`–`P06` retain the earlier measured or user-selected standalone patches.
- **[Implemented]** `P09`–`P12` retain the four candidates from the immediately preceding standalone package.

## Critical interpretation of the evidence

### Measured near-lossless or coding-gain lane

- **[Measured]** `P02` is faster by `3.39%` on A1 and `2.76%` on A2, while the reported YUV changes round to `-0.01%` and `+0.01%`.
- **[Unknown]** The supplied report does not publish uncertainty beyond the displayed precision, so `+0.01%` is not proof of literal zero loss.
- **[Measured]** `P03` and `P04` improve reported BD-rate and are faster on both classes.
- **[Decision]** `P03` and `P04` remain useful even though their speedups are below 2%, because each is a measured Pareto improvement.

### Measured small-loss speed lane

- **[Measured]** `P01` and the original `P05` operating point deliver more than 3.5% speed on each class with small positive YUV BD-rate.
- **[Decision]** These patches are retained as efficiency options, not described as lossless.

### Restored candidates

- **[Measured]** The fixed-margin stationarity endpoints both exceed 3.5% speed on A1 and A2.
- **[猜测]** `P13` should remove at least as much transform-partition search work as margin 2 on deeper layers, but changed decisions can make total runtime and BD-rate non-monotonic.
- **[Measured]** The Speed-2 WienerNS and exhaustive-MV mechanisms have effects above 6.7% on their binding measured classes.
- **[猜测]** `P14` and `P15` have credible room to exceed 2% at Speed 1 even if their contribution is diluted by the larger Speed-1 total-time denominator.
- **[Unknown]** Promotion to another preset can change both the candidate population and the quality cost, so the Speed-2 values are not Speed-1 predictions.

## Patch details

### P01 — Speed-3 TX-statistics pruning

- **[Implemented]** Enables conservative `prune_tx_type_using_stats = 1` at Speed 3 for the existing large-resolution path.
- **[Measured]** The exact-anchor CTC result is `+6.55% / +0.15%` on A1 and `+5.68% / +0.22%` on A2.
- **[Decision]** Keep as an already proven speed patch with a disclosed coding cost.

### P02 — Speed-3 DC-block prediction level 1

- **[Implemented]** Promotes only level 1, not the more aggressive winner-stage level 2.
- **[Measured]** It produces a class-robust 2.76–3.39% speedup with reported YUV changes near zero.
- **[Decision]** This is the first patch to rebaseline if the objective is reliable speed with no measured material loss.

### P03 — restore smooth intra

- **[Implemented]** Restores `SMOOTH_PRED`, `SMOOTH_V_PRED`, and `SMOOTH_H_PRED` at Speed 3.
- **[Measured]** The CTC result improves YUV BD-rate by `1.28%` on A1 and `0.88%` on A2 while also reducing time.
- **[Unknown]** The causal explanation for the timing improvement was not established by counters.

### P04 — CCSO BO-first ordering

- **[Implemented]** Tries the cheaper band-offset-only family first when CCSO cost termination is enabled.
- **[Measured]** The exact-anchor result is faster and improves reported YUV BD-rate on both classes.
- **[Decision]** Keep as a low-magnitude measured Pareto win.

### P05 and P13 — transform-stationarity alternatives

- **[Implemented]** `P05` scopes the margin-2 residual-stationarity gate to Speed 4 and computes it only after cheap eligibility gates.
- **[Validated]** `P05` compiles as the affected `tx_search.c` translation unit against the current anchor configuration.
- **[Measured]** The original 0009b policy measured `+4.01% / +0.15%` on A1 and `+3.57% / +0.07%` on A2.
- **[Implemented]** `P13` keeps margin 2 on hierarchy depth 0–2 and uses margin 1 only on deeper layers.
- **[Decision]** Run `P05` and `P13` as separate baseline comparisons.
- **[Decision]** Do not apply both.

### P06 — orientation partition pruning 0006e

- **[Implemented]** Uses source-profile anisotropy, frame-depth protection, and block-size-graded evidence.
- **[User result]** The user selected 0006e after testing it against 0006f because 0006e had the better tradeoff.
- **[Unknown]** The exact per-class values were not in the local reports, so this report does not invent them.

### P08 — all-context top-2 intra candidate

- **[Measured]** Its R3-04 parent measured A1 `+1.80% / +0.22%` and A2 `+2.09% / -0.05%`.
- **[Decision]** The measured parent is removed because it fails the current class-by-class screen.
- **[Implemented]** `P08` adds the remaining inter-frame intra path and contains all three top-2 sites so it applies independently to the clean anchor.
- **[Measured]** On the Paris proxy, `P08` and R3-04 produced byte-identical output while `P08` reduced TX-type calls by `3.29%` and TX RD evaluations by `1.98%` relative to R3-04.
- **[Unknown]** The incremental wall-time effect was inside proxy noise, and `P08` has no full A1/A2 CTC result.
- **[Decision]** Retain `P08` for one standalone evaluation; remove it if it repeats R3-04's sub-threshold A1 tradeoff.

### P09 and P10 — Speed-2 refinements

- **[Implemented]** `P09` preserves the current CCSO tolerance on intra/reference layers and uses a 1% continuation requirement only on deeper inter layers.
- **[猜测]** `P09` can exceed 2% because the parent early terminator is a large measured hotspot, but its incremental threshold response is unknown.
- **[Implemented]** `P10` raises the natural-content exhaustive-MV threshold from `1<<26` to `1<<28` only on nonboosted Speed-2 frames.
- **[猜测]** `P10` can exceed 2% if leaf frames still enter the mesh fallback often enough.

### P11, P12, P14, and P15 — Speed-1 promotions

- **[Implemented]** Each patch promotes or guards one existing mechanism; none contains another promotion.
- **[Decision]** Skip these four when the project scope is only Speeds 2–4.
- **[Decision]** When Speed 1 matters, test `P14` first, `P11` second, `P12` third, and `P15` fourth.
- **[Derived]** That order follows the measured parent-feature headroom on the binding class, not a target-preset measurement.

## Recommended standalone EDA order

| Priority | Patch | Comparison | Reason |
|---:|---|---|---|
| 1 | `P02` | **[Decision]** Clean anchor vs P02 | **[Measured]** Already clears roughly 2% on both classes with near-zero rounded YUV change |
| 2 | `P05` | **[Decision]** Clean anchor vs P05 | **[Measured]** Original margin-2 result is 3.57–4.01% with small loss |
| 3 | `P08` | **[Decision]** Clean anchor vs P08 | **[Measured]** Extends the borderline R3-04 win and removes more measured TX work |
| 4 | `P13` | **[Decision]** Clean anchor vs P13 | **[Measured]** Both threshold endpoints exceed the relaxed speed target |
| 5 | `P09` | **[Decision]** Clean anchor vs P09 | **[Measured]** CCSO early termination has the largest relevant parent headroom |
| 6 | `P10` | **[Decision]** Clean anchor vs P10 | **[Measured]** Exhaustive-MV parent feature is useful on both classes |
| 7 | `P14` | **[Decision]** Clean anchor vs P14 at Speed 1 | **[Measured]** Highest Speed-1 promotion headroom after class binding |
| 8 | `P11`, `P12`, `P15` | **[Decision]** Three separate clean-anchor runs | **[Decision]** Optional Speed-1 queue |

- **[Decision]** `P01`, `P03`, `P04`, and `P06` need rebaselining only if the current anchor or test contract has changed since their prior evaluation.
- **[Decision]** Do not submit a combined arm from this package.

## Keep criteria under the revised threshold

- **[Decision]** Require positive timing movement on both A1 and A2.
- **[Decision]** Treat approximately 2% per class as a useful target, not a mathematical cliff.
- **[Decision]** Require repeated or high-accuracy timing when a result is within normal run noise.
- **[Decision]** For a no-loss claim, require full-precision aggregate and per-sequence BD-rate rather than a displayed `0.00%`.
- **[Decision]** Inspect per-sequence tails before accepting a small aggregate loss.
- **[Decision]** Preserve measured Pareto repairs even when speed is below 2%.
- **[Decision]** Keep each test baseline-versus-one-patch; do not infer combined behavior by adding percentages.

## Exclusions retained after lowering the threshold

- **[Decision]** Combination patches remain excluded because the user requested standalone attribution.
- **[Measured]** 0817 adaptive-TCQ and compound-backoff patches slow the encoder, so the lower speed threshold does not rescue them.
- **[Measured]** Claude patches 0001, 0007, 0008, 0010, and the bit-exact micro-optimizations were lossy, slower, inconsistent, or neutral in the supplied CTC results.
- **[Measured]** 0009c buys only modest extra speed over 0009b while increasing measured loss to `0.30%` on A1 and `0.40%` on A2.
- **[Decision]** 0009c remains excluded because the new request favors reliable speed without loss, not looser pruning at a worse tradeoff.
- **[User result]** 0006f remains excluded because the user preferred 0006e after direct evaluation.
- **[Measured]** R3-04/`P07` gives only `1.80%` speedup with `+0.22%` YUV BD-rate on A1.
- **[Decision]** R3-04/`P07` is excluded because it fails the current per-class speed-and-loss screen.
- **[Measured]** R3-02 and R3-05 are slow in full CTC.
- **[Measured]** R4-02 has an unresolved incremental timing effect and was supplied either as a dependency delta or as a cumulative two-gate patch.
- **[Decision]** R4-02 remains excluded because neither form satisfies the current standalone-attribution requirement.
- **[Measured]** R4-03 targets quality recovery on a different PR anchor rather than a clean-anchor speed feature.
- **[Decision]** R4-00 remains instrumentation only.
- **[Validated]** The earlier Round-2 micro-patches had build and one-frame checks but no A1/A2 timing.
- **[Decision]** They are not called valid 2% candidates without a measured signal.

## Validation

- **[Validated]** All 14 patch files pass `git apply --check` independently against `fe1bfdee5427ea2e01149c5ebce904084a93ba79`.
- **[Validated]** `P05` passes a current-anchor translation-unit compile.
- **[Validated]** `P09` previously passed a full Release `avmenc` build and smoke encode on the same anchor.
- **[Validated]** `P13` previously passed a full Release `avmenc` build on the same anchor.
- **[Validated]** `P10`, `P11`, `P12`, `P14`, and `P15` previously passed affected-translation-unit compilation on the same anchor.
- **[Validated]** `P01`–`P04` were encoded in the exact-anchor Cloud EDA runs.
- **[Validated]** The original `P06`, 0009b source for `P05`, and `P08` were built and encoded in their source studies.
- **[Unknown]** This packaging pass did not run new A1/A2 CTC jobs.
- **[Unknown]** Apply and compile checks do not establish speed, coding efficiency, conformance breadth, or thread-safety.

## Files

- **[Implemented]** `patches/P01-s3-tx-stat-pruning-level1-fe1bfdee.patch`
- **[Implemented]** `patches/P02-s3-dc-block-pred-level1-fe1bfdee.patch`
- **[Implemented]** `patches/P03-s3-restore-smooth-intra-fe1bfdee.patch`
- **[Implemented]** `patches/P04-s2-ccso-bo-first-fe1bfdee.patch`
- **[Implemented]** `patches/P05-s4-tx-stationarity-margin2-fe1bfdee.patch`
- **[Implemented]** `patches/P06-s4-orientation-size-graded-0006e-fe1bfdee.patch`
- **[Implemented]** `patches/P08-s4-intra-top2-all-contexts-r4-01-fe1bfdee.patch`
- **[Implemented]** `patches/P09-s2-frame-aware-ccso-tolerance-fe1bfdee.patch`
- **[Implemented]** `patches/P10-s2-leaf-exhaustive-mv-threshold-fe1bfdee.patch`
- **[Implemented]** `patches/P11-s1-promote-ccso-early-termination-fe1bfdee.patch`
- **[Implemented]** `patches/P12-s1-leaf-disable-ext-partitions-fe1bfdee.patch`
- **[Implemented]** `patches/P13-s4-frame-aware-tx-stationarity-hybrid-fe1bfdee.patch`
- **[Implemented]** `patches/P14-s1-promote-wienerns-zero-refine-fe1bfdee.patch`
- **[Implemented]** `patches/P15-s1-promote-exhaustive-mv-threshold-fe1bfdee.patch`
