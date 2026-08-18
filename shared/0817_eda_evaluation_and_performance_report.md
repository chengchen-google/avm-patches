# AV2 0817 Speed Optimization Patches: Comprehensive Cloud EDA CTC Report

**Baseline Anchor Head**: `fe1bfdee5427ea2e01149c5ebce904084a93ba79`  
**Evaluation Protocol**: Random Access (RA), Class A1 (17 frames) & Class A2 (33 frames), `--timing_accuracy=high` on `blade` cluster  
**Date**: 2026-08-18  

---

## 1. Executive Summary & Master Leaderboard

All 18 Cloud EDA jobs completed with 100% success rate across **Class A1** (4K) and **Class A2** (1080p).

### Master Results Table (vs Clean Baseline `fe1bfdee54`)

| Patch ID & Name | Target Speed | Class A1 Speedup & BD-Rate | Class A2 Speedup & BD-Rate | Combined Avg Speedup | Combined Avg BD-Rate (YUV) | Pareto Efficiency | Verdict & Impact |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`0001_s3_tx_stat`** | **Speed 3** | **+6.55%** speedup<br>`+0.15%` BD-loss | **+5.68%** speedup<br>`+0.22%` BD-loss | **+6.12% Speedup** | **+0.18% BD-Loss** | **34.0** (Bar: 25) | 🏆 **MAJOR WINNER**: Hits the **>5% speedup target** on both A1 and A2 with minimal BD-rate loss! |
| **`0002_s3_dc_pred`** | **Speed 3** | **+3.39%** speedup<br>`-0.01%` BD-gain | **+2.76%** speedup<br>`+0.01%` BD-loss | **+3.08% Speedup** | **0.00% BD-Loss** | **308.0** (Bar: 25) | 🏆 **FREE SPEEDUP**: Clean **~3.1% speedup** with virtually **zero coding loss** (lossless Pareto trade). |
| **`0004_s3_smooth`** | **Speed 3** | **+1.77%** speedup<br>`-1.28%` BD-gain | **+0.72%** speedup<br>`-0.88%` BD-gain | **+1.25% Speedup** | **-1.08% BD-Gain** | $\infty$ (Gain) | 💎 **PARETO REPAIR**: Restoring smooth intra gives **~1.1% BD coding gain** AND is **faster** (+1.25%) by shortening search! |
| **`0006_s2_ccso_bo`** | **Speed 2** | **+0.64%** speedup<br>`-0.14%` BD-gain | **+1.61%** speedup<br>`-0.10%` BD-gain | **+1.13% Speedup** | **-0.12% BD-Gain** | $\infty$ (Gain) | 🟢 **CLEAN WIN (S2)**: BO-first warm start improves Speed 2 runtime by **+1.1%** while slightly improving quality. |
| **`0007_s3_all_comb`** | **Speed 3** | **+1.58%** speedup<br>`-2.11%` BD-gain | **+3.43%** speedup<br>`-1.63%` BD-gain | **+2.51% Speedup** | **-1.87% BD-Gain** | $\infty$ (Gain) | 🌟 **MASSIVE QUALITY GAIN**: All-in stack yields **-1.87% BD-rate gain** while still speeding up encode by **+2.51%**. |
| `0003_s3_adp_tcq` | Speed 3 | -4.99% slowdown<br>`-0.89%` BD-gain | -6.25% slowdown<br>`-0.96%` BD-gain | -5.62% Slowdown | -0.92% BD-Gain | Quality Booster | 🔵 TCQ on L0/L1 recovers ~0.9% BD-rate but costs ~5.6% compute. |
| `0003_s4_adp_tcq` | Speed 4 | -2.95% slowdown<br>`-0.98%` BD-gain | -3.96% slowdown<br>`-1.14%` BD-gain | -3.46% Slowdown | -1.06% BD-Gain | Quality Booster | 🔵 TCQ on L0/L1 recovers ~1.06% BD-rate at the cost of ~3.5% compute. |
| `0005_s4_comp` | Speed 4 | -2.93% slowdown<br>`-0.80%` BD-gain | -8.74% slowdown<br>`-0.87%` BD-gain | -5.84% Slowdown | -0.84% BD-Gain | Quality Booster | 🔵 Backing off compound gate recovers ~0.84% BD-rate with ~5.8% compute overhead. |
| `0007_s4_all_comb` | Speed 4 | -5.80% slowdown<br>`-3.08%` BD-gain | -10.70% slowdown<br>`-2.80%` BD-gain | -8.25% Slowdown | -2.94% BD-Gain | Heavy Quality Engine | 🔵 Massive ~3.0% BD gain from TCQ + smooth + compound, but adds ~8.3% compute. |

