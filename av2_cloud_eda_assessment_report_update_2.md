# AV2 Speedup Evaluation Report: Evolution of Patches 0006 & 0009
**Anchor Baseline**: `d6b40b789381601440e4ce2cc1164cd57e8c3c7d` (`origin/av2-enc` HEAD)  
**Evaluation Standard**: Official AOM CTC Tool Suite (`compare_eda_runs.py` + `bjontegaard_metric.bdRateExtend`)  
**Testsets**: Class A1 (4K UHD 2160p, 17 frames, 6 QPs: 110, 135, 160, 185, 210, 235) & Class A2 (1080p FHD, 33 frames, 6 QPs)  
**Configuration**: Random Access (`--test_configs=ra`), Speed 4 (`--cpu-used=4`)  
**Efficiency Bar Metric**: $\text{Trade-off Ratio} = \frac{100\% - \text{EncTime}(\%)}{\Delta \text{PSNR-YUV BD-Rate (\%)}} \ge 20.0$ for Speed 4.

---

## 1. Executive Summary & Headline Findings

Across 3 iterative rounds of algorithm tuning and 16 full EDA cloud evaluations:

1. **Patch 0009 Pareto Optimum: Patch 09b (MARGIN = 2)**
   * **Winner**: **Patch 09b (Margin 2)** is the unambiguous global optimum on the Pareto frontier.
   * Delivers **+4.01% (4K) and +3.57% (1080p) speedup** with virtually lossless quality (**+0.15% on 4K, +0.07% on 1080p**), achieving massive trade-off ratios of **26.7 on 4K** and **51.0 on 1080p** (well above the 20.0 bar).
   * **Patch 09c (Margin 1)** pushed past the knee of the curve: it gained only +0.4%–1.1% extra speedup while BD-rate loss quadrupled to +0.30%–0.40%, falling below the bar (ratios 14.7 / 11.8).

2. **Patch 0006 Pareto Optimum: Patch 06c (Resolution-Scaled)**
   * **Winner**: **Patch 06c (Resolution-Scaled)** is the only orientation partition variant that passes the bar on 4K UHD.
   * By scaling block size thresholds with resolution and gating noise/depth, 06c reduced BD-rate loss to **+0.29%**, delivering **+6.07% speedup** with a ratio of **20.9 (PASS ✅)** on Class A1.
   * **Patch 06d (Un-blunted)** restored high speedup (+11.96% on 4K), but re-introduced quality penalty (+0.75% BD-rate), reducing its ratio to 15.9 (FAIL).

3. **Combined Best Formulation: Patch 06c + 09b**
   * **Winner**: **Patch 06c + 09b** achieves **+11.87% speedup** on 4K UHD with **+0.54% PSNR-YUV BD-rate**, maintaining a ratio of **22.0 (PASS ✅)**.

---

## 2. Complete Evolution Master Table (Speed 4 vs `d6b40b` Baseline)

