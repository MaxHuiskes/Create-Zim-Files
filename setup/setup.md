---

# **ZIM Site Creator & Portable Offline Kiwix Server**

A complete solution to **archive websites as ZIM files** and serve them offline via a **portable Kiwix server**. Works on Raspberry Pi Zero 2 W, Pi 4, and small x86 SBCs.

---

## **Overview**

**ZIM Site Creator** automates:

* Downloading a website (pages, images, assets).
* Converting it into a ZIM file using `zimwriterfs`.
* Cleaning up temporary files after creating the ZIM.

**Portable Kiwix Server**:

* Serves multiple ZIM files using Docker.
* Can run on battery-powered devices with Wi-Fi hotspot access.
* Perfect for offline educational, research, or personal use.

---

## **1. Prerequisites**

### For ZIM Creation

* Linux system (Ubuntu/Debian tested)
* `wget`
* `zimwriterfs` ([installation guide](https://wiki.kiwix.org/wiki/Zimwriterfs))
* Optional: `pandoc` & `texlive-xetex` for PDF documentation

```bash
sudo apt update
sudo apt install wget zimwriterfs
```

### For Portable Kiwix Server

* Docker & Docker Compose
* Optional: hostapd and dnsmasq for Wi-Fi hotspot

---

## **2. ZIM Creation Script**

Clone repo and make script executable:

```bash
git clone https://github.com/MaxHuiskes/Create-Zim-Files.git
cd Create-Zim-Files
chmod +x make_zim.sh
```

### Usage

```bash
sudo ./make_zim.sh <site_url> <output_folder> <zim_title> <zim_description> <creator>
```

### Example

```bash
sudo ./make_zim.sh http://textfiles.com /media/disk2t/data/selfmade "Textfiles.com Archive" "Archived text files from textfiles.com" "textfiles.com"
```

* After running, only the `.zim` file remains in the output folder.

---

## **3. Generate `library.xml` for Kiwix**

```bash
sudo kiwix-manage /media/kiwix/data/library.xml add /media/kiwix/data/*.zim --zimPathToSave=/data
```

* Updates the library to include all ZIMs.
* Check content:

```bash
kiwix-manage /media/kiwix/data/library.xml show
```

---

## **4. Docker Compose Setup**

Create `docker-compose.yml`:

```yaml
version: "3.8"
services:
  kiwix:
    image: kiwix/kiwix-serve:arm32v7  # arm32 for Pi Zero 2 W, use aarch64 for Pi 4
    container_name: kiwix
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - /media/kiwix/data:/data
    command:
      - "--library"
      - "/data/library.xml"
```

Start server:

```bash
docker-compose up -d
```

* Access via browser: `http://<device_ip>:8080`

---

## **5. Optional: Battery-Powered Wi-Fi Hotspot**

1. Install hotspot tools:

```bash
sudo apt install hostapd dnsmasq
sudo systemctl stop hostapd dnsmasq
```

2. Configure static IP (`/etc/dhcpcd.conf`):

```text
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
```

3. Configure hostapd (`/etc/hostapd/hostapd.conf`):

```text
interface=wlan0
ssid=OfflineServer
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=YourPassword
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
```

4. Start hotspot:

```bash
sudo systemctl start hostapd
sudo systemctl start dnsmasq
```

* Connect devices to Wi-Fi and access server at `http://192.168.4.1:8080`.

---

## **6. Hardware Recommendations**

| Device                | Notes                                         |
| --------------------- | --------------------------------------------- |
| Raspberry Pi Zero 2 W | 512 MB RAM, small ZIMs only                   |
| Raspberry Pi 4        | 2–8 GB RAM, handles large ZIMs like Wikipedia |
| Odroid N2/N2+         | Fast CPU, small form factor                   |
| Intel NUC / x86 SBC   | Full Linux support, large storage options     |

**Common peripherals**: microSD (16–32 GB), external SSD/USB (≥128 GB), battery pack (10,000–20,000 mAh), optional USB OTG hub.

---

## **7. PDF Documentation**

Generate a PDF explaining the script and workflow:

```bash
pandoc docs/explanation.md -o docs/explanation.pdf
```

---

## **8. Tips**

* Keep ZIMs small on Pi Zero 2 W.
* Update `library.xml` whenever adding new ZIMs.
* Use battery packs ≥10,000 mAh for extended portability.
* Fully offline: clients can connect via hotspot or local network.

---

## **License**

MIT License

---
