sed -i \
  -e '/<path name="headphones-hifi-dac">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dac-advanced">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dac-aux">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dacdop">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dacdop-advanced">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  -e '/<path name="headphones-hifi-dacdop-aux">/a\        <ctl name="Es9218 Bypass" value="0" />' \
  device/lge/g6-common/audio/mixer_paths_tasha.xml
cd device/lge/g6-common
git diff
