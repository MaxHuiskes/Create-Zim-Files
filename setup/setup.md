Here’s an expanded **complete guide** covering a few small devices (Raspberry Pi Zero 2 W, Pi 4, and small x86 SBCs) for setting up a portable offline Kiwix server with battery-powered Wi-Fi access:

---

# **Portable Offline Kiwix Server Guide**

This guide explains how to set up a battery-powered, portable offline Kiwix server to serve ZIM files (Wikipedia, documentation, or custom sites) on different small devices.

---

## **1. Supported Hardware**

| Device                | Notes                                                |
| --------------------- | ---------------------------------------------------- |
| Raspberry Pi Zero 2 W | 512 MB RAM, ARMv7, lightweight, ideal for small ZIMs |
| Raspberry Pi 4        | 2–8 GB RAM, handles large ZIMs (Wikipedia)           |
| Odroid N2/N2+         | 2–4 GB RAM, fast CPU, small form factor              |
| Intel NUC / x86 SBC   | Full Linux support, more storage options             |

**Common peripherals:**

* MicroSD card (16–32 GB for OS)
* External SSD/USB (≥128 GB recommended)
* Battery pack (10,000–20,000 mAh)
* Optional: USB OTG hub

---

## **2. Install OS**

### Raspberry Pi:

1. Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/) to flash **Raspberry Pi OS Lite (32-bit)**.
2. Enable SSH (headless) if needed.
3. Boot and login.

### x86 SBCs:

1. Install Ubuntu Server (20.04+ recommended).
2. Update system:

```bash
sudo apt update && sudo apt upgrade -y
```

---

## **3. Install Docker**

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pi   # Or your username
sudo systemctl enable docker
sudo reboot
```

Test Docker:

```bash
docker run --rm alpine uname -m
```

* Pi Zero 2 W → `armv7l`
* Pi 4 → `aarch64`
* x86 → `x86_64`

---

## **4. Prepare Storage**

1. Mount external SSD or USB:

```bash
sudo mkdir -p /media/kiwix
sudo mount /dev/sda1 /media/kiwix
```

2. Create data folder:

```bash
mkdir -p /media/kiwix/data
```

3. Copy ZIM files or generate new ones in `data/`.

---

## **5. Generate `library.xml`**

```bash
sudo kiwix-manage /media/kiwix/data/library.xml add /media/kiwix/data/*.zim --zimPathToSave=/data
```

* Updates library to include all ZIMs in `/data`.
* Use `kiwix-manage ... show` to verify.

---

## **6. Docker Compose Setup**

Create `docker-compose.yml`:

```yaml
version: "3.8"
services:
  kiwix:
    image: kiwix/kiwix-serve:arm32v7  # arm32 for Pi Zero 2 W
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

Access via browser: `http://<device_ip>:8080`

---

## **7. Optional: Battery-Powered Wi-Fi Hotspot**

### Install hotspot tools:

```bash
sudo apt install hostapd dnsmasq
sudo systemctl stop hostapd dnsmasq
```

### Configure static IP (`/etc/dhcpcd.conf`):

```text
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
```

### Configure hostapd (`/etc/hostapd/hostapd.conf`):

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

### Start hotspot:

```bash
sudo systemctl start hostapd
sudo systemctl start dnsmasq
```

* Connect devices to Wi-Fi and access server at `http://192.168.4.1:8080`.

---

## **8. Usage Tips**

* Add new ZIMs → update `library.xml` with `kiwix-manage`.
* Smaller devices like Pi Zero 2 W: use small/medium ZIMs (DevDocs, StackExchange, self-made sites).
* Pi 4 / x86 SBC: can serve large ZIMs (Wikipedia) smoothly.
* Use battery packs rated ≥10,000 mAh for extended portability.

---

This guide covers **different hardware**, portable Wi-Fi access, and Docker-based Kiwix server setup, making it fully offline and portable.

---

If you want, I can also **draft a visual workflow diagram** showing: **ZIM creation → library.xml → Docker → Wi-Fi hotspot → client access**. This would make it much easier for beginners to follow. Do you want me to do that?
