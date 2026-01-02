# Omarchy Dual-Boot Installation Guide
## ASUS Zephyrus G14 (GA403UI) - Windows + Omarchy

This guide covers the complete installation process for setting up Omarchy (Arch Linux) alongside Windows in a dual-boot configuration.

---

## 🚨 Prerequisites

- **Windows already installed** on the system
- **Arch Linux installation media** (USB drive)
- **Backup** of all important data
- **Shrunk Windows partition** to make space for Omarchy (use Windows Disk Management)

> **Important**: This installation uses a **dedicated EFI partition for Omarchy**, separate from the Windows EFI partition. This prevents boot conflicts and keeps both operating systems independent.

---

## 📋 Partition Scheme

The installation will create the following partitions on **unallocated space**:

| Partition | Size | Type | Format | Mount Point | Purpose |
|-----------|------|------|--------|-------------|---------|
| **EFI (Omarchy)** | 1.5 GB | EFI System Partition | FAT32 | `/boot` | Dedicated Omarchy bootloader (Limine) |
| **Root + Home** | 100% remaining | Linux filesystem | BTRFS (encrypted) | `/` | Encrypted root with subvolumes |

### BTRFS Subvolumes

The encrypted BTRFS partition will contain:

- `@` → `/` (root)
- `@home` → `/home` (user data)
- `@pkg` → `/var/cache/pacman/pkg` (package cache)
- `@log` → `/var/log` (system logs)

---

## 🔧 Installation Steps

### Step 1: Boot into Arch Installation Media

1. Insert the Arch Linux USB drive
2. Restart and press `ESC` or `F2` to enter boot menu
3. Select the USB drive to boot
4. When prompted, select the first option: `Arch Linux install medium`

---

### Step 2: Connect to Internet

Once booted into the live environment:

```bash
# Check network status
ip link

# Connect to WiFi (if needed)
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "YourNetworkName"
exit

# Verify connection
ping archlinux.org
```

---

### Step 3: Launch Archinstall

```bash
archinstall
```

---

### Step 4: Configure Archinstall

#### 📍 **Archinstall language**
- Select: `English`

#### 💾 **Mirrors**
- Select: `Mirror region` → Choose your region (e.g., `United States`)

#### 🌐 **Locales**
- **Locale language**: `en_US`
- **Locale encoding**: `UTF-8`

#### 💿 **Disk configuration**
- Select: `Manual Partitioning`

---

### Step 5: Manual Partitioning (CRITICAL)

#### **Select the disk** 
- Choose your NVMe drive (e.g., `/dev/nvme0n1`)

#### **Create partitions**

You should see existing Windows partitions. **Do not modify them!**

On the **free/unallocated space**, create:

##### **Partition 1: EFI (Omarchy Dedicated)**
- **Size**: `1.5 GB` (1536 MiB)
- **Type**: `EFI System Partition`
- **Format**: `FAT32`
- **Mountpoint**: `/boot`
- **Flags**: `boot, esp`

> ⚠️ **Critical**: This is a **separate EFI partition exclusively for Omarchy**, not shared with Windows. This prevents boot conflicts.

