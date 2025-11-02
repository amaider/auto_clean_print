#!/bin/bash

PRINTER_NAME=""
LP_OPTIONS="media=a4"
PAGE_W=""
PAGE_H=""

# Function to print usage
usage() {
    echo "Usage: $0 -d PRINTER_NAME [-o LP_OPTIONS] [-w PAGE_WIDTH] [-h PAGE_HEIGHT]"
    echo
    echo "Options:"
    echo "  -d PRINTER_NAME   (required) Name of the printer: lpstat -d"
    echo "  -o LP_OPTIONS     (optional) lp options, default: 'media=a4'"
    echo "  -w PAGE_WIDTH     (optional) Page width in points, default: 595.28 (DIN A4)"
    echo "  -h PAGE_HEIGHT    (optional) Page height in points, default: 841.89 (DIN A4)"
    echo
    echo "Example:"
    echo "  $0 -d EPSON_Series -o 'media=a4' -w 595.28 -h 841.89"
    exit 1
}


# Parse arguments
while getopts "d:o:w:h:" opt; do
    case $opt in
        d) PRINTER_NAME="$OPTARG" ;;
        o) LP_OPTIONS="$OPTARG" ;;
        w) PAGE_W="$OPTARG" ;;
        h) PAGE_H="$OPTARG" ;;
        *) usage ;;
    esac
done

# Ensure required printer argument is provided
if [ -z "$PRINTER_NAME" ]; then
    echo "Error: Printer name is required." >&2
    usage
fi

FILE="$(dirname "${BASH_SOURCE[0]}")/auto_clean_print.ps"
# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE" >&2
    exit 1
fi

# Increment the /NTH number
# Update /DATESTRING to today's date
sed -i -e 's|/NTH \([0-9]*\) def|echo "/NTH $((\1 + 1)) def"|e' \
    -e "s|/DATESTRING (.*) def|/DATESTRING ($(date +"%Y-%m-%d")) def|" "$FILE"

# Update PAGE_W and PAGE_H if provided
if [ -n "$PAGE_W" ]; then
    sed -i "s|/PAGE_W [0-9.]* def|/PAGE_W $PAGE_W def|" "$FILE"
fi
if [ -n "$PAGE_H" ]; then
    sed -i "s|/PAGE_H [0-9.]* def|/PAGE_H $PAGE_H def|" "$FILE"
fi

# Print
lp -d "$PRINTER_NAME" -o "$LP_OPTIONS" "$FILE"
# if lp has error, exit with error, so home assistant script uses stderr
if [ $? -ne 0 ]; then
    exit 1
fi

exit 0