**complete guide for setting up a portable offline server on a Raspberry Pi Zero 2 W** with Kiwix, Docker, and battery-powered Wi-Fi access:

---

## **Portable Offline Kiwix Server Guide (Pi Zero 2 W)**

### **1. Hardware Requirements**

* **Raspberry Pi Zero 2 W** (512 MB RAM, quad-core ARMv7)
* **MicroSD card** (16–32 GB for OS)
* **External USB storage** (SSD or flash drive, recommended ≥128 GB for multiple ZIMs)
* **Power supply** or **portable battery pack**
* **Optional:** USB OTG hub (if connecting multiple devices)

---

### **2. Install Raspberry Pi OS**

1. Flash **Raspberry Pi OS Lite (32-bit)** to the SD card using [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
2. Boot Pi and enable SSH for headless setup.

---

### **3. Install Docker**

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pi
sudo systemctl enable docker
sudo reboot
```

* Test Docker:

```bash
docker run --rm arm32v7/alpine uname -m
```

* Should return `armv7l`.

---

### **4. Prepare Storage**

* Mount your external SSD/USB drive:

```bash
sudo mkdir -p /media/kiwix
sudo mount /dev/sda1 /media/kiwix
```

* Copy your ZIM files:

```
/media/kiwix/data
    ├─ wikipedia-en_2025-08.zim
    ├─ devdocs_en_javascript_2025-07.zim
    ├─ selfmade_site.zim
    └─ library.xml
```

---

### **5. Generate `library.xml`**

```bash
sudo kiwix-manage /media/kiwix/data/library.xml add /media/kiwix/data/*.zim --zimPathToSave=/data
```

---

### **6. Docker Compose for Kiwix**

Create `docker-compose.yml` on the Pi:

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

Start the server:

```bash
docker-compose up -d
```

Access it via browser on your local network:

```
http://<pi_ip>:8080
```

---

### **7. Optional: Portable Wi-Fi Hotspot**

1. Install hostapd and dnsmasq:

```bash
sudo apt install hostapd dnsmasq
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
```

2. Configure `/etc/dhcpcd.conf` to assign static IP to Wi-Fi.
3. Configure `/etc/hostapd/hostapd.conf`:

```
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

---

### **8. Usage**

* Place ZIM files in `/media/kiwix/data/`.
* Update `library.xml` using `kiwix-manage` after adding new ZIMs.
* Access via browser on `http://OfflineServer:8080` (if hotspot is active) or local network IP.

---

### **9. Notes**

* **Memory limitations:** Pi Zero 2 W struggles with huge ZIMs (Wikipedia). Smaller ZIMs like documentation, StackExchange, or self-made sites work best.
* **Battery operation:** Use a 10,000–20,000 mAh power bank for hours of uptime.
* **Portability:** Everything fits into a small case; Wi-Fi hotspot makes it fully offline.

---
