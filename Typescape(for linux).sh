#!/bin/sh
echo -ne '\033c\033]0;test for main\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Typescape(for linux).x86_64" "$@"
