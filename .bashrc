function toolbox_download() {
    # downloads & extracts latest version of JetBrains Toolbox to the user's home directory
    cd ~
    clear
    echo "downloads most current jetbrains toolbox file - overwrites old version at jetbrains-toolbox.tgz"

    local jetbrains_tb_releases_url
    jetbrains_tb_releases_url='https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release'

    local jetbrains_tb_download_url
    jetbrains_tb_download_url=$(curl "$jetbrains_tb_releases_url" | jq --raw-output '.TBA[0].downloads.linux.link')

    # Work as root to avoid permissions issues; show progress bar
    sudo curl --output jetbrains-toolbox-current.tgz --progress-bar --location "$jetbrains_tb_download_url"
    sudo chown root:root jetbrains-toolbox-current.tgz

    # Create destination dir and extract contents so name is predicatable (strip version number from dir name)
    local extraction_dir
    extraction_dir="jetbrains-toolbox-current"

    sudo mkdir -p "$extraction_dir"
    sudo tar -xzvf jetbrains-toolbox-current.tgz --strip-components=1 -C "$extraction_dir"
    sudo rm jetbrains-toolbox-current.tgz

    echo ""
    echo -e "${Gold3}jetbrains-toolbox unzipped${NO_COLOR}"
    echo -e "${Gold3}jetbrains-toolbox binary @: /opt/jetbrains-toolbox/jetbrains-toolbox${NO_COLOR}"
    echo ""
    ls
}

function toolbox_update() {
    # Installs the latest version of JetBrains Toolbox as root, using toolbox_download function
    # work as root to avoid permissions issues
    toolbox_download

    # Define source and destination paths with 'toolbox_' prefix for clarity
    local toolbox_source_path
    toolbox_source_path="$HOME/jetbrains-toolbox-current/jetbrains-toolbox"

    local toolbox_destination_path="/opt/jetbrains-toolbox/jetbrains-toolbox"
    toolbox_destination_path

    local toolbox_symlink_path
    toolbox_symlink_path="/usr/local/bin/jetbrains-toolbox"

    # Copy the downloaded jetbrains-toolbox to the destination
    sudo cp "$toolbox_source_path" "$toolbox_destination_path"

    # Check for toolbox symlink -- create if it doesn't exist
    if [[ ! -L "$toolbox_symlink_path" || "$(readlink -f "$toolbox_symlink_path")" != "$toolbox_destination_path" ]]; then
        sudo ln -sf "$toolbox_destination_path" "$toolbox_symlink_path"
        sudo chown root:root "$toolbox_symlink_path"
        echo "Toolbox symlink created at $toolbox_symlink_path"
    else
        echo "Toolbox symlink already exists and is correctly set."
    fi

    echo -e "${Gold3}JetBrains Toolbox updated successfully.${NO_COLOR}"
    echo ""
}
