# AV2 Speed Optimization: Cloud EDA Performance Report (Patches 0020–0024)
## Strict Individual Set Evaluation (Both A1 and A2 Must Pass Independently)

**Evaluation Date:** August 21, 2026  
**Baseline Anchor:** Commit [`5d628d840b`](file:///usr/local/google/home/chengchen/avm_worktree_2) (*"Promote WienerNS zero-refine to speed 1 (#5293)"*)  
**Test Configuration:** AOM CTC Random Access (RA), CTC v9  
**Individual Bar Requirements:**
- **Speed 1:** $\text{Ratio} \ge 35$ on **both** A1 (4K, 17f) and A2 (1080p, 33f)
- **Speed 3:** $\text{Ratio} \ge 25$ on **both** A1 (4K, 17f) and A2 (1080p, 33f)
- **Speed 4:** $\text{Ratio} \ge 20$ on **both** A1 (4K, 17f) and A2 (1080p, 33f)

$$\text{Tradeoff Ratio} = \frac{\text{EncSpeedup \%}}{\text{PSNR-YUV BD-Rate \%}}$$

---

## 1. Executive Summary & Qualification Matrix

| Patch | Branch | Test Preset | Target Bar | Set A1 (4K 17f) Metrics & Ratio | Set A2 (1080p 33f) Metrics & Ratio | Qualification Verdict |
| :--- | :--- | :---: | :---: | :--- | :--- | :---: |
| **Patch 0020**<br>*(Pyramid-Gated Ext Part)* | [`experiment/patch_0020`](file:///usr/local/google/home/chengchen/avm_worktree_2) | **Speed 1** | **$\ge 35$** | **+2.02%** speedup, +0.00% BD<br>Ratio: **Pure Gain** (<font color="green">**PASS A1**</font>) | **+0.71%** speedup, -0.00% BD<br>Ratio: **Pure Gain** (<font color="green">**PASS A2**</font>) | **MARGINAL WIN**<br>(Nearly bit-identical; modest speedup) |
| **Patch 0021**<br>*(Disable Uneven 4-Way)* | [`experiment/patch_0021`](file:///usr/local/google/home/chengchen/avm_worktree_2) | **Speed 1** | **$\ge 35$** | **+6.23%** speedup, +0.03% BD<br>Ratio: **207.7** (<font color="green">**PASS A1**</font>) | **+6.70%** speedup, +0.06% BD<br>Ratio: **111.7** (<font color="green">**PASS A2**</font>) | <font color="green">**FULLY QUALIFIED / PASS**</font><br>(Exceeds bar by 3.2x to 5.9x on both sets!) |
| **Patch 0023**<br>*(Dry Pass Tool Reduction)* | [`experiment/patch_0023`](file:///usr/local/google/home/chengchen/avm_worktree_2) | **Speed 3** | **$\ge 25$** | **+6.16%** speedup, +0.59% BD<br>Ratio: **10.4** (<font color="red">**FAIL A1**</font>) | **+6.14%** speedup, +0.57% BD<br>Ratio: **10.8** (<font color="red">**FAIL A2**</font>) | <font color="red">**DISQUALIFIED / FAIL**</font><br>(Both A1 & A2 miss bar 25) |
| **Patch 0024**<br>*(TX Ranking w/o Trellis)* | [`experiment/patch_0024`](file:///usr/local/google/home/chengchen/avm_worktree_2) | **Speed 4** | **$\ge 20$** | **0.00%** speedup, +0.00% BD<br>Ratio: **N/A** (0.00% delta) | **0.00%** speedup, +0.00% BD<br>Ratio: **N/A** (0.00% delta) | **NO-OP / RETIRED**<br>(Path not reached in CTC RA) |

---

## 2. Invocations & Traceability Matrix

| Arm | Git Commit | Test Tag | Invocations (A1 17f / A2 33f) | User Console Links |
| :--- | :---: | :--- | :--- | :--- |
| **Baseline (Speed 1)** | [`5d628d840b`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `av2_enc_5d628d_base` | `2a44b2c1-6cc3-4713-bbdc-b17f56b93611`<br>`2ed1a651-af4c-4ae7-b4f7-a4380b18ba26` | [A1 Console](http://edacloud/invocations/2a44b2c1-6cc3-4713-bbdc-b17f56b93611)<br>[A2 Console](http://edacloud/invocations/2ed1a651-af4c-4ae7-b4f7-a4380b18ba26) |
| **Baseline (Speed 3)** | [`5d628d840b`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `av2_enc_5d628d_base` | `757fcc44-17cc-4369-bd2d-74cc7bad75bf`<br>`cee363a0-2f0e-43df-b049-009fb21cbdb0` | [A1 Console](http://edacloud/invocations/757fcc44-17cc-4369-bd2d-74cc7bad75bf)<br>[A2 Console](http://edacloud/invocations/cee363a0-2f0e-43df-b049-009fb21cbdb0) |
| **Baseline (Speed 4)** | [`5d628d840b`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `av2_enc_5d628d_base` | `14bad88f-d51e-4001-96bb-309a55fe55d3`<br>`84406324-4e23-4be2-bb50-205c2997a591` | [A1 Console](http://edacloud/invocations/14bad88f-d51e-4001-96bb-309a55fe55d3)<br>[A2 Console](http://edacloud/invocations/84406324-4e23-4be2-bb50-205c2997a591) |
| **Patch 0020 (Speed 1)** | [`1c3dbf4ac3`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `p0820_20_pyr_ext_part_s1` | `ebc7abb4-6232-43f4-b80b-bd874923bb37`<br>`93f09813-7597-414d-9630-4817c6e1ac30` | [A1 Console](http://edacloud/invocations/ebc7abb4-6232-43f4-b80b-bd874923bb37)<br>[A2 Console](http://edacloud/invocations/93f09813-7597-414d-9630-4817c6e1ac30) |
| **Patch 0021 (Speed 1)** | [`5c383134fe`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `p0820_21_dis_4way_s1` | `5724eb4c-197b-4769-b328-2d401e1efd10`<br>`498e160d-5dd1-42b0-ac51-0bd8c9edb6d6` | [A1 Console](http://edacloud/invocations/5724eb4c-197b-4769-b328-2d401e1efd10)<br>[A2 Console](http://edacloud/invocations/498e160d-5dd1-42b0-ac51-0bd8c9edb6d6) |
| **Patch 0023 (Speed 3)** | [`ba1bb7f8ad`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `p0820_23_dry_pass_tools_s3` | `acd1b3b0-bf28-4709-9988-876c6f23d325`<br>`44605777-8f82-428d-b3e5-a16ee106b1af` | [A1 Console](http://edacloud/invocations/acd1b3b0-bf28-4709-9988-876c6f23d325)<br>[A2 Console](http://edacloud/invocations/44605777-8f82-428d-b3e5-a16ee106b1af) |
| **Patch 0024 (Speed 4)** | [`c972fe50a0`](file:///usr/local/google/home/chengchen/avm_worktree_2) | `p0820_24_tx_no_trellis_s4` | `c94e5743-2e44-4ba8-9a5d-415b9bcfd177`<br>`592c0e85-02bd-4b6e-ad1b-ac6e66043c41` | [A1 Console](http://edacloud/invocations/c94e5743-2e44-4ba8-9a5d-415b9bcfd177)<br>[A2 Console](http://edacloud/invocations/592c0e85-02bd-4b6e-ad1b-ac6e66043c41) |

---

## 3. Per-Patch Performance Breakdown

### Patch 0021: Disable Uneven 4-Way Partitions at Speed 1
> [!IMPORTANT]
> **Key Finding:** By disabling only the speculative uneven 4-way shapes (`HORZ_4A/4B`, `VERT_4A/4B`), Patch 0021 achieves extraordinary efficiency at Speed 1:
> - **A1 (4K, 17f):** **+6.23% speedup** with only **+0.03% PSNR-YUV** $\rightarrow$ **Ratio = 207.7** (Bar: 35) $\rightarrow$ <font color="green">**PASS**</font>
> - **A2 (1080p, 33f):** **+6.70% speedup** with only **+0.06% PSNR-YUV** $\rightarrow$ **Ratio = 111.7** (Bar: 35) $\rightarrow$ <font color="green">**PASS**</font>

#### Sequence Breakdown: A1 (4K, 17 frames, Speed 1)
| Sequence | PSNR-Y | PSNR-U | PSNR-V | PSNR-YUV | SSIM | VMAF | EncTime (Speedup) | Ratio |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| BoxingPractice_3840x2160_5994fps_10bit | +0.26% | +0.52% | -1.49% | +0.16% | +0.25% | +0.49% | 91.56% (+8.44%) | 52.8 |
| Crosswalk_3840x2160_5994fps_10bit_420 | -0.18% | +0.28% | +0.68% | -0.09% | -0.45% | -0.52% | 94.72% (+5.28%) | Pure Gain |
| FoodMarket2_3840x2160_5994fps_10bit_42 | -0.17% | -0.35% | -0.61% | -0.21% | -0.00% | +0.25% | 95.93% (+4.07%) | Pure Gain |
| Neon1224_3840x2160_2997fps | -0.05% | +0.18% | +0.15% | -0.02% | -0.10% | +0.22% | 94.64% (+5.36%) | Pure Gain |
| NocturneDance_3840x2160p_10bit_60fps | +0.03% | +0.32% | +1.37% | +0.08% | +0.04% | +0.92% | 92.28% (+7.72%) | 96.5 |
| PierSeaSide_3840x2160_2997fps_10bit_42 | +0.66% | +0.92% | -0.02% | +0.65% | +0.56% | +0.05% | 93.65% (+6.35%) | 9.8 |
| Tango_3840x2160_5994fps_10bit_420 | -0.36% | -0.72% | -0.60% | -0.39% | -0.27% | +0.15% | 94.58% (+5.42%) | Pure Gain |
| TimeLapse_3840x2160_5994fps_10bit_420 | -0.03% | +1.26% | +0.09% | +0.04% | -0.06% | +0.58% | 92.88% (+7.12%) | 178.0 |
| **Average (A1, 4K)** | **+0.02%** | **+0.30%** | **-0.05%** | **+0.03%** | **-0.00%** | **+0.27%** | **93.77% (+6.23%)** | **207.7 (PASS $\ge 35$)** |

#### Sequence Breakdown: A2 (1080p, 33 frames, Speed 1)
| Sequence | PSNR-Y | PSNR-U | PSNR-V | PSNR-YUV | SSIM | VMAF | EncTime (Speedup) | Ratio |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Aerial3200_1920x1080_5994_10bit_420 | +0.22% | -0.47% | +0.70% | +0.21% | +0.11% | +0.42% | 92.92% (+7.08%) | 33.7 |
| Boat_1920x1080_5994_10bit_420 | +0.05% | -0.51% | +1.67% | +0.11% | -0.02% | +0.18% | 91.10% (+8.90%) | 80.9 |
| CrowdRun_1920x1080p50 | +0.03% | -0.36% | -0.47% | -0.01% | +0.08% | +0.12% | 89.96% (+10.04%) | Pure Gain |
| DinnerSceneCropped_1920x1080_2997fps | -0.21% | -0.15% | -1.21% | -0.27% | -0.30% | -0.06% | 96.46% (+3.54%) | Pure Gain |
| FoodMarket_1920x1080_5994_10bit_420 | -0.24% | -1.35% | -1.20% | -0.34% | -0.26% | -0.40% | 93.30% (+6.70%) | Pure Gain |
| GregoryScarf_1080x1920p30_yuv420p10le | -0.01% | -0.19% | +0.82% | +0.02% | +0.05% | +0.04% | 95.45% (+4.55%) | 227.5 |
| MeridianTalk_sdr_1920x1080p_5994_10bit | -0.08% | +1.33% | +1.31% | +0.07% | -0.23% | -2.08% | 93.79% (+6.21%) | 88.7 |
| Motorcycle_1920x1080_30fps_8bit | +0.00% | +0.09% | +0.87% | +0.04% | +0.02% | -0.16% | 92.00% (+8.00%) | 200.0 |
| OldTownCross_1920x1080p50 | +0.50% | -1.76% | +1.54% | +0.49% | +0.59% | +0.08% | 91.51% (+8.49%) | 17.3 |
| PedestrianArea_1920x1080p25 | -0.26% | +0.44% | +1.56% | -0.12% | -0.24% | +0.85% | 94.74% (+5.26%) | Pure Gain |
| RitualDance_1920x1080_5994_10bit_420 | +0.12% | -0.55% | +0.92% | +0.13% | -0.01% | -0.10% | 96.66% (+3.34%) | 25.7 |
| Riverbed_1920x1080p25 | -0.01% | +0.38% | +4.36% | +0.09% | +0.07% | +0.49% | 96.02% (+3.98%) | 44.2 |
| RushFieldCuts_1920x1080_2997 | +0.14% | +0.88% | -0.51% | +0.15% | +0.12% | +0.40% | 90.87% (+9.13%) | 60.9 |
| Skater227_1920x1080_30fps | +0.29% | -1.29% | -0.77% | +0.12% | +0.25% | +0.58% | 98.37% (+1.63%) | 13.6 |
| ToddlerFountainCropped_1080x1080p2997 | +0.02% | -3.09% | +0.50% | -0.06% | +0.08% | +0.93% | 92.80% (+7.20%) | Pure Gain |
| TreesAndGrass_1920_1080_30fps_8bit | +0.05% | +0.78% | -1.81% | +0.03% | +0.15% | +0.20% | 91.41% (+8.59%) | 286.3 |
| TunnelFlag_1920x1080_5994_10bit_420 | +0.20% | +0.34% | -1.36% | +0.15% | +0.27% | +0.32% | 91.10% (+8.90%) | 59.3 |
| Vertical_bees_1080x1920_2997 | +0.19% | -0.24% | +0.12% | +0.16% | +0.08% | -0.10% | 91.68% (+8.32%) | 52.0 |
| WorldCup_1920x1080_30p | +0.30% | +0.06% | -1.28% | +0.21% | +0.22% | +0.83% | 93.13% (+6.87%) | 32.7 |
| **Average (A2, 1080p)** | **+0.07%** | **-0.30%** | **+0.30%** | **+0.06%** | **+0.05%** | **+0.13%** | **93.30% (+6.70%)** | **111.7 (PASS $\ge 35$)** |

---

### Patch 0020: Pyramid-Gated Extended Partitions at Speed 1
> [!NOTE]
> **Finding:** Gating by `pyramid_level >= 3` protects almost all frames in RA CTC, resulting in an almost bit-identical stream (+0.00% BD-rate) with a modest +0.7% to +2.0% speedup. It passes technically, but leaves most of the partition search speedup untapped.

---

### Patch 0023: Dry Pass Tool Reduction at Speed 3
> [!CAUTION]
> **Finding:** Disabling wedge, warp modes, and reducing precisions in the dry pass causes too much ranking distortion:
> - **A1 (4K):** +0.59% PSNR-YUV for +6.16% speedup $\rightarrow$ Ratio **10.4** (<font color="red">**FAIL < 25**</font>)
> - **A2 (1080p):** +0.57% PSNR-YUV for +6.14% speedup $\rightarrow$ Ratio **10.8** (<font color="red">**FAIL < 25**</font>)

---

### Patch 0024: Transform-Type Ranking Without Trellis at Speed 4
> [!NOTE]
> **Finding:** Call site in `tx_search.c` is not reached on standard CTC RA content (`prune_tx_type_est_rd = 1` with `num_allowed > 2`). Result is identically `+0.00%` on all sequences.

---

## 4. Summary & Recommendation

1. **Prioritize Landing Patch 0021 (`disable_uneven_4way_partitions` @ Speed 1)**:
   - Delivers a clean **+6.5% overall speedup** with virtually **zero quality degradation (+0.03% to +0.06% BD-rate)**.
   - Clears the strict individual threshold with ratios of **207.7 on 4K A1** and **111.7 on 1080p A2** (both $\gg 35$).
2. **Retire Patch 0023 and Patch 0024**.
