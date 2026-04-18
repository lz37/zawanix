#!/usr/bin/env bash

set -euo pipefail

TOML="/etc/nixos/home/zerozawa/wallpapers/wallpapers.toml"

length=$(yq -p toml '.pixiv | length' "$TOML" 2>/dev/null)
updated=0

for i in $(seq 0 $((length - 1))); do
    id=$(yq -p toml ".pixiv[$i].id" "$TOML" 2>/dev/null)
    p=$(yq -p toml ".pixiv[$i].p // 0" "$TOML" 2>/dev/null)
    hash=$(yq -p toml ".pixiv[$i].hash // \"\"" "$TOML" 2>/dev/null)

    if [[ -n "$hash" ]]; then
        echo "Skipping id=$id p=$p (hash already present)"
        continue
    fi

    if [[ "$p" -eq 0 ]]; then
        suffix=""
    else
        suffix="-$((p + 1))"
    fi
    url="https://pixiv.cat/${id}${suffix}.jpg"

    echo "Fetching hash for $url ..."
    hash_val=$(nurl "$url" -f fetchurl | grep 'hash = "' | sed 's/.*hash = "\(.*\)".*/\1/')

    if [[ -z "$hash_val" ]]; then
        echo "  ERROR: failed to get hash for $url" >&2
        continue
    fi

    echo "  -> $hash_val"
    yq -i -p toml -o toml ".pixiv[$i].hash = \"$hash_val\"" "$TOML" 2>/dev/null
    ((updated++)) || true
done

if [[ "$updated" -eq 0 ]]; then
    echo "Nothing to update."
else
    echo "Done! Updated $updated entries."
fi
