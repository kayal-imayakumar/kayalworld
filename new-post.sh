#!/usr/bin/env bash
# Scaffold a new blog post: content/posts/<slug>.md + static/assets/images/<slug>/
set -euo pipefail

cd "$(dirname "$0")"

if [ $# -lt 1 ]; then
  echo "Usage: $0 \"Post Title\"" >&2
  exit 1
fi

title="$1"

slug=$(echo "$title" \
  | iconv -f utf-8 -t ascii//translit 2>/dev/null \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')

if [ -z "$slug" ]; then
  echo "Could not derive a URL slug from title: $title" >&2
  exit 1
fi

post_path="content/posts/${slug}.md"
image_dir="static/assets/images/${slug}"

if [ -e "$post_path" ]; then
  echo "A post already exists at $post_path" >&2
  exit 1
fi

mkdir -p "$image_dir"

date_str=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

cat > "$post_path" <<EOF
---
title: "${title}"
date: ${date_str}
---
Hello, readers!

EOF

echo "Created $post_path"
echo "Image folder: $image_dir (drop images here, then reference as /assets/images/${slug}/<filename>)"
