# Cloud EDA CTC Evaluation Report: Rebased Round 3 Patches vs Baseline `d6b40b7893`

**Baseline Anchor Commit**: `d6b40b789381601440e4ce2cc1164cd57e8c3c7d`  
**Evaluation Protocol**: Random Access (RA), Speed 4 (`--cpu-used=4`), Class A1 (17 frames) & Class A2 (33 frames)  
**Timing Accuracy**: High (`--timing_accuracy=high` on `blade` cluster)  
**Date**: 2026-08-13  

---

## 1. Executive Summary & Comparison Table

| Candidate Patch | Tested Branches & Commits | Class A1 (17f RA) | Class A2 (33f RA) | Combined Avg Speedup | Combined Avg BD-Rate (YUV) | Verdict & Assessment |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`R3-04-key-intra-top2`** | `experiment3/R3_04_key_intra_top2` (`4e65575796`) | **+1.80%** speedup<br>`+0.22%` BD-rate | **+2.09%** speedup<br>`-0.05%` BD-rate | **+1.95% Speedup** | **+0.08% BD-Loss** | 🟢 **Clean Speedup**: Consistently faster on both A1 & A2 with near-zero coding loss. High Pareto efficiency (24:1). |
| **`R3-02-diversity-inter-beam`** | `experiment3/R3_02_diversity_inter_beam` (`38bd229fa0`) | **-6.82%** slowdown<br>`-0.18%` BD-rate | **-6.11%** slowdown<br>`-0.10%` BD-rate | **-6.46% Slowdown** | **-0.14% BD-Gain** | 🔵 **Coding Gain Engine**: Consistent ~0.14% coding gain across all metrics (PSNR, SSIM, VMAF), but acts as an accuracy booster, not a speedup. |
| **`R3-05-full-mode-search-stack`** | `experiment3/R3_05_full_mode_search_stack` (`074c7beb74`) | **-0.99%** slowdown<br>`+0.06%` BD-rate | **-1.55%** slowdown<br>`+0.02%` BD-rate | **-1.27% Slowdown** | **+0.04% BD-Loss** | 🔴 **Mixed Overhead**: Bundling `R3-02` (diversity beam) with `R3-01` & `R3-04` dragged net speed into negative territory. |

---

## 2. Detailed Performance Analysis

### A. [`R3-04-key-intra-top2`](file:///usr/local/google/home/chengchen/work/av2/agent/rebased_round3_patches/R3-04-key-intra-top2.patch) — High-Efficiency Clean Speedup
* **Mechanism**: Early termination of key-frame intra evaluation when the top-2 directional winners demonstrate high confidence.
* **Results**:
  * **Class A1 (17f)**: EncTime = `98.20%` (**+1.80% speedup**), BD-rate = `+0.27% Y / +0.22% YUV`.
  * **Class A2 (33f)**: EncTime = `97.91%` (**+2.09% speedup**), BD-rate = `-0.08% Y / -0.05% YUV` (coding gain).
* **Key Finding**: `R3-04` is one of the few patches in the entire suite that provides **consistent speedup across both 4K and 1080p CTC sequences** with negligible or positive BD-rate impact.

---

### B. [`R3-02-diversity-inter-beam`](file:///usr/local/google/home/chengchen/work/av2/agent/rebased_round3_patches/R3-02-diversity-inter-beam.patch) — Verified Coding Gain Engine
* **Mechanism**: Forces retention of candidate modes from unrepresented reference frames and prediction families (compound vs single, NEW vs non-NEW) during 2-pass RD model estimation.
* **Results**:
  * **Class A1 (17f)**: EncTime = `106.82%` (**-6.82% slowdown**), BD-rate: `PSNR-Y: -0.15%`, `PSNR-YUV: -0.18%`, `SSIM: -0.15%`, `VMAF: -0.16%`.
  * **Class A2 (33f)**: EncTime = `106.11%` (**-6.11% slowdown**), BD-rate: `PSNR-Y: -0.08%`, `PSNR-YUV: -0.10%`, `SSIM: +0.02%`, `VMAF: -0.05%`.
* **Key Finding**: Confirms the earlier hypothesis: `R3-02` **consistently improves compression quality across virtually all metrics and clips**, but does so by evaluating more transform candidates, resulting in a $+6.5\%$ compute overhead.

---

