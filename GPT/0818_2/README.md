# AV2 expanded standalone patch bundle

**[Implemented]** This bundle contains 14 independently applicable patches for anchor `fe1bfdee5427ea2e01149c5ebce904084a93ba79`.

**[Implemented]** No combined multi-feature patch is included.

**[Decision]** Read `AV2_0818_Expanded_Standalone_Speed_Patch_Report.md` before selecting EDA arms.

**[Decision]** Apply exactly one patch to a clean anchor for each standalone evaluation:

```bash
git checkout fe1bfdee5427ea2e01149c5ebce904084a93ba79
git apply /path/to/patches/P02-s3-dc-block-pred-level1-fe1bfdee.patch
```

**[Decision]** `P05` and `P13` are alternatives; do not apply both.

**[Validated]** Every `.patch` file passes `git apply --check` against the stated anchor.

**[Implemented]** `SHA256SUMS` records the packaged-file hashes.
