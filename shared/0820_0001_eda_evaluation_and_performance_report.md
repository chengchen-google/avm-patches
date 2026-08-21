# AV2 0820/0001 (Speed 4 Non-DCT TCQ Rank/Refine): Cloud EDA Evaluation Report

**Baseline Anchor Commit**: `5d628d840b84be2eef1d0b1e2b7353719cc1f92a` (*origin/av2-enc*)  
**Evaluated Branch**: `0820/0001_s4_non_dct_tcq_rank_refine` (commit `75f43d5a92c415f4395a59436e7dbc9866bd2df1`)  
**Feature Description**: In inter transform search at Speed 4, evaluate non-DCT 2D transforms with scalar/B quantization proxy and only refine candidates within 12.5% margin with full TCQ.  
**Evaluation Protocol**: Random Access (RA), Class A1 (17 frames) & Class A2 (33 frames), `--timing_accuracy=high` on `blade` cluster  
**Acceptance Criterion**: Both Class A1 and Class A2 must pass the bar individually ($\ge 1.5\text{--}2.0\%$ speedup, healthy Pareto ratio $\ge 15\times$).  
**Date**: 2026-08-21  

---

## 1. Executive Summary & Verdict: ❌ REJECTED (Fails Both A1 and A2)

The candidate patch **`0820/0001`** fails the acceptance bar on both classes individually:

- **Class A1 (4K, 17f RA, Speed 4)**: **101.08% EncTime** (**-1.07% slowdown / overhead**) at **-0.04% PSNR-YUV BD** $\rightarrow$ ❌ **FAILS A1**
- **Class A2 (1080p, 33f RA, Speed 4)**: **100.25% EncTime** (**-0.25% slowdown / neutral**) at **+0.00% PSNR-YUV BD** $\rightarrow$ ❌ **FAILS A2**

---

## 2. Complete Performance & BD-Rate Table

| Candidate Branch / Patch | Target Preset | Testset / Class | EncTime | Speedup (%) | PSNR-Y BD | PSNR-YUV BD | SSIM BD | VMAF BD | Pareto Ratio | Individual Class Status |
| :--- | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **`0820/0001` (TCQ Rank/Refine)**<br>(`75f43d5a92`) | **Speed 4** | **Class A1** (4K, 17f RA) | **101.08%** | **-1.07%** | $-0.03\%$ | **-0.04%** | $-0.02\%$ | $+0.06\%$ | N/A (Slowdown) | ❌ **FAIL (A1)** |
| | | **Class A2** (1080p, 33f RA) | **100.25%** | **-0.25%** | $+0.00\%$ | **+0.00%** | $-0.01\%$ | $-0.11\%$ | N/A (Slowdown) | ❌ **FAIL (A2)** |
| | | **Combined Average** | **100.67%** | **-0.66%** | **-0.015%** | **-0.020%** | **-0.015%** | **-0.025%** | N/A | ⛔ **DISQUALIFIED (Reject)** |

---

## 3. Sequence Breakdown Analysis

### Class A1 (4K, 17 frames RA)
7 out of 8 sequences suffer runtime regression / slowdown:
- `Crosswalk`: EncTime **102.64%** (+2.64% slowdown)
- `BoxingPractice`: EncTime **101.38%** (+1.38% slowdown)
- `NocturneDance`: EncTime **101.32%** (+1.32% slowdown)
- `TimeLapse`: EncTime **101.27%** (+1.27% slowdown)
- `Tango`: EncTime **100.96%** (+0.96% slowdown)
- `Neon1224`: EncTime **100.61%** (+0.61% slowdown)
- `FoodMarket2`: EncTime **100.57%** (+0.57% slowdown)
- `PierSeaSide`: EncTime **99.91%** (+0.09% speedup)

### Class A2 (1080p, 33 frames RA)
13 out of 19 sequences show no speedup or slight slowdowns:
- `PedestrianArea`: EncTime **102.16%**
- `OldTownCross`: EncTime **101.74%**
- `WorldCup`: EncTime **101.63%**
- `FoodMarket`: EncTime **101.37%**
- `Motorcycle`: EncTime **100.73%**
- `Skater227`: EncTime **100.71%**
- `TunnelFlag`: EncTime **100.55%**
- `GregoryScarf`: EncTime **100.38%**
- `RushFieldCuts`: EncTime **100.28%**
- `Vertical_bees`: EncTime **100.19%**
- `ToddlerFountain`: EncTime **100.10%**
- `DinnerScene`: EncTime **100.06%**
- `CrowdRun`: EncTime **100.03%**
- `Riverbed`: EncTime **99.89%**
- `Boat`: EncTime **99.79%**
- `RitualDance`: EncTime **99.73%**
- `Aerial3200`: EncTime **99.55%**
- `MeridianTalk`: EncTime **98.22%**
- `TreesAndGrass`: EncTime **97.75%**

---

## 4. Technical Analysis & Root Cause

1. **Double-Pass Overhead**:
   - The rank-then-refine scheme computes scalar quantization, coefficient rate estimation, and block distortion for every non-DCT candidate.
   - For candidates within the 12.5% margin, it then invokes the full TCQ pass and re-evaluates distortion and rate.
   - In full SIMD-optimized AV2 inter transform search, the added bookkeeping and two-pass quantization overhead outweighs the TCQ cycles saved on rejected candidates.
2. **Recommendation**:
   - **Reject `0820/0001`**. Do not merge into upstream.