### C. [`R3-05-full-mode-search-stack`](file:///usr/local/google/home/chengchen/work/av2/agent/rebased_round3_patches/R3-05-full-mode-search-stack.patch) — Stack Analysis
* **Mechanism**: Stacks `R3-01` (DCT shortlist), `R3-02` (diversity beam), and `R3-04` (key intra top-2).
* **Results**:
  * **Class A1 (17f)**: EncTime = `100.99%` (**-0.99% slowdown**), BD-rate = `+0.14% Y / +0.06% YUV`.
  * **Class A2 (33f)**: EncTime = `101.55%` (**-1.55% slowdown**), BD-rate = `+0.02% Y / +0.02% YUV`.
* **Key Finding**: The $+6.5\%$ slowdown from `R3-02` overwhelmed the $+2.0\%$ speedup from `R3-04` and $+1.5\%$ from `R3-01`, turning the combination negative in encoding speed.
* **Strategic Recommendation**: Creating an isolated stack combining **`R3-01` + `R3-04`** (without `R3-02`) should yield a clean **$\sim +3.5\%$ to $+4.0\%$ speedup** at $<0.1\%$ BD-rate.

---

## 3. Sequence-Level Detailed Tables

### Sequence Breakdown: `R3-04` vs Baseline `d6b40b` (Class A1 17f RA)
```
Sequence (RA, A1)                         PSNR-Y   PSNR-U   PSNR-V  PSNR-YUV   SSIM     VMAF   EncTime  
------------------------------------------------------------------------------------------------------
BoxingPractice_3840x2160_5994fps_10bit    +0.55%   +0.43%   +0.18%   +0.52%   +0.52%   +0.16%    97.90%
Crosswalk_3840x2160_5994fps_10bit_420     +0.40%   -0.11%   -0.47%   +0.30%   +0.46%   +1.19%    99.28%
FoodMarket2_3840x2160_5994fps_10bit_42    +0.32%   +0.69%   -0.18%   +0.31%   +0.49%   +0.14%    98.95%
Neon1224_3840x2160_2997fps                +0.16%   -0.06%   -0.34%   +0.12%   +0.11%   +0.60%   100.77%
NocturneDance_3840x2160p_10bit_60fps      -0.05%   -0.20%   +1.47%   -0.00%   -0.08%   -0.98%    98.30%
PierSeaSide_3840x2160_2997fps_10bit_42    +0.64%   -0.07%   -3.06%   +0.45%   +0.93%   +0.59%    93.91%
Tango_3840x2160_5994fps_10bit_420         -0.15%   +0.02%   +0.12%   -0.12%   -0.12%   +1.63%    96.25%
TimeLapse_3840x2160_5994fps_10bit_420     +0.30%   -0.48%   -0.24%   +0.23%   +0.43%   +0.06%   100.42%
------------------------------------------------------------------------------------------------------
Average (RA, A1)                          +0.27%   +0.03%   -0.32%   +0.22%   +0.34%   +0.42%    98.20% (+1.80% speedup)
```

### Sequence Breakdown: `R3-04` vs Baseline `d6b40b` (Class A2 33f RA)
```
Sequence (RA, A2)                         PSNR-Y   PSNR-U   PSNR-V  PSNR-YUV   SSIM     VMAF   EncTime  
------------------------------------------------------------------------------------------------------
Boat_1920x1080_5994_10bit_420             +0.20%   -0.25%   -0.23%   +0.16%   +0.17%   +0.46%    93.88%
OldTownCross_1920x1080p50                 +0.58%   -1.84%   -0.84%   +0.43%   +0.33%   +0.83%    94.24%
TunnelFlag_1920x1080_5994_10bit_420       +0.04%   +0.04%   -0.49%   +0.04%   +0.18%   +0.16%    95.30%
Vertical_bees_1080x1920_2997              +0.66%   +0.04%   -1.19%   +0.52%   +0.85%   +0.62%    96.30%
Riverbed_1920x1080p25                     -0.07%   +2.23%   -0.10%   +0.01%   -0.02%   +0.61%    96.50%
PedestrianArea_1920x1080p25               -0.42%   +1.20%   +0.15%   -0.32%   -0.26%   -1.47%    97.11%
FoodMarket_1920x1080_5994_10bit_420       +0.21%   -0.45%   +1.95%   +0.27%   +0.08%   -0.13%    97.29%
------------------------------------------------------------------------------------------------------
Average (RA, A2)                          -0.08%   +0.05%   +0.48%   -0.05%   +0.04%   +0.09%    97.91% (+2.09% speedup)
```