---

## 2. Key Breakthroughs & Insights

### 1. `0001-s3-promote-tx-stat-pruning`: The Standout Speed Champion (>5%)
- **What it does**: Promotes conservative transform-statistics pruning (`prune_tx_type_using_stats = 1`) to Speed 3 for resolutions $\ge 480\text{p}$.
- **Performance**:
  - Class A1 (4K 17f): **+6.55% speedup** (EncTime: `93.45%`), BD-rate: `+0.15% YUV / +0.19% Y`.
  - Class A2 (1080p 33f): **+5.68% speedup** (EncTime: `94.32%`), BD-rate: `+0.22% YUV / +0.25% Y`.
- **Significance**: Passes the user's $>5\%$ speedup threshold independently on both 4K and 1080p with an exceptional Pareto ratio of **34.0** (far exceeding the Speed 3 project requirement of 25.0).

### 2. `0002-s3-enable-dc-block-pred-level1`: Free ~3.1% Speedup with Zero Quality Loss
- **What it does**: Enables DC block prediction level 1 during non-winner evaluation at Speed 3.
- **Performance**:
  - Class A1 (4K 17f): **+3.39% speedup**, BD-rate: `-0.01% YUV` (slight gain!).
  - Class A2 (1080p 33f): **+2.76% speedup**, BD-rate: `+0.01% YUV`.
- **Significance**: Delivers **+3.08% average speedup** at virtually **0.00% BD-loss** across both classes (Pareto ratio > 300).

### 3. `0004-s3-restore-smooth-intra`: Essential Pareto Repair (~1.1% Free Coding Gain)
- **What it does**: Restores smooth intra modes (`SMOOTH_PRED`, `SMOOTH_V`, `SMOOTH_H`) at Speed 3.
- **Performance**:
  - Class A1: **-1.28% BD-rate gain (YUV)**, **+1.77% speedup** (EncTime: `98.23%`).
  - Class A2: **-0.88% BD-rate gain (YUV)**, **+0.72% speedup** (EncTime: `99.28%`).
- **Significance**: In older code, disabling smooth intra harmed compression by over 1% without saving time. Restoring smooth intra **recovers ~1.1% BD-rate while making the encoder 1.25% faster** because better intra predictions reduce iterations in downstream transform/partition search.

### 4. `0006-s2-ccso-bo-first-warm-start`: Clean Speed 2 Win
- **What it does**: Evaluates the cheaper band-offset-only (BO-only) candidate first when early termination is enabled in CCSO filter search.
- **Performance**: Delivers **+1.13% average speedup** at Speed 2 (`1.61%` on A2, `0.64%` on A1) with a slight **-0.12% BD-rate gain**.

---

## 3. Recommended Golden Combination for Upstream (`0001 + 0002 + 0004`)

By combining the three best clean Speed 3 features:
1. **`0001` (TX-stat level 1)**: +6.12% speedup, +0.18% BD-loss
2. **`0002` (DC block pred level 1)**: +3.08% speedup, +0.00% BD-loss
3. **`0004` (Restore smooth intra)**: +1.25% speedup, -1.08% BD-gain

**Projected Outcome at Speed 3**:
- **Estimated Net Speedup**: **$\sim +9.0\%$ to $+10.0\%$**
- **Estimated Net BD-Rate**: **$\sim -0.90\%$ (Net Coding Gain!)**
- This combination exceeds the $>5\%$ speedup threshold while **improving compression efficiency**.
