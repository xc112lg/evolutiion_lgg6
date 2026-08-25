echo "--- keys dir ---"
ls -la vendor/lineage-priv/keys/ 2>&1
echo "--- keys.mk ---"
cat vendor/lineage-priv/keys/keys.mk 2>&1
echo "--- git status ---"
cd vendor/lineage-priv/keys && git remote -v && git log -1 --oneline; cd - 
echo "--- msm8996.mk include count ---"
grep -c "lineage-priv/keys/keys.mk" device/lge/msm8996-common/msm8996.mk