##### **Partition 2: Encrypted Root**
- **Size**: `100%` (all remaining space)
- **Type**: `Linux filesystem`
- **Format**: `BTRFS`
- **Encryption**: `Yes`
- **Encryption password**: Enter a strong passphrase (you'll need this on every boot)
- **Mountpoint**: `/`

#### **Configure BTRFS subvolumes**

When prompted for subvolumes, create the following:

| Subvolume | Mount Point |
|-----------|-------------|
| `@` | `/` |
| `@home` | `/home` |
| `@pkg` | `/var/cache/pacman/pkg` |
| `@log` | `/var/log` |

---

### Step 6: Disk Encryption

- **Encryption type**: `Encryption password` (password only, no TPM or key file)
- **Password**: Enter a **strong passphrase**
- **Confirm password**: Re-enter the same passphrase

> This password will be required **every time you boot** into Omarchy.

---

### Step 7: Bootloader

- Select: `Limine`

Limine is a modern, fast bootloader that will detect both Omarchy and Windows.

---

### Step 8: Swap Configuration

- Select: `No swap` or `zram` (recommended for 32GB RAM laptops)

---

### Step 9: Hostname

- Enter: `g14-omarchy` (or your preferred hostname)

---

### Step 10: Root Password

- **Set root password**: Enter a strong password
- **Confirm**: Re-enter the password

> ⚠️ **Important**: You will NOT use root for daily operations, but this is needed for system recovery.

---

### Step 11: User Account

- **Add a user**: `yes`
- **Username**: Enter your username (e.g., `mlopes`)
- **Password**: Enter your user password
- **Confirm password**: Re-enter
- **Sudo privileges**: `yes` ✓

> ✅ **This is the account you'll use daily**, with sudo rights.

---

### Step 12: Profile

- Select: `Do not use a profile` or `minimal`

> We'll install the full Omarchy environment in the next phase.

---

### Step 13: Audio

- Select: `Pipewire`

---

### Step 14: Kernels

- Select: `linux` (default kernel)

> Note: The G14-specific kernel (`linux-g14`) will be installed during the Omarchy post-installation.

---

### Step 15: Additional Packages

- Leave empty (press Enter)

We'll install everything through the Omarchy installer.

---

### Step 16: Network Configuration

- **Network configuration**: `Copy network configuration from ISO`

This will preserve your WiFi settings.

---

### Step 17: Timezone

- Select your timezone: `Region` → `City`
  - Example: `America` → `New_York`
  - Example: `Europe` → `London`

---

### Step 18: Automatic Time Sync (NTP)

- Select: `yes` ✓

---

### Step 19: Install

- Review all settings
- Select: `Install`
- Confirm: `yes`

The installation will now proceed. This may take 10-20 minutes depending on internet speed.

---

## 🔄 Post-Installation

### Step 1: Reboot

When installation completes:

```bash
# Remove installation media
# Then reboot
reboot
```

---

### Step 2: First Boot

1. **GRUB/Limine menu** will appear
2. You may see both **Omarchy** and **Windows** entries
3. Select **Arch Linux** (Omarchy)
4. **Enter disk encryption password** when prompted
5. **Login with your user account** (NOT root!)

---

### Step 3: Connect to Internet (if needed)

```bash
# If WiFi isn't connected
nmcli device wifi connect "YourNetworkName" password "YourPassword"

# Or use iwctl
iwctl
station wlan0 connect "YourNetworkName"
exit
```

---

### Step 4: Install Omarchy

Run the official Omarchy installer:

```bash
curl -fsSL https://omarchy.org/install | bash
```

This will:
- Install the G14-optimized kernel (`linux-g14`)
- Set up Hyprland with G14-specific configurations
- Install all system utilities and applications
- Configure asusctl for hardware control
- Set up the complete Omarchy desktop environment

---

### Step 5: Apply Your Dotfiles

After the Omarchy installer completes and you reboot:

```bash
# Clone your dotfiles
cd ~
git clone <your-dotfiles-repo> ~/.dotfiles

# Run your install script
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

This will apply all your custom configurations for:
- Hyprland (scratchpads, keybindings, monitors)
- Waybar
- Neovim
- Shell configurations
- And more

---

## 🎯 Verification Checklist

After installation and reboot, verify:

- [ ] Dual-boot menu shows both Omarchy and Windows
- [ ] Disk encryption prompts for password on boot
- [ ] Can boot into Omarchy successfully
- [ ] Can boot into Windows successfully
- [ ] WiFi connects automatically
- [ ] Audio works (Pipewire)
- [ ] ASUS hardware controls work (asusctl)
- [ ] Display brightness controls work
- [ ] GPU switching works (asusctl)
- [ ] All scratchpads function (Super+A, Super+M, etc.)

---

## 🔧 Troubleshooting

### Windows not appearing in boot menu

```bash
# Reinstall Limine and detect Windows
sudo limine-deploy
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Network not working after reboot

```bash
# Enable NetworkManager
sudo systemctl enable --now NetworkManager
```

### Display issues

```bash
# Check if nvidia drivers are loaded
lspci -k | grep -A 3 VGA

# If needed, reinstall drivers
sudo pacman -S nvidia-dkms nvidia-utils
```

---

## 📸 Screenshots Reference

### Archinstall Disk Configuration Example

**Expected partition layout:**

```
Device              Size    Type                    Mount
/dev/nvme0n1p1      100M    Windows Recovery        (do not modify)
/dev/nvme0n1p2      16M     Microsoft reserved      (do not modify)
/dev/nvme0n1p3      250G    Windows (NTFS)          (do not modify)
/dev/nvme0n1p4      512M    Windows EFI             (do not modify)
/dev/nvme0n1p5      1.5G    EFI (Omarchy)           /boot (FAT32) ✓ NEW
/dev/nvme0n1p6      500G    BTRFS (encrypted)       / ✓ NEW
```

---

## 🎓 Key Points Summary

1. **Dedicated EFI**: Omarchy uses its own 1.5GB FAT32 EFI partition, separate from Windows
2. **Full disk encryption**: Password required on every boot (password only, no TPM)
3. **BTRFS subvolumes**: Organized root, home, package cache, and logs
4. **Limine bootloader**: Modern bootloader with dual-boot support
5. **User account**: Always log in with your user (not root), which has sudo privileges
6. **Post-install**: Run Omarchy installer AFTER base Arch installation completes
7. **Dotfiles**: Apply your custom configurations after Omarchy is installed

---

## 📝 Notes

- The installation creates a completely independent Omarchy environment
- Windows and Omarchy do not share any partitions except the boot menu
- The separate EFI partition ensures Windows updates won't break Omarchy boot
- Encryption password is required on every boot for security
- BTRFS subvolumes allow for efficient snapshots and backups

---

**Installation Date**: January 2, 2026  
**System**: ASUS Zephyrus G14 (GA403UI)  
**OS**: Omarchy (Arch Linux) + Windows 11 Dual-Boot
