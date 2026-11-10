#!/bin/bash
# Sony ZV-1 / RX100 series memory card maintenance (macOS + Linux, no extra packages).
#
# Run this AFTER you deleted clips / photos on the camera or in a file manager, to clean up
# everything that makes the camera report "database repair failed":
#
#   1. foreign directories left by other operating systems
#      (.Trashes, .Spotlight-V100, .fseventsd, .TemporaryItems, ...)
#   2. macOS AppleDouble leftovers: ._* and .DS_Store
#   3. empty shooting folders under DCIM
#   4. stale AVCHD shell (PRIVATE/AVCHD with an empty BDMV/STREAM) and all-zero AVF_INFO/AVIN*.INT
#   5. dangling <Material> entries in PRIVATE/M4ROOT/MEDIAPRO.XML (entries whose .MP4 was deleted)
#   6. read-only health report: file integrity, DB consistency, free space
#
# It NEVER deletes photos (DCIM) or movies (PRIVATE/M4ROOT/CLIP, THMBNL).
#
# usage:
#   ./zv1-card-cleanup.sh                     # dry run, prints the plan
#   ./zv1-card-cleanup.sh --apply             # do it
#   ./zv1-card-cleanup.sh --apply /Volumes/NO_NAME
#
# Orphan thumbnails (movie deleted, no longer referenced by the database) are ALWAYS
# removed - they never belong to a live clip. --prune-orphan-thumbs is still accepted
# but no longer needed. If ALL clips were deleted, MEDIAPRO.XML is deleted outright
# (the camera rebuilds a fresh database via "Restore Database").

set -u

APPLY=0
PRUNE_THUMBS=0
ROOT=""

for arg in "$@"; do
    case "$arg" in
        --apply)             APPLY=1 ;;
        --prune-orphan-thumbs) PRUNE_THUMBS=1 ;;
        -h|--help)           awk 'NR==1{next} /^#/{print; next} {exit}' "$0"; exit 0 ;;
        -*)                  echo "unknown option: $arg"; exit 2 ;;
        *)                   ROOT="$arg" ;;
    esac
done

if [ -z "$ROOT" ]; then
    ROOT="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || ROOT="$(pwd)"
fi
[ -d "$ROOT" ] || { echo "ERROR: not a directory: $ROOT"; exit 1; }

DCIM="$ROOT/DCIM"
M4="$ROOT/PRIVATE/M4ROOT"
AVF="$ROOT/AVF_INFO"
XML="$M4/MEDIAPRO.XML"

echo
echo "Sony card maintenance - $ROOT"

if [ ! -d "$DCIM" ] && [ ! -d "$M4" ]; then
    echo "ERROR: '$ROOT' is not a Sony camera card (neither DCIM/ nor PRIVATE/M4ROOT/ found)."
    exit 1
fi

TMPD="${TMPDIR:-/tmp}"
PLAN="$(mktemp "$TMPD/zv1plan.XXXXXX")"
EXLIST="$(mktemp "$TMPD/zv1exist.XXXXXX")"
XMLNEW="$(mktemp "$TMPD/zv1xml.XXXXXX")"
CNTF="$(mktemp "$TMPD/zv1cnt.XXXXXX")"
ZEROLIST="$(mktemp "$TMPD/zv1zero.XXXXXX")"
BADLIST="$(mktemp "$TMPD/zv1bad.XXXXXX")"
trap 'rm -f "$PLAN" "$EXLIST" "$XMLNEW" "$CNTF" "$CNTF.total" "$CNTF.keys" "$ZEROLIST" "$BADLIST" "$BADLIST.a" "$BADLIST.b"' EXIT

plan_add() { printf '%s\t%s\n' "$1" "$2" >> "$PLAN"; }

dir_size_kb() { du -sk "$1" 2>/dev/null | awk '{print $1}'; }

# ---------------------------------------------------------------- 1. foreign directories
for name in .Trashes .Spotlight-V100 .fseventsd .TemporaryItems .Trash-501 'System Volume Information' lost+found; do
    [ -e "$ROOT/$name" ] && plan_add "$ROOT/$name" 'directory created by another OS'
done

