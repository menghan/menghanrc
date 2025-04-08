#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import random
import sys
from pathlib import Path
import requests # type: ignore # Ignore type checking for requests if no stubs installed

# --- Configuration ---

# Dictionary mapping target names to their 'latest' release URLs.
# The URL should ideally point to a resource that redirects to the
# actual latest version asset. GitHub's '/latest/download/...' pattern is typical.
LATEST_RELEASES = {
    "neovim": "https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.appimage",
    # Add other targets here, e.g.:
    # "ripgrep": "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-x86_64-unknown-linux-musl.tar.gz",
}

# Default probability (in percent) to check for updates if --force-check-update is not used.
DEFAULT_CHANCE_PERCENT = 10

# --- Constants ---
# Using distinct exit codes for different states can be helpful for scripting:
# 0: Success (No check run, or check run and no update found)
# 1: Error (Configuration error, network error, file I/O error)
# 2: Update Available (A new version was detected *this run*, or was detected previously and is pending)
EXIT_CODE_SUCCESS_NO_UPDATE = 0
EXIT_CODE_ERROR = 1
EXIT_CODE_UPDATE_AVAILABLE = 2

# --- Helper Functions ---

def get_release_url(url: str, timeout: int = 15) -> str | None:
    """
    Performs an HTTP HEAD request to find the final URL after redirects.

    Args:
        url: The initial URL to check (e.g., the '/latest/download/' URL).
        timeout: Request timeout in seconds.

    Returns:
        The final URL after all redirects, or None if an error occurs or
        the URL cannot be resolved.
    """
    try:
        headers = {
            # Set a user agent to be polite and potentially avoid blocking.
            'User-Agent': 'github-release-checker-script/1.0',
        }
        # Use allow_redirects=False with HEAD. requests will raise on 1st redirects,
        # and the response.url will contain the release URL.
        response = requests.head(url, allow_redirects=False, timeout=timeout, headers=headers)
        response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)

        release_download_url = response.headers.get('Location', '')
        # Basic sanity check: Ensure we got a plausible URL (not empty, etc.)
        if release_download_url and isinstance(release_download_url, str) and release_download_url.startswith("http"):
            return release_download_url
        else:
            print(f"Error: Could not resolve a valid final URL from {url}. Got: {release_download_url}", file=sys.stderr)
            return None

    except requests.exceptions.TooManyRedirects:
        print(f"Error: Too many redirects while checking URL: {url}", file=sys.stderr)
        return None
    except requests.exceptions.Timeout:
        print(f"Error: Request timed out while checking URL: {url}", file=sys.stderr)
        return None
    except requests.exceptions.HTTPError as e:
        print(f"Error: HTTP error {e.response.status_code} while checking URL: {url}", file=sys.stderr)
        return None
    except requests.exceptions.RequestException as e:
        # Catch any other requests-related errors (DNS, Connection, etc.)
        print(f"Error: Network or request error while checking URL: {url} - {e}", file=sys.stderr)
        return None
    except Exception as e:
        # Catch unexpected errors during the request process
        print(f"Error: An unexpected error occurred during URL check: {e}", file=sys.stderr)
        return None


def read_url_from_file(filepath: Path) -> str:
    """
    Reads a URL from the specified file.

    Args:
        filepath: The Path object pointing to the file.

    Returns:
        The URL string read from the file, stripped of whitespace.
        Returns an empty string if the file doesn't exist or an error occurs.
    """
    if not filepath.is_file():
        return "" # File doesn't exist, treat as empty content
    try:
        content = filepath.read_text(encoding='utf-8').strip()
        # Basic validation: is it a non-empty string?
        # More robust validation (e.g., URL format) could be added if needed.
        return content if content else ""
    except IOError as e:
        print(f"Warning: Could not read file {filepath}: {e}", file=sys.stderr)
        return "" # Return empty string on read error
    except Exception as e:
        print(f"Warning: An unexpected error occurred reading file {filepath}: {e}", file=sys.stderr)
        return ""

def write_url_to_file(filepath: Path, url: str) -> bool:
    """
    Writes a URL to the specified file. Creates parent directories if needed.

    Args:
        filepath: The Path object pointing to the file.
        url: The URL string to write.

    Returns:
        True if writing was successful, False otherwise.
    """
    try:
        # Ensure parent directory exists
        filepath.parent.mkdir(parents=True, exist_ok=True)
        filepath.write_text(url + '\n', encoding='utf-8') # Add newline for clarity
        return True
    except IOError as e:
        print(f"Error: Could not write to file {filepath}: {e}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Error: An unexpected error occurred writing file {filepath}: {e}", file=sys.stderr)
        return False

