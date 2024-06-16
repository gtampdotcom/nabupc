#!/bin/bash

# Script by GTAMP with help from ChatGPT

echo "Script for generating libmsx patches"
echo "It helps convert MSX roms to NABU PC"
echo "z80dasm is required"
echo "Run this script from a duplicate of your nabu_msx folder"
echo "Put all your MSX ROMs in that folder."
echo "Make sure they have no spaces or special characters in their names."
echo ""
echo "WARNING: THIS WILL OVERWRITE EXISTING .Z80 SOURCE FILES"
echo "Press any key to continue or Ctrl+C to cancel."
read -n 1 -s -r -p ""

# Check if there are any .rom files in the current directory
if ! compgen -G '*.rom' > /dev/null; then
    echo "No .rom files found in the current directory."
    exit 1
fi

# Generate the game list from the .rom files in the current directory
gameList=(*.rom)

# Template content for the .z80 files
templateHeader='; Bulk Conversion
;
; Copyright (c) 2024 Brian Johnson.  All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
;
; THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
; IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
; OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
; IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
; INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
; NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
; THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'

templateSplash='
.section .rodata.splash, "adr"
.global splash_msg
splash_msg:
    .byte 6, 12, 19, "conversion by GTAMP"
    .byte 0, 0, 0

.section .msx, "acrx"
.incbin "PLACEHOLDER"

'

# Iterate over each ROM file
for game in "${gameList[@]}"; do
    echo "Processing $game"
    patches_section_added=""
    patches=""
    
    # Extract the folder name (game name without extension)
    foldername="${game%.rom}"
    # Create the folder if it doesn't exist
    mkdir -p "$foldername"
    # Create the filename with .z80 extension
    filename="$foldername/$foldername.z80"
    
    # Use z80dasm to disassemble and grep for IM2 instructions
    strings=$(z80dasm -g 0x4000 -t -l "$game" 2>/dev/null | grep "im ")

    # Loop through each line returned by grep
    while IFS= read -r line; do
        # Extract the 4-digit hex number after the semicolon
        hex_number=$(echo "$line" | grep -oP '(?<=;)[0-9a-fA-F]{4}')
        
        # Check if hex_number exists
        if [ -n "$hex_number" ]; then
            # Add 1 to IM2 address
            incremented_hex=$(printf '%04X' $(( 0x$hex_number + 1 )))
            echo "IM2: $incremented_hex"
            
            templatePatches='
    .word 0x'"$incremented_hex"'
    .byte 1, 0x5e
'
            patches+="$templatePatches"
        fi
    done <<< "$strings"

    # Search the disassembled output for IN, OUT, and OUTI commands accessing ports 099h, 098h, 0a0h, 0a1h, and 0a2h
    port_access=$(z80dasm -g 0x4000 -t -l "$game" 2>/dev/null | grep -E '^\s*(in|out|outi)\s+.*\((099h|098h|0a0h|0a1h|0a2h)\)')
    
    # Loop through each line returned by grep
    while IFS= read -r line; do
        # Extract the 4-digit hex number after the semicolon
        hex_number=$(echo "$line" | grep -oP '(?<=;)[0-9a-fA-F]{4}')
        
        # Check if hex_number exists
        if [ -n "$hex_number" ]; then
            # Add 1 to address
            incremented_hex=$(printf '%04X' $(( 0x$hex_number + 1 )))
            
            # Extract the instruction and port number
            instruction=$(echo "$line" | grep -oP '^\s*(in|out|outi)')
            port=$(echo "$line" | grep -oP '\((099h|098h|0a0h|0a1h|0a2h)\)')
            
            # Trim leading white space from the instruction
            trimmed_instruction=$(echo "$instruction" | xargs)
            echo "$trimmed_instruction $port access at: $incremented_hex"
            
            # Determine the patch value
            case "$port" in
                "(099h)")
                    patch_value="VDP_LATCH"
                    ;;
                "(098h)")
                    patch_value="VDP_DATA"
                    ;;
                "(0a0h)")
                    patch_value="PSG_WRITE"
                    ;;
                "(0a1h)")
                    patch_value="PSG_LATCH"
                    ;;
                "(0a2h)")
                    patch_value="PSG_WRITE"
                    ;;
            esac
            
            templatePatches='
    .word 0x'"$incremented_hex"'
    .byte 1, '"$patch_value"'
'
            patches+="$templatePatches"
        fi
    done <<< "$port_access"

    # Create the content for the .z80 file
    content="$templateHeader"
    
    if [ -n "$patches" ]; then
        # Add the rom_patch_table section only if patches were found
        if [ -z "$patches_section_added" ]; then
            content+="
.include \"constants.inc\"
.section .rodata.patches, \"adr\"
.global rom_patch_table
rom_patch_table:
; ---------------------------------------------
; Use Interrupt Mode 2 and Port Access Changes
; ---------------------------------------------"
            patches_section_added=true
        fi
        content+="$patches"
        content+="
    .word 0
    .byte 0
    "  # Terminating entry
    fi
    
    # Add the splash screen and ROM include section
    content+="${templateSplash/PLACEHOLDER/$game}"
    
    # Write the content to the .z80 file
    printf "%s" "$content" > "$filename"
done

echo "Processing complete."