# ---------------------------------------------------------------- 2. macOS leftovers
# skip anything inside the foreign directories above: they are removed whole,
# so listing their contents would only produce redundant plan entries
find "$ROOT" \
    \( -name .Trashes -o -name .Spotlight-V100 -o -name .fseventsd -o \
       -name .TemporaryItems -o -name .Trash-501 -o \
       -name 'System Volume Information' -o -name lost+found \) -prune -o \
    -type f \( -name '._*' -o -name .DS_Store \) -print 2>/dev/null |
while IFS= read -r f; do
    printf '%s\t%s\n' "$f" 'macOS metadata leftover' >> "$PLAN"
done

# ---------------------------------------------------------------- 3. empty DCIM folders
if [ -d "$DCIM" ]; then
    find "$DCIM" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while IFS= read -r d; do
        # a folder that only holds ._*/.DS_Store ghosts is "empty" for our purposes:
        # those files are already on the plan, so flag the folder in the same run
        leftover=$(find "$d" -mindepth 1 ! -name '._*' ! -name .DS_Store -print -quit 2>/dev/null)
        scan_rc=$?
        if [ "$scan_rc" -ne 0 ]; then
            echo "  WARNING: cannot list $d - folder left untouched"
        elif [ -z "$leftover" ]; then
            printf '%s\t%s\n' "$d" 'empty DCIM shooting folder' >> "$PLAN"
        fi
    done
fi

# ---------------------------------------------------------------- 4. stale AVCHD / zeroed INT
AVCHD="$ROOT/PRIVATE/AVCHD"
if [ -d "$AVCHD" ]; then
    if [ -d "$AVCHD/BDMV/STREAM" ]; then
        has_stream=$(find "$AVCHD/BDMV/STREAM" -type f -print -quit 2>/dev/null)
        scan_rc=$?
    else
        has_stream=""
        scan_rc=0    # no STREAM dir at all: genuinely an empty shell
    fi
    if [ -z "$has_stream" ] && [ "$scan_rc" -ne 0 ]; then
        # a scan failure is NOT an empty stream - never delete on suspicion
        echo "  WARNING: cannot scan $AVCHD/BDMV/STREAM (card/reader error?) - AVCHD left untouched"
    elif [ -z "$has_stream" ]; then
        plan_add "$AVCHD" 'stale AVCHD index (BDMV/STREAM is empty)'
    fi
fi
if [ -d "$AVF" ]; then
    for f in "$AVF"/AVIN*.INT; do
        [ -f "$f" ] || continue
        # LC_ALL=C: under a UTF-8 locale tr aborts on binary data ("Illegal byte
        # sequence"), which can make a real index count as empty (0 bytes)
        nonzero=$(LC_ALL=C tr -d '\000' < "$f" | wc -c | tr -d ' ')
        if [ "$nonzero" = "0" ]; then
            plan_add "$f" 'all-zero AVIN index, never written by the camera'
        fi
    done
fi

