# AV2 Speed Optimization: Cloud EDA Performance Report (Patches 0013–0016)

**Evaluation Date:** August 19, 2026  
**Baseline Anchor:** Commit [`ea89c216c6`](file:///usr/local/google/home/chengchen/avm_worktree_2) (*"Fast warp delta search for four and six param models in warp newmv (#5272)"*)  
**Test Configuration:** AOM CTC Random Access (RA), CTC v9  
**Testsets:** A1 (4K, 17 frames), A2 (1080p, 33 frames)

---

## 1. Executive Summary

| Patch | Branch | Test Preset | Testset | PSNR-Y | PSNR-U | PSNR-V | PSNR-YUV | SSIM | VMAF | EncTime (Speedup) | Tradeoff Ratio | Target Bar | Recommendation |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Patch 0013**<br>*(DC Pred L2)* | [`experiment/patch_0013`](file:///usr/local/google/home/chengchen/avm_worktree_2) | **Speed 3** | **A1** (17f)<br>**A2** (33f) | +0.04%<br>+0.03% | -0.14%<br>-0.36% | +0.27%<br>-0.34% | **+0.04%**<br>**-0.00%** | -0.00%<br>-0.00% | -0.03%<br>+0.07% | 94.78% (**+5.22%**)<br>98.01% (**+1.99%**) | **130.5**<br>**Pure Gain** | **25** | **LAND** (Exceeds bar by 5.2x) |
| **Patch 0014**<br>*(Warp Diamond)* | [`experiment/patch_0014`](file:///usr/local/google/home/chengchen/avm_worktree_2) | **Speed 3** | **A1** (17f)<br>**A2** (33f) | -0.04%<br>+0.02% | +0.02%<br>+0.10% | +0.12%<br>-0.11% | **-0.03%**<br>**+0.02%** | +0.01%<br>+0.03% | -0.02%<br>-0.05% | 99.46% (**+0.54%**)<br>99.63% (**+0.37%**) | **Pure Gain**<br>**18.5** | **25** | **BORDERLINE** (Modest +0.4% speedup) |
| **Patch 0015**<br>*(TX Stat Pruning)* | [`experiment/patch_0015`](file:///usr/local/google/home/chengchen/avm_worktree_2) | **Speed 2** | **A1** (17f)<br>**A2** (33f) | +0.19%<br>+0.17% | +0.23%<br>-0.15% | -0.51%<br>-0.49% | **+0.16%**<br>**+0.13%** | +0.24%<br>+0.23% | +0.26%<br>+0.08% | 95.98% (**+4.02%**)<br>95.54% (**+4.46%**) | **25.1**<br>**34.3** | **30** | **PASS ON A2** (+4.3% speedup, ratio 34.3 > 30) |
| **Patch 0016**<br>*(Remove Pure Loss)* | [`experiment/patch_0016`](file:///usr/local/google/home/chengchen/avm_worktree_2) | **Speed 4** | **A1** (17f)<br>**A2** (33f) | -0.06%<br>-0.12% | -0.28%<br>-0.41% | -0.31%<br>-0.11% | **-0.08%**<br>**-0.14%** | -0.04%<br>-0.14% | -0.19%<br>-0.23% | 101.72% (**-1.72%**)<br>102.00% (**-2.00%**) | **Quality Gain**<br>**Quality Gain** | **N/A** | **LAND** (Recovers -0.14% BD at 1.8% time cost) |

---

## 2. Invocations & Traceability Matrix

| Arm | Git Commit | Test Tag | Invocations (A1 17f / A2 33f) | User Console Links |
| :--- | :---: | :--- | :--- | :--- |
| **Baseline (Speed 1)** | [`ea89c216c6`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `av2_enc_ea89c2_base` | `68225cd1-34f2-41cb-8cf2-c0bc19dea412`<br>`feca0b47-12a6-4d57-8223-c49a926afa28` | [A1 Console](http://edacloud/invocations/68225cd1-34f2-41cb-8cf2-c0bc19dea412)<br>[A2 Console](http://edacloud/invocations/feca0b47-12a6-4d57-8223-c49a926afa28) |
| **Baseline (Speed 2)** | [`ea89c216c6`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `av2_enc_ea89c2_base` | `2241dac0-3a98-4438-a7c1-8a833cb5a293`<br>`6da701c1-bf8a-4861-a166-7881f5c20bd5` | [A1 Console](http://edacloud/invocations/2241dac0-3a98-4438-a7c1-8a833cb5a293)<br>[A2 Console](http://edacloud/invocations/6da701c1-bf8a-4861-a166-7881f5c20bd5) |
| **Baseline (Speed 3)** | [`ea89c216c6`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `av2_enc_ea89c2_base` | `4523d0df-bad2-4366-8225-17830d182459`<br>`e7d344d8-b7fb-4098-9a13-967ee5391bc4` | [A1 Console](http://edacloud/invocations/4523d0df-bad2-4366-8225-17830d182459)<br>[A2 Console](http://edacloud/invocations/e7d344d8-b7fb-4098-9a13-967ee5391bc4) |
| **Baseline (Speed 4)** | [`ea89c216c6`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `av2_enc_ea89c2_base` | `83003c2e-0e40-4230-a70d-e445cc7cbe33`<br>`cdc99e11-6461-409e-9725-49384b4b7d83` | [A1 Console](http://edacloud/invocations/83003c2e-0e40-4230-a70d-e445cc7cbe33)<br>[A2 Console](http://edacloud/invocations/cdc99e11-6461-409e-9725-49384b4b7d83) |
| **Patch 0013 (Speed 3)** | [`707cdbf4b0`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `p0818_13_dc_pred_s3` | `22965f70-0b4c-4019-be6e-1913557cb961`<br>`8e927034-1914-4efa-b602-a90009aec63f` | [A1 Console](http://edacloud/invocations/22965f70-0b4c-4019-be6e-1913557cb961)<br>[A2 Console](http://edacloud/invocations/8e927034-1914-4efa-b602-a90009aec63f) |
| **Patch 0014 (Speed 3)** | [`e47417551a`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `p0818_14_warp_dia_s3` | `94deacd2-327c-457b-9609-a681045197ad`<br>`c92a97be-0f8c-4e21-8355-3ff03d84fd61` | [A1 Console](http://edacloud/invocations/94deacd2-327c-457b-9609-a681045197ad)<br>[A2 Console](http://edacloud/invocations/c92a97be-0f8c-4e21-8355-3ff03d84fd61) |
| **Patch 0015 (Speed 2)** | [`0dbcb33438`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `p0818_15_tx_stat_s2` | `be451528-d07c-43fd-8f44-914e293866a6`<br>`bb367a46-7b49-4f42-900a-a44306221e6f` | [A1 Console](http://edacloud/invocations/be451528-d07c-43fd-8f44-914e293866a6)<br>[A2 Console](http://edacloud/invocations/bb367a46-7b49-4f42-900a-a44306221e6f) |
| **Patch 0016 (Speed 4)** | [`a722a28d10`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `p0818_16_rm_loss_s4` | `3bd164af-6055-43d9-956f-9f6add1308ce`<br>`924d5422-fc2a-4a4e-9012-8b0618b9f5e8` | [A1 Console](http://edacloud/invocations/3bd164af-6055-43d9-956f-9f6add1308ce)<br>[A2 Console](http://edacloud/invocations/924d5422-fc2a-4a4e-9012-8b0618b9f5e8) |

---

## 3. Per-Patch Performance Breakdown

### Patch 0013: DC Block Prediction Level 2 at Speed 3
> [!TIP]
> **Key Finding:** Setting `dc_blk_pred_level = 2` at Speed 3 yields substantial speedups (+5.22% on 4K, +1.99% on 1080p) with virtually zero quality penalty.

#### Sequence Breakdown: A1 (4K, 17 frames, Speed 3)
| Sequence | PSNR-Y | PSNR-U | PSNR-V | PSNR-YUV | SSIM | VMAF | EncTime |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| BoxingPractice_3840x2160_5994fps_10bit | +0.01% | -0.04% | +0.49% | +0.05% | +0.07% | +0.01% | 90.19% |
| Crosswalk_3840x2160_5994fps_10bit_420 | -0.27% | +1.40% | +1.14% | -0.06% | -0.53% | -0.37% | 94.64% |
| FoodMarket2_3840x2160_5994fps_10bit_420 | -0.04% | +1.40% | -0.16% | +0.03% | -0.26% | +0.17% | 96.03% |
| Neon1224_3840x2160_2997fps | +0.04% | +0.07% | +0.06% | +0.04% | +0.19% | +0.27% | 93.21% |
| NocturneDance_3840x2160p_10bit_60fps | -0.02% | -0.07% | +0.94% | +0.01% | -0.02% | -0.08% | 97.22% |
| PierSeaSide_3840x2160_2997fps_10bit_420 | +0.27% | -0.14% | +0.30% | +0.25% | +0.16% | -0.34% | 97.22% |
| Tango_3840x2160_5994fps_10bit_420 | +0.32% | -3.44% | -0.47% | +0.04% | +0.22% | +0.35% | 93.78% |
| TimeLapse_3840x2160_5994fps_10bit_420 | +0.02% | -0.30% | -0.15% | -0.01% | +0.16% | -0.29% | 96.13% |
| **Average (A1)** | **+0.04%** | **-0.14%** | **+0.27%** | **+0.04%** | **-0.00%** | **-0.03%** | **94.78% (+5.22%)** |

#### Sequence Breakdown: A2 (1080p, 33 frames, Speed 3)
| Sequence | PSNR-Y | PSNR-U | PSNR-V | PSNR-YUV | SSIM | VMAF | EncTime |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Aerial3200_1920x1080_5994_10bit_420 | -0.02% | -0.47% | +2.04% | +0.03% | +0.03% | +0.40% | 98.63% |
| Boat_1920x1080_5994_10bit_420 | +0.01% | -0.12% | +0.15% | +0.01% | -0.05% | -0.14% | 98.81% |
| CrowdRun_1920x1080p50 | +0.03% | -0.09% | -1.03% | -0.02% | -0.14% | +0.03% | 98.69% |
| DinnerSceneCropped_1920x1080_2997fps | -0.22% | -2.48% | -1.52% | -0.41% | -0.17% | -0.93% | 100.32% |
| FoodMarket_1920x1080_5994_10bit_420 | -0.05% | -1.31% | +0.08% | -0.10% | -0.22% | +0.16% | 96.37% |
| GregoryScarf_1080x1920p30_yuv420p10le | -0.08% | -0.43% | -0.32% | -0.12% | -0.09% | -0.29% | 98.70% |
| MeridianTalk_sdr_1920x1080p_5994_10bit | +0.35% | +0.91% | +3.02% | +0.57% | +0.44% | +2.04% | 97.52% |
| Motorcycle_1920x1080_30fps_8bit | +0.03% | -0.10% | -1.18% | -0.02% | +0.03% | +0.15% | 98.04% |
| OldTownCross_1920x1080p50 | +0.16% | -0.05% | -0.74% | +0.11% | +0.11% | -0.52% | 98.09% |
| PedestrianArea_1920x1080p25 | -0.24% | -0.12% | -0.52% | -0.25% | -0.53% | -0.12% | 93.20% |
| RitualDance_1920x1080_5994_10bit_420 | +0.06% | -0.33% | -0.06% | +0.04% | +0.06% | +0.79% | 96.87% |
| Riverbed_1920x1080p25 | +0.10% | -1.00% | -0.89% | +0.04% | +0.10% | -0.05% | 95.22% |
| RushFieldCuts_1920x1080_2997 | +0.08% | +0.23% | -0.16% | +0.08% | +0.04% | -0.07% | 98.02% |
| Skater227_1920x1080_30fps | +0.13% | -1.59% | -3.25% | -0.18% | -0.09% | -0.18% | 95.05% |
| ToddlerFountainCropped_1080x1080p2997 | -0.04% | +0.63% | -5.88% | -0.16% | +0.03% | -0.82% | 98.57% |
| TreesAndGrass_1920_1080_30fps_8bit | +0.14% | +0.69% | +2.10% | +0.23% | +0.16% | +0.60% | 100.10% |
| TunnelFlag_1920x1080_5994_10bit_420 | -0.08% | -0.47% | +1.46% | -0.02% | +0.15% | -0.58% | 97.88% |
| Vertical_bees_1080x1920_2997 | +0.08% | -0.52% | +1.80% | +0.13% | +0.12% | +0.53% | 101.74% |
| WorldCup_1920x1080_30p | +0.10% | -0.24% | -1.64% | +0.00% | -0.05% | +0.38% | 100.78% |
| **Average (A2)** | **+0.03%** | **-0.36%** | **-0.34%** | **-0.00%** | **-0.00%** | **+0.07%** | **98.01% (+1.99%)** |

---

### Patch 0014: Warp Search Diamond Pattern at Speed 3
> [!NOTE]
> **Key Finding:** Promotes diamond warp search to Speed 3. Yields a modest speedup (+0.37%–+0.54%) with neutral BD-rate.

#### Summary Across Sets:
- **A1 (4K)**: **+0.54% speedup**, **-0.03% PSNR-YUV** (neutral / slight gain).
- **A2 (1080p)**: **+0.37% speedup**, **+0.02% PSNR-YUV**, Ratio = **18.5** (Target Bar: 25).

---

### Patch 0015: Transform-Statistics Pruning at Speed 2
> [!IMPORTANT]
> **Key Finding:** Promotes transform-statistics pruning to Speed 2. Consistently achieves **+4.0% to +4.5% speedup**. On 1080p (A2), it scores a ratio of **34.3**, beating the Speed 2 bar (30).

#### Sequence Breakdown: A2 (1080p, 33 frames, Speed 2)
| Sequence | PSNR-Y | PSNR-U | PSNR-V | PSNR-YUV | SSIM | VMAF | EncTime |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Aerial3200_1920x1080_5994_10bit_420 | +0.12% | -2.22% | -1.22% | -0.02% | +0.07% | -0.01% | 91.69% |
| Boat_1920x1080_5994_10bit_420 | +0.29% | -0.03% | -2.20% | +0.14% | +0.29% | +0.22% | 99.60% |
| CrowdRun_1920x1080p50 | +0.14% | +0.50% | +0.17% | +0.16% | +0.08% | +0.42% | 94.32% |
| DinnerSceneCropped_1920x1080_2997fps | -0.12% | -0.92% | -2.04% | -0.27% | +0.14% | +0.34% | 93.91% |
| FoodMarket_1920x1080_5994_10bit_420 | -0.14% | +0.00% | -0.92% | -0.18% | -0.08% | -0.18% | 94.17% |
| GregoryScarf_1080x1920p30_yuv420p10le | -0.00% | +0.08% | +0.60% | +0.03% | -0.01% | -0.29% | 93.24% |
| MeridianTalk_sdr_1920x1080p_5994_10bit | +0.75% | +2.10% | +0.99% | +0.80% | +1.10% | +2.49% | 97.45% |
| Motorcycle_1920x1080_30fps_8bit | +0.17% | -0.95% | -0.43% | +0.10% | +0.30% | +0.05% | 92.60% |
| OldTownCross_1920x1080p50 | +0.41% | -0.27% | -0.45% | +0.35% | +0.16% | +0.76% | 92.64% |
| PedestrianArea_1920x1080p25 | +0.38% | +0.57% | +1.12% | +0.43% | +0.41% | +0.46% | 96.21% |
| RitualDance_1920x1080_5994_10bit_420 | +0.19% | +2.39% | -0.12% | +0.27% | +0.05% | +1.62% | 98.71% |
| Riverbed_1920x1080p25 | +0.07% | +0.17% | -3.95% | +0.01% | +0.14% | +0.06% | 94.37% |
| RushFieldCuts_1920x1080_2997 | +0.16% | -0.41% | +0.53% | +0.15% | +0.24% | -0.64% | 96.93% |
| Skater227_1920x1080_30fps | +0.40% | -1.00% | +0.42% | +0.31% | +0.88% | -1.51% | 99.34% |
| ToddlerFountainCropped_1080x1080p2997 | +0.27% | -1.83% | -0.11% | +0.19% | +0.31% | -0.32% | 93.91% |
| TreesAndGrass_1920_1080_30fps_8bit | +0.26% | +0.19% | +1.70% | +0.30% | +0.31% | +0.32% | 93.77% |
| TunnelFlag_1920x1080_5994_10bit_420 | -0.37% | -1.92% | -4.77% | -0.60% | -0.37% | -1.89% | 98.67% |
| Vertical_bees_1080x1920_2997 | -0.01% | +0.02% | +0.49% | +0.02% | -0.01% | -0.49% | 97.76% |
| WorldCup_1920x1080_30p | +0.32% | +0.58% | +0.94% | +0.36% | +0.35% | +0.02% | 96.61% |
| **Average (A2)** | **+0.17%** | **-0.15%** | **-0.49%** | **+0.13%** | **+0.23%** | **+0.08%** | **95.54% (+4.46%)** |

---

### Patch 0016: Remove Pure-Loss Speed Features at Speed 4
> [!TIP]
> **Key Finding:** Disabling 3 inefficient speed features recovers **-0.14% PSNR-YUV BD-rate** and **-0.23% VMAF** on A2, with a modest 2.0% encode time impact (13:1 quality recovery efficiency).

#### Sequence Breakdown: A2 (1080p, 33 frames, Speed 4)
| Sequence | PSNR-Y | PSNR-U | PSNR-V | PSNR-YUV | SSIM | VMAF | EncTime |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Aerial3200_1920x1080_5994_10bit_420 | -0.06% | -0.03% | -0.80% | -0.08% | -0.08% | +0.26% | 101.37% |
| Boat_1920x1080_5994_10bit_420 | +0.04% | -0.75% | -1.14% | -0.05% | +0.02% | +0.15% | 103.91% |
| CrowdRun_1920x1080p50 | -0.09% | -0.15% | +0.50% | -0.07% | -0.02% | +0.28% | 103.11% |
| DinnerSceneCropped_1920x1080_2997fps | -0.28% | -0.54% | -0.22% | -0.29% | +0.02% | -1.90% | 104.80% |
| FoodMarket_1920x1080_5994_10bit_420 | -0.13% | +0.05% | -1.13% | -0.17% | -0.11% | -0.75% | 101.60% |
| GregoryScarf_1080x1920p30_yuv420p10le | -0.18% | -0.38% | +0.23% | -0.18% | -0.25% | -0.89% | 101.51% |
| MeridianTalk_sdr_1920x1080p_5994_10bit | -0.45% | -0.44% | +0.03% | -0.41% | -0.54% | -1.90% | 102.92% |
| Motorcycle_1920x1080_30fps_8bit | -0.20% | +0.01% | +0.20% | -0.18% | -0.40% | +0.15% | 102.18% |
| OldTownCross_1920x1080p50 | -0.08% | -0.53% | -0.26% | -0.10% | -0.11% | -0.26% | 99.64% |
| PedestrianArea_1920x1080p25 | -0.14% | -0.26% | -0.12% | -0.14% | -0.27% | +0.98% | 101.88% |
| RitualDance_1920x1080_5994_10bit_420 | -0.26% | -1.25% | -1.43% | -0.36% | -0.35% | -0.06% | 100.42% |
| Riverbed_1920x1080p25 | -0.17% | -0.36% | -0.34% | -0.19% | -0.17% | -0.42% | 102.20% |
| RushFieldCuts_1920x1080_2997 | -0.09% | -0.37% | +0.65% | -0.08% | -0.08% | -0.17% | 103.19% |
| Skater227_1920x1080_30fps | +0.16% | -0.90% | +0.66% | +0.13% | -0.44% | +0.39% | 101.75% |
| ToddlerFountainCropped_1080x1080p2997 | -0.08% | -1.31% | +3.35% | -0.04% | +0.18% | +0.63% | 103.30% |
| TreesAndGrass_1920_1080_30fps_8bit | +0.03% | +0.20% | -0.89% | +0.01% | +0.13% | -0.16% | 101.48% |
| TunnelFlag_1920x1080_5994_10bit_420 | -0.08% | -1.57% | -1.66% | -0.20% | +0.12% | -0.41% | 101.06% |
| Vertical_bees_1080x1920_2997 | -0.29% | -0.25% | +0.73% | -0.23% | -0.12% | -0.72% | 97.70% |
| WorldCup_1920x1080_30p | -0.01% | +1.11% | -0.38% | +0.03% | -0.22% | +0.45% | 104.19% |
| **Average (A2)** | **-0.12%** | **-0.41%** | **-0.11%** | **-0.14%** | **-0.14%** | **-0.23%** | **102.00% (-2.00%)** |

---

## 4. Recommendations & Next Steps

1. **Prioritize Landing Patch 0013**: Promotes DC-block prediction level 2 to Speed 3 with outstanding efficiency (+5.22% on A1 with ratio 130.5; +1.99% on A2 with 0.00% BD-rate cost).
2. **Land Patch 0016 for Quality Recovery**: Disables ineffective shortcuts at Speed 4, recovering -0.14% BD-rate / -0.23% VMAF with negligible encode time overhead (~1.8%).
3. **Advance Patch 0015 for Speed 2**: Provides a strong +4.5% speedup at Speed 2 with ratio 34.3 on 1080p A2, clearing the Speed 2 bar (30).
4. **Patch 0014**: Delivers ~+0.4% speedup at Speed 3; can be included in a wider speed feature promotion bundle.
