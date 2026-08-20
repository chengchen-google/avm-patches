# AV2 0819 standalone speed candidates

- **[Implemented]** This directory contains six independent patches and one detailed report.
- **[Validated]** Every patch is based directly on `ea89c216c629019f586ced5a701e56200169e012` and passes `git apply --check` at that anchor.
- **[Decision]** Apply and evaluate one patch at a time; none requires another patch.
- **[Decision]** Do not combine candidates in a single EDA arm.

## Apply one arm

```bash
git checkout ea89c216c629019f586ced5a701e56200169e012
git am /path/to/patches/N03-s3-tx-stationarity-margin2-ea89c216.patch
```

- **[Decision]** Replace the example filename with exactly one candidate.
- **[Decision]** Return to the clean anchor before applying the next candidate.
- **[Unknown]** The six exact policies have not yet received A1/A2 EDA results.

## Contents

- **[Implemented]** `AV2_0819_Standalone_Speed_Research_Report.md` contains the evidence audit, estimates, risks, and test order.
- **[Implemented]** `patches/` contains `N01` through `N06` as mail-formatted Git patches.
- **[Implemented]** `SHA256SUMS` verifies the patch payloads.
