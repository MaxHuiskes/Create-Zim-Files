# ZIM Site Creator

A lightweight tool to **archive websites as ZIM files** for offline browsing with [Kiwix](https://kiwix.org/).

## Overview

ZIM Site Creator automates:

* Downloading a website with all pages, assets, and images.
* Converting it into a ZIM file using `zimwriterfs`.
* Cleaning up temporary files after creating the ZIM.

**Purpose:**

* Make any public website accessible offline.
* Create offline libraries for personal, educational, or remote use.
* Integrate with a Kiwix Docker stack to serve multiple ZIM files over HTTP.

## Prerequisites

* Linux system (tested on Ubuntu)
* `wget`
* `zimwriterfs` ([installation guide](https://wiki.kiwix.org/wiki/Zimwriterfs))
* Optional: `pandoc` & `texlive-xetex` to generate PDF documentation

Install dependencies (Ubuntu/Debian):

```bash
sudo apt update
sudo apt install wget zimwriterfs
```

## Installation

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/zim-site-creator.git
cd zim-site-creator
chmod +x make_zim.sh
```

## Usage

```bash
sudo ./make_zim.sh <site_url> <output_folder> <zim_title> <zim_description> <creator>
```

### Example

```bash
sudo ./make_zim.sh http://textfiles.com /media/disk2t/data/selfmade "Textfiles.com Archive" "Archived text files from textfiles.com" "textfiles.com"
```

* `site_url` → website to archive
* `output_folder` → folder to save the `.zim` file
* `zim_title` → ZIM file title
* `zim_description` → description metadata
* `creator` → creator/author metadata

After running, only the `.zim` file remains in the output folder.

## Docker Stack Integration

You can serve ZIM files with Kiwix using Docker Compose:

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

1. Place all `.zim` files in `/media/disk2t/wikipedia/`.
2. Generate or update `library.xml` using `kiwix-manage`.
3. Run the stack: `docker-compose up -d`.
4. Access your offline library at `http://<server-ip>:8087`.

## Optional PDF Documentation

Generate a PDF explaining the script:

```bash
pandoc docs/explanation.md -o docs/explanation.pdf
```

## Contributing

Contributions welcome! Fork the repo, make changes, and submit a pull request.

## License

MIT License
