# AV2 0819 standalone speed research and candidate patches

**[Validated] Baseline anchor:** `ea89c216c629019f586ced5a701e56200169e012`  
**[Measured] Evidence source:** `shared/0818_2_eda_evaluation_and_performance_report.md` and the related reports in `avm-patches`  
**[Implemented] Deliverable:** six new standalone patches, each based directly on the clean anchor  
**[Decision] Scope:** no combinations and no reissued, already-evaluated patch  
**[Decision] Date:** 2026-08-19

## Claim labels

- **[Measured]** A value copied from a supplied A1/A2 report.
- **[Derived]** A statement that follows directly from inspected source or arithmetic.
- **[Implemented]** A property of the supplied code.
- **[Validated]** A check executed on the supplied artifact.
- **[Decision]** A selection or evaluation rule used in this report.
- **[Unknown]** A result that the available evidence does not establish.
- **[猜测]** An unmeasured prediction or hypothesis.

## 1. Executive result

- **[Measured]** The newest EDA report confirms four class-robust speed mechanisms: Speed-4 transform stationarity (`P05`, `+7.68%/+8.34%` A1/A2), Speed-4 orientation pruning (`P06`, `+3.05%/+2.89%`), Speed-4 all-context intra top-2 (`P08`, `+7.81%/+7.02%`), and Speed-1 CCSO early termination (`P11`, `+33.32%/+11.42%`).
- **[Measured]** Speed-1 WienerNS zero-refinement (`P14`) is asymmetric: `+4.62%` on A1 but only `+0.93%` on A2.
- **[Measured]** The same report rejects the stronger Speed-2 CCSO tolerance (`P09`), leaf exhaustive-MV threshold (`P10`), and leaf extended-partition disable (`P12`), because every one slowed both A1 and A2.
- **[Measured]** Separate EDA confirms Speed-3 DC prediction level 2 at `+5.22%/+1.99%` with approximately neutral aggregate YUV, Speed-2 TX-statistics pruning at `+4.02%/+4.46%` with `+0.16%/+0.13%` YUV, and Speed-3 warp diamond at only `+0.54%/+0.37%`.
- **[Decision]** This package therefore extends only measured winners or measured high-headroom mechanisms into adjacent presets, except for two deliberately conservative intra-shortlist variants.
- **[Decision]** Tested failures, the sub-1% warp promotion, quality-only patches, and combination arms are excluded.
- **[Unknown]** None of the six exact policies below has new A1/A2 EDA data yet.

## 2. New candidate index

| Priority | Patch | Target | Single mechanism | Evidence basis | Expected result |
|---:|---|---:|---|---|---|
| 1 | `N03` | Speed 3 | Residual-stationarity transform-partition pruning, margin 2 | **[Measured]** The same policy at Speed 4 gives `+7.68%/+8.34%`, with `+0.14%/+0.13%` YUV | **[猜测]** Roughly `+3%` to `+8%`; highest chance in this set of clearing 2% on both classes |
| 2 | `N01` | Speed 1 | Promote frame TX-statistics pruning | **[Measured]** At Speed 2 it gives `+4.02%/+4.46%`, with `+0.16%/+0.13%` YUV | **[猜测]** Roughly `+2%` to `+5%`; small positive BD-rate remains possible |
| 3 | `N02` | Speed 2 | Promote conservative DC-block prediction level 1 | **[Measured]** At Speed 3 it gives `+3.39%/+2.76%`, with `-0.01%/+0.01%` YUV | **[猜测]** Roughly `+1.5%` to `+4%`; best near-lossless candidate |
| 4 | `N05` | Speed 4 | Top-2 intra shortlist only on non-boosted frames | **[Measured]** All-context top-2 gives `+7.81%/+7.02%`, with `+0.41%/+0.19%` YUV | **[猜测]** Roughly `+3%` to `+6%`, with less loss than the measured all-context policy |
| 5 | `N04` | Speed 3 | Size- and hierarchy-graded orientation pruning of HORZ/VERT | **[Measured]** The effective policy at Speed 4 gives `+3.05%/+2.89%`, with `+0.11%/+0.09%` YUV | **[猜测]** Roughly `+1.5%` to `+4%`; class robustness is plausible but not established |
| 6 | `N06` | Speed 3 | Reduce the full intra model-RD pool from four to three | **[Measured]** Speed-4 top-2 has large timing headroom; the exact Speed-3 top-3 point is unmeasured | **[猜测]** Roughly `+1.5%` to `+4%`; it may miss the 2% target |

- **[Decision]** The numeric ranges are screening estimates, not performance claims.
- **[Decision]** The estimates must not be added together because each patch is intended for an independent clean-anchor run.

## 3. Evidence audit: what was retained and what was retired

### Retained as evidence, not repackaged

- **[Measured]** `P05`, `P06`, `P08`, `P11`, and `P14` have completed A1/A2 results in the 0818_2 report.
- **[Measured]** Claude `0013` and `0015` have completed A1/A2 results for Speed-3 DC prediction level 2 and Speed-2 TX-statistics pruning.
- **[Decision]** Those exact patches are not duplicated in this package.
- **[Derived]** `N01` and `N02` are new target-preset operating points, not reruns of `0015` or the prior Speed-3 DC arms.
- **[Derived]** `N03` and `N04` move successful Speed-4 mechanisms to Speed 3 while guarding the code with `speed == 3`, so the measured Speed-4 preset is unchanged.