# ---------------------------------------------------------------- 5. MEDIAPRO.XML dangling entries
# A <Material> block is dropped ONLY when its own movie (CLIP\*.MP4) is gone. A missing
# sidecar (.MP4/.THMBNL) alone is not enough - the clip stays playable, so the entry stays.
PRUNED=0
REFUSED=0
ORPHANS=0
XML_ACTION=none
if [ -f "$XML" ]; then
    if [ -d "$M4" ]; then
        ( cd "$M4" && find . -type f | sed 's|^\./||' ) > "$EXLIST"
    else
        : > "$EXLIST"
    fi
    if [ ! -s "$EXLIST" ]; then
        echo "  ERROR: cannot list $M4 - refusing to touch MEDIAPRO.XML"
        REFUSED=1
    else
        awk -v EXIST="$EXLIST" -v CNT="$CNTF" '
            BEGIN {
                nkeys = 0
                while ((getline l < EXIST) > 0) { sub(/\r$/, "", l); if (l != "") { ex[l] = 1; nkeys++ } }
                removed = 0; total = 0
            }
            # ([^A-Za-z0-9_]|$) emulates \b after "Material": portable to BSD awk
            # and also matches a bare <Material> like the PowerShell version
            /^[ \t]*<Material([^A-Za-z0-9_]|$)/ { buf = $0 "\n"; inblk = 1; total++; next }
            inblk {
                buf = buf $0 "\n"
                if ($0 ~ /<\/Material>/) { inblk = 0; flush_block(buf) }
                next
            }
            { print }
            function flush_block(b,   n, i, arr, primary, first, u, nuri) {
                n = split(b, arr, "\n"); nuri = 0; primary = ""
                for (i = 1; i <= n; i++) {
                    if (match(arr[i], /uri="\.\/[^"]+"/)) {
                        u = substr(arr[i], RSTART + 7, RLENGTH - 8)   # strip uri="./ and closing quote
                        if (nuri == 0) first = u
                        # string regex (not /.../): macOS/BSD awk cannot parse an
                        # escaped slash inside a bracket character class
                        if (primary == "" && u ~ "^CLIP/[^/]*\\.MP4$") primary = u
                        nuri++
                    }
                }
                if (primary == "") primary = first
                if (primary != "" && !(primary in ex)) removed++; else printf "%s", b
            }
            END { print removed + 0 > CNT; print total + 0 > (CNT ".total"); print nkeys + 0 > (CNT ".keys") }
        ' "$XML" > "$XMLNEW"
        PRUNED=$(cat "$CNTF" 2>/dev/null || echo 0)
        TOTAL=$(cat "$CNTF.total" 2>/dev/null || echo 0)
        KEYS=$(cat "$CNTF.keys" 2>/dev/null || echo 0)
        PRUNED=${PRUNED:-0}; TOTAL=${TOTAL:-0}; KEYS=${KEYS:-0}
        if [ "$KEYS" -eq 0 ] && [ -s "$EXLIST" ]; then
            echo "  ERROR: could not verify the M4ROOT file list (parser failure?) - refusing to touch MEDIAPRO.XML"
            REFUSED=1
        elif [ "$TOTAL" -gt 0 ] && [ "$PRUNED" -eq "$TOTAL" ]; then
            # EVERY entry dangles. That is only dangerous if clips are still on the card
            # (loud inconsistency / list failure). If CLIP/ has no .MP4 at all the movies
            # are really gone - scrapping the database is the fix and lets the camera
            # rebuild a fresh one via Restore Database. This decision does NOT rely on
            # the KEYS count: the three checks above (file list readable, XML parses,
            # clips gone) are the real evidence.
            # ._*.MP4 AppleDouble ghosts are NOT clips - they are on the plan too
            if [ -d "$M4/CLIP" ] && \
               find "$M4/CLIP" -maxdepth 1 -type f -name '*.MP4' ! -name '._*' -print -quit 2>/dev/null | grep -q .; then
                echo "  ERROR: ALL $TOTAL entries dangle, yet clips are still in CLIP/ - inconsistent, MEDIAPRO.XML left untouched"
                REFUSED=1
            else
                plan_add "$XML" 'movie database lists ONLY deleted clips - delete so the camera rebuilds it'
                XML_ACTION=delete
                PRUNED=0          # no in-place rewrite needed; the file goes via the plan
            fi
        elif [ "$PRUNED" -gt 0 ] && [ "$KEYS" -lt 3 ]; then
            # not a whole-DB wipe, something to prune, but too little on the card
            # to trust a partial rewrite (nothing to prune -> nothing to say)
            echo "  ERROR: only $KEYS file(s) under PRIVATE/M4ROOT (card almost empty?) - refusing to touch MEDIAPRO.XML"
            REFUSED=1
        elif [ "$PRUNED" -gt 0 ]; then
            XML_ACTION=rewrite    # partial prune: rewrite the database in place
        fi
    fi
fi
if [ "$REFUSED" = "1" ]; then PRUNED=0; fi

# thumbnails whose movie is gone - ALWAYS removed now (they never belong to a live clip:
# a thumbnail is kept only if its movie still exists AND the database still references it)
# checked against the database as it will look AFTER this run, so thumbnails orphaned by
# this run are reported too
REFXML="$XML"
case "$XML_ACTION" in
    rewrite|delete) [ -s "$XMLNEW" ] && REFXML="$XMLNEW" ;;   # future state: materials pruned / gone
