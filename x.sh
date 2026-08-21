# 1. Clone your repo
git clone https://github.com/xc112lg/android_kernel_lge_msm8996_r2.git
cd android_kernel_lge_msm8996_r2

# 2. Check out your target branch
git checkout swan26

# 3. Add Inkypen79's msm8998 repo as a remote and fetch it
git remote add msm8996 Inkypen79/android_kernel_lge_msm8996.git
git fetch msm8996

# 4. Merge lineage-24.0 from that remote into swan24
git merge -X theirs msm8996/lineage-24.0 --allow-unrelated-histories -m "Merge https://github.com/Inkypen79/android_kernel_qcom_msm8998 into swan24"

# 5. Resolve any conflicts if they come up
git status
# ...fix conflicts if needed, then:
git add .
git commit 

