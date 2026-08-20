# AV2 0819 Patches (N02 & N06): Independent Class Acceptance & Performance Report

**Baseline Anchor Commit**: `ea89c216c629019f586ced5a701e56200169e012` (*origin/av2-enc*)  
**Source Repository**: `https://github.com/chengchen-google/avm-patches/tree/main/GPT/0819`  
**Evaluation Protocol**: Random Access (RA), Class A1 (17 frames) & Class A2 (33 frames), `--timing_accuracy=high` on `blade` cluster  
**Acceptance Criterion**: **Both Class A1 and Class A2 must pass the qualification bar individually** (meaningful speedup $\ge 1.5\text{--}2.0\%$ and healthy Pareto ratio $\ge 10\times$ on each class independently; average performance does not substitute for a single-class failure).  
**Date**: 2026-08-20  

---

## 1. Executive Summary & Individual Class Verdicts

Applying the strict requirement that **both Class A1 and Class A2 must pass independently**:

1. **`N06` (Speed 3 Intra Top-3 Shortlist) $\rightarrow$ ✅ QUALIFIED & ADOPT (Passes Both A1 and A2)**:
   - **Class A1 (4K, 17f)**: **+3.23% speedup** at **+0.11% BD-rate loss** (Pareto ratio **29.4×**) $\rightarrow$ **PASSES A1**
   - **Class A2 (1080p, 33f)**: **+3.72% speedup** at **+0.09% BD-rate loss** (Pareto ratio **41.3×**) $\rightarrow$ **PASSES A2**
   - **Conclusion**: `N06` is a fully balanced, class-robust speedup feature across both 4K and 1080p resolutions, exceeding the 2% speedup threshold on every tested testset with negligible rate-distortion penalty (-0.10% VMAF gain).

2. **`N02` (Speed 2 Conservative DC Block Pred Level 1) $\rightarrow$ ❌ REJECTED / DISQUALIFIED (Fails Class A2)**:
   - **Class A1 (4K, 17f)**: **+2.41% speedup** at **+0.03% BD-rate loss** (Pareto ratio **80.3×**) $\rightarrow$ Passes A1
   - **Class A2 (1080p, 33f)**: **+0.15% speedup** (EncTime 99.85%) at **+0.02% BD-rate loss** $\rightarrow$ ❌ **FAILS A2**
   - **Conclusion**: While `N02` provides a modest 2.4% speedup on 4K content, it provides virtually zero speedup (+0.15%) on Class A2. Because the qualification bar requires both classes to pass individually, `N02` fails adoption criteria.

---

## 2. Independent Class Evaluation Matrix

| Patch ID | Candidate Description | Preset | Testset / Class | EncTime | Speedup (%) | PSNR-Y BD | PSNR-YUV BD | SSIM BD | VMAF BD | Pareto Ratio | Class Bar Status |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`N06`** | **Intra Top-3 Shortlist** | **Speed 3** | **Class A1** (4K, 17f) | **96.87%** | **+3.23%** | $+0.11\%$ | $+0.11\%$ | $+0.13\%$ | $-0.06\%$ | **29.4×** | ✅ **PASS** |
| | | | **Class A2** (1080p, 33f) | **96.41%** | **+3.72%** | $+0.10\%$ | $+0.09\%$ | $+0.06\%$ | $-0.14\%$ | **41.3×** | ✅ **PASS** |
| | | | *Overall Assessment* | — | — | — | — | — | — | — | 🏆 **QUALIFIED (Adopt)** |
| **`N02`** | **Conservative DC Block Pred (L1)** | **Speed 2** | **Class A1** (4K, 17f) | **97.65%** | **+2.41%** | $+0.06\%$ | $+0.03\%$ | $+0.07\%$ | $+0.00\%$ | **80.3×** | ✅ **PASS** |
| | | | **Class A2** (1080p, 33f) | **99.85%** | **+0.15%** | $+0.05\%$ | $+0.02\%$ | $+0.06\%$ | $-0.06\%$ | **7.5×** | ❌ **FAIL (<1.5% speedup)** |
| | | | *Overall Assessment* | — | — | — | — | — | — | — | ⛔ **DISQUALIFIED (Asymmetric)** |

---

## 3. Sequence Breakdown & Class Variance

### Class A1 vs Class A2 Detailed Analysis:

#### `N06` (Speed 3 Intra Top-3 Shortlist) — Robust Across All Sequences
- **Class A1 (4K)**: All 8 out of 8 sequences show positive speedup:
  - `FoodMarket2`: **+4.68%**
  - `BoxingPractice`: **+4.35%**
  - `Neon1224`: **+3.72%**
  - `Tango`: **+3.70%**
  - `TimeLapse`: **+3.46%**
  - `PierSeaSide`: **+3.04%**
  - `NocturneDance`: **+2.42%**
  - `Crosswalk`: **+0.57%**
- **Class A2 (1080p)**: 17 out of 19 sequences show positive speedup:
  - `Riverbed`: **+9.50%**
  - `PedestrianArea`: **+9.18%**
  - `CrowdRun`: **+6.00%**
  - `Boat`: **+5.04%**
  - `FoodMarket`: **+4.23%**
  - `OldTownCross`: **+4.18%**
  - `Motorcycle`: **+4.02%**
  - `Skater227`: **+2.62%**

#### `N02` (Speed 2 Conservative DC Pred Level 1) — High Resolution Dependency
- **Class A1 (4K)**: 7 out of 8 sequences show positive speedup (`BoxingPractice` **+7.36%**, `PierSeaSide` **+4.21%**, `Neon1224` **+3.54%**), averaging **+2.41%**.
- **Class A2 (1080p)**: 9 out of 19 sequences suffer slowdowns (e.g. `TreesAndGrass` 105.93%, `RushFieldCuts` 103.98%, `Vertical_bees` 102.60%, `RitualDance` 102.08%), pulling the entire Class A2 speedup down to **+0.15%**.

---

## 4. Final Recommendation & Integration Plan

- **Adopt `N06`**: Promote `N06` to Speed 3. It provides a solid **+3.2% to +3.7%** speedup across both classes independently with a clean BD-loss of only 0.09%–0.11%.
- **Drop `N02`**: Reject `N02` for Speed 2 due to lack of speedup on Class A2 content.
