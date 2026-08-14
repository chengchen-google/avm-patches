# AV2 Speedup Evaluation Report: Improved Patches (06c, 09b, 06c+09b)
**Anchor Baseline**: `d6b40b789381601440e4ce2cc1164cd57e8c3c7d` (`origin/av2-enc` HEAD)  
**Evaluation Standard**: Official AOM CTC Tool Suite (`compare_eda_runs.py` + `bjontegaard_metric.bdRateExtend`)  
**Testsets**: Class A1 (4K UHD 2160p, 17 frames, 6 QPs: 110, 135, 160, 185, 210, 235) & Class A2 (1080p FHD, 33 frames, 6 QPs)  
**Configuration**: Random Access (`--test_configs=ra`), Speed 4 (`--cpu-used=4`)  
**Pass Criteria Bar**: $\text{Ratio} = \frac{100\% - \text{EncTime}(\%)}{\Delta \text{PSNR-YUV BD-Rate (\%)}} \ge 20.0$ for Speed 4.

---

## 1. Executive Summary & Headline Breakthroughs

1. **Patch 09b (Transform Partition Stationarity - Lazy + Aggressive) is an Outstanding Success**:
   - Delivers **+4.01% speedup** on 4K (Class A1) and **+3.57% speedup** on 1080p (Class A2).
   - Near-zero BD-rate impact: **+0.15% on A1** and **+0.07% on A2**.
   - Achieves a trade-off ratio of **51.0 on 1080p** and **26.7 on 4K** (both well above the 20.0 bar), surpassing the original Patch 09 on both speedup (+1.3%–1.4% faster) and efficiency.
2. **Patch 06c (Orientation Partition Pruning - Resolution Scaled) Crosses the Bar on 4K**:
   - On Class A1 (4K), BD-rate loss was successfully reduced from +0.75% to **+0.29%**, achieving **+6.07% speedup** with a ratio of **20.9** (**PASS ✅**).
3. **Combined Patch 06c + 09b Clears the Bar with High Speedup on 4K**:
   - On Class A1 (4K), the combination delivers **+11.87% encoding speedup** with only **+0.54% PSNR-YUV BD-rate loss**, achieving a trade-off ratio of **22.0** (**PASS ✅**).

---

## 2. Master Results Table (Speed 4 vs `d6b40b` Baseline)

| Candidate Configuration | Testset | Speedup (%) | PSNR-Y BD | PSNR-YUV BD | VMAF BD | Bar Req | Ratio (YUV) | Pass Status |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Patch 09b (Lazy + Aggr)** | **Class A1 (4K, 17f)** | **+4.01%** | +0.18% | **+0.15%** | +0.32% | 20.0 | **26.7** | **PASS ✅** |
| **Patch 09b (Lazy + Aggr)** | **Class A2 (1080p, 33f)** | **+3.57%** | +0.06% | **+0.07%** | +0.23% | 20.0 | **51.0** | **PASS ✅** |
| **Patch 06c (Res-Scaled)** | **Class A1 (4K, 17f)** | **+6.07%** | +0.31% | **+0.29%** | +0.33% | 20.0 | **20.9** | **PASS ✅** |
| **Patch 06c (Res-Scaled)** | **Class A2 (1080p, 33f)** | **+6.21%** | +0.46% | **+0.46%** | +0.37% | 20.0 | 13.5 | Close / FAIL ❌ |
| **Patch 06c + 09b Combined** | **Class A1 (4K, 17f)** | **+11.87%** | +0.59% | **+0.54%** | +0.43% | 20.0 | **22.0** | **PASS ✅** |
| **Patch 06c + 09b Combined** | **Class A2 (1080p, 33f)** | **+9.80%** | +0.72% | **+0.72%** | +0.52% | 20.0 | 13.6 | FAIL ❌ |

---

## 3. Direct Evolution: Original Patches (Round 1) vs Improved Patches (Round 2)

### A. Patch 09 vs Patch 09b (Transform Partition Stationarity)
* **Round 1 (Patch 09)**:
  - Class A1: +2.60% Speedup, +0.11% BD-Rate $\rightarrow$ Ratio 23.6
  - Class A2: +2.27% Speedup, +0.09% BD-Rate $\rightarrow$ Ratio 25.2