### Retired from the research queue

- **[Measured]** `P09` slows A1/A2 by `2.33%/1.41%`; stronger CCSO-tolerance variants are not proposed again.
- **[Measured]** `P10` slows A1/A2 by `1.73%/1.59%`; exhaustive-MV threshold variants are not proposed again.
- **[Measured]** `P12` slows A1/A2 by `1.45%/1.11%`; guarded extended-partition disable variants are not proposed again.
- **[Measured]** Speed-3 warp diamond produces only `0.37%` to `0.54%`; a further warp-search promotion is below the current approximately-2% objective.
- **[Measured]** The earlier adaptive-TCQ and compound-backoff arms are slower, even though they improve coding efficiency.
- **[Decision]** No combination patch is included, even when two mechanisms target different subsystems.

## 4. Candidate details

### N01 — Speed-1 frame TX-statistics pruning

- **[Implemented]** `N01` sets `prune_tx_type_using_stats = 1` only when `speed == 1` and the shorter frame dimension is at least 480 pixels.
- **[Derived]** The patch reuses the current per-update-type probability table and thresholds; the code change itself is only a preset assignment.
- **[Measured]** The immediately adjacent Speed-2 operating point saves `4.02%` on A1 and `4.46%` on A2 for `+0.16%/+0.13%` YUV.
- **[猜测]** Speed 1 offers more transform candidates for the same frame-level shortlist to remove, but its larger total runtime can dilute the percentage contribution.
- **[猜测]** The likely failure mode is a BD-rate increase larger than at Speed 2, not added decision overhead.
- **[Decision]** Run this second because its parent signal is class-robust and the implementation is exceptionally small.

### N02 — Speed-2 conservative DC-block prediction

- **[Implemented]** `N02` sets `dc_blk_pred_level = 1` only at Speed 2.
- **[Derived]** Level 1 enables the existing mean/variance DC-only residual test in default and mode evaluation but leaves winner-mode evaluation unchanged; level 2 would also enable the winner stage.
- **[Measured]** Level 1 at Speed 3 saves `3.39%` on A1 and `2.76%` on A2, while reported YUV is `-0.01%/+0.01%`.
- **[Measured]** Level 2 at Speed 3 saves `5.22%` on A1 but only `1.99%` on A2, with reported aggregate YUV near zero.
- **[Decision]** Level 1 is selected for the first Speed-2 arm because its measured class floor is higher and it changes fewer evaluation stages.
- **[猜测]** The Speed-2 percentage may fall below 2% on one class because a preset promotion changes both the candidate population and the total-time denominator.

### N03 — Speed-3 residual-stationarity transform pruning

- **[Implemented]** `N03` ports the measured margin-2 residual-stationarity policy to `speed == 3` only.
- **[Implemented]** The residual is sampled into four row and four column strips; a partition cutting a stationary axis is skipped when the largest strip is no more than 1.5 times the mean.
- **[Implemented]** The residual walk is lazy and occurs only after existing legality and search-policy gates leave a non-`NONE` transform partition candidate.
- **[Measured]** At Speed 4, this policy saves `7.68%` on A1 and `8.34%` on A2 for `+0.14%/+0.13%` YUV.
- **[猜测]** Speed 3 should expose at least as much removable transform-partition work per qualifying block, but total runtime and changed RD paths prevent a monotonic guarantee.
- **[Decision]** This is the first EDA arm because it has the largest balanced parent timing signal.

### N04 — Speed-3 size-graded orientation pruning

- **[Implemented]** `N04` profiles row and column source means on at most a 32-by-32 sample lattice and prunes only the unsupported plain rectangular direction.
- **[Implemented]** The anisotropy threshold increases for 32-pixel and 64-pixel blocks and for low hierarchy depths; depth 0 is fully protected.
- **[Implemented]** The profile is computed lazily and only when at least one plain rectangular partition remains legal.
- **[Derived]** The clean anchor sets `disable_ext_partitions = true` for every speed at or above 2, so the extended-partition hooks in the historical 0006e source are inactive at the Speed-3 target.
- **[Implemented]** `N04` therefore ports only the effective HORZ/VERT path and omits inactive extended-partition plumbing.
- **[Measured]** The corresponding Speed-4 result is `+3.05%/+2.89%` with `+0.11%/+0.09%` YUV.
- **[猜测]** The profile overhead could consume more of the gain at Speed 3 if existing partition gates already remove most legal rectangles.

### N05 — Speed-4 non-boosted-frame intra top-2

