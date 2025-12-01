---

# **ZIM Site Creator & Portable Offline Kiwix Server (Pi Zero 2 W)**

A complete solution to **archive websites as ZIM files** and serve them offline via a **portable Kiwix server** on a Raspberry Pi Zero 2 W.

---

## **1. Hardware Requirements**

* **Raspberry Pi Zero 2 W** (512 MB RAM, quad-core ARMv7)
* **MicroSD card** (16–32 GB for OS)
* **External USB storage** (SSD or flash drive, ≥128 GB recommended)
* **Power supply** or **portable battery pack**
* **Optional:** USB OTG hub

---

## **2. Install Raspberry Pi OS**

1. Flash **Raspberry Pi OS Lite (32-bit)** using [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
2. Boot Pi and enable SSH for headless setup.

---

## **3. Install Docker**

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pi
sudo systemctl enable docker
sudo reboot
```

Test Docker:

```bash
docker run --rm arm32v7/alpine uname -m
```

* Should return `armv7l`.

---

## **4. Prepare Storage**

* Mount external SSD/USB:

```bash
sudo mkdir -p /media/kiwix
sudo mount /dev/sda1 /media/kiwix
```

* Copy ZIM files:

```
/media/kiwix/data
    ├─ wikipedia-en_2025-08.zim
    ├─ devdocs_en_javascript_2025-07.zim
    ├─ selfmade_site.zim
    └─ library.xml
```

---

## **5. Create ZIM Files (Optional)**

Use the **ZIM Site Creator script** to archive websites:

```bash
sudo ./make_zim.sh <site_url> <output_folder> <zim_title> <zim_description> <creator>
```

Example:

```bash
sudo ./make_zim.sh http://textfiles.com /media/kiwix/data "Textfiles.com Archive" "Archived text files from textfiles.com" "textfiles.com"
```

* Only the `.zim` file will remain; temporary files are removed automatically.

---

## **6. Generate `library.xml`**

```bash
sudo kiwix-manage /media/kiwix/data/library.xml add /media/kiwix/data/*.zim --zimPathToSave=/data
```

* Updates the library to include all ZIM files.
* Verify content:

```bash
kiwix-manage /media/kiwix/data/library.xml show
```

---

## **7. Docker Compose Setup**

Create `docker-compose.yml`:

```yaml
version: "3.8"
services:
  kiwix:
    image: kiwix/kiwix-serve:arm32v7
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

Access via browser on local network:

```
http://<pi_ip>:8080
```

---

## **8. Optional: Battery-Powered Wi-Fi Hotspot**

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

## **9. Usage Tips**

* Update `library.xml` whenever adding new ZIMs.
* Pi Zero 2 W: use small/medium ZIMs (e.g., documentation, StackExchange, self-made sites).
* Pi Zero 2 W struggles with large ZIMs like full Wikipedia.
* Battery packs ≥10,000 mAh provide hours of uptime.
* Fully portable setup: all-in-one small case with optional Wi-Fi hotspot.

---

## **10. License**

MIT License

---