| Round & Variant | Description / Core Mechanism | Testset | Speedup (%) | PSNR-Y BD | PSNR-YUV BD | VMAF BD | Bar Req | Ratio (YUV) | Pass Status |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Round 1 (09)** | Margin 4 (Strongest strip $\le 1.25\times$ mean) | **Class A1 (4K)** | +2.60% | +0.11% | +0.11% | -0.07% | 20.0 | **23.6** | **PASS ✅** |
| **Round 1 (09)** | Margin 4 (Strongest strip $\le 1.25\times$ mean) | **Class A2 (1080p)** | +2.27% | +0.10% | +0.09% | +0.09% | 20.0 | **25.2** | **PASS ✅** |
| **Round 2 (09b)** | **Margin 2 (Lazy + Strip $\le 1.50\times$ mean)** | **Class A1 (4K)** | **+4.01%** | +0.18% | **+0.15%** | +0.32% | 20.0 | **26.7** | **PASS ✅ (Optimum)** |
| **Round 2 (09b)** | **Margin 2 (Lazy + Strip $\le 1.50\times$ mean)** | **Class A2 (1080p)** | **+3.57%** | +0.06% | **+0.07%** | +0.23% | 20.0 | **51.0** | **PASS ✅ (Optimum)** |
| **Round 3 (09c)** | Margin 1 (Lazy + Strip $\le 2.00\times$ mean) | **Class A1 (4K)** | +4.40% | +0.38% | +0.30% | +0.21% | 20.0 | 14.7 | FAIL ❌ |
| **Round 3 (09c)** | Margin 1 (Lazy + Strip $\le 2.00\times$ mean) | **Class A2 (1080p)** | +4.71% | +0.42% | +0.40% | +0.22% | 20.0 | 11.8 | FAIL ❌ |
| | | | | | | | | | |
| **Round 1 (06)** | Base Ext Partition Texture Pruning | **Class A1 (4K)** | +14.00% | +0.85% | +0.75% | +0.90% | 20.0 | 18.7 | FAIL ❌ |
| **Round 1 (06)** | Base Ext Partition Texture Pruning | **Class A2 (1080p)** | +18.52% | +1.39% | +1.29% | +0.59% | 20.0 | 14.4 | FAIL ❌ |
| **Round 2 (06c)** | **Res-Scaled Floors (16@4K, 32@1080p)** | **Class A1 (4K)** | **+6.07%** | +0.31% | **+0.29%** | +0.33% | 20.0 | **20.9** | **PASS ✅ (Optimum)** |
| **Round 2 (06c)** | **Res-Scaled Floors (16@4K, 32@1080p)** | **Class A2 (1080p)** | **+6.21%** | +0.46% | **+0.46%** | +0.37% | 20.0 | 13.5 | FAIL ❌ |
| **Round 3 (06d)** | Un-blunted (No frame gate, 16 floor ext) | **Class A1 (4K)** | +11.96% | +0.84% | +0.75% | +0.89% | 20.0 | 15.9 | FAIL ❌ |
| **Round 3 (06d)** | Un-blunted (No frame gate, 16 floor ext) | **Class A2 (1080p)** | +9.57% | +0.98% | +0.92% | +0.56% | 20.0 | 10.4 | FAIL ❌ |
| | | | | | | | | | |
| **Round 2 (06c+09b)** | **Combined (06c + 09b)** | **Class A1 (4K)** | **+11.87%** | +0.59% | **+0.54%** | +0.43% | 20.0 | **22.0** | **PASS ✅ (Optimum)** |
| **Round 2 (06c+09b)** | **Combined (06c + 09b)** | **Class A2 (1080p)** | **+9.80%** | +0.72% | **+0.72%** | +0.52% | 20.0 | 13.6 | FAIL ❌ |
| **Round 3 (06d+09c)** | Combined (06d + 09c) | **Class A1 (4K)** | +17.57% | +1.22% | +1.08% | +0.95% | 20.0 | 16.3 | FAIL ❌ |
| **Round 3 (06d+09c)** | Combined (06d + 09c) | **Class A2 (1080p)** | +14.38% | +1.18% | +1.11% | +0.91% | 20.0 | 13.0 | FAIL ❌ |

---

## 3. Deep Dive: Patch 0009 Margin Parameter Curve

The stationarity pruning threshold controls the energy deviation allowed across residual strips:
- **Margin 4 (Round 1)**: Strongest strip $\le 1.25\times$ mean energy.
- **Margin 2 (Round 2)**: Strongest strip $\le 1.50\times$ mean energy + lazy evaluation.
- **Margin 1 (Round 3)**: Strongest strip $\le 2.00\times$ mean energy + lazy evaluation.

```
Efficiency Ratio vs Margin:
Class A2 (1080p):  Margin 4 (Ratio 25.2)  -->  Margin 2 (Ratio 51.0) [PEAK]  -->  Margin 1 (Ratio 11.8) [DECAY]
Class A1 (4K):     Margin 4 (Ratio 23.6)  -->  Margin 2 (Ratio 26.7) [PEAK]  -->  Margin 1 (Ratio 14.7) [DECAY]
```

* **Why Margin 2 Peaks**: At Margin 2, non-split blocks with mild residual gradients are correctly pruned without mistaking structured edges for stationary noise. The lazy evaluation also eliminates profiling overhead on blocks that were already skipping partition search.
* **Why Margin 1 Decays**: At Margin 1 ($2.0\times$ mean), true edge transitions inside transform blocks begin to be misclassified as stationary, sacrificing transform coding gain for only modest marginal runtime savings.

---

## 4. Deep Dive: Patch 0006 Orientation Pruning Dynamics

- **Patch 06 (Round 1)**: Pruned aggressively on all resolutions and block sizes $\ge 16$. Yielded massive speedup (+14.0%–18.5%), but high BD-rate loss (+0.75%–1.29%).
- **Patch 06c (Round 2)**: Introduced resolution-scaled block size floors (16 at 4K, 32 at 1080p) + variance noise floor + frame gate. This preserved fine textures, dropping BD-rate loss on 4K to **+0.29%**, enabling it to cross the bar at ratio **20.9**.
- **Patch 06d (Round 3)**: Removed frame gate and relaxed extended partition floor. This brought speedup back up to +12.0%, but BD-rate loss escalated back to +0.75%, proving that the frame gate and higher resolution floors were strictly necessary to protect RD performance.

---

## 5. Final Recommendations

1. **Adopt Patch 09b (Margin 2) for All Resolutions and Classes**:
   * Clean, robust **+3.6% to +4.0% speedup** with minimal BD-rate impact (+0.07%–0.15%) and outstanding trade-off ratios (**51.0 on 1080p, 26.7 on 4K**).
2. **Adopt Patch 06c for 4K / High-Resolution Content**:
   * Gives **+6.07% speedup** on 4K UHD while meeting the efficiency bar (ratio 20.9).
3. **Combined Deployment (06c + 09b)**:
   * Provides **+11.87% speedup on 4K UHD** while clearing the required bar (ratio 22.0).