#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDML="${1:-$DIR/l1000.gdml}"
DETS="${2:-$DIR/l1000-dets.mac}"

for f in "$GDML" "$DETS"; do
  [ -r "$f" ] || { echo "ERROR: cannot read '$f'" >&2; exit 1; }
done

# ── scale ─────────────────────────────────────────────────────────
lv=$(grep -c '<volume name='        "$GDML")   # component definitions
pv=$(grep -c '<physvol name='       "$GDML")   # placements / instances
bs=$(grep -c '<bordersurface'       "$GDML")   # optical boundaries
echo
echo "SCALE"
printf "  %-42s %d\n" "logical volumes (component definitions):" "$lv"
printf "  %-42s %d\n" "physical volumes (placements/instances):" "$pv"
printf "  %-42s %d\n" "optical border surfaces:"                 "$bs"

# ── material inventory (count = lv using each material) ────────
echo
echo "MATERIALS  (count = # of component definitions using it)"
grep -oE '<materialref ref="[^"]+"' "$GDML" | sed -E 's/.*"([^"]+)"/\1/' \
  | sort | uniq -c | sort -rn | awk '{printf "  %7d  %s\n", $1, $2}'

# ── placement multiplicity (which definitions are instanced most) ──────────
echo
echo "MOST-PLACED COMPONENTS  (count = placements referencing that definition)"
grep -oE '<volumeref ref="[^"]+"' "$GDML" | sed -E 's/.*"([^"]+)"/\1/' \
  | sort | uniq -c | sort -rn | head -15 | awk '{printf "  %7d  %s\n", $1, $2}'

# ── detector readout (RMG RegisterDetector by type) ────────────────────────
echo
echo "DETECTOR READOUT  (RegisterDetector by type)"
awk '/RegisterDetector/{print $2}' "$DETS" | sort | uniq -c \
  | awk '{printf "  %7d  %s\n", $1, $2}'
printf "  %7d  TOTAL\n" "$(grep -c 'RegisterDetector' "$DETS")"



echo
echo
echo
echo "to list volumes made of a given material (e.g. LiquidArgon):"
echo "  awk '/<volume name=/{v=\$0} /materialref ref=\"LiquidArgon\"/{gsub(/.*name=\"|\".*/,\"\",v);print v}' \"$GDML\""

#   grep -c '<volume name='  l1000.gdml           # 2,756 LVs logical volumes
#   grep -c '<physvol name=' l1000.gdml           # 17,196 PVs placements (NOT bare '<physvol')
#   grep -c '<bordersurface' l1000.gdml           # 29,658 optical surfaces (x2 is physvolref)
#   grep -oE '<materialref ref="[^"]+"' l1000.gdml | sort | uniq -c | sort -rn   # materials
#   awk '/RegisterDetector/{print $2}' l1000-dets.mac | sort | uniq -c           # readout





# /RMG/Geometry/PrintListOfLogicalVolumes        2,756 LVs definition (colour/material live here)
# /RMG/Geometry/PrintListOfPhysicalVolumes       17,196 PVs instance (position lives here)