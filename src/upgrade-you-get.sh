#!/bin/sh

# Set OS-dependent variables
OS_NAME=`uname -s`
if [ "$OS_NAME" = 'Darwin' ]; then    # macOS
    VERSION_FILE="$HOME/Library/Application Support/MoonPlayer/you-get-version.txt"
    DEST_DIR="$HOME/Library/Application Support/MoonPlayer/you-get"
elif [ "$OS_NAME" = 'Linux' ]; then   # Linux
    VERSION_FILE="$HOME/.moonplayer/you-get-version.txt"
    DEST_DIR="$HOME/.moonplayer/you-get"
    TMPDIR="/tmp"
else
    echo "Unsupported system!"
    exit 0
fi

# Set network tool
if which curl > /dev/null; then
    alias downloader="curl -L -o"
    alias fetcher="curl -s"
else
    alias downloader="wget -q -O"
    alias fetcher="wget -q -O -"
fi


cd "$TMPDIR"
echo ""
echo -e "\033[34m ---------- Checking you-get's update --------- \033[0m"


# Check whether Python3 is installed
which python3 > /dev/null || {
echo -e "\033[31m *********** Error *********** \033[0m"
echo -e "\033[31m Python3 is not installed. Please download it from \033[0m"
echo -e "\033[31m https://www.python.org/downloads/mac-osx/ \033[0m"
echo -e "\033[31m and then install it. \033[0m"
echo -e "\033[31m ************ End ************ \033[0m"
exit 0
}

# Get latest you-get version
get_latest_version() {
    export PYTHONIOENCODING=utf8
    fetcher 'https://api.github.com/repos/soimort/you-get/branches/develop' | \
        python -c "import sys, json; sys.stdout.write(json.load(sys.stdin)['commit']['sha'])"
}

LATEST_VERSION=`get_latest_version`
if [ -n "$LATEST_VERSION" ]; then
    echo "Latest version: $LATEST_VERSION"
else
    echo 'Error: Cannot get the latest version of you-get. Please try again later.'
    exit 0
fi


# Get current you-get version
if [ -e "$VERSION_FILE" ] && [ -d "$DEST_DIR" ]; then
    CURRENT_VERSION=`cat "$VERSION_FILE"`
    echo "Current version: $CURRENT_VERSION"
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo "You-get already up-to-date."
        echo -e "\033[34m -------------------- End --------------------- \033[0m"
        exit 0
    fi
else
    echo "Current version: Not installed"
fi


# Download latest version
echo ""
echo -e "\033[34m -------------- Updating you-get -------------- \033[0m"
echo "Downloading https://github.com/soimort/you-get/archive/develop.zip"
downloader you-get.zip "https://github.com/soimort/you-get/archive/develop.zip"

echo ""
echo "Installing..."
unzip -q you-get.zip
rm -rf "$DEST_DIR"
mv you-get-develop "$DEST_DIR"
chmod +x "$DEST_DIR/you-get"
rm -f you-get.zip


# Save version info
echo "$LATEST_VERSION" > "$VERSION_FILE"

echo ""
echo -e "\033[34m -------------------- End --------------------- \033[0m"

