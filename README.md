# Spotify Ad Muter Service

Automatically detects and mutes Spotify advertisements on Linux.

## Features

- 🎵 Monitors Spotify player via D-Bus/MPRIS
- 🔇 Automatically mutes when ads are detected
- 🔊 Unmutes when regular content resumes
- 🚀 Lightweight background service

## Installation

### Quick Install (Recommended)

One-line installation that automatically downloads, installs, and sets up the systemd service:

```bash
curl -sfSL https://raw.githubusercontent.com/aminrazeghi/SpotifyMuter/main/install.sh | bash
```

The service will start automatically and run in the background whenever you're logged in.

**What it does:**
- Downloads the latest release binary
- Installs to `~/.local/bin`
- Creates and enables a systemd user service for automatic startup

### Manual Installation from Release

1. Download the latest release from the [Releases page](../../releases)
2. Extract the archive:
   ```bash
   tar -xzf spotify-ad-muter-linux-x64.tar.gz
   ```
3. Move to a directory in your PATH:
   ```bash
   mkdir -p ~/.local/bin
   mv spotify_muter ~/.local/bin/
   chmod +x ~/.local/bin/spotify_muter
   ```
4. (Optional) Create systemd service - see [Systemd Service Setup](#systemd-service-setup)

### Build from Source

#### Requirements

- CMake 3.10+
- GLib 2.0
- GIO 2.0
- C++17 compiler (g++ or clang++)
- pkg-config

#### Build Steps

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt-get install cmake g++ libglib2.0-dev pkg-config

# Build
mkdir build && cd build
cmake ..
make

# Run
./spotify_muter
```

## Systemd Service Setup

If you used the installation script, the service is already configured. Otherwise, create a user service manually:

### Create Service File

Create `~/.config/systemd/user/spotify-ad-muter.service`:

```ini
[Unit]
Description=Spotify Ad Muter Service
After=default.target

[Service]
Type=simple
ExecStart=%h/.local/bin/spotify_muter
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

### Enable and Start

```bash
# Reload systemd
systemctl --user daemon-reload

# Enable service to start on login
systemctl --user enable spotify-ad-muter.service

# Start the service now
systemctl --user start spotify-ad-muter.service

# Check status
systemctl --user status spotify-ad-muter.service
```

### Service Management

```bash
# View logs
journalctl --user -u spotify-ad-muter.service -f

# Stop service
systemctl --user stop spotify-ad-muter.service

# Restart service
systemctl --user restart spotify-ad-muter.service

# Disable auto-start
systemctl --user disable spotify-ad-muter.service
```

## Uninstall

Run the uninstall script:

```bash
./uninstall.sh
```

This will:
- Stop and disable the systemd service
- Remove the service file
- Remove the binary from `~/.local/bin`

## Usage

### Running Manually

If not using the systemd service, run the executable while Spotify is playing:

```bash
./spotify_muter
```

The service will:
- Monitor Spotify for track changes
- Detect ads by checking for "advertisement" in track titles
- Mute volume when ads play
- Restore volume when regular content resumes

Press `Ctrl+C` to stop the service.

## Creating a Release

To create a new release:

1. Tag your commit with a version:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. GitHub Actions will automatically:
   - Build the binary
   - Create a release on the releases page
   - Upload the compiled binary as a downloadable asset

## How It Works

The service uses the MPRIS D-Bus interface to:
1. List all media players on the session bus
2. Filter for Spotify (`org.mpris.MediaPlayer2.spotify`)
3. Read track metadata (specifically `xesam:title`)
4. Check if the title contains "advertisement"
5. Control the player's volume property accordingly

## License

MIT License - feel free to use and modify as needed.
