#!/usr/bin/env bash
# Run from your Flutter project root:
#   bash check_logos.sh lib/<folder>/Explore/explore_screen_data.dart
FILE="${1:-lib/Explore/explore_screen_data.dart}"
DIR="lib/assets/logos"

echo "== 1. Paths in the map that do NOT exist on disk (fix the name or the file) =="
grep -o "lib/assets/logos/[^']*" "$FILE" | sort -u | while read -r f; do
  [ -f "$f" ] || echo "MISSING: $f"
done

echo
echo "== 2. Files on disk that the map never uses =="
for f in "$DIR"/*.svg; do
  grep -q "$f" "$FILE" || echo "UNUSED: $f"
done

echo
echo "== 3. SVGs flutter_svg may fail to draw (run svgo on these) =="
grep -l -E "<style|<filter|<text|<image|<foreignObject" "$DIR"/*.svg

echo
echo "== 4. SVGs with no viewBox (they render tiny or cropped) =="
grep -L "viewBox" "$DIR"/*.svg

echo
echo "== 5. File names with capital letters (break on Android/Linux) =="
ls "$DIR" | grep '[A-Z]'
echo
echo "Done."