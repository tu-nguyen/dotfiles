#!/usr/bin/env bash

# This script automates the setup of userChrome.css for Firefox.
# It attempts to find your default Firefox profile, creates the 'chrome'
# directory if it doesn't exist, and then copies an existing userChrome.css
# file from a specified source path.

# --- Start Load Configuration ---
if [ -z "$DOTFILES_CONFIG_DIR" ]; then
    DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
fi

if [ -z "$DOTFILES_CONFIG_FILE" ]; then
    DOTFILES_CONFIG_FILE="$DOTFILES_CONFIG_DIR/.dotfile_config.env"
fi

if [ -f "$DOTFILES_CONFIG_FILE" ]; then
    source "$DOTFILES_CONFIG_FILE"
else
    echo "[Error] Configuration file not found at $DOTFILES_CONFIG_FILE" >&2
    exit 1
fi

DOTFILES_CONFIG_DIR="$HOME/.config/dotfiles"
[[ -f "$DOTFILES_CONFIG_DIR/.init" ]] && . "$DOTFILES_CONFIG_DIR/.init"
# --- End Load Configuration ---

# Function to check if a specific Firefox add-on is installed and enabled
# Arguments:
#   $1: Full path to the Firefox profile directory
#   $2: The ID of the add-on to check (e.g., "treestyletab@piro.mo")
check_addon_installed() {
    local profile_dir="$1"
    local addon_id="$2"
    local extensions_json="$profile_dir/extensions.json"

    t DEBUG "Checking for add-on '$addon_id' in '$extensions_json'"  >&2

    if [ ! -f "$extensions_json" ]; then
        t WARNING "extensions.json not found at '$extensions_json'. Cannot check add-on status." >&2
        return 1
    fi

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        t Error "'jq' command not found. Please install jq to check add-on status (e.g., sudo apt install jq)." >&2
        return 1
    fi

    # Use jq to check for the add-on.
    # .addons[] iterates through each add-on object.
    # select(.id == "$addon_id") filters for the specific add-on.
    # .userDisabled == false checks if it's NOT user-disabled (i.e., enabled).
    # .active == true checks if it's currently active (loaded in memory).
    # .appDisabled == false checks if it's NOT disabled by the application (e.g., compatibility issues).
    # The output is then piped to head -n 1 to get just one match if found.

    local is_installed=$(jq -r --arg ADDON_ID "$addon_id" \
        '.addons[] | select(.id == $ADDON_ID and .userDisabled == false and .active == true and .appDisabled == false) | .id' \
        "$extensions_json" | head -n 1)

    if [ -n "$is_installed" ]; then
        t OK "Add-on ${HDR_F}$addon_id (Tree Style Tab)${NC} is installed and enabled."
        return 0 # Add-on is installed and enabled
    else
        t ERR "Add-on ${ERR}$addon_id (Tree Style Tab)${NC} is NOT found or not enabled."
        # You might want to provide instructions to the user here.
        return 1 # Add-on not found or not enabled
    fi
}

# Function to find the Firefox profile directory
find_firefox_path() {
    local profile_base_path=""

    if  [[ "$OS_TYPE" == "linux" ]]; then
        if [ -d "$HOME/.mozilla/firefox" ]; then
            profile_base_path="$HOME/.mozilla/firefox"
        else
            profile_base_path="$HOME/snap/firefox/common/.mozilla/firefox" # Snap path
        fi
    elif [[ "$OS_TYPE" == "wsl" ]]; then
        local raw_win_appdata=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:APPDATA" | tr -d '\r\n')
        local raw_win_userprofile=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:USERPROFILE" | tr -d '\r\n')

        if [ -n "$raw_win_appdata" ]; then
            profile_base_path=$(wslpath -u "$raw_win_appdata")/Mozilla/Firefox
        elif [ -n "$raw_win_userprofile" ]; then
            profile_base_path=$(wslpath -u "$raw_win_userprofile")/AppData/Roaming/Mozilla/Firefox
        else
            t ERROR "Could not determine Windows APPDATA or USERPROFILE paths." >&2
            exit 1
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        profile_base_path="$HOME/Library/Application Support/Firefox"
    fi

    echo $profile_base_path
}

# Function to check a given base path for a Firefox profile
check_base_path() {
    local profiles_ini="$FF_PATH/profiles.ini"
    local MIN_FILES_REQUIRED=4
    if [ -f "$profiles_ini" ]; then
        local default_profile_dir=$(grep -A 5 "\[Profile" "$profiles_ini" | grep "Default=1" -B 3 | grep "Path=" | cut -d '=' -f 2)
        if [ -n "$default_profile_dir" ]; then
            local full_profile_path="$FF_PATH/$default_profile_dir"
            if [ -d "$full_profile_path" ]; then
                # Check file count
                local local file_count=$(find "$full_profile_path" -maxdepth 1 -type f | grep -c .)
                if (( file_count >= MIN_FILES_REQUIRED )); then
                    echo "$full_profile_path"
                    return 0 # Found and returned
                fi
            fi
        fi
    fi

    # Fallback: If profiles.ini parsing fails, try to find a common default profile name
    local latest_profile=""
    local latest_mtime=0
    for profile_dir in "$FF_PATH"/Profiles/*; do
        # Check if it's a directory and matches the naming pattern
        if [ -d "$profile_dir" ]; then
            # Get the modification time of the directory
            # For GNU systems (Linux, WSL), use stat -c %Y
            # For macOS/BSD, use stat -f %m
            local mtime=""
            if command -v stat >/dev/null 2>&1 && stat -c %Y "$profile_dir" >/dev/null 2>&1; then
                # GNU stat (Linux, WSL)
                mtime=$(stat -c %Y "$profile_dir")
            elif command -v stat >/dev/null 2>&1 && stat -f %m "$profile_dir" >/dev/null 2>&1; then
                # BSD stat (macOS)
                mtime=$(stat -f %m "$profile_dir")
            else
                # Fallback if stat isn't robust or portable enough, or just skip mtime check
                # You might need to adjust this if stat fails frequently.
                # For this specific scenario, given we expect stat, it's fine.
                t WARNING "'stat' command not behaving as expected for modification time check. Skipping time comparison for '$profile_dir'." >&2
                continue # Skip to the next directory
            fi

            # Check if this profile is newer than the current latest
            if [ -n "$mtime" ] && (( mtime > latest_mtime )); then
                latest_mtime="$mtime"
                latest_profile="$profile_dir"
            fi
        fi
    done

    if [ -n "$latest_profile" ]; then
        echo "$latest_profile"
        return 0
    fi

    # If no matching profile was found after checking all directories
    t DEBUG "No matching default-release or .default profile found in '$current_base_path'." >&2 # Add debug
    return 1
}

# Function to set up userChrome.css by copying from a source
setup_userchrome_css() {
    local source_css_path="$DOTFILES_REPO_DIR/setup/firefox/userChrome.css"

    if [ -z "$FF_PROFILE" ]; then
        t ERROR "Cannot set up userChrome.css: Firefox profile path not provided." >2
        return 1
    fi

    if [ ! -f "$source_css_path" ]; then
        t Error "Source userChrome.css file not found at: $source_css_path" >&2
        t "Please ensure the file exists before running the script." >&2
        return 1
    fi

    local chrome_dir="$FF_PROFILE/chrome"
    local dest_css_path="$chrome_dir/userChrome.css"

    # Ensure the 'chrome' directory exists
    mkdir -p "$chrome_dir"
    if [ $? -ne 0 ]; then
        t Error "Could not create 'chrome' directory at: $chrome_dir" >&2
        return 1
    fi
    t "Ensured 'chrome' directory exists at: $chrome_dir"

    # Copy the userChrome.css file
    cpp -q "$source_css_path" "$dest_css_path"
    if [ $? -eq 0 ]; then
        t OK "Successfully copied userChrome.css from to '$(basename $dest_css_path)'"
        t "${BOLD}Please follow the steps below.${NC}"
        echo "${HDR_F}For userChrome.css to work, you need to enable it in Firefox${NC}:"
        echo "${SEL_F}1${NC}. Open Firefox."
        echo "${SEL_F}2${NC}. Type '${SUB_F}about:config${NC}' in the address bar and press ${HDR_F}Enter${NC}."
        echo "${SEL_F}3${NC}. Accept the risk warning."
        echo "${SEL_F}4${NC}. Search for '${SUB_F}toolkit.legacyUserProfileCustomizations.stylesheets${NC}'."
        echo "${SEL_F}5${NC}. Toggle its value to '${SUB_F}true${NC}'."
        echo "${SEL_F}6${NC}. Restart Firefox completely."
    else
        t ERROR "Error copying userChrome.css from '$source_css_path' to '$dest_css_path'" >&2
        return 1
    fi
}

# Main execution
t "Attempting to set up userChrome.css for Firefox.."

FF_PATH=$(find_firefox_path)
FF_PROFILE=$(check_base_path)

if [ $? -eq 0 ] && [ -n "$FF_PROFILE" ]; then
    t "Found Firefox profile: $FF_PROFILE"
    # Check for Tree Style Tab
    TST_ADDON_ID="treestyletab@piro.sakura.ne.jp"
    if check_addon_installed "$FF_PROFILE" "$TST_ADDON_ID"; then
        setup_userchrome_css
    else
        t ERROR "Setup failed. Please install Tree Style Tab plugin"
    fi

else
    t ERROR "Setup failed. Please check the console output for details." >&2
fi
