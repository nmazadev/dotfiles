#!/bin/bash
# OCR: select a screen area, read its text with tesseract, copy it to the clipboard.
# Used by the waybar OCR button.
# Usage: ocr.sh [lang|status]
#   no argument: select an area and copy its text
#   lang:   wofi menu to pick the tesseract language, the current one marked with •
#   status: JSON for the waybar module (tooltip shows the language)

lang_file="$HOME/.cache/ocr-lang"
lang=$(cat "$lang_file" 2>/dev/null)
[ -z "$lang" ] && lang="eng+spa"

case $1 in
status)
    printf '{"text":"󱘢","tooltip":"OCR (%s)\\nClick: select text · right-click: language"}\n' "$lang"
    ;;
lang)
    mapfile -t langs < <(tesseract --list-langs 2>/dev/null | tail -n +2 | grep -vx osd)
    printf '%s\n' "${langs[@]}" | grep -qx eng && printf '%s\n' "${langs[@]}" | grep -qx spa \
        && langs+=("eng+spa")
    menu=""
    for l in "${langs[@]}"; do
        line=$l
        [ "$l" = "$lang" ] && line="$line  •"
        menu+="$line"$'\n'
    done
    picked=$(printf '%s' "$menu" | wofi --dmenu --prompt "OCR language ($lang)" \
        --style "$HOME/.cache/wal/wofi.css" --width 300 --height 200)
    [ -z "$picked" ] && exit 0
    echo "${picked%% *}" > "$lang_file"
    pkill -RTMIN+10 waybar
    ;;
*)
    region=$(slurp) || exit 0
    # upscaling first makes small UI text much easier for tesseract to read
    text=$(grim -g "$region" - | magick - -resize 200% png:- | tesseract - - -l "$lang" 2>/dev/null \
        | sed -e 's/[[:space:]]*$//' -e '/./,$!d')  # trailing spaces/form feed, leading blank lines
    if [ -z "$text" ]; then
        notify-send -t 2000 "OCR" "No text found"
        exit 0
    fi
    printf '%s' "$text" | wl-copy
    notify-send -t 3000 "OCR: copied" "$(head -c 80 <<<"$text")"
    ;;
esac