* **Round 2 (Patch 09b)**:
  - Class A1: **+4.01% Speedup** (+1.41% gain), **+0.15% BD-Rate** $\rightarrow$ **Ratio 26.7** ✅
  - Class A2: **+3.57% Speedup** (+1.30% gain), **+0.07% BD-Rate** $\rightarrow$ **Ratio 51.0** ✅
* **Key Mechanism**: Lazy stationarity evaluation avoids wasting cycles on pre-pruned blocks, while loosening `TX_PART_STATIONARITY_MARGIN` to 2 captures substantially more prunes without quality penalty.

### B. Patch 06 vs Patch 06c (Orientation Partition Pruning)
* **Round 1 (Patch 06)**:
  - Class A1: +14.00% Speedup, +0.75% BD-Rate $\rightarrow$ Ratio 18.7 (FAIL)
  - Class A2: +18.52% Speedup, +1.29% BD-Rate $\rightarrow$ Ratio 14.4 (FAIL)
* **Round 2 (Patch 06c)**:
  - Class A1: **+6.07% Speedup**, **+0.29% BD-Rate** (loss cut by 61%) $\rightarrow$ **Ratio 20.9** ✅ (**PASS**)
  - Class A2: **+6.21% Speedup**, **+0.46% BD-Rate** (loss cut by 64%) $\rightarrow$ Ratio 13.5
* **Key Mechanism**: Resolution-scaled block size floor (16 for 4K, 32 for 1080p), absolute variance noise floor, and narrowed frame-aware depth gating eliminate erroneous prunes on fine textures and flat regions.

---

## 4. Per-Sequence Performance Breakdown

### Patch 09b: Class A1 (4K UHD)
| Sequence | PSNR-Y BD | PSNR-YUV BD | VMAF BD | EncTime (%) | Speedup (%) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| BoxingPractice | +0.14% | +0.14% | -0.94% | 95.82% | **+4.18%** |
| Crosswalk | +0.17% | +0.07% | +0.79% | 97.81% | **+2.19%** |
| FoodMarket2 | +0.34% | +0.30% | +0.19% | 98.52% | **+1.48%** |
| Neon1224 | +0.28% | +0.28% | +0.54% | 98.14% | **+1.86%** |
| NocturneDance | +0.06% | +0.07% | +0.72% | 96.61% | **+3.39%** |
| PierSeaSide | +0.08% | +0.06% | -0.11% | 94.77% | **+5.23%** |
| Tango | +0.05% | +0.02% | +1.02% | 97.23% | **+2.77%** |
| TimeLapse | +0.36% | +0.24% | +0.35% | 89.37% | **+10.63%** |
| **Average (Class A1)** | **+0.18%** | **+0.15%** | **+0.32%** | **95.99%** | **+4.01%** |

### Patch 09b: Class A2 (1080p FHD - Sample)
| Sequence | PSNR-Y BD | PSNR-YUV BD | VMAF BD | EncTime (%) | Speedup (%) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Aerial3200 | -0.25% | -0.23% | -0.04% | 96.70% | **+3.30%** |
| Boat | +0.15% | +0.17% | +0.28% | 94.15% | **+5.85%** |
| CrowdRun | +0.07% | +0.05% | +0.16% | 95.63% | **+4.37%** |
| Motorcycle | -1.80% | -1.68% | -0.36% | 95.97% | **+4.03%** |
| OldTownCross | +0.32% | +0.35% | +0.71% | 94.53% | **+5.47%** |
| TreesAndGrass | +0.39% | +0.43% | +0.50% | 92.60% | **+7.40%** |
| TunnelFlag | +0.01% | +0.02% | -0.55% | 95.77% | **+4.23%** |
| **Average (Class A2)** | **+0.06%** | **+0.07%** | **+0.23%** | **96.43%** | **+3.57%** |

---

## 5. Conclusions & Next Steps

1. **Patch 09b is ready for mainlining**: It delivers **+3.6% to +4.0% solid speedup** with an extraordinary ratio of **26.7 (4K) / 51.0 (1080p)**.
2. **Patch 06c proves resolution-scaling is effective**: Cutting BD-rate loss to +0.29% allowed it to pass on 4K with +6.07% speedup.
3. **Combined 06c + 09b provides +11.87% speedup on 4K UHD** while clearing the CTC trade-off bar (ratio 22.0 $\ge 20.0$).