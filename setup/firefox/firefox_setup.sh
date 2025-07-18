#!/bin/bash

# This script automates the setup of userChrome.css for Firefox.
# It attempts to find your default Firefox profile, creates the 'chrome'
# directory if it doesn't exist, and then copies an existing userChrome.css
# file from a specified source path.

# Function to find the Firefox profile directory
find_firefox_profile() {
    local profile_base_path=""

    if  [[ "$OS" == "Linux" ]]; then
        profile_base_path="$HOME/.mozilla/firefox"
        profile_base_path_snap="$HOME/snap/firefox/common/.mozilla/firefox" # Snap path
    elif [[ "$OS" == "WSL" ]]; then
        WIN_APPDATA=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:APPDATA" | tr -d '\r')
        WIN_USERPROFILE=$(powershell.exe -NoProfile -NonInteractive -Command "\$Env:USERPROFILE" | tr -d '\r')

        if [ -n "$WIN_APPDATA" ]; then
            profile_base_path=$(echo "$WIN_APPDATA" | sed 's/\\/\//g')/Mozilla/Firefox/Profiles
        elif [ -n "$WIN_USERPROFILE" ]; then
            profile_base_path=$(echo "$WIN_USERPROFILE" | sed 's/\\/\//g')/AppData/Roaming/Mozilla/Firefox/Profiles
        else
            echo "Error: Could not determine Windows APPDATA or USERPROFILE paths." >&2
            exit 1
        fi
    elif [[ "$OS" == "macOS" ]]; then
        profile_base_path="$HOME/Library/Application Support/Firefox/Profiles"
    fi

    # Function to check a given base path for a Firefox profile
    check_base_path() {
        local current_base_path="$1"
        if [ ! -d "$current_base_path" ]; then
            return 1 # Path does not exist
        fi

        local profiles_ini="$current_base_path/profiles.ini"
        if [ -f "$profiles_ini" ]; then
            local default_profile_dir=$(grep -A 5 "\[Profile" "$profiles_ini" | grep "Default=1" -B 3 | grep "Path=" | cut -d '=' -f 2)
            
            if [ -n "$default_profile_dir" ]; then
                local full_profile_path="$current_base_path/$default_profile_dir"
                if [ -d "$full_profile_path" ]; then
                    echo "$full_profile_path"
                    return 0
                fi
            fi
        fi

        # Fallback: If profiles.ini parsing fails, try to find a common default profile name
        for profile_dir in "$current_base_path"/*; do
            if [[ "$profile_dir" =~ \.default-release$ || "$profile_dir" =~ \.default$ ]]; then
                if [ -d "$profile_dir" ]; then
                    echo "$profile_dir"
                    return 0
                fi
            fi
        done
        return 1
    }

    # Try standard path first
    if [ -n "$profile_base_path" ]; then
        found_profile=$(check_base_path "$profile_base_path")
        if [ $? -eq 0 ] && [ -n "$found_profile" ]; then
            echo "$found_profile"
            return 0
        fi
    fi

    # If not found in standard path, try Snap path (if applicable)
    if [ "$system" == "Linux" ] && [ -n "$profile_base_path_snap" ]; then
        found_profile=$(check_base_path "$profile_base_path_snap")
        if [ $? -eq 0 ] && [ -n "$found_profile" ]; then
            echo "$found_profile"
            return 0
        fi
    fi

    echo "Could not find a default Firefox profile. Please ensure Firefox has been run at least once." >&2
    return 1
}

# Function to set up userChrome.css by copying from a source
setup_userchrome_css() {
    local profile_path="$1"
    local source_css_path="$DOTFILE_DIR/setup/firefox/userChrome.css"

    if [ -z "$profile_path" ]; then
        echo "Cannot set up userChrome.css: Firefox profile path not provided." >2
        return 1
    fi

    if [ ! -f "$source_css_path" ]; then
        echo "Error: Source userChrome.css file not found at: $source_css_path" >&2
        echo "Please ensure the file exists before running the script." >&2
        return 1
    fi

    local chrome_dir="$profile_path/chrome"
    local dest_css_path="$chrome_dir/userChrome.css"

    # Ensure the 'chrome' directory exists
    mkdir -p "$chrome_dir"
    if [ $? -ne 0 ]; then
        echo "Error: Could not create 'chrome' directory at: $chrome_dir" >&2
        return 1
    fi
    echo "Ensured 'chrome' directory exists at: $chrome_dir"

    # Copy the userChrome.css file
    cp "$source_css_path" "$dest_css_path"
    if [ $? -eq 0 ]; then
        echo "Successfully copied userChrome.css from '$source_css_path' to '$dest_css_path'"
        echo ""
        echo "IMPORTANT: For userChrome.css to work, you need to enable it in Firefox:"
        echo "1. Open Firefox."
        echo "2. Type 'about:config' in the address bar and press Enter."
        echo "3. Accept the risk warning."
        echo "4. Search for 'toolkit.legacyUserProfileCustomizations.stylesheets'."
        echo "5. Toggle its value to 'true'."
        echo "6. Restart Firefox completely."
    else
        echo "Error copying userChrome.css from '$source_css_path' to '$dest_css_path'" >&2
        return 1
    fi
}

# Main execution
echo "Attempting to set up userChrome.css for Firefox.."
PROFILE_PATH=$(find_firefox_profile)

if [ $? -eq 0 ] && [ -n "$PROFILE_PATH" ]; then
    echo "Found Firefox profile: $PROFILE_PATH"
    setup_userchrome_css "$PROFILE_PATH"
else
    echo "Setup failed. Please check the console output for details." >&2
fi