esac
if [ -d "$M4/THMBNL" ] && [ -f "$REFXML" ]; then
    ORPHANS=0
    for t in "$M4/THMBNL"/*.JPG; do
        [ -f "$t" ] || continue
        base=$(basename "$t" T01.JPG)
        [ "$base" = "$(basename "$t")" ] && continue          # not a camera thumbnail name
        rel="THMBNL/$(basename "$t")"
        # remove it when the movie is gone AND the (future) database does not reference it
        if [ ! -f "$M4/CLIP/$base.MP4" ] && ! grep -q "uri=\"./$rel\"" "$REFXML"; then
            ORPHANS=$((ORPHANS + 1))
            plan_add "$t" 'thumbnail whose movie is missing'
        fi
    done
fi

# ---------------------------------------------------------------- report
COUNT=$(wc -l < "$PLAN" | tr -d ' ')
echo
if [ "$COUNT" = "0" ] && [ "$XML_ACTION" = "none" ]; then
    if [ "$REFUSED" = "1" ]; then
        echo "Nothing else to clean up, but MEDIAPRO.XML was NOT touched (see ERROR above)."
    else
        echo "Nothing to clean up: card structure looks consistent."
    fi
else
    echo "PLAN"
    if [ "$COUNT" != "0" ]; then
        while IFS="$(printf '\t')" read -r p reason; do
            [ -n "$p" ] || continue
            if [ -d "$p" ]; then kind=DIR;  sz=$(dir_size_kb "$p")k
            else kind=FILE; sz=$(wc -c < "$p" | tr -d ' ')b; fi
            printf '  %-4s %12s  %s\n' "$kind" "$sz" "$reason"
            printf '       %s\n' "$p"
        done < "$PLAN"
    fi
    if [ "$XML_ACTION" = "rewrite" ]; then
        echo
        echo "  MEDIAPRO.XML: $PRUNED dangling <Material> entry/entries will be removed"
    elif [ "$XML_ACTION" = "delete" ]; then
        echo
        echo "  MEDIAPRO.XML: ALL $TOTAL entries dangle - the file will be DELETED so the camera rebuilds it"
    fi
    if [ "$ORPHANS" -gt 0 ]; then
        echo
        echo "  NOTE: $ORPHANS orphan thumbnail(s) will be deleted (movie gone, not referenced by the database)"
    fi
fi

# ---------------------------------------------------------------- execute
if [ "$APPLY" = "1" ]; then
    while IFS="$(printf '\t')" read -r p reason; do
        [ -n "$p" ] || continue
        rm -rf -- "$p" && echo "  removed: $p" || echo "  FAILED: $p"
    done < "$PLAN"

    if [ "$XML_ACTION" = "rewrite" ] && [ -f "$XML" ]; then
        # validate the rewrite BEFORE it replaces the database
        newclips=$(grep -cE '<Material([^A-Za-z0-9_]|$)' "$XMLNEW" || true)
        expected_clips=$((TOTAL - PRUNED))
        if [ ! -s "$XMLNEW" ] || ! grep -q '</MediaProfile>' "$XMLNEW" || ! grep -q '<Contents>' "$XMLNEW"; then
            echo "  ERROR: rewritten MEDIAPRO.XML failed validation - original left untouched"
        elif [ "$newclips" -ne "$expected_clips" ]; then
            echo "  ERROR: entry count mismatch ($newclips != $expected_clips) - original left untouched"
        else
            backup="${TMPDIR:-/tmp}/MEDIAPRO.XML.$(date +%Y%m%d-%H%M%S).bak"
            cp -p "$XML" "$backup" || echo "  ERROR: could not write backup - MEDIAPRO.XML left untouched"
            if cat "$XMLNEW" > "$XML"; then
                echo "  MEDIAPRO.XML rewritten ($PRUNED of $TOTAL entries removed, backup: $backup)"
            else
                echo "  ERROR: write failed - restore from $backup"
            fi
        fi
    fi
    echo
    echo "DONE - removed $COUNT item(s)"
else
    echo
    echo "DRY RUN - nothing was deleted. Re-run with --apply to execute."
fi

# ---------------------------------------------------------------- health check (read only)
echo
echo "HEALTH CHECK (read only)"

if [ -d "$DCIM" ]; then
    arw=$(find "$DCIM" -type f -name '*.ARW' ! -name '._*' | wc -l | tr -d ' ')
    jpg=$(find "$DCIM" -type f -name '*.JPG' ! -name '._*' | wc -l | tr -d ' ')
    find "$DCIM" -type f -name '*.ARW' ! -name '._*' -exec basename {} .ARW \; | sort > "$BADLIST.a"
    find "$DCIM" -type f -name '*.JPG' ! -name '._*' -exec basename {} .JPG \; | sort > "$BADLIST.b"
    lone=$(comm -3 "$BADLIST.a" "$BADLIST.b" | wc -l | tr -d ' ')
    echo "  photos: $arw ARW / $jpg JPG, unpaired: $lone"
    : > "$BADLIST"
    find "$DCIM" -type f -name '*.JPG' ! -name '._*' | while IFS= read -r f; do
        tail -c 2 "$f" | od -An -tx1 | tr -d ' \n' | grep -q '^ffd9$' || echo "$f" >> "$BADLIST"
    done
    broken=$(wc -l < "$BADLIST" | tr -d ' ')
    echo "  JPG with valid EOI marker: $((jpg - broken))/$jpg"
    [ "$broken" != "0" ] && sed 's/^/    /' "$BADLIST"
fi

if [ -d "$M4/CLIP" ]; then
    mp4total=0; mp4ok=0
    for f in "$M4/CLIP"/*.MP4; do
        [ -f "$f" ] || continue
        case "$(basename "$f")" in ._*) continue ;; esac    # skip AppleDouble sidecars
        mp4total=$((mp4total + 1))
        # bytes 4..7 must spell "ftyp" (hex 66 74 79 70); bytes 0..3 are the box size.
        # moov is normally near the end, but faststart files put it up front - accept either
        if dd if="$f" bs=1 skip=4 count=4 2>/dev/null | od -An -tx1 | tr -d ' \n' | grep -q '^66747970$' \
           && { tail -c 65536 "$f" | grep -a -q 'moov' || head -c 65536 "$f" | grep -a -q 'moov'; }; then
            mp4ok=$((mp4ok + 1))
        else
            echo "    MP4 incomplete: $(basename "$f")"
        fi
    done
    echo "  MP4 with ftyp + moov: $mp4ok/$mp4total"
fi

if [ -f "$XML" ]; then
    clips=$(grep -cE '<Material([^A-Za-z0-9_]|$)' "$XML" || true)
    missing=0
    while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        [ -e "$M4/$rel" ] || { missing=$((missing + 1)); echo "    MEDIAPRO.XML references missing file: $rel"; }
    done <<EOF
$(sed -n 's/.*uri="\.\/\([^"]*\)".*/\1/p' "$XML")
EOF
    echo "  MEDIAPRO.XML: $clips clips registered, $missing referenced files missing"
