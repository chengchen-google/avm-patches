# AV2 Speed-4 Advanced Speed Research

## Executive decision

[Verified] This research is anchored to AVM commit `5d628d840b84be2eef1d0b1e2b7353719cc1f92a` and contains one standalone patch. It does not combine this proposal with 0006e, N02, N06, N07, N08, or any other speed patch.

| Candidate | Decision | Local evidence | CTC status |
|---|---|---|---|
| `0001-Speed-4-rank-non-DCT-inter-transforms-before-TCQ-ref.patch` | [Action] Evaluate by itself | [Measured] 10.58% user-CPU time reduction on a small generic-CPU activation screen; output matched baseline on that screen | [Verified] Not run; no claim that A1 or A2 passes |

[Rejected] I did not package two additional micro-optimizations after they screened flat: an exact DC-only quantization path measured about 0.5% slower, and skipping TCQ context initialization at `eob == 1` recovered less than about 1% on the same local screen.

[猜测] The submitted patch has a plausible Speed-4 CTC time reduction of roughly 2–6% on x86, with substantial sequence dependence. This estimate is intentionally below the 10.58% generic-CPU screen because the screen had no x86 SIMD and used synthetic, low-resolution content.

## Correction: N07 and N08 are already upstream

[Verified] N07 is already present at commit `247c63a3cc4d5b6143e14ab2d2bd25d4547c255a`, titled `Bypass Luma plane search in CCSO (#5273)`, and is an ancestor of the requested anchor.

[Verified] N08 is already present at commit `a5d3d1c3a7d534d76caed0fd3faf3bf9e03acaf6`, titled `Handle near zero coefficients in tcq (#5261)`, and is an ancestor of the requested anchor.

[Verified] N07's upstream commit message reports average encoding time of 96.65% at Speed 1, while N08's upstream commit message reports 96.42% at Speed 1. Re-submitting either patch against `5d628d840` would therefore be redundant.

[Verified] The earlier N07/N08 candidate list was based on a stale view of the codebase. The current research re-indexed every idea against the exact requested commit before implementation.

## Evidence used

[Verified] The analysis cross-checked the current source tree, the supplied Speed-4 profile `Claude/PROFILE_5d628d8_cpu4.txt`, and the evaluation reports under `shared/` and `Claude/` in `chengchen-google/avm-patches`.

[Measured] In the supplied current-code profile, `av2_trellis_quant` alone accounts for 9.95% self instructions. Related quantization, TCQ state-decision, coefficient-rate, and transform-search work raises the actionable call-chain cost well above that self-only figure, although the exact aggregate depends on attribution.

[Verified] Commit `a5d3d1c3a` already specializes near-zero TCQ coefficient processing, so another coefficient-level `q == 1` shortcut is not a new opportunity at this anchor.

[Verified] Commit `7c9dfbaa287ab6df4613f746bbab4b410853fced` disabled the broad Speed-4 `perform_coeff_opt_based_on_satd` feature because its quality cost was not justified by its time saving. The submitted patch therefore does not restore that broad block-level skip.

[Inference] The remaining opportunity is to avoid full TCQ for clearly noncompetitive transform-type candidates while preserving full TCQ for DCT and for any non-DCT candidate close enough to become the winner.

## Submitted patch: non-DCT TCQ rank, then refine

### Scope

[Verified] The speed feature is enabled only at Speed 4 and above through `TX_SPEED_FEATURES::tcq_non_dct_rank_then_refine`.

[Verified] It applies only during inter transform-type search, only to non-`DCT_DCT` 2-D candidates for which TCQ is active, and only when trellis was not already disabled.

[Verified] It excludes lossless behavior through the existing `tcq_enable()` decision and explicitly excludes FSC and inter-FSC candidates.

[Verified] `DCT_DCT` always receives the original full FP-quantization plus TCQ evaluation.

### Algorithm

[Verified] Each eligible non-DCT candidate is first quantized through the existing scalar/B path, and its normal coefficient rate and distortion are computed as a ranking proxy.

[Verified] If no winner exists, if the proxy already beats the current winner, or if the proxy is within 12.5% of the current best RD, the candidate is immediately re-quantized and re-evaluated with the original full TCQ path.

[Verified] A candidate that survives refinement can become the winner only with its full-TCQ rate, distortion, EOB, entropy context, and dequantized coefficients.

[Verified] A proxy candidate outside the margin exits immediately. Its proxy EOB and entropy state cannot update the winner or drive the existing adaptive early-termination heuristics.

[Verified] The 12.5% setting is exposed as `AVM_TCQ_RANK_REFINE_MARGIN_DEN=8`; a smaller denominator makes the window wider and safer but slower.

### Why this differs from the rejected broad SATD feature

[Verified] The upstream-disabled SATD feature made a block-level coefficient-optimization decision before transform-type competition was resolved.

[Verified] This patch retains full TCQ for the reference DCT candidate and performs a candidate-specific rate-distortion proxy before deciding whether to refine a non-DCT candidate.

[Inference] That structure should be less likely to lose a useful non-DCT winner than an unconditional or block-wide TCQ skip, but it is not mathematically lossless.

### Quality risk

[Verified] Scalar/B RD is a proxy, not a lower bound on full-TCQ RD.

[Verified] The approximation can fail if a non-DCT candidate is more than 12.5% worse under scalar quantization but would improve enough under TCQ to beat the current full-TCQ winner.

[Verified] The local activation clip produced both refined and rejected candidates, yet the final IVF matched baseline byte-for-byte. That proves no winner inversion on that sample only.

[猜测] Winner inversions should be uncommon because the gate is limited to non-DCT inter candidates and retains a 12.5% rescue window, but only CTC A1/A2 results can establish whether the patch passes the requested bar.

## Local validation

### Build

[Verified] Baseline and patch both compiled successfully from the exact anchor with Release configuration and the generic CPU target.

[Verified] The validation build disabled `CONFIG_ML_PART_SPLIT`, `CONFIG_DIP_EXT_PRUNING`, and TensorFlow Lite only to avoid an unrelated dependency-extraction restriction in this environment. Baseline and patch used identical configuration.

[Verified] `git diff --check` passed, and the generated mail patch passes `git apply --check` on a clean `5d628d840` tree.

### Activation and bitstream checks

[Measured] Temporary instrumentation on a 128x72, 10-bit, six-frame Speed-4 clip observed both paths: candidates inside the margin were refined with full TCQ, and candidates outside the margin were rejected after proxy evaluation.

[Measured] The six-frame baseline and patched IVF files had identical SHA-256 `c90268b9d0347e61357e0b630b39d7670993ce80ac37af675546cf9085d88f04`.

[Measured] The final three-frame timing outputs also matched baseline with SHA-256 `914337af8dcd25e7536180946316d02e445426f5659e75b656bf67b74ea453d2` in all paired runs.

[Verified] Temporary instrumentation is not present in the submitted patch.

### Timing screen

[Verified] Command shape: one pass, `--cpu-used=4`, one thread, constant-quality mode, `--qp=80`, 10-bit input/output, three frames, with the process pinned to one CPU.

| Run | Baseline user CPU | Patched user CPU |
|---|---:|---:|
| 1 | [Measured] 19.189 s | [Measured] 17.422 s |
| 2 | [Measured] 19.796 s | [Measured] 17.439 s |
| Mean | [Measured] 19.4925 s | [Measured] 17.4305 s |

[Measured] The mean user-CPU time reduction is `(19.4925 - 17.4305) / 19.4925 = 10.58%`; the corresponding throughput increase is 11.83%.

[Verified] Wall time was noisier than user CPU time in the shared environment, so wall-time outliers were not used for the headline screen.

[Verified] This is an activation screen, not an EDA substitute: it uses a generic build, a synthetic source, one resolution, one QP, and three coded frames.

[Measured] A 20–25% refinement window removed most of the local time saving, showing that the tradeoff is sensitive to the margin and that a wider window should not be assumed to retain useful speed.

## Recommended EDA plan

[Action] Evaluate the patch standalone on the exact `5d628d840` baseline at Speed 4; do not combine it with 0006e or another candidate in the first run.

[Action] Run the normal RA matrix for both A1 and A2, using the same frame counts, QPs, compiler, machine pinning, and aggregation method as the recent reports.

[Action] Treat A1 and A2 as independent gates. Do not accept the patch because an overall average passes if A1 fails.

[Action] Compare per-sequence encoding time as well as the class aggregate; TCQ candidate mix can make the gain heterogeneous.

[Action] Record at least PSNR-YUV and the existing class-specific bar metrics. The local byte-identical sample does not imply CTC neutrality.

[Action] If quality narrowly fails but speed is clearly useful, rerun only one safer variant with `AVM_TCQ_RANK_REFINE_MARGIN_DEN=5` (20% window). If that variant loses the speed benefit, reject the idea rather than combining it with another patch.

[Action] If either A1 or A2 fails materially, reject this patch at the current gate; do not justify it with the synthetic 10.58% screen.

## Exclusion ledger

| Idea | Decision | Evidence |
|---|---|---|
| N07 CCSO luma bypass | [Rejected] Do not evaluate again | [Verified] Already upstream as `247c63a3c` |
| N08 near-zero TCQ specialization | [Rejected] Do not evaluate again | [Verified] Already upstream as `a5d3d1c3a` |
| Exact DC-only quant fast path | [Rejected] Not packaged | [Measured] Paired local mean was about 0.5% slower than baseline |
| `eob == 1` TCQ context-init bypass | [Rejected] Not packaged | [Measured] Incremental effect was below about 1% locally |
| 20–25% rank/refine window | [Rejected] Not packaged | [Measured] Removed most local speed benefit |
| Patch combinations | [Rejected] Not generated | [Verified] The deliverable contains one patch directly against the anchor |

## Follow-up research, not submitted patches

[Action] If this patch passes, collect CTC telemetry for proxy RD, refined RD, current-best RD, rejection count, and winner inversions. That data can replace the fixed margin with a content-aware gate.

[猜测] Deferring refinement until the best one or two non-DCT proxy candidates are known could eliminate repeated immediate refinements, but it requires safely preserving or recomputing candidate state and should not be implemented without telemetry.

[猜测] A transform-size- and EOB-conditioned rescue margin may preserve more quality than one global threshold at the same speed, but the supplied profile does not contain the joint distribution needed to design it responsibly.

## Application

[Verified] The patch is a standard mail-formatted commit whose parent is `5d628d840b84be2eef1d0b1e2b7353719cc1f92a`.

```bash
git checkout 5d628d840b84be2eef1d0b1e2b7353719cc1f92a
git am 0001-Speed-4-rank-non-DCT-inter-transforms-before-TCQ-ref.patch
```

[Verified] Patch commit: `75f43d5a92c415f4395a59436e7dbc9866bd2df1`.
