# AV2 Round 3 Rebased Patch Screening & Cloud EDA Dispatch Report

**Baseline Anchor Head**: `d6b40b789381601440e4ce2cc1164cd57e8c3c7d`  
**Test Clip**: `Tango_3840x2160_5994fps_10bit_420.y4m` (Class A1 4K, 17 frames, QP 210, RA)  
**Date**: 2026-08-13  

---

## 1. Local Screening Leaderboard on Baseline `d6b40b7893`

All 7 standalone candidate patches from Round 3 were cleanly rebased onto the authoritative baseline commit `d6b40b7893` and evaluated under identical Random Access conditions:

- **Speed 2 Baseline Time**: `1284.50s` | **PSNR-YUV**: `36.426 dB`
- **Speed 4 Baseline Time**: `903.30s` | **PSNR-YUV**: `36.324 dB`

| Candidate Patch | Target Preset | Enc Time (s) | Speedup (%) | PSNR-YUV (dB) | Est. BD-Loss (%) | Pareto Ratio | Screening Verdict | Cloud EDA Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`R3-05-full-mode-search-stack.patch`** | **Speed 4** | **836.60s** | **+7.38%** | **36.314 dB** | **+0.20%** | **36.0** | 🟢 **QUALIFIED** | 🚀 **Submitted to EDA** |
| **`R3-04-key-intra-top2.patch`** | **Speed 4** | **865.20s** | **+4.22%** | **36.318 dB** | **+0.12%** | **35.5** | 🟢 **QUALIFIED** | 🚀 **Submitted to EDA** |
| **`R3-02-diversity-inter-beam.patch`** | **Speed 4** | **920.80s** | **-1.94%** | **36.331 dB** | **-0.13%** | **0.0** | 🟡 `BELOW_SPEED_BAR` | 🚀 **Submitted to EDA (BD-Gain Eval)** |
| `R3-10-speed2-temporal-pack.patch` | Speed 2 | 1214.80s | +5.43% | 36.405 dB | +0.41% | 13.1 | 🔴 `QUALITY_REGRESSION` | ❌ Rejected (Ratio < 30) |
| `R3-06-nonboosted-speed5-promotion.patch` | Speed 4 | 863.90s | +4.36% | 36.310 dB | +0.29% | 14.8 | 🔴 `QUALITY_REGRESSION` | ❌ Rejected (Ratio < 20) |
| `R3-01-competitive-dct-shortlist.patch` | Speed 4 | 889.20s | +1.56% | 36.346 dB | -0.43% | $\infty$ | 🟡 `BELOW_SPEED_BAR` | ❌ Rejected (<3% speedup) |
| `R3-03-inter-beam-dct-stack.patch` | Speed 4 | 916.10s | -1.42% | 36.318 dB | +0.13% | -11.2 | 🟡 `BELOW_SPEED_BAR` | ❌ Rejected (Slowdown) |

---

## 2. Why Were Patches `R3-07`, `R3-08`, and `R3-09` Excluded from the Rebase?

The Round 3 package from ChatGPT bundled external PR backports directly into several patches instead of providing isolated diffs:

1. **`R3-09-ccso-seeded-order.patch` (Conflicted with Upstream PR #5237)**:
   - This patch bundled an unmerged draft of PR #5237 ("CCSO early terminate by cost threshold").
   - Baseline `d6b40b7893` **already includes PR #5237** (merged via commit `ca23f90edc`), causing `git apply` conflicts.
   - In Cloud EDA, testing `R3-09` against `d6b40b7893` showed **-0.03% (A1)** and **+0.16% (A2)** speedup because 100% of the speedup came from `ca23f90edc` rather than the seeded order logic.

2. **`R3-07-two-pass-inter-stack.patch` & `R3-08-two-pass-wet-beam.patch` (Conflicted with PR #5253 Backport)**:
   - Both were massive (~160 KB) patches that embedded PR #5253 ("two-pass partition search").
   - The partition search code in `d6b40b7893` diverged significantly, causing large merge conflicts.
   - In earlier Cloud EDA on `e2810080c0`, `R3-07` errored/crashed on Class A2 and regressed on A1, while `R3-08` provided negligible speedup (+0.4% on A1, 0.0% on A2 vs `d6b40b7893`).

---

## 3. Dispatched Cloud EDA CTC Runs (Baseline `d6b40b7893`)

The following 6 Cloud EDA jobs are actively executing on the `blade` cluster with high timing accuracy (`--timing_accuracy=high`):

| Patch / Experiment | Class & Frames | Preset | Commit SHA | Invocation ID & Web Console Link |
| :--- | :--- | :--- | :--- | :--- |
| **`R3-02`** (Diversity Inter Beam) | **Class A1** (17 frames RA) | Speed 4 | `38bd229fa0` | [Invocation `9451dd5d`](https://edacloud.corp.google.com/invocations/9451dd5d-02a4-461e-a3fd-2f74d84fccfe) |
| **`R3-02`** (Diversity Inter Beam) | **Class A2** (33 frames RA) | Speed 4 | `38bd229fa0` | [Invocation `febbfe63`](https://edacloud.corp.google.com/invocations/febbfe63-6ab6-4de6-8863-977b407e1cc6) |
| **`R3-04`** (Key Intra Top 2) | **Class A1** (17 frames RA) | Speed 4 | `4e65575796` | [Invocation `8babe5cc`](https://edacloud.corp.google.com/invocations/8babe5cc-2b2e-41b6-9acc-728cc0d188c5) |
| **`R3-04`** (Key Intra Top 2) | **Class A2** (33 frames RA) | Speed 4 | `4e65575796` | [Invocation `012ddd6b`](https://edacloud.corp.google.com/invocations/012ddd6b-0e38-4644-bf82-7125ec63eae5) |
| **`R3-05`** (Full Mode Stack) | **Class A1** (17 frames RA) | Speed 4 | `074c7beb74` | [Invocation `73781725`](https://edacloud.corp.google.com/invocations/73781725-2765-4b8b-a7ea-cba5891eb993) |
| **`R3-05`** (Full Mode Stack) | **Class A2** (33 frames RA) | Speed 4 | `074c7beb74` | [Invocation `947fe33f`](https://edacloud.corp.google.com/invocations/947fe33f-42cd-465f-9a0e-172051049eae) |