fi

# zero-byte files (PRIVATE/SONY/SONYCARD.IND is a normal empty placeholder on Sony cards)
find "$ROOT" -type f -size 0 ! -name 'SONYCARD.IND' 2>/dev/null > "$ZEROLIST"
ZERO=$(wc -l < "$ZEROLIST" | tr -d ' ')
if [ "$ZERO" != "0" ]; then
    echo "  zero-byte files: $ZERO"
    sed 's/^/    /' "$ZEROLIST"
fi

files=$(find "$ROOT" -type f 2>/dev/null | wc -l | tr -d ' ')
# macOS ships BSD stat (-f %z), Linux ships GNU stat (-c %s); probe once and
# use the matching syntax (the old -c then `-z $used` fallback never fired:
# awk's END block prints "0.00" even on zero input)
if stat -c %s / >/dev/null 2>&1; then
    used=$(find "$ROOT" -type f -exec stat -c %s {} + 2>/dev/null | awk '{s+=$1} END{printf "%.2f", s/1073741824}')
else
    used=$(find "$ROOT" -type f -exec stat -f %z {} + 2>/dev/null | awk '{s+=$1} END{printf "%.2f", s/1073741824}')
fi
echo "  files: $files, used: ${used:-?} GB"

echo
echo "Now safe-eject the card, insert it in the camera and run \"Restore Database\"."