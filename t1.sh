rm -rf .repo/local_manifests/
rm -rf device/lge vendor/lineage-priv/keys
rm -rf vendor/lge/ kernel/lge/msm8996
rm -rf hardware/qcom-caf/msm8996
rm -rf hardware/qcom-caf/common build/soong

#rm -rf out/target/product/*/obj/KERNEL_OBJ

#repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --depth=1 --git-lf
repo init -u https://github.com/Evolution-X/manifest -b cnb --git-lfs --depth=1 
#repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs --depth=1
git clone https://github.com/xc112lg/local_manifests --depth 1 -b a18 .repo/local_manifests
# repo sync -c -j64 --force-sync --no-clone-bundle --optimized-fetch  --no-tags >/dev/null 2>&1
# /opt/crave/resync.sh
curl -sf https://raw.githubusercontent.com/xc112lg/lg_releases/refs/heads/main/resync.sh | bash 2>&1 | tee build1.log && curl -F "file=@build1.log" https://temp.sh/upload
