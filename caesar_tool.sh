#!/bin/bash
# Advanced Caesar Cipher Tool with extended features and rainbow colors
# Developed by DoomSlayer
# Version 3.0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

rainbow_text() {
    local text="$1"
    local colors=('\033[31m' '\033[33m' '\033[32m' '\033[36m' '\033[34m' '\033[35m')
    local length=${#text}
    local i color_index=0

    for (( i=0; i<length; i++ )); do
        color_index=$(( i % ${#colors[@]} ))
        printf "${colors[color_index]}%s${NC}" "${text:i:1}"
    done
    echo -e "${NC}"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        for i in $(seq 0 3); do
            printf "\r${CYAN}[%c] Processing...${NC}" "${spinstr:$i:1}"
            sleep $delay
        done
    done
    printf "\r${GREEN}Done!           ${NC}\n"
}

guess_language() {
    local text="$1"
    local arabic=$(echo "$text" | grep -oP '[\p{Arabic}]' 2>/dev/null | wc -l)
    local english=$(echo "$text" | grep -oP '[A-Za-z]' | wc -l)

    if (( arabic > english )); then
        echo "Arabic"
    else
        echo "English"
    fi
}

show_help() {
    echo -e "${YELLOW}Caesar Cipher Help:${NC}"
    echo "Shifts each letter by a fixed number."
    echo "Simple but weak encryption."
    echo "Use brute force if shift unknown."
    echo "Avoid using for sensitive data."
    echo
}

# Caesar cipher that preserves case and optionally shifts numbers and symbols
caesar_cipher() {
    local text="$1"
    local shift="$2"
    local shift_nums=$3

    python3 - <<END
import sys

text = """$text"""
shift = $shift
shift_nums = $shift_nums

def shift_char(c, shift):
    if c.isalpha():
        base = ord('A') if c.isupper() else ord('a')
        return chr((ord(c) - base + shift) % 26 + base)
    elif shift_nums:
        if c.isdigit():
            return chr((ord(c) - ord('0') + shift) % 10 + ord('0'))
        # Optional: add more symbol shifts if wanted
    return c

result = ''.join(shift_char(c, shift) for c in text)
print(result)
END
}

brute_force() {
    local text="$1"
    local shift_nums=$2
    echo
    for ((s=0; s<26; s++)); do
        result=$(caesar_cipher "$text" $s $shift_nums)
        echo -e "${CYAN}Shift $s:${NC} $result"
    done
    echo
}

clear
echo -e "$(rainbow_text "=======================================")"
echo -e "     $(rainbow_text "Caesar Cipher Tool by DoomSlayer")"
echo -e "$(rainbow_text "=======================================")"

# خيار إدخال من ملف أو من نص يدوي
echo -e "${YELLOW}Choose input method:${NC}"
echo "1) Enter text manually"
echo "2) Load text from file"
read -rp "Enter choice [1-2]: " input_method

if [[ "$input_method" == "2" ]]; then
    read -rp "Enter filename: " filename
    if [[ ! -f "$filename" ]]; then
        echo -e "${RED}File not found! Exiting.${NC}"
        exit 1
    fi
    input=$(cat "$filename")
else
    read -rp "Enter your text: " input
fi

lang=$(guess_language "$input")
echo -e "\nDetected Language: ${YELLOW}$lang${NC}"

while true; do
    echo -e "\n${YELLOW}Choose an action:${NC}"
    echo "1) Encode"
    echo "2) Decode"
    echo "3) Brute Force"
    echo "4) Help"
    echo "5) Exit"

    read -rp "Enter choice [1-5]: " choice

    case $choice in
        1|2)
            read -rp "Enter shift value (positive integer): " shift_val
            if ! [[ "$shift_val" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Invalid shift value.${NC}"
                continue
            fi
            # سؤال هل يشفر الأرقام والرموز
            read -rp "Shift numbers and symbols as well? (y/n): " shift_nums_input
            if [[ "$shift_nums_input" =~ ^[Yy]$ ]]; then
                shift_nums=1
            else
                shift_nums=0
            fi

            if [ "$choice" -eq 2 ]; then
                shift_val=$(( -shift_val ))
            fi

            echo -e "\n${CYAN}Processing...${NC}"
            caesar_cipher "$input" "$shift_val" $shift_nums &
            spinner $!
            ;;
        3)
            # نفس سؤال shift للأرقام في الbrute force
            read -rp "Shift numbers and symbols as well? (y/n): " shift_nums_input
            if [[ "$shift_nums_input" =~ ^[Yy]$ ]]; then
                shift_nums=1
            else
                shift_nums=0
            fi

            echo -e "\n${CYAN}Trying all shifts 0-25...${NC}"
            brute_force "$input" $shift_nums
            ;;
        4)
            show_help
            ;;
        5)
            echo -e "${GREEN}Thank you for using the tool! Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Try again.${NC}"
            ;;
    esac
done

echo -e "\n${YELLOW}Security Note:${NC} Caesar cipher is weak encryption."
echo -e "Avoid using it for sensitive data."

echo -e "\nThank you for using Caesar Cipher Tool - Developed by $(rainbow_text "DoomSlayer")"
