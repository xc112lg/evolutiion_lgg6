# 1. Clone your repo
git clone https://github.com/LineageOS/android_kernel_lge_msm8996.git
cd android_kernel_lge_msm8996

# 2. Check out your target branch
git checkout lineage-22.1

# 3. Add Inkypen79's msm8998 repo as a remote and fetch it
git remote add msm8998 https://github.com/Inkypen79/android_kernel_qcom_msm8998.git
git fetch msm8998

# 4. Merge lineage-24.0 from that remote into swan24
git merge msm8998/lineage-24.0 --allow-unrelated-histories -m "Merge https://github.com/Inkypen79/android_kernel_qcom_msm8998 into swan24"

# 5. Resolve any conflicts if they come up
git status
# ...fix conflicts if needed, then:
git add .
git commit 

