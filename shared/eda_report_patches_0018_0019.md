# AV2 Speed Optimization: Cloud EDA Performance Report (Patches 0018 & 0019)
## Strict Individual Set Evaluation (Speed 1 Bar: Ratio $\ge 35$ on both A1 and A2)

**Evaluation Date:** August 20, 2026  
**Baseline Anchor:** Commit [`ea89c216c6`](file:///usr/local/google/home/chengchen/avm_worktree_2) (*"Fast warp delta search for four and six param models in warp newmv (#5272)"*)  
**Test Configuration:** AOM CTC Random Access (RA), CTC v9  
**Individual Bar Requirement:** Both A1 (4K, 17f) and A2 (1080p, 33f) must achieve **$\text{Ratio} \ge 35$** independently.

---

## 1. Executive Qualification Summary

| Patch | Target Speed | Required Bar | Set A1 (4K 17f) Metrics | Set A1 Ratio & Status | Set A2 (1080p 33f) Metrics | Set A2 Ratio & Status | Final Qualification Status |
| :--- | :---: | :---: | :--- | :---: | :--- | :---: | :---: |
| **Patch 0018**<br>*(Exhaustive MV Thresh)* | **Speed 1** | **$\ge 35$** | +0.00% PSNR-YUV<br>+0.00% speedup | **N/A**<br>(Merged upstream) | +0.00% PSNR-YUV<br>+0.00% speedup | **N/A**<br>(Merged upstream) | **RETIRED**<br>(PR #5263 already in base) |
| **Patch 0019**<br>*(Disable Ext Partitions)* | **Speed 1** | **$\ge 35$** | **+15.92%** speedup<br>+0.52% PSNR-YUV | **30.6** (Misses 35)<br><font color="red">**FAIL (A1)**</font> | **+22.75%** speedup<br>+0.60% PSNR-YUV | **37.9** (Passes 35)<br><font color="green">**PASS (A2)**</font> | <font color="red">**DISQUALIFIED / FAIL**</font><br>(A1 misses bar 35) |

---

## 2. Invocations & Traceability Matrix

| Arm | Git Commit | Test Tag | Invocations (A1 17f / A2 33f) | User Console Links |
| :--- | :---: | :--- | :--- | :--- |
| **Baseline (Speed 1)** | [`ea89c216c6`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `av2_enc_ea89c2_base` | `68225cd1-34f2-41cb-8cf2-c0bc19dea412`<br>`feca0b47-12a6-4d57-8223-c49a926afa28` | [A1 Console](http://edacloud/invocations/68225cd1-34f2-41cb-8cf2-c0bc19dea412)<br>[A2 Console](http://edacloud/invocations/feca0b47-12a6-4d57-8223-c49a926afa28) |
| **Patch 0018 (Speed 1)** | [`d0156da856`](file:///usr/local/google/home/chengchen/av2/avm) | `p0819_18_exh_mv_s1` | `d30a784f-7c4e-4ccd-bc1a-584a2eec0a11`<br>`ab04fcfa-0774-43c9-864d-f03eaff935f1` | [A1 Console](http://edacloud/invocations/d30a784f-7c4e-4ccd-bc1a-584a2eec0a11)<br>[A2 Console](http://edacloud/invocations/ab04fcfa-0774-43c9-864d-f03eaff935f1) |
| **Patch 0019 (Speed 1)** | [`b242538361`](file:///usr/local/google/home/chengchen/av2/avm) | `p0819_19_dis_ext_part_s1` | `f1c41266-0fdd-4fa8-9bf2-15fb3ff320a5`<br>`57217d77-3d10-4960-8357-1d4ada268c22` | [A1 Console](http://edacloud/invocations/f1c41266-0fdd-4fa8-9bf2-15fb3ff320a5)<br>[A2 Console](http://edacloud/invocations/57217d77-3d10-4960-8357-1d4ada268c22) |

---

## 3. Per-Patch Performance Breakdown

### Patch 0018: Exhaustive MV Search Threshold at Speed 1
> [!NOTE]
> **Root Cause:** Commit [`14a892d0`](file:///usr/local/google/home/chengchen/av2/avm) (PR #5263) was already merged into the upstream baseline, updating `sf->mv_sf.exhaustive_searches_thresh` to `(1 << 26)`. Patch 0018 is functionally equivalent to baseline.

- **A1 (4K, 17f)**: PSNR-YUV `+0.00%`, EncTime `100.93%` (no change).
- **A2 (1080p, 33f)**: PSNR-YUV `+0.00%`, EncTime `100.20%` (no change).

---

### Patch 0019: Disable Extended Partitions at Speed 1
> [!CAUTION]
> **Strict Qualification Assessment:**
> - **A2 (1080p, 33f):** Achieves **+22.75% speedup** for **+0.60% BD-rate**, yielding a ratio of **37.9** $\rightarrow$ <font color="green">**PASS (37.9 > 35)**</font>.
> - **A1 (4K, 17f):** Achieves **+15.92% speedup** for **+0.52% BD-rate**, yielding a ratio of **30.6** $\rightarrow$ <font color="red">**FAIL (30.6 < 35)**</font>.
> - **Conclusion:** Because **both A1 and A2 must individually pass**, Patch 0019 does not qualify in its unconstrained form.
> - **Recommendation:** Explore enabling `disable_ext_partitions` at Speed 1 only for non-4K resolutions (e.g. `!is_720p_or_larger` or `is_1080p_or_smaller`).

#### Sequence Breakdown: A1 (4K, 17 frames, Speed 1)
| Sequence | PSNR-Y | PSNR-U | PSNR-V | PSNR-YUV | SSIM | VMAF | EncTime (Speedup) | Ratio | Individual Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| BoxingPractice_3840x2160_5994fps_10bit | +0.83% | +0.88% | +0.97% | +0.84% | +0.90% | +1.75% | 80.62% (+19.38%) | 23.1 | FAIL |
| Crosswalk_3840x2160_5994fps_10bit_420 | -0.26% | -0.59% | +1.16% | -0.17% | -0.03% | -0.40% | 86.70% (+13.30%) | Gain | PASS |
| FoodMarket2_3840x2160_5994fps_10bit_42 | +0.21% | +0.23% | +0.52% | +0.23% | +0.40% | -0.41% | 85.00% (+15.00%) | 65.2 | PASS |
| Neon1224_3840x2160_2997fps | +0.49% | +0.31% | +0.75% | +0.50% | +0.63% | +0.62% | 83.91% (+16.09%) | 32.2 | FAIL |
| NocturneDance_3840x2160p_10bit_60fps | +0.72% | +0.39% | +1.94% | +0.75% | +0.79% | +0.23% | 83.12% (+16.88%) | 22.5 | FAIL |
| PierSeaSide_3840x2160_2997fps_10bit_42 | +1.21% | +1.20% | +1.51% | +1.22% | +1.33% | +1.06% | 83.63% (+16.37%) | 13.4 | FAIL |
| Tango_3840x2160_5994fps_10bit_420 | +0.03% | -0.32% | +0.26% | +0.03% | +0.12% | +0.87% | 86.29% (+13.71%) | 457.0 | PASS |
| TimeLapse_3840x2160_5994fps_10bit_420 | +0.76% | +0.76% | +1.46% | +0.80% | +0.85% | +0.67% | 83.56% (+16.44%) | 20.6 | FAIL |
| **Average (A1, 4K)** | **+0.50%** | **+0.36%** | **+1.07%** | **+0.52%** | **+0.62%** | **+0.55%** | **84.08% (+15.92%)** | **30.6** | <font color="red">**FAIL (< 35)**</font> |

#### Sequence Breakdown: A2 (1080p, 33 frames, Speed 1)
| Sequence | PSNR-Y | PSNR-U | PSNR-V | PSNR-YUV | SSIM | VMAF | EncTime (Speedup) | Ratio | Individual Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Aerial3200_1920x1080_5994_10bit_420 | +0.54% | +0.66% | +0.93% | +0.56% | +0.54% | +0.25% | 74.79% (+25.21%) | 45.0 | PASS |
| Boat_1920x1080_5994_10bit_420 | +0.50% | +2.12% | +0.71% | +0.58% | +0.35% | +0.75% | 70.51% (+29.49%) | 50.8 | PASS |
| CrowdRun_1920x1080p50 | +0.69% | +1.01% | +1.84% | +0.76% | +0.62% | +0.86% | 70.23% (+29.77%) | 39.2 | PASS |
| DinnerSceneCropped_1920x1080_2997fps | +0.44% | -2.13% | +5.13% | +0.64% | +0.20% | +0.15% | 84.84% (+15.16%) | 23.7 | FAIL |
| FoodMarket_1920x1080_5994_10bit_420 | +0.74% | +1.62% | +0.72% | +0.77% | +0.84% | +0.21% | 76.94% (+23.06%) | 29.9 | FAIL |
| GregoryScarf_1080x1920p30_yuv420p10le | +0.45% | +1.04% | +0.41% | +0.48% | +0.41% | +1.29% | 78.25% (+21.75%) | 45.3 | PASS |
| MeridianTalk_sdr_1920x1080p_5994_10bit | +0.07% | +3.46% | +0.45% | +0.19% | +0.83% | +3.20% | 77.86% (+22.14%) | 116.5 | PASS |
| Motorcycle_1920x1080_30fps_8bit | +0.43% | +0.61% | +0.92% | +0.46% | +0.56% | +0.66% | 71.95% (+28.05%) | 61.0 | PASS |
| OldTownCross_1920x1080p50 | +1.12% | +0.17% | +1.80% | +1.13% | +1.12% | +1.77% | 77.95% (+22.05%) | 19.5 | FAIL |
| PedestrianArea_1920x1080p25 | +0.58% | -0.23% | -0.23% | +0.49% | +0.73% | +0.79% | 82.22% (+17.78%) | 36.3 | PASS |
| RitualDance_1920x1080_5994_10bit_420 | +0.77% | +1.72% | +0.04% | +0.77% | +0.81% | +0.95% | 81.35% (+18.65%) | 24.2 | FAIL |
| Riverbed_1920x1080p25 | +0.19% | +1.19% | +1.06% | +0.24% | +0.12% | -0.38% | 79.67% (+20.33%) | 84.7 | PASS |
| RushFieldCuts_1920x1080_2997 | +0.83% | +1.72% | +0.29% | +0.84% | +0.71% | +1.15% | 73.58% (+26.42%) | 31.5 | FAIL |
| Skater227_1920x1080_30fps | +0.15% | -0.73% | -1.14% | +0.01% | +0.07% | -1.29% | 93.77% (+6.23%) | 623.0 | PASS |
| ToddlerFountainCropped_1080x1080p2997 | +0.25% | +3.60% | +1.57% | +0.38% | +0.24% | +0.79% | 73.26% (+26.74%) | 70.4 | PASS |
| TreesAndGrass_1920_1080_30fps_8bit | +0.35% | +0.64% | +0.52% | +0.37% | +0.42% | -0.05% | 71.73% (+28.27%) | 76.4 | PASS |
| TunnelFlag_1920x1080_5994_10bit_420 | +1.22% | +1.94% | +3.87% | +1.33% | +1.27% | +1.76% | 75.93% (+24.07%) | 18.1 | FAIL |
| Vertical_bees_1080x1920_2997 | +0.78% | +0.40% | +1.32% | +0.79% | +0.76% | +0.55% | 79.00% (+21.00%) | 26.6 | FAIL |
| WorldCup_1920x1080_30p | +0.70% | -1.33% | +0.36% | +0.58% | +0.74% | +1.27% | 77.34% (+22.66%) | 39.1 | PASS |
| **Average (A2, 1080p)** | **+0.57%** | **+0.92%** | **+1.08%** | **+0.60%** | **+0.60%** | **+0.77%** | **77.25% (+22.75%)** | **37.9** | <font color="green">**PASS (>= 35)**</font> |
