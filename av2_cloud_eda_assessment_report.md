# AV2 Encoder Speed-Up Optimizations: Master Benchmark & Assessment Report
**Standard Governing Document**: `google3/experimental/users/chengchen/skills/av2-speed-optimization/SKILL.md`  
**Matching Baseline Anchor**: Commit `d6b40b789381601440e4ce2cc1164cd57e8c3c7d` (`origin/av2-enc` HEAD)  
**Test Sets**: Class A1 (17 frames, 4K), Class A2 (33 frames, 4K) | **Presets**: Speed 1, Speed 2, Speed 3, Speed 4

---

## 1. Evaluation Methodology & Metric Formulation

Per [`SKILL.md`](file:///google/src/head/depot/google3/experimental/users/chengchen/skills/av2-speed-optimization/SKILL.md#L63-L90), speed features are evaluated by the **Complexity-to-Efficiency Ratio**:

$$\text{Complexity-to-Efficiency Ratio} = \frac{\text{Encoder Run-Time Reduction (\%)}}{\text{PSNR-YUV BD-Rate Loss (\%)}} = \frac{100\% - \text{EncTime}(\%)}{\Delta \text{BD-Rate (\%) (\ge 0)}}$$

### Mandatory Threshold Bars:
* **Speed 1**: **Ratio $\ge 35.0$** (across both Class A1 and Class A2)
* **Speed 2**: **Ratio $\ge 30.0$** (across both Class A1 and Class A2)
* **Speed 3**: **Ratio $\ge 25.0$** (across both Class A1 and Class A2)
* **Speed 4**: **Ratio $\ge 20.0$** (across both Class A1 and Class A2)
* **Bit-Exact / Lossless Speedup**: If $\Delta \text{BD-Rate} \le 0.00\%$ and $\text{Speedup} > 0.0\%$, the ratio is $\infty$ (Strict Win-Win).

---

## 2. Run Status & Job Completion Audit

| Category | Total Runs | Full (100% Completed) | Partial (In-Progress) | Total Jobs Finished |
| :--- | :---: | :---: | :---: | :---: |
| **Individual Pruning Patches (Speed 4)** | 14 runs | **14 / 14 (100%)** | 0 / 14 | **1,134 / 1,134 jobs (100%)** |
| **All-10 Combined Suite (Speeds 1–4)** | 8 runs | **5 / 8 (62.5%)** | 3 / 8 | **546 / 648 jobs (84.3%)** |
| **Bit-Exact Patches (Speeds 1–2)** | 10 runs | **4 / 10 (40.0%)** | 6 / 10 | **658 / 810 jobs (81.2%)** |
| **TOTAL** | **32 runs** | **23 / 32 (71.9%)** | **9 / 32 (28.1%)** | **2,338 / 2,592 jobs (90.2%)** |

> [!NOTE]
> All 14 Speed 4 individual pruning runs (Patches 01, 04, 06, 07, 08, 09, 10 across both Class A1 and Class A2) are **100% complete full runs** (48/48 for A1, 114/114 for A2). Partial results are present only in longer-running Speeds 1 and 2 runs.

---

## 3. FULL Completed Runs Performance Table (vs Baseline `d6b40b7893`)

These results are obtained from **100% finished runs (48/48 jobs for A1, 114/114 jobs for A2)** with no missing chunks or data points:

| Candidate Patch | Speed | Testset & Job Status | Speedup (%) | PSNR-Y BD | PSNR-U BD | PSNR-V BD | PSNR-YUV BD | SSIM | MS-SSIM | VMAF | Ratio (PSNR-YUV) | Pass Bar? |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 🌟 **`Patch 09 (TX Partition Stationarity)`** | **4** | **A1 (17f) - FULL (48/48)** | **+2.60%** | **+0.11%** | **+0.15%** | **+0.21%** | **+0.11%** | **+0.11%** | **+0.13%** | **-0.07%** | **23.6** | ✅ **PASS** |
| 🌟 **`Patch 09 (TX Partition Stationarity)`** | **4** | **A2 (33f) - FULL (114/114)** | **+2.27%** | **+0.10%** | **-0.07%** | **+0.21%** | **+0.09%** | **+0.10%** | **+0.10%** | **+0.09%** | **25.2** | ✅ **PASS** |
| 🚀 **`Patch 06 (Orientation Part Pruning)`** | **4** | **A1 (17f) - FULL (48/48)** | **+14.00%** | +0.85% | +0.13% | -0.12% | +0.75% | +0.89% | +0.72% | +0.90% | **18.7** | ❌ Close (Bar 20) |
| 🚀 **`Patch 06 (Orientation Part Pruning)`** | **4** | **A2 (33f) - FULL (114/114)** | **+18.52%** | +1.39% | +0.57% | +0.20% | +1.29% | +1.57% | +1.19% | +0.59% | **14.4** | ❌ Close (Bar 20) |
| ⚡ **`Patch 01 (TX Saturation Exit)`** | **4** | **A1 (17f) - FULL (48/48)** | **+4.27%** | +1.26% | +1.13% | +0.91% | +1.22% | +1.36% | +1.47% | +1.26% | 3.5 | ❌ FAIL |
| ⚡ **`Patch 01 (TX Saturation Exit)`** | **4** | **A2 (33f) - FULL (114/114)** | **+5.05%** | +0.92% | +0.16% | +0.80% | +0.88% | +1.04% | +1.10% | +1.13% | 5.7 | ❌ FAIL |
| **`Patch 07 (Parent RD Density Term)`** | **4** | **A1 (17f) - FULL (48/48)** | +0.22% | +0.32% | +0.28% | -0.05% | +0.30% | +0.43% | +0.32% | +0.42% | 0.7 | ❌ FAIL |
| **`Patch 07 (Parent RD Density Term)`** | **4** | **A2 (33f) - FULL (114/114)** | **+2.84%** | +0.78% | +0.92% | +0.72% | +0.76% | +0.99% | +0.81% | +0.45% | 3.7 | ❌ FAIL |
| **`Patch 08 (DRL Dispersion Budget)`** | **4** | **A1 (17f) - FULL (48/48)** | -0.45% | +0.05% | -0.09% | +0.12% | +0.04% | +0.10% | +0.07% | +0.16% | -11.3 | ❌ FAIL |
| **`Patch 08 (DRL Dispersion Budget)`** | **4** | **A2 (33f) - FULL (114/114)** | **+0.91%** | -0.04% | +0.23% | +0.32% | -0.01% | +0.01% | -0.02% | -0.11% | **$\infty$ (Gain)** | ✅ PASS A2 |
| **`Patch 04 (Sub-Pel Curvature Gate)`** | **4** | **A1 (17f) - FULL (48/48)** | -1.31% | +0.13% | -0.06% | +0.14% | +0.11% | +0.15% | +0.18% | +0.32% | -11.9 | ❌ FAIL |
| **`Patch 04 (Sub-Pel Curvature Gate)`** | **4** | **A2 (33f) - FULL (114/114)** | +0.05% | -0.03% | +0.35% | -0.29% | -0.03% | +0.01% | +0.01% | +0.07% | **$\infty$ (Gain)** | ✅ PASS A2 |
| **`Patch 10 (Adaptive ME Range)`** | **4** | **A1 (17f) - FULL (48/48)** | -0.14% | -0.04% | +0.04% | -0.03% | -0.04% | -0.08% | -0.04% | +0.25% | No Speedup | ❌ FAIL |
| **`Patch 10 (Adaptive ME Range)`** | **4** | **A2 (33f) - FULL (114/114)** | -0.71% | -0.22% | +0.07% | -0.02% | -0.20% | -0.11% | -0.14% | -0.15% | No Speedup | ❌ FAIL |
| **`Patch 02 (Sparse STX Buffer - BitExact)`** | **2** | **A1 (17f) - FULL (48/48)** | -2.34% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | No Speedup | ❌ Noise |
| **`Patch 03 (PMC Arena Alloc - BitExact)`** | **2** | **A1 (17f) - FULL (48/48)** | -2.50% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | No Speedup | ❌ Noise |
| **`Patch 05 (Full-Pel ME Memo - BitExact)`** | **2** | **A1 (17f) - FULL (48/48)** | -1.39% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | No Speedup | ❌ Noise |
| **`Bit-Exact Combined (02+03+05)`** | **2** | **A1 (17f) - FULL (48/48)** | -2.55% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | No Speedup | ❌ Noise |
| **`All-10 Patches Combined`** | **4** | **A1 (17f) - FULL (48/48)** | **+20.34%** | +2.65% | +1.46% | +1.46% | +2.50% | +2.92% | +2.76% | +2.88% | 8.1 | ❌ FAIL |
| **`All-10 Patches Combined`** | **4** | **A2 (33f) - FULL (114/114)** | **+24.00%** | +3.57% | +2.21% | +2.41% | +3.45% | +3.97% | +3.56% | +2.96% | 7.0 | ❌ FAIL |
| **`All-10 Patches Combined`** | **3** | **A1 (17f) - FULL (48/48)** | **+25.18%** | +3.34% | +1.62% | +0.93% | +3.12% | +3.71% | +3.22% | +3.75% | 8.1 | ❌ FAIL |
| **`All-10 Patches Combined`** | **3** | **A2 (33f) - FULL (114/114)** | **+29.25%** | +4.09% | +0.99% | +1.65% | +3.85% | +4.62% | +4.05% | +3.45% | 7.6 | ❌ FAIL |
| **`All-10 Patches Combined`** | **2** | **A1 (17f) - FULL (48/48)** | **+30.74%** | +2.69% | +1.28% | +1.94% | +2.55% | +3.06% | +2.67% | +2.80% | 12.1 | ❌ FAIL |

---

## 4. PARTIAL In-Progress Runs Table (Early Signal Monitoring)

These results are obtained from **partial runs currently completing in the background**:

| Candidate Patch | Speed | Testset & Progress | Speedup (%) | PSNR-Y BD | PSNR-U BD | PSNR-V BD | PSNR-YUV BD | SSIM | MS-SSIM | VMAF | Ratio (PSNR-YUV) | Pass Bar? |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`Patch 02 (Sparse STX Buffer - BitExact)`** | **2** | **A2 (33f) - PARTIAL (102/114, 89.5%)** | **+0.41%** | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | **$\infty$ (BitExact)** | ✅ PASS A2 |
| **`Patch 03 (PMC Arena Alloc - BitExact)`** | **2** | **A2 (33f) - PARTIAL (102/114, 89.5%)** | **+0.07%** | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | **$\infty$ (BitExact)** | ✅ PASS A2 |
| **`Patch 05 (Full-Pel ME Memo - BitExact)`** | **2** | **A2 (33f) - PARTIAL (101/114, 88.6%)** | -1.01% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | No Speedup | ❌ Noise |
| **`Bit-Exact Combined (02+03+05)`** | **2** | **A2 (33f) - PARTIAL (96/114, 84.2%)** | -1.17% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | No Speedup | ❌ Noise |
| **`Bit-Exact Combined (02+03+05)`** | **1** | **A1 (17f) - PARTIAL (39/48, 81.2%)** | -0.67% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | No Speedup | ❌ Noise |
| **`Bit-Exact Combined (02+03+05)`** | **1** | **A2 (33f) - PARTIAL (78/114, 68.4%)** | **+0.32%** | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | +0.00% | **$\infty$ (BitExact)** | ✅ PASS A2 |
| **`All-10 Patches Combined`** | **2** | **A2 (33f) - PARTIAL (108/114, 94.7%)** | **+33.09%** | +3.92% | +1.62% | +2.58% | +3.75% | +4.35% | +3.42% | +3.25% | 8.8 | ❌ FAIL |
| **`All-10 Patches Combined`** | **1** | **A1 (17f) - PARTIAL (47/48, 97.9%)** | **+29.09%** | +3.14% | +1.83% | +2.17% | +3.01% | +3.48% | +3.05% | +2.94% | 9.7 | ❌ FAIL |
| **`All-10 Patches Combined`** | **1** | **A2 (33f) - PARTIAL (71/114, 62.3%)** | **+3.98%** | +0.00% | -0.44% | +0.01% | -0.01% | -0.06% | -0.02% | -0.08% | **$\infty$ (Gain)** | ✅ PASS A2 |

---

## 5. Key Conclusions

1. **`Patch 09` is fully verified on 100% completed runs**:
   * **Full data across all chunks**: +2.60% speedup on A1 (Ratio: 23.6), +2.27% speedup on A2 (Ratio: 25.2). Qualified for Speed 4 adoption.
2. **`Patch 06` is fully verified on 100% completed runs**:
   * **Full data across all chunks**: +14.00% speedup on A1 (Ratio: 18.7), +18.52% speedup on A2 (Ratio: 14.4).
3. **Bit-Exact Optimizations (02, 03, 05)**:
   * 0.00% BD-rate impact verified across both complete A1 runs and partial (>85%) A2 runs.