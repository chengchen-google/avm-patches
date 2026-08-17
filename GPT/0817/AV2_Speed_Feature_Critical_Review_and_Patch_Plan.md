# AV2 Speed-Feature Critical Review and Patch Plan

**Review date:** 2026-08-17  
**AVM anchor:** `fe1bfdee5427ea2e01149c5ebce904084a93ba79`  
**Input report:** [AV2 Speed Feature Tradeoff Report](https://github.com/chengchen-google/avm-patches/blob/main/shared/AV2_Speed_Feature_Tradeoff_Report.md)  
**Relationship to 0006e:** the patches in this package are independent deltas against the anchor and apply cleanly after `0006e-orientation-pruning-size-graded.patch`.

## Evidence labels

- `[Report]` — stated in the supplied report, but not independently reproducible from raw logs supplied with it.
- `[Code]` — verified in AVM source at the exact anchor.
- `[Recalc]` — recalculated from the report's published A1/A2 numbers.
- `[Inference]` — a technical conclusion drawn from the report and code.
- `[Unknown]` — the supplied evidence is insufficient to determine the claim.
- `[猜测]` — an unmeasured performance hypothesis.
- `[Recommendation]` — proposed next action, not a measured result.
- `[Validation]` — a local build, apply, or smoke-test result.

## 1. Executive decision

[Inference] The report is valuable as a hotspot map, but its headline conclusion that 21 of 101 features pass is not reliable enough for patch selection.

[Recalc] Using the correct relative-speed formula, enforcing the bar independently on A1 and A2, and refusing to classify rounded `0.00%` BD-rate entries as proven passes leaves **six demonstrable passes** in the published table, not 21.

[Inference] The report's four proposed algorithms should not be implemented as written:

| Proposal | Decision | Main reason | Best next step |
|---|---|---|---|
| DIP gradient-anisotropy gate | Reject as written | `[Code]` DIP already has a richer TFLite content/RD gate; the proposed two-gradient statistic is weaker and its projection is arithmetically inconsistent. | `[Recommendation]` Trace and calibrate the existing DIP gate before adding another classifier. |
| Block-level, EOB-gated TCQ | Reject as written | `[Code]` TCQ selection is sequence/frame signaled and EOB depends on the quantization path, making the proposed pre-gate circular without extra work or syntax. | `[Recommendation]` Test the existing normative frame-adaptive TCQ mode. Patch 0003 does this. |
| Smooth-intra SATD gate | Do not add the gate yet | `[Report]` simply restoring smooth intra improved reported BD-rate and had no consistent timing cost; AV2 has no mode named `PLANAR`. | `[Recommendation]` First test the minimal restoration in patch 0004. |
| MV-collinearity compound gate | Reject as written | `[Code]` a safer level-1 version of the current evidence gate already exists; MV collinearity does not imply predictor redundancy across references. | `[Recommendation]` Test level 1 with patch 0005 before inventing another gate. |

[Recommendation] If EDA capacity is tight, prioritize **0001 (Speed-3 TX-stat promotion)** and **0006 (CCSO BO-first warm start)**. Use a short timing pilot before full CTC. Patch 0004 is a quality/Pareto repair rather than a speed candidate. Patches 0002, 0003, and 0005 are second-tier experiments.

[猜测] Of the supplied candidates, the combination of 0001 and 0002 has the clearest path to exceeding 5% at Speed 3, but the report cannot establish additivity or guarantee that threshold.

[Recommendation] Do not benchmark patch 0007 first. It is an integration/build artifact containing every candidate and would destroy causal attribution.

## 2. Critical audit of the report methodology

### 2.1 The speed formula is wrong for the stated quantity

[Report] The baseline with the speed feature ON is normalized to 100, and `T_off` is the measured time after disabling the feature.

[Recalc] The report calls `T_off - 100` the feature's percentage speedup. That is a percentage-point increase in the slower branch's time, not the speedup of ON relative to OFF.

[Recalc] The correct relative speedup is:

\[
S_{\text{ON vs OFF}} = 100 \times \frac{T_{\text{off}} - 100}{T_{\text{off}}}.
\]

[Recalc] Example: test 4 reports A1 `T_off = 138.00`. The report calls this a 38.00% A1 saving; the true ON-vs-OFF saving is `27.54%`.

[Inference] This error increasingly overstates large features and therefore distorts both ranking and compliance ratios.

### 2.2 A1 and A2 must pass separately

[Report] The table averages A1 and A2 time and BD-rate before computing one ratio.

[Recommendation] Apply the required bar independently to A1 and A2. A feature that passes only after averaging can hide a class-specific failure, exactly the failure mode already observed in earlier patch evaluation.

### 2.3 Rounded zero is not evidence of infinite efficiency

[Report] Several entries with `0.00%` published BD-rate are assigned infinite ratios and marked PASS.

[Unknown] A displayed `0.00%` can be a small loss, a small gain, or measurement noise because the report supplies neither additional precision nor uncertainty intervals.

[Recommendation] Treat these entries as **precision-limited**, not passes. Retest them with full-precision per-sequence output and repeated timings.

### 2.4 OFF ablations are marginal and interaction-dependent

[Inference] Disabling one feature inside an already-pruned preset measures its marginal effect in that exact preset. It does not measure the feature's intrinsic effect, its value at another speed, or the sum of its effect with another patch.

[Inference] Search heuristics can change the path through later searches, so a negative or near-zero timing delta does not automatically mean the assignment is dead.

[Recommendation] Test promotions at their target speed and test combinations only after measuring their components.

### 2.5 The aggregate is not a workload-weighted speed result

[Report] The report uses a simple average of class-level percentages.

[Unknown] The report does not provide per-clip baseline seconds, repeated timing variance, or enough raw data to construct a runtime-weighted aggregate.

[Recommendation] Report A1 and A2 independently first; if a portfolio aggregate is needed, weight each clip by baseline wall time and publish both weighted and unweighted views.

### 2.6 “All speed features” is too broad

[Report] The 101 tests enumerate assignments in two good-quality setters in `speed_features.c`.

[Code] Later setters such as ERP can overwrite or duplicate assignments, and other speed-related logic exists outside those two setters.

[Inference] The experiment is an assignment-ablation sweep, not a complete map of every effective speed mechanism in the encoder.

### 2.7 Corrected demonstrable pass set

[Recalc] The table below keeps the report's sign-inverted BD-loss convention for comparability, uses the correct speed denominator, requires a positive published loss, and requires both classes to meet the preset bar.

| Test | Feature | Bar | A1 true speed / loss / ratio | A2 true speed / loss / ratio |
|---:|---|---:|---:|---:|
| 4 | `early_terminate_ccso_search_by_cost` | 30 | 27.54 / 0.35 / **78.7** | 19.45 / 0.37 / **52.6** |
| 10 | `disable_ext_partitions` | 30 | 15.80 / 0.43 / **36.8** | 18.65 / 0.35 / **53.3** |
| 11 | `exhaustive_searches_thresh` | 30 | 5.43 / 0.15 / **36.2** | 8.02 / 0.09 / **89.1** |
| 23 | `prune_2d_txfm_mode` | 30 | 2.02 / 0.05 / **40.4** | 0.69 / 0.02 / **34.3** |
| 28 | `wienerns_refine_iters` | 30 | 22.90 / 0.12 / **190.9** | 6.76 / 0.08 / **84.5** |
| 77 | `prune_tx_type_using_stats` | 20 | 4.64 / 0.18 / **25.8** | 4.69 / 0.03 / **156.3** |

[Inference] This is a conservative demonstrability filter, not proof that every excluded zero-loss entry is bad.

[Unknown] Test 101 (`dc_blk_pred_level = 2`) is promising, but its A2 BD-rate is rounded to `0.00%`; the published precision cannot prove its A2 ratio.

## 3. Full picture of the current speed-feature portfolio

### 3.1 High-confidence, high-leverage mechanisms

[Recalc] CCSO early termination, WienerNS refinement suppression, and extended-partition disabling are the largest class-robust measured mechanisms in the table after correcting the denominator.

[Inference] These mechanisms remove or terminate expensive outer searches, which is consistent with their much larger timing effects than micro-pruners.

[Recommendation] New work should improve candidate ordering, bounds, or reuse inside these hotspots rather than merely add more global tool disables.

### 3.2 Moderate but clean search pruning

[Recalc] Exhaustive-MV thresholding, 2D-transform pruning, and transform-statistics pruning clear both class bars with published nonzero losses.

[Inference] Test 77 is especially relevant to Speed 3 because it is close to 5% in both classes at Speed 4 while using only the conservative level 1.

### 3.3 Precision-limited candidates

[Report] Tests 76, 78, 79, 82, 84, 88–90, 100, and 101 contain rounded zero or mixed-sign BD-rate results.

[Unknown] Their ratios cannot be ranked reliably from two-decimal BD-rate output.

[Recommendation] Retest only candidates with a material timing signal. Test 101 qualifies; sub-0.5% timing entries do not justify full EDA unless they compose with an already planned patch.

### 3.4 Destructive or misconfigured shortcuts

[Recalc] Tests 34, 35, and 85 trade substantial quality for speed but miss their bars independently by a wide margin.

[Recalc] Tests 61 and 72 report large quality recovery when disabled without a consistent speed cost, making them candidates for restoration or for diagnosing a search-order bug.

[Inference] These results do not prove that DIP, TCQ, smooth modes, coefficient optimization, or compound prediction are inherently inefficient; they show that the current binary or aggressive policy is inefficient under the tested preset.

### 3.5 Inactive, overwritten, or subsumed assignments

[Code] Tests 1, 30, and 32 are resolution-guarded away on A1/A2.

[Code] `use_square_partition_only_threshold` is assigned repeatedly and then unconditionally overwritten with `BLOCK_LARGEST` at the end of the frame-size setter.

[Code] ERP logic later reassigns `simple_motion_search_split` and `simple_motion_search_early_term_none` at Speed 2 and above.

[Inference] The report overgeneralizes when it says tests 6–9 are all overridden by ERP level 6. Test 6 is already initialized to zero, tests 7–8 are duplicated by ERP, and test 9 is more plausibly rendered ineffective by `disable_ext_partitions` than by the same ERP assignments.

[Unknown] The claim that TPL is below 3% of execution time is not supported by component timing in the supplied report. Near-zero OFF deltas do not establish that percentage.

[Recommendation] Clean overwritten assignments for maintainability, but do not claim an encoder speedup for cleanup alone.

## 4. Evaluation of the four proposals

### 4.1 Proposal 1 — DIP gradient-anisotropy gating

[Code] `CONFIG_DIP_EXT_PRUNING` defaults to enabled, and DIP search already computes model RDs, retains top DIP candidates, and runs a TFLite gate using normalized source pixels, QP, block dimensions, DC RD, current best RD, best non-DIP mode, and per-DIP model RDs.

[Code] Conventional directional intra search also has a Sobel/HOG-based mode pruner.

[Inference] A scalar `|Gx-Gy|/(Gx+Gy)` gate duplicates weaker directional evidence and does not establish that a learned DIP mode is redundant merely because the block is isotropic by that statistic.

[Recalc] The proposal says it recovers 0.85 points of a 1.05-point loss while retaining 80% of a 2.45-point saving. Under its own assumptions, the remaining loss is 0.20 and retained saving is 1.96, giving a ratio of about **9.8**, not greater than 35.

[Recommendation] Do not code this proposal. Add counters to the existing TFLite gate for keep rate, DIP-winner rate when rejected, block size, QP, update type, and RD margin. Then sweep the existing threshold or retained top-mode count.

### 4.2 Proposal 2 — block-level EOB/temporal TCQ

[Code] AV2 exposes `TCQ_DISABLE`, `TCQ_8ST`, and `TCQ_8ST_FR`; the frame-adaptive mode enables TCQ on intra or pyramid-level 0/1 frames.

[Code] Encoder and decoder both derive block quantization behavior from the signaled frame TCQ mode, lossless state, plane, and transform class.

[Inference] Using `eob > 16` to decide whether TCQ should have been run is circular: EOB is a result of quantization, while coefficient syntax/decoding depends on whether TCQ was active. A preliminary scalar quantization pass would also consume part of the intended saving.

[Code] The good-quality API default at this anchor sets `enable_tcq = 1`, while the CLI help string says mode 2 is the default.

[Unknown] The supplied report does not publish the test command, so it is unknown whether test 35 restored full-frame TCQ or frame-adaptive TCQ.

[Recalc] The proposal's own numbers leave 0.41 points of loss after recovering 0.90 from 1.31; `9.2 / 0.41 = 22.4`, not at least 30.

[Recommendation] Patch 0003 forces the already normative frame-adaptive mode at Speed 3/4 and preserves explicit TCQ disable. Evaluate it only after recording the exact TCQ flag used in the original test.

### 4.3 Proposal 3 — Planar/DC margin for smooth intra

[Code] AV2 defines `SMOOTH_PRED`, `SMOOTH_V_PRED`, and `SMOOTH_H_PRED`; no encoder mode named `PLANAR` exists at this anchor.

[Report] Disabling smooth intra produces A1 `-1.28% BD / 99.14% time` and A2 `-0.88% BD / 100.34% time` when the feature is turned OFF relative to the current baseline.

[Inference] The direct experiment already supports restoring the modes before adding another lossy gate. The opposite timing signs across A1/A2 are more consistent with a small effect or timing noise than with a demonstrated zero-cost theorem.

[Recommendation] Test patch 0004 as a Pareto repair. Only design a smooth-mode gate if a repeated run shows a meaningful slowdown from restoration.

### 4.4 Proposal 4 — compound gating by MV collinearity

[Code] The current level-2 gate prunes when the corresponding best single mode is not available; level 1 preserves the compound candidate in that case and prunes only when single-mode evidence exists.

[Inference] Similar MV direction across different references does not imply similar predictors because reference time, occlusion, local deformation, and reconstructed content differ. Raw vectors would also need temporal-distance normalization before comparison.

[Recalc] The proposal's own numbers leave 0.43 points of loss after recovering 0.70 from 1.13; `6.8 / 0.43 = 15.8`, not at least 25.

[Recommendation] Test the existing level-1 behavior in patch 0005. If it remains below bar, trace cached single-predictor SAD/correlation before designing a predictor-domain similarity gate.

## 5. New opportunities derived from the data

### 5.1 Promote transform-statistics pruning to Speed 3 — patch 0001

[Recalc] At Speed 4, test 77 saves 4.64% on A1 and 4.69% on A2 by the correct formula, with class-specific ratios of 25.8 and 156.3.

[Inference] This is the strongest measured candidate for promotion because its conservative level already passes the stricter Speed-3 bar on the published Speed-4 A1/A2 numbers.

[猜测] Speed 3 may expose at least as much transform-search work, so the timing effect could approach or exceed 5%; interactions can make it smaller or worsen loss.

[Code] Patch 0001 enables level 1 at Speed 3 for 480p and larger, matching the existing resolution guard.

### 5.2 Enable conservative DC-block prediction at Speed 3 — patch 0002

[Recalc] Test 101 saves 2.32% on A1 and 3.65% on A2 at Speed 4 by the correct formula; A1's published ratio is 28.9 and A2 loss is precision-limited.

[Code] Level 1 applies DC prediction to the two non-winner evaluation stages, while level 2 also applies it in winner mode.

[Inference] Level 1 is a conservative Speed-3 complement to transform-statistics pruning, not a standalone >5% candidate.

[猜测] 0001 plus 0002 may exceed 5%, but the gains must not be added arithmetically.

### 5.3 Use normative frame-adaptive TCQ — patch 0003

[Inference] This is the legal, low-complexity version of the temporal-layer portion of proposal 2.

[猜测] It should cost less than full-frame TCQ and recover more coding efficiency than disabling TCQ globally; its class-specific ratio is unknown.

[Code] Patch 0003 applies the policy only at Speed 3/4, leaves Speed 5+ disabled as before, respects `enable_tcq = 0`, and retains full TCQ for a single-picture header.

### 5.4 Restore smooth intra before inventing a gate — patch 0004

[Inference] This is a likely Pareto cleanup based on the published signs, but it is not a speedup idea.

[Unknown] Repeated timing is needed before calling the restoration cost-free.

### 5.5 Back off compound pruning from level 2 to level 1 — patch 0005

[Inference] This directly targets the identifiable unsafe case in current code: pruning without corresponding single-mode evidence.

[猜测] It may recover a disproportionate share of the 1.11–1.15% class loss while retaining part of the 5.23–10.34% true speed saving of level 2 versus OFF.

### 5.6 CCSO BO-only warm start — patch 0006

[Code] Under the current early-termination policy, CCSO exits the entire nested search when a parameter family fails to improve the global best by about 0.1%.

[Code] The current loop visits full edge-filter families before the cheaper band-offset-only family.

[Inference] Evaluating BO-only first gives the full search a finite RD bound from a distinct, cheap family and can prevent the early terminator from never considering BO-only.

[猜测] Because CCSO is the largest measured hotspot, search ordering has high upside, but this exact reordering may speed up, slow down, improve quality, or degrade quality depending on candidate distributions.

[Code] Patch 0006 changes ordering only when early termination is enabled; exhaustive-search ordering and its candidate set remain unchanged.

### 5.7 Trace-guided follow-ups without patches yet

[Recommendation] For TX statistics, log the retained cumulative probability mass and the winning pruned transform. Replace a fixed threshold only after deriving per-size/update-type miss curves.

[Recommendation] For CCSO, log which nested indices win and where early exit occurs. A previous-frame-parameter or reuse-candidate warm start is higher confidence only if winner persistence is demonstrated.

[Recommendation] For compound prediction, compare cached single predictors in the pixel domain only when those buffers already exist; otherwise the gate can cost more than it saves.

[Recommendation] Do not prioritize TPL micro-pruners from this report until component timing shows a material TPL share.

## 6. EDA plan with stop conditions

### Stage 0 — fix the measurement contract

1. `[Recommendation]` Record the complete command line, especially `--enable-tcq`, tool configuration, thread count, and frame-parallel settings.
2. `[Recommendation]` Interleave baseline and candidate runs by clip/QP/worker, include warm-up, and repeat timing enough to publish dispersion or confidence intervals.
3. `[Recommendation]` Preserve full-precision per-sequence BD-rate and wall time; do not classify displayed `0.00%` as zero.
4. `[Recommendation]` Compute A1 and A2 ratios independently with `100*(T_off-100)/T_off`.
5. `[Recommendation]` Inspect per-clip tails before accepting a class average.

### Stage 1 — cheap timing pilots

1. `[Recommendation]` Pilot 0001, 0002, and 0001+0002 at Speed 3 on at least one representative A1 and one A2 clip at a middle QP.
2. `[Recommendation]` Stop the 0001+0002 line before full CTC if the combined timing signal is clearly below the desired 5% portfolio threshold.
3. `[Recommendation]` Pilot 0006 separately at Speed 2, because that is where the report directly measured the CCSO feature and where the bar is hardest.
4. `[Recommendation]` Do not infer BD-rate compliance from the pilot; it is only a cost-control screen.

### Stage 2 — full independent CTC

| Priority | Patch | Preset | Required comparison | Acceptance question |
|---:|---|---:|---|---|
| 1 | 0001 | 3 | clean anchor vs 0001 | `[Recommendation]` Do A1 and A2 each meet ratio 25, and is speed material? |
| 1 | 0006 | 2 | clean anchor vs 0006 | `[Recommendation]` Do A1 and A2 each meet ratio 30, with no CCSO quality tail? |
| 1 | 0004 | 3 | clean anchor vs 0004 | `[Recommendation]` Is quality recovered without a repeatable slowdown? |
| 2 | 0002 | 3 | clean anchor vs 0002 | `[Recommendation]` Does level 1 meet ratio 25 independently despite modest speed? |
| 2 | 0003 | 3 and 4 | disabled vs frame-adaptive vs full | `[Recommendation]` Is frame-adaptive on the Pareto frontier and above each preset bar? |
| 2 | 0005 | 4 | level 0 vs level 1 vs level 2 | `[Recommendation]` Does level 1 meet ratio 20 in both classes? |

[Recommendation] Test 0001+0002 only after their marginal results are known. Test accepted candidates on top of 0006e last, because 0006e changes partition decisions and therefore can change downstream transform, intra, and compound workloads.

## 7. Patch manifest

[Code] Every patch is based on `fe1bfdee5427ea2e01149c5ebce904084a93ba79`.

| Patch | Purpose | Files | SHA-256 |
|---|---|---|---|
| `0001-s3-promote-tx-stat-pruning-fe1bfdee.patch` | Speed-3 TX-stat level 1 | `speed_features.c` | `025be7bf8c1bf18264c1af98025daeec299857ba2ceae43835e2b1b65f8fd9fa` |
| `0002-s3-enable-dc-block-pred-level1-fe1bfdee.patch` | Speed-3 DC predictor level 1 | `speed_features.c` | `53c1b6486ee5f860220e40e11b1fffd7dfcbc9742639f5b6b5ccb77464781bc1` |
| `0003-s3-s4-frame-adaptive-tcq-fe1bfdee.patch` | Frame-adaptive TCQ at Speed 3/4 | `speed_features.c/.h` | `ffa115e62b8c06f22abf232fd4747f276504976ae56e10047ae8c1005aacb67f` |
| `0004-s3-restore-smooth-intra-fe1bfdee.patch` | Restore smooth modes | `speed_features.c` | `054d3a9bfc5df157308b676fd31da2691479976581645cde3ec593530e0e1824` |
| `0005-s4-compound-prune-level1-fe1bfdee.patch` | Back off compound gate to level 1 | `speed_features.c` | `c07dfe3d8f5c08ee4df857be2fa81762a212f41b5108e652f07d79fd20d429ab` |
| `0006-s2-ccso-bo-first-warm-start-fe1bfdee.patch` | BO-first CCSO ordering under early exit | `pickccso.c` | `06b518959020bd1363b5664c69699fc430341fbcb65b57b4c83cec8f783b32af` |
| `0007-integration-all-candidates-fe1bfdee.patch` | Build/smoke integration only | `speed_features.c/.h`, `pickccso.c` | `26c1beeb9946d71f280bb0c4d1cf6f881f17098402fe8eb0b0e2bd469ecd1231` |

## 8. Validation performed

[Validation] `git apply --check` passes for every independent patch and for the integration patch on the clean anchor.

[Validation] The integration patch also passes `git apply --check` after applying `0006e-orientation-pruning-size-graded.patch` to the anchor.

[Validation] `git diff --check` passes for every implementation worktree.

[Validation] The integration source builds Release `avmenc` and `avmdec` with `CONFIG_ML_PART_SPLIT=1` and `AVM_TARGET_CPU=generic`.

[Validation] One-frame 480x480 synthetic AV2 encode/decode smoke tests completed at Speed 2, Speed 3, and Speed 4; each decoded one frame at the expected dimensions.

[Unknown] No CTC EDA, BD-rate measurement, production-CPU timing, sanitizer run, or exhaustive conformance test was performed here.

[Inference] Build and smoke success establish integration viability only; they provide no evidence that any candidate passes the speed/quality bar.

## 9. Source pointers

- `[Code]` [Speed-feature assignments and overwrite behavior](https://github.com/AOMediaCodec/avm/blob/fe1bfdee5427ea2e01149c5ebce904084a93ba79/av2/encoder/speed_features.c)
- `[Code]` [DIP search and TFLite pruning inputs](https://github.com/AOMediaCodec/avm/blob/fe1bfdee5427ea2e01149c5ebce904084a93ba79/av2/encoder/intra_mode_search.c)
- `[Code]` [Sobel/HOG directional pruning](https://github.com/AOMediaCodec/avm/blob/fe1bfdee5427ea2e01149c5ebce904084a93ba79/av2/encoder/intra_mode_search_utils.h)
- `[Code]` [TCQ modes and block applicability](https://github.com/AOMediaCodec/avm/blob/fe1bfdee5427ea2e01149c5ebce904084a93ba79/av2/common/quant_common.h)
- `[Code]` [Frame-adaptive TCQ policy](https://github.com/AOMediaCodec/avm/blob/fe1bfdee5427ea2e01149c5ebce904084a93ba79/av2/encoder/encodeframe.c)
- `[Code]` [Compound level-1/level-2 behavior](https://github.com/AOMediaCodec/avm/blob/fe1bfdee5427ea2e01149c5ebce904084a93ba79/av2/encoder/rdopt.c)
- `[Code]` [CCSO search and early termination](https://github.com/AOMediaCodec/avm/blob/fe1bfdee5427ea2e01149c5ebce904084a93ba79/av2/encoder/pickccso.c)