- **[Implemented]** `N05` keeps the original four model-RD survivors on frames selected by the existing `frame_is_kf_gf_arf()` classifier and uses two survivors only on the remaining Speed-4 frames.
- **[Derived]** This is a quality-protected variant of `P08`; it does not contain `P08` as a dependency and applies directly to the clean anchor.
- **[Measured]** `P08` changes all contexts and saves `7.81%` on A1 and `7.02%` on A2, with `+0.41%/+0.19%` YUV.
- **[猜测]** Restoring the full pool on boosted frames should reduce propagation of a locally worse intra decision, while the more numerous non-boosted frames retain most of the timing opportunity.
- **[Unknown]** The supplied reports do not attribute `P08` timing or BD-rate by frame type, so the retained fraction cannot be calculated from the existing data.

### N06 — Speed-3 intra top-3

- **[Implemented]** `N06` reduces the full model-RD survivor pool from four to three only at Speed 3.
- **[Implemented]** Existing fast dry-pass and reused wet-pass limits remain one and two; no other mode or transform gate changes.
- **[Derived]** The patch is an intermediate operating point rather than a promotion of the all-context Speed-4 top-2 policy.
- **[猜测]** It has lower quality risk than top-2 but also the greatest risk in this package of landing below 2% speedup.
- **[Decision]** Run it last unless Speed-3 near-lossless changes are more valuable than larger Speed-4 gains.

## 5. Recommended standalone EDA matrix

| Order | Arm | Baseline | Preset | A1 | A2 | Primary question |
|---:|---|---|---:|---|---|---|
| 1 | `N03` | **[Decision]** clean `ea89c216` | 3 | **[Decision]** 17-frame RA | **[Decision]** 33-frame RA | **[Decision]** Does margin 2 remain above 2% per class at an acceptable loss? |
| 2 | `N01` | **[Decision]** clean `ea89c216` | 1 | **[Decision]** 17-frame RA | **[Decision]** 33-frame RA | **[Decision]** Does the Speed-2 TX-stat winner promote cleanly to Speed 1? |
| 3 | `N02` | **[Decision]** clean `ea89c216` | 2 | **[Decision]** 17-frame RA | **[Decision]** 33-frame RA | **[Decision]** Is the near-zero-loss DC gain still roughly 2% per class? |
| 4 | `N05` | **[Decision]** clean `ea89c216` | 4 | **[Decision]** 17-frame RA | **[Decision]** 33-frame RA | **[Decision]** How much of `P08` speed survives when boosted frames are protected? |
| 5 | `N04` | **[Decision]** clean `ea89c216` | 3 | **[Decision]** 17-frame RA | **[Decision]** 33-frame RA | **[Decision]** Does 0006e remain useful one preset slower after profile overhead? |
| 6 | `N06` | **[Decision]** clean `ea89c216` | 3 | **[Decision]** 17-frame RA | **[Decision]** 33-frame RA | **[Decision]** Is top-3 large enough to measure and small enough to stay near neutral? |

- **[Decision]** Every row is baseline versus one patch; do not stack rows.
- **[Decision]** Keep A1 and A2 as independent acceptance checks; do not let an average hide a weak or slower class.
- **[Decision]** Use high-accuracy timing and repeat any result close to 2% before calling it reliable.
- **[Decision]** For a no-loss claim, inspect full-precision aggregate and per-sequence results rather than values rounded to `0.00%`.
- **[Decision]** A small positive aggregate loss can still be considered separately as a speed/quality tradeoff, but it should not be described as lossless.

## 6. Validation and limitations

- **[Validated]** Every patch is a mail-formatted commit whose parent is `ea89c216c629019f586ced5a701e56200169e012`.
- **[Validated]** Every patch independently passes `git apply --check` against that clean anchor.
- **[Validated]** Every candidate worktree passes `git diff --check` before patch generation.
- **[Validated]** Patch statistics confirm that each file contains one mechanism and no previously evaluated patch or combination stack.
- **[Unknown]** This environment did not provide CMake or Ninja, so a full AVM build and encode smoke test were not run in this pass.
- **[Unknown]** Static apply checks do not establish compilation, bitstream conformance, thread determinism, coding efficiency, or encoder speed.
- **[Decision]** Run a normal release build and a short encode smoke test before launching each Cloud EDA arm.

## 7. Patch files

- **[Implemented]** `patches/N01-s1-tx-stats-ea89c216.patch`
- **[Implemented]** `patches/N02-s2-dc-pred-l1-ea89c216.patch`
- **[Implemented]** `patches/N03-s3-tx-stationarity-margin2-ea89c216.patch`
- **[Implemented]** `patches/N04-s3-orientation-size-graded-ea89c216.patch`
- **[Implemented]** `patches/N05-s4-nonboosted-intra-top2-ea89c216.patch`
- **[Implemented]** `patches/N06-s3-intra-top3-ea89c216.patch`

## 8. Source references

- **[Measured]** New EDA report: <https://github.com/chengchen-google/avm-patches/blob/main/shared/0818_2_eda_evaluation_and_performance_report.md>
- **[Measured]** Additional evaluated promotions: <https://github.com/chengchen-google/avm-patches/blob/main/shared/Claude_eda_report_patches_0013_to_0016.md>
- **[Measured]** Earlier feature tradeoff study: <https://github.com/chengchen-google/avm-patches/blob/main/shared/AV2_Speed_Feature_Tradeoff_Report.md>
