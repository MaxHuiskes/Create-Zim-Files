# ZIM Site Creator

A lightweight tool to **archive websites as ZIM files** for offline browsing with Kiwix.

## Overview

ZIM Site Creator automates:

* Downloading a website with all pages and assets.
* Converting it into a ZIM file with `zimwriterfs`.
* Cleaning up temporary files.

## Prerequisites

* Raspberry Pi OS / Debian / Ubuntu
* `wget`
* `zimwriterfs` (included in **zim-tools**)

Install dependencies on Raspberry Pi:

```bash
sudo apt update
sudo apt install wget zim-tools
```

`zimwriterfs` becomes available after installing `zim-tools`.

## Installation

Clone the repository:

```bash
git clone https://github.com/MaxHuiskes/Create-Zim-Files.git
cd Create-Zim-Files
chmod +x make_zim.sh
```

## Usage

```bash
sudo ./make_zim.sh <site_url> <output_folder> <zim_title> <zim_description> <creator>
```

### Example

```bash
sudo ./make_zim.sh http://textfiles.com /media/disk2t/data/selfmade \
"Textfiles.com Archive" \
"Archived text files from textfiles.com" \
"textfiles.com"
```

Arguments:

* `site_url` → website to download
* `output_folder` → location where the `.zim` will be stored
* `zim_title` → title inside ZIM metadata
* `zim_description` → description metadata
* `creator` → creator metadata

The script deletes the temporary download directory and leaves only the final `.zim`.

## Docker Stack Integration (Optional)

Serve the ZIM files with kiwix-serve:

```yaml
version: "3.8"
services:
  kiwix:
    image: ghcr.io/kiwix/kiwix-serve
    container_name: kiwix
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - /media/disk2t/data:/data
    command: ["--library", "/data/library.xml"]
```

Steps:

1. Place `.zim` files in `/media/disk2t/data/`.
2. Update `library.xml`:

```bash
kiwix-manage /media/disk2t/data/library.xml add /media/disk2t/data/*.zim
```

3. Start:

```bash
docker compose up -d
```

4. Access via:

```
http://<server-ip>:8080
```

## Optional PDF Documentation

Requires pandoc + texlive:

```bash
sudo apt install pandoc texlive-xetex
pandoc docs/explanation.md -o docs/explanation.pdf
```

## Contributing

Fork → Change → Pull Request.

## License

MIT License