# --- Main Logic ---

def main():
    """
    Main function to parse arguments and check for updates.
    """
    parser = argparse.ArgumentParser(
        description="Check for new GitHub releases based on 'latest' download URLs.",
        epilog="Example: python check_release.py neovim --chance 20"
    )
    parser.add_argument(
        "target",
        help="The name of the target application to check (e.g., 'neovim'). Must be defined in LATEST_RELEASES."
    )
    parser.add_argument(
        "--force-check-update",
        action="store_true",
        help="Force the check, ignoring the probability chance."
    )
    parser.add_argument(
        "--chance",
        type=int,
        default=DEFAULT_CHANCE_PERCENT,
        help=f"Percentage chance (0-100) of checking for an update (default: {DEFAULT_CHANCE_PERCENT}). Ignored if --force-check-update is used."
    )

    args = parser.parse_args()
    target = args.target
    force_check = args.force_check_update
    chance_percent = args.chance

    if target == 'nvim':
        target = 'neovim'

    # --- 1. Validate Target ---
    if target not in LATEST_RELEASES:
        print(f"Error: No known release info for target '{target}'. Known targets: {', '.join(LATEST_RELEASES.keys())}", file=sys.stderr)
        sys.exit(EXIT_CODE_ERROR)

    latest_release_lookup_url = LATEST_RELEASES[target]

    # Validate chance value
    if not (0 <= chance_percent <= 100):
         print(f"Error: Chance must be between 0 and 100, got {chance_percent}", file=sys.stderr)
         sys.exit(EXIT_CODE_ERROR)

    # --- 2. Decide Whether to Check ---
    to_check_update = False
    if force_check:
        to_check_update = True
    else:
        # Generate a random integer between 0 and 99 inclusive
        random_value = random.randint(0, 99)
        if random_value < chance_percent:
            to_check_update = True

    # --- 3. Define State File Paths ---
    home_dir = Path.home()
    # File storing the URL of the *currently installed* version.
    # This file should be managed by the installation/update script.
    current_version_file = home_dir / f".{target}.curr_version.url"
    # File storing the URL of the *next available* version (if detected).
    # This acts as a flag indicating an update is pending.
    next_version_file = home_dir / f".{target}.next_version.url"

    # --- 4. Check if Update is Already Pending ---
    # If the next_version_file exists, it means a previous run detected an update
    # that hasn't been installed yet.
    pending_url = ''
    if next_version_file.is_file():
        pending_url = read_url_from_file(next_version_file)

    # Get the URL of the actual latest release asset by resolving the lookup URL
    if pending_url:
        next_release_url = pending_url
    elif not to_check_update:
        sys.exit(EXIT_CODE_SUCCESS_NO_UPDATE)
    else:
        next_release_url = get_release_url(latest_release_lookup_url)

    if not next_release_url:
        # Error message already printed by get_release_url
        print(f"Error: Failed to determine the latest release URL for '{target}'. Cannot check for updates.", file=sys.stderr)
        sys.exit(EXIT_CODE_ERROR)

    # Get the URL of the currently installed version
    current_release_url = read_url_from_file(current_version_file)

    # --- 6. Compare Versions and Update State ---
    if next_release_url == current_release_url:
        # Ensure no stale pending file exists if versions match now
        if next_version_file.exists():
            try:
                next_version_file.unlink()
            except OSError as e:
                print(f"Warning: Could not remove stale pending update file {next_version_file}: {e}", file=sys.stderr)
        sys.exit(EXIT_CODE_SUCCESS_NO_UPDATE)
    else:
        # New version detected!
        print(f"'{target}' has a new release available. Run your update script (e.g., 'xyz {target}') to install.")

        # Save the new version URL to the next_version file to signal pending update
        if write_url_to_file(next_version_file, next_release_url):
            sys.exit(EXIT_CODE_UPDATE_AVAILABLE)
        else:
            # Failed to write the flag file, report error.
            print(f"Error: Failed to write pending update file {next_version_file}. Update cannot be signaled.", file=sys.stderr)
            sys.exit(EXIT_CODE_ERROR)

# --- Entry Point ---

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        # Catch-all for unexpected errors in main logic
        import traceback
        print(f"\nCritical Error: An unexpected error occurred: {e}", file=sys.stderr)
        print("Traceback:", file=sys.stderr)
        traceback.print_exc(file=sys.stderr)
        sys.exit(EXIT_CODE_ERROR)
