# Yeni sistem (düz Arch) notları

Sahibi 23 Kasım 2026'da bootc'li `nos`'u bıraktı ve normal bir Arch kurulumuna geçti. Bu depo (`github.com/ichbinbekir/dotfiles`, chezmoi kaynağı) sahibinin kişisel ayarlarını tutuyor; bu dosya ayrıca yeni sistemde yapılan bütün ayarların (sistem geneli dahil) kaydı. **Eski proje** `~/Documents/nos/` (artık git deposu değil; içinde bu depo da duruyor): oradaki `CLAUDE.md` (aşağıda "eski CLAUDE.md") ve `core/`, `machines/` gibi yollar eski sistemin; gerekçe, taşınacaklar listesi, paket listeleri, donanım notları için başvuru.

## Çalışma şekli

- Cevaplar Türkçe, sade, teknik terimsiz. Sahibinin kabuğu **fish**: komutlar fish biçiminde (heredoc yok; `printf ... | sudo tee`, `set`, `env VAR=...`).
- **Bu depoya commit atılır** (conventional commit, İngilizce mesaj); **push sadece sahibi söyleyince.** Eski `nos` artık git deposu değil.
- `sudo` şifre istiyor; Claude sistem dosyalarını kendisi yazamaz. Komutlar sohbette verilir, sahibi çalıştırır.
- **Her dosya değişikliği aşağıdaki "Yapılan değişiklikler"e yazılır** (hangi dosya, ne, neden, nasıl geri alınır) ve sohbette de söylenir.
- **Kalıntı bırakılmaz.** Geçici dosyalar (indirmeler, denemeler, derleme klasörleri) sadece `~/.cache/` ya da `/tmp` gibi silinebilir yerlerde. Bir paketin kendi dosyasının üstüne yazılmaz; ek ayar dosyası (`/etc/...d/`) kullanılır. Gereksiz paket, servis, dosya eklenmez.
- Bir şey yapılmadan önce mevcut durum kontrol edilir (dosya var mı, ne yazıyor).
- **Ev klasörüne giden her ayar bu depoya da eklenir** (sahibinin kuralı). Sistem geneline (`/etc`) yazılanlar buraya girmez, sadece bu dosyada not edilir. Gizli bilgiler (SSH anahtarı, şifre, token) asla girmez.
- README İngilizce; bu dosya Türkçe.

## Sistem

- Acer Nitro AN16-51, Arch, KDE Plasma 6.8 (Wayland), çekirdek 7.3.x. Bilgisayar adı `billmonster`, kullanıcı `bekir`.
- Sistem dili İngilizce (`LANG=en_US.UTF-8`), klavye Türkçe Q.
- Giriş ekranı (SDDM) KWin Wayland ile (aşağıda "Giriş ekranı Wayland'de").

## Yapılan değişiklikler

### Klavye: Türkçe Q (24 Kasım 2026)

Sahibi `/etc/vconsole.conf`'a `KEYMAP=trq` yazmıştı (sadece metin ekranı). Giriş ekranı ve KDE ABD düzenindeydi (`localectl`: "X11 Layout: (unset)", `~/.config/kxkbrc` yok).

- **`/etc/X11/xorg.conf.d/00-keyboard.conf`**: `sudo localectl --no-convert set-x11-keymap tr pc105` ile (localed yazıyor; `--no-convert` vconsole'a dokunmasın diye). Giriş ekranı (SDDM, X11) bunu kullanıyor. SDDM ileride Wayland'e alınırsa KWin `--locale1` ile aynı ayarı localed'den okur, değişiklik gerekmez.
- **`/etc/xdg/kxkbrc`** (`[Layout]` `LayoutList=tr`, `Use=true`): KDE oturumu (KWin) düzeni localed'den değil kullanıcının `kxkbrc`'sinden okuyor; `/etc/xdg` bütün kullanıcılar için varsayılan. Sahibi KDE Ayarları'nda klavyeyi değiştirirse `~/.config/kxkbrc` oluşur ve bunu ezer (normal).
- Geri almak: `sudo rm /etc/X11/xorg.conf.d/00-keyboard.conf /etc/xdg/kxkbrc`.
- Kontrol: `localectl status` → "X11 Layout: tr"; giriş ekranında ve KDE'de `ı`/`i`/`ş` tuşları.

### Acer güç modları (24 Kasım 2026)

Çekirdek 7.3.5'in `acer_wmi`'sinde AN16-51 hâlâ yok (listede AN515-58 var); sahibinin 7 Kasım yaması henüz gelmemiş. `predator_v4` kapalıydı, `/sys/firmware/acpi/platform_profile` yoktu, `power-profiles-daemon` kurulu ama kapalıydı.

- **`/etc/modprobe.d/acer-nitro.conf`**: `options acer_wmi predator_v4=1` (eski sistemdeki `nos-acer.conf`'un aynısı; nedeni eski CLAUDE.md "Acer güç modları ve fanlar"). Güç modları, fan/ısı sensörleri, turbo tuşu. Fan hızını elle ayarlama (pwm) bununla açılmaz, yama gelince açılır.
- **`power-profiles-daemon.service` açıldı** (`systemctl enable --now`): KDE'deki güç modu seçicisi bunu kullanıyor (eski sistemde de açıktı).
- Kalkar: yama Arch çekirdeğine gelince `/etc/modprobe.d/acer-nitro.conf` silinir (kontrol: `zstdcat (modinfo -n acer_wmi) | strings | grep AN16-51`).
- Kontrol (yeniden başlattıktan sonra): `cat /sys/firmware/acpi/platform_profile_choices` → `low-power quiet balanced balanced-performance performance`; `powerprofilesctl`; turbo tuşu modları değiştiriyor.

### Giriş ekranı Wayland'de (24 Kasım 2026)

SDDM paketin varsayılanıyla X11'de çalışıyordu (`/usr/lib/sddm/sddm.conf.d/default.conf` `DisplayServer=x11`). Xorg oturum boyunca arkada kalıp NVIDIA kartını tutuyordu (eski sistemde görüldü).

- **`/etc/sddm.conf.d/10-wayland.conf`**: eski sistemin `core/system_files/etc/sddm.conf.d/10-wayland.conf`'unun aynısı (`DisplayServer=wayland`, KWin `--drm --no-lockscreen --no-global-shortcuts --locale1`, `QT_WAYLAND_SHELL_INTEGRATION=layer-shell`). `/etc`'de olmalı (`/usr/lib/sddm/sddm.conf.d/`'de paketin `default.conf`'u alfabede sonra gelip ezer). Kurulum: Claude dosyayı kendi geçici klasörüne yazdı, sahibi `sudo install -Dm644 <dosya> /etc/sddm.conf.d/10-wayland.conf` ile kopyaladı.
- Klavye: `--locale1` ile KWin düzeni localed'den (`00-keyboard.conf`'un kaynağı) alıyor; ek ayar gerekmez. Varsayılan temanın göstergesi Wayland'de "Layout ?? zz" yazabilir, düzen yine doğru (eski sistemde görüldü).
- `xorg-server` sddm'in bağımlılığı olarak kurulu kalıyor, kullanılmıyor.
- Geri almak: `sudo rm -r /etc/sddm.conf.d`.
- Kontrol: girişten sonra `pgrep -a Xorg` boş olmalı. NVIDIA kartının boştayken uyuması ayrıca çekirdek 7.3'teki RTD3 sorununa bağlı (eski CLAUDE.md "Hibrit grafik"), bu ayar onu çözmez.
- **Ölçek (25 Kasım):** giriş ekranı çok büyüktü: sahibinin ölçeği %125 (`~/.config/kwinoutputconfig.json`, `eDP-1` 2560×1600), SDDM'nin KWin'i ise kendi seçtiği ölçekle açılıyordu. Sahibi Sistem Ayarları → Giriş Ekranı (SDDM) → "Apply Plasma Settings…" ile düzeltti (doğruladı). Bu düğme (`/usr/lib/kf6/kauth/kcmsddm_authhelper`) sadece `kdeglobals`, `plasmarc`, `kcminputrc`, `kwinoutputconfig.json`'u `/var/lib/sddm/.config/`'e kopyalıyor; ekran/tema/yazı tipi değişince yeniden basılmalı. `/etc/sddm.conf` (`[Theme] Current=breeze` vb.) de bu KCM'nin yazdığı dosya.
- **Gece ışığı (25 Kasım, sahibi çalıştırdı, giriş ekranında çalışıyor):** düğme `kwinrc`'yi kopyalamadığı için giriş ekranında kapalıydı. Sahibinin `[NightColor]`'ı `Active=true`, `Mode=Constant` (sıcaklık varsayılan 4500K, konum gerekmez). Komutlar: `sudo -u sddm env HOME=/var/lib/sddm kwriteconfig6 --file /var/lib/sddm/.config/kwinrc --group NightColor --key Active true` ve aynısı `--key Mode Constant` (dosya `sddm` kullanıcısına ait olsun diye `-u sddm`). Sahibi gece ışığı ayarını (sıcaklık, mod) değiştirirse buraya da elle yazılmalı. Geri almak: `sudo -u sddm env HOME=/var/lib/sddm kwriteconfig6 --file /var/lib/sddm/.config/kwinrc --group NightColor --key Active --delete`.

### Açılış animasyonu (plymouth) (24 Kasım 2026)

Açılış yöneticisi **GRUB** (2.16; `/boot/grub/grub.cfg`), initramfs **mkinitcpio** (`HOOKS=(base systemd autodetect microcode modconf keyboard sd-vconsole block filesystems fsck)`, `kms` yok). Sahibi `plymouth` paketini kurmuştu; tema Arch varsayılanı `bgrt` (`/etc/plymouth/plymouthd.conf`: UEFI üretici logosu + dönen simge).

- **`/etc/default/grub`**: `GRUB_CMDLINE_LINUX_DEFAULT`'a `splash` eklendi (`loglevel=3 quiet splash zswap.enabled=0`). GRUB'da `.d` ek dosyası yok (Arch'ın GRUB'u desteklemiyor), dosyanın kendisi `sed` ile düzenlendi.
- **`/etc/mkinitcpio.conf`**: `HOOKS`'a `systemd`'den hemen sonra `plymouth` (Arch Wiki). `conf.d` ek dosyası bütün `HOOKS` dizisini kopyalamayı gerektirdiği için ana dosya düzenlendi.
- Ardından `mkinitcpio -P` ve `grub-mkconfig -o /boot/grub/grub.cfg`.
- `kms` hook'u bilerek eklenmedi: plymouth initramfs'te çekirdeğin `simpledrm`'iyle başlıyor, i915 yüklenince geçiyor (bir an titreme olabilir). Rahatsız ederse `kms` eklenebilir (NVIDIA modülleri `drivers/gpu/drm` altında olmadığı için girmez).
- `sddm.service` zaten `After=plymouth-quit.service`.
- Geri almak: iki `sed`'in tersi (`splash` ve `plymouth` kelimelerini silmek), sonra yine `mkinitcpio -P` ve `grub-mkconfig`.
- Açılışta Esc yazıları gösterir.

### Takas: zram (24 Kasım 2026)

`zram-generator` kuruluydu ama ayar dosyası yoktu, sistemde hiç takas yoktu (`swapon` boş). Çekirdek satırında `zswap.enabled=0` var (kurulumdan; zram ile zswap birlikte kullanılmaz, doğru).

- **`/etc/systemd/zram-generator.conf`**: eski sistemdeki `core/system_files/usr/lib/systemd/zram-generator.conf`'un aynısı: `[zram0]` `zram-size = min(ram, 8192)` (16 GB RAM'de 8 GB), `compression-algorithm = zstd`. Paket `/usr/lib`'e dosya koymuyor; `/etc` yöneticinin yeri.
- Açılışta generator kendisi kuruyor; ilk sefer `systemctl daemon-reload` + `systemctl start systemd-zram-setup@zram0.service` ile yeniden başlatmadan açıldı.
- swappiness gibi sysctl ayarı yapılmadı (eski sistemde de yoktu).
- Disk swap yok. Kurulumdan kalma boş bir `@swap` btrfs alt birimi `/swap`'a bağlı (`/etc/fstab`); içinde dosya yok. Eski sistemdeki açık konu (zram arkasına 16 GB swapfile, hazırda bekletme) için hazır duruyor; istenmezse fstab satırı + alt birim silinebilir.
- Geri almak: `sudo swapoff /dev/zram0; sudo rm /etc/systemd/zram-generator.conf; sudo systemctl daemon-reload`.
- Kontrol: `zramctl` (zstd, 8G), `swapon --show`.

### İşlemci zamanlayıcısı: bpfland (24 Kasım 2026)

Çekirdekte `CONFIG_SCHED_CLASS_EXT=y`; önce `/sys/kernel/sched_ext/state` `disabled`. Eski sistemdeki gibi (eski CLAUDE.md "sched_ext").

- **Paketler:** `scx-scheds` (bütün zamanlayıcılar, ~154 MB; tek paket, ayıklanmıyor) + `scx-tools` (`scx_loader` servisi, `scxctl`, `scxtui`).
- **`/etc/scx_loader.toml`**: eski sistemin `core/system_files/etc/scx_loader.toml`'unun aynısı: `default_sched = "scx_bpfland"`, `default_mode = "Auto"`. scx_loader sırayla `/etc/scx_loader/config.toml` → `/etc/scx_loader.toml` → `/usr/share/scx_loader/config.toml` (paketinki, `default_sched` yorumda) arıyor. Kurulum: Claude dosyayı kendi geçici klasörüne yazdı, sahibi `sudo install -Dm644` ile kopyaladı.
- **`scx_loader.service` açıldı** (`enable --now`; paket açmıyor).
- Değiştirmek: dosyada `scx_lavd`; geçici `scxctl switch -s lavd`, `scxctl stop`.
- Geri almak: `sudo systemctl disable --now scx_loader.service; sudo rm /etc/scx_loader.toml; sudo pacman -Rns scx-tools scx-scheds`.
- Kontrol: `cat /sys/kernel/sched_ext/state` → `enabled`, `cat /sys/kernel/sched_ext/root/ops` → `bpfland...`, `scxctl get`.
- İşlemci hibrit (P+E çekirdek); bpfland bunu hesaba katıyor. Oyunda davranışı sahibinin deneyimine göre değerlendirilecek (alternatif lavd).

### Yan disk (NTFS) (24 Kasım 2026)

Diskler: `nvme1n1` sistem (2 GB EFI `/boot/efi` + btrfs; alt birimler `@`, `@home`, `@log`, `@cache`, `@snapshots`, `@swap`; Windows artık yok), `nvme0n1` veri diski: tek NTFS bölümü `nvme0n1p1`, etiket "Side Disk", UUID `FE7E04597E040D59`. Çekirdekte iki NTFS sürücüsü var: `ntfs3` (Paragon, 5.15'ten beri) ve yeni `ntfs`; `ntfs-3g` de kurulu.

- **`/etc/fstab`'a satır** (sona eklendi):
  `UUID=FE7E04597E040D59  /mnt/sidedisk  ntfs3  uid=1000,gid=1000,umask=022,windows_names,noatime,nofail  0 0`
  - `ntfs3`: çekirdeğin olgun sürücüsü, ntfs-3g'den (FUSE) hızlı. Yeni `ntfs` sürücüsü çok yeni olduğu için seçilmedi.
  - `uid/gid=1000`, `umask=022`: dosyalar `bekir`'in, diğerleri okuyabilir. `windows_names`: Windows'un kabul etmediği adlarla dosya oluşturmayı engeller. `nofail`: disk yoksa ya da bağlanamazsa açılış durmaz.
  - Bağlama noktası `/mnt/sidedisk` (sahibinin alışkanlığı; kalıcı, elle tanımlı diskler için `/mnt` doğru yer, `/media` çıkarılabilir diskler için).
- Uygulama: `sudo systemctl daemon-reload; sudo mount -a` (systemd bağlama noktası klasörünü kendisi oluşturur).
- Bağlanmazsa: ntfs3 "kirli" işaretli (düzgün kapatılmamış) NTFS'i yazılabilir bağlamaz; `sudo ntfsfix -d /dev/nvme0n1p1`.
- Proton/Steam oyunları NTFS'te güvenilir çalışmaz (eski not); Linux oyunları btrfs'te.
- Snapshot'lanmıyor; ayrı yedek önerildi (eski not).
- Geri almak: `sudo umount /mnt/sidedisk`, fstab'dan satırı silmek, `sudo systemctl daemon-reload`, `sudo rmdir /mnt/sidedisk`.
- **`fstrim.timer` açıldı** (sahibi, `enable --now`; eski sistemde de açıktı). Ana disk btrfs `discard=async` ile zaten TRIM yapıyor; timer yan disk ve EFI için.

### Servisler (24 Kasım 2026)

Eski `core/services.txt` + `machines/nitro/services.txt` ile karşılaştırıldı. Açık olanlar: sddm, NetworkManager (+ `-wait-online`, `-dispatcher`), bluetooth, power-profiles-daemon, scx_loader, warp-svc, fstrim.timer.

- **`systemd-timesyncd` açıldı:** kapalıydı, saat hiç eşitlenmiyordu (`timedatectl`: "System clock synchronized: no").
- **`nvidia-powerd` açıldı:** Dynamic Boost (eski sistemde de açıktı; RTD3 ile ilgisi yok).
- **`nvidia-suspend`/`-resume`/`-hibernate` kapatıldı:** kurulumda (14:16) açılmışlardı. Sürücü `UseKernelSuspendNotifiers: 1` ile video belleğini uykuda kendisi koruyor (`/proc/driver/nvidia/params`); eski sistemde de bu yüzden kapalıydı. Uykudan sonra sorun çıkarsa ilk bakılacak yer; geri açmak `systemctl enable nvidia-suspend nvidia-resume nvidia-hibernate`. (Uykudan sonra parlaklık sorunu bundan bağımsız, eski sistemde bu servisler kapalıyken de vardı.)
- **Bekleyen (sahibi ayrıca karar verecek):** `systemd-resolved` (şifreli DNS için; zapret/mobil veri işiyle birlikte, `/etc/resolv.conf` bağlantısı gerekir), ufw, snapper zamanlayıcıları, keyd, libvirtd.socket, zapret, switcheroo-control (paketleri henüz kurulmadı).

### systemd-oomd (24 Kasım 2026)

RAM dolunca donma yerine baskıyı yapan uygulamayı kapatır. Arch'ta hiçbir birime izleme ayarı yok; eski sistemdeki gibi Fedora'nın `systemd-oomd-defaults`'ının aynısı (nedenler eski CLAUDE.md "systemd-oomd"). systemd 262.

- **`/etc/systemd/oomd.conf.d/10-oomd.conf`**: `DefaultMemoryPressureDurationSec=20s`.
- **`/etc/systemd/system/-.slice.d/10-oomd.conf`**: `ManagedOOMSwap=kill` (zram %90 dolunca en çok takas kullanan kapatılır).
- **`/etc/systemd/system/user@.service.d/10-oomd.conf`**: `ManagedOOMMemoryPressure=kill`, `ManagedOOMMemoryPressureLimit=50%`.
- **`/etc/systemd/user/-.slice.d/10-oomd.conf`**: aynı iki satır, **geçici çözüm** systemd#43174 (kullanıcı yöneticisi reload'da kök dilimini "auto" bildirip izlemeyi siliyor; 255–262'de var). Değerler `user@.service.d`'dekiyle aynı kalmalı. **Kalkar:** systemd düzeltince.
- **`systemd-oomd.service` açıldı** (`enable --now`).
- Kurulum: Claude dosyaları geçici klasörde `etc/systemd/...` ağacı olarak hazırladı, sahibi `sudo cp -rv` ile `/etc/systemd/`'ye kopyaladı; `daemon-reload` (sistem + `--user`).
- Bedeli: baskı uzun sürerse uygulamanın tamamı uyarısız kapanır (tarayıcının bütün sekmeleri, ağır derleme yapan terminal).
- Kontrol: `oomctl` → "Swap Monitored CGroups" altında `/`, "Memory Pressure Monitored CGroups" altında `/user.slice/user-1000.slice/user@1000.service` (limit 50%).
- Geri almak: `sudo systemctl disable --now systemd-oomd`; dört dosyayı silmek; `sudo systemctl daemon-reload; systemctl --user daemon-reload`.

### Açılış süresi (24 Kasım 2026, ölçüm)

`systemd-analyze`: firmware 14.3 sn + loader (GRUB) 14.5 sn + kernel 0.5 sn + initrd 1.4 sn + userspace 2.4 sn = 33 sn. Servis tarafında yavaşlatan yok (en uzun NetworkManager 0.7 sn; hata veren servis yok). Eski sistemdeki `networkd-wait-online` sorunu burada yok (networkd kapalı); `NetworkManager-wait-online` açık ama açılışta onu bekleyen bir şey yok (sadece haftalık `archlinux-keyring-wkd-sync`), süreye etkisi yok.

- Zamanın çoğu GRUB (menüde `GRUB_TIMEOUT=5` bekleme + dosya okuma) ve BIOS'ta.
- **`/etc/default/grub`'a `GRUB_EARLY_INITRD_LINUX_STOCK=''` eklendi** (dosyanın sonuna; Arch Wiki, Microcode): `/boot/intel-ucode.img` (16 MB) GRUB'a ayrıca initrd olarak ekleniyordu, oysa mkinitcpio'nun `microcode` hook'u mikrokodu zaten initramfs'e koyuyor (çift yükleme). Ardından `grub-mkconfig`. Geri almak: satırı silip `grub-mkconfig -o /boot/grub/grub.cfg`. `/boot/intel-ucode.img` dosyası `intel-ucode` paketinin, durur (silinmez).
- Menü süresi: önce `GRUB_TIMEOUT=5` kaldı (sahibinin kararı); 25 Kasım'da sahibi 3 sn istedi (`sed` + `grub-mkconfig` komutları verildi; aşağıda "GRUB yavaş çiziyordu").
- BIOS süresi (14 sn) Linux'tan düzeltilemez; Acer BIOS'unda "Fast Boot" varsa sahibi bakabilir.

### SSH anahtarları (24 Kasım 2026)

Eski sistemden yedek: `/mnt/sidedisk/onceki pc/ssh.tar.gz` (sahibinin; yerinde duruyor). Claude `~`'a izinleriyle açtı (`tar -xzpf`), `known_hosts.old` (eski yedek kopya) alınmadı.

- **`~/.ssh/`**: `id_ed25519` (600) + `.pub`, `config` (GitHub'a `ssh.github.com:443` üzerinden; 22 numaralı port engelli ağlar için), `known_hosts`.
- Doğrulandı: `ssh -T git@github.com` → "Hi ichbinbekir!".
- Gizli bilgi: dotfiles'a ve hiçbir depoya girmez.

### git kimliği (24 Kasım 2026)

- **`~/.gitconfig`**: `git config --global` ile `user.name = ichbinbekir`, `user.email = bekiirun@gmail.com` (dosya yoktu).
- **`dot_gitconfig`** (bu depoda): aynı içerik; chezmoi yönetiyor (aşağıda).

### Dotfiles: chezmoi (24 Kasım 2026)

Sahibi `~/Documents/nos/.git`'i kaldırdı; `~/Documents/nos/dotfiles/` artık kendi deposu (`git@github.com:ichbinbekir/dotfiles.git`, dal `master`; eski Hyprland ayarları `old/`'da, geçmiş korunuyor). Eski düzende kaynak nos deposuydu ve kökteki `.chezmoiroot` (`dotfiles`) chezmoi'yi bu klasöre yönlendiriyordu; artık depo kökü doğrudan chezmoi kaynağı, `.chezmoiroot` gerekmiyor.

- **chezmoi kaynağı `~/.local/share/chezmoi`** (chezmoi'nin varsayılanı; GitHub'dan `chezmoi init` ile klonlandı). `~/Documents/nos/dotfiles` ayrı bir çalışma kopyası (sahibi `nos` klasörünü ileride taşıyabilir; chezmoi buna bağlı olmasın diye, sahibinin kararı). İlk denemede `~/.config/chezmoi/chezmoi.toml` `sourceDir` ile bu klasör kaynak yapılmıştı, sahibi istemedi, silindi. İki kopya GitHub üzerinden eşitlenir: Documents'ta commit + push → `chezmoi update` (çek + uygula); ya da `chezmoi cd` ile chezmoi'nin kopyasında çalışılır.
- **`.chezmoiignore`**: `README.md`, `CLAUDE.md`, `old` ev klasörüne yazılmıyor (önceden sadece README vardı; `old/` ve `CLAUDE.md` `~`'a kopyalanacaktı).
- **README.md** yeni depoya göre yeniden yazıldı (eski metin nos kurulum programından ve `.chezmoiroot`'tan bahsediyordu).
- `chezmoi apply --force` (önce `chezmoi diff` incelendi): yeni `~/.config/espanso/`, `~/.config/keyd/app.conf`, `~/.config/fish/functions/fish_prompt.fish`, `~/.config/systemd/user/default.target.wants/espanso.service` (bağlantı); `~/.config/fish/config.fish` (fish'in varsayılanıydı) dotfiles'taki ile değişti; `~/.config/fish` ve `functions` klasörleri 700 → 755; `~/.gitconfig` aynıydı. `chezmoi verify` temiz.
- espanso bağlantısı espanso kurulana kadar boşa gösteriyordu; 25 Kasım'da kuruldu (aşağıda "espanso"). keyd: aşağıda.
- `~/Documents/nos/` içinde sahibinin bıraktığı `dotfiles-old/` (taşımadan önceki kopya) ve kökte `.chezmoiroot` artık kullanılmıyor; silinip silinmeyeceği sahibinin kararı.
- Kullanım: Documents'taki depoda düzenle → commit + push → `chezmoi update`. Ev klasöründe değiştirilen dosyayı depoya almak `chezmoi re-add <dosya>` (chezmoi'nin kopyasına yazar; oradan `chezmoi git -- commit/push`, sonra Documents'ta `git pull`).

### keyd: tuş eşleme (24 Kasım 2026)

Sahibi `keyd` paketini kurmuştu (2.6.0); servis kapalı, `/etc/keyd/` boş, kullanıcı `keyd` grubunda değildi, `python-dbus` yoktu. Eski sistemdeki gibi (eski CLAUDE.md "Tuş eşleme (keyd)"): Sober'da ESDF, `.` ile aç/kapat, her yerde Caps Lock = F19.

- **`python-dbus`** kuruldu: `keyd-application-mapper` KDE 6'da kwin betiği + D-Bus ile odaktaki pencereyi öğreniyor (`python-gobject` zaten vardı).
- **`/etc/keyd/default.conf`**: eski `core/system_files/etc/keyd/default.conf` ile aynı (`[ids] *`, boş `[main]`, boş `[nomap]`). Bütün klavyeleri yakalar, hiçbir tuşu değiştirmez; bu olmadan uygulama eşlemeleri çalışmaz. Kurulum: geçici klasörden `sudo install -Dm644`.
- **`keyd.service` açıldı** (`enable --now`).
- **Kullanıcı `keyd` grubuna eklendi** (`usermod -aG keyd bekir`; mapper'ın keyd soketine erişimi). Grup ancak **yeniden başlatınca** geçerli (eski sistemde oturumu kapatıp açmak yetmedi).
- **`dot_config/autostart/keyd-application-mapper.desktop`** (dotfiles): girişte `keyd-application-mapper`'ı başlatır. Eski sistemde `/etc/xdg/autostart` + `/usr/libexec` sarmalayıcısıydı (herkes için, `app.conf` yoksa çıkıyordu); artık kullanıcıya özel, `app.conf` de dotfiles'ta olduğu için sarmalayıcı gerekmiyor. `~/.config/autostart/`'a elle de kopyalandı (push + `chezmoi update` öncesi; içerik aynı).
- Eşlemeler: `dot_config/keyd/app.conf` (`[*sober*]`, `[*]` `capslock = f19`). Bölüm adları KDE'nin `resourceClass`'ının küçük harf + `-` hali; keyd tuş adları ABD yerleşimine göre (Türkçe Q'da `.` = `slash`).
- Kontrol: `systemctl is-active keyd`, `id` içinde `keyd`, yeniden başlattıktan sonra `pgrep -af keyd-application-mapper`; Caps Lock büyük harf açmamalı.
- Geri almak: `sudo systemctl disable --now keyd; sudo rm /etc/keyd/default.conf; sudo gpasswd -d bekir keyd`; autostart dosyasını depodan ve `~/.config/autostart`'tan silmek.

### root hesabı kilitli (25 Kasım 2026)

Sahibi root'a doğrudan girilmesin, sadece `sudo` ile geçilsin istedi (eski sistemde de root kilitliydi).

- **`sudo passwd -l root`**: `/etc/shadow`'da root'un şifresinin başına `!` konur; şifreyle giriş (tty, SDDM, `su`) olmaz. `sudo -i` / `sudo su` kullanıcının kendi şifresiyle çalışır (`wheel`).
- **`passwd -d` (şifreyi silmek) kullanılmaz:** Arch'ın `/etc/pam.d/system-auth`'unda `pam_unix.so ... nullok` var; şifresi boş root'a şifresiz girilirdi.
- Bedeli: sistem açılmayıp acil kurtarma kabuğuna (emergency/rescue) düşerse root kilitli olduğu için kabuk açılmaz. O durumda kurtarma: GRUB'da `e` ile çekirdek satırına `init=/bin/bash`, ya da kurulum USB'si + `arch-chroot`. (İstenirse `SYSTEMD_SULOGIN_FORCE=1` ile kurtarma kabuğu şifresiz açılabilir; sahibine sorulmadı, eklenmedi.)
- Geri almak: `sudo passwd -u root` (eski şifre geri gelir) ya da `sudo passwd root` ile yeni şifre.
- Kontrol: `sudo passwd -S root` → ikinci alan `L`.

### Podman (25 Kasım 2026)

Docker yerine Podman (Claude'un önerisi, sahibi kabul etti; gerekirse Docker'a geçilebilir): arka plan servisi yok, kapsayıcılar kullanıcıyla (rootless) çalışır, `docker` grubu = root yetkisi sorunu yok, eski sistemde de vardı.

- **Paketler:** `podman` + `crun` (OCI çalışma ortamı; açıkça yazıldı ki pacman `crun`/`runc` arasında sormasın). Bağımlılıklar kendiliğinden (conmon, containers-common, passt, netavark, catatonit).
- `/etc/subuid` ve `/etc/subgid`'de `bekir:100000:65536` kurulumdan beri var; rootless için ek ayar gerekmedi.
- İmajlar ve kapsayıcılar `~/.local/share/containers/` (btrfs `@home`). Ev klasörüne snapper kurulursa bunlar da snapshot'a girer; o zaman ayrı alt birim düşünülmeli.
- Kısa imaj adları (`alpine`) registry sorabilir; tam ad (`docker.io/library/alpine`) kullanılır.
- Docker'a geçiş: `sudo pacman -Rns podman` + `docker`; imajlar yeniden indirilir, kapsayıcı/volume'ler taşınmaz. Docker'a bağlı bir araç sorun çıkarırsa önce `podman-docker` (+ `podman.socket` kullanıcı servisi) denenir.
- Compose: henüz kurulmadı (gerekince `docker-compose` + `podman.socket`, ya da `podman-compose`).

### Paket önbelleği temizliği (25 Kasım 2026)

`/var/cache/pacman/pkg` (btrfs `@cache`) 2.4 GB / 2000 dosyaydı; pacman eski sürümleri hiç silmiyor.

- **`pacman-contrib`** kuruldu (`paccache`).
- **`/etc/pacman.d/hooks/paccache.hook`**: her pacman işleminden sonra `paccache -rk2` (kurulu her paketin son iki sürümü: şimdiki + geri dönmek için bir önceki) ve `paccache -ruk0` (kaldırılmış paketlerin hepsi). Arch Wiki'deki hook; `paccache.timer` (haftalık) yerine sahibinin isteğiyle hook. Kurulum: geçici klasörden `sudo install -Dm644`; ilk temizlik elle `sudo paccache -rk2; sudo paccache -ruk0`.
- Bir paketi iki sürümden eskiye düşürmek gerekirse önbellekte olmaz; Arch Archive (`archive.archlinux.org`) kullanılır.
- yay'ın derleme klasörleri (`~/.cache/yay`, 1.1 GB: cloudflare-warp-bin, helium-browser-bin, visual-studio-code-bin) bunun kapsamında değil; yay bunları kendisi silmiyor. Temizlik: `yay -Sc` (kaldırılmış AUR paketleri + pacman önbelleği sorar) ya da klasörü silmek (sonraki güncellemede yeniden indirilir).
- Geri almak: `sudo rm /etc/pacman.d/hooks/paccache.hook`.

### Sanal makineler: libvirt (25 Kasım 2026)

Sahibi kurdu: `libvirt` 12.9, `qemu-desktop`, `virt-manager` (Arch paketi, Flatpak değil), `dnsmasq`, `edk2-ovmf`, `swtpm`. Kullanıcı `libvirt` grubunda (paketin sysusers'ından grup; sahibi eklemiş). Hiçbir libvirt birimi açık değildi, virt-manager bağlanamıyordu.

- **`libvirtd.socket` açıldı** (`enable --now`; `Also=` ile `libvirtd-ro.socket`, `libvirtd-admin.socket` de). Eski sistemdeki gibi tek parça (monolithic) daemon, soketle: açılışta sadece soket dinler (süreç yok), virt-manager bağlanınca `libvirtd` başlar, boşta 120 sn sonra kapanır (`libvirtd.service`'te `LIBVIRTD_ARGS="--timeout 120"`). **`libvirtd.service` açılmaz** (açılırsa açılışta başlar ve sürekli çalışır; eski sistemde sahibi elle açmıştı, "gereksiz açılış" buydu). `virtlogd`/`virtlockd` libvirtd başlarken gerekirse kendiliğinden gelir.
- Modüler daemon'lar (`virtqemud` vb.) kullanılmıyor; ikisi birlikte açılmamalı.
- **`default` NAT ağı autostart** (`sudo virsh net-autostart default`; `/etc/libvirt/qemu/networks/autostart/default.xml` bağlantısı): libvirtd her başladığında ağ (virbr0 + dnsmasq) kalkar; açılışta değil. libvirtd kapandıktan sonra ağ (dnsmasq) açık kalır, zararsız.
- Güvenlik duvarı: ufw 25 Kasım'da kuruldu, eski sistemdeki üç `virbr0` kuralı eklendi (aşağıda "Güvenlik duvarı: ufw").
- Kontrol: `systemctl is-active libvirtd.socket` → active; virt-manager açılınca `systemctl is-active libvirtd` → active, kapatınca ~2 dk sonra inactive; `virsh -c qemu:///system net-list --all` → default active, autostart yes.
- Geri almak: `sudo systemctl disable --now libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket`; `sudo virsh net-autostart --disable default`.

### espanso (25 Kasım 2026)

Sahibi `yay -S espanso-wayland` ile kurdu (AUR pkgbase `espanso` 2.4.1-2, kaynaktan Rust derlemesi; tarif X11 ve Wayland'i birlikte derliyor, yay sadece Wayland'i kuruyor). `-bin` sürümü bilerek seçilmedi (eski sistemde Debian paketi Arch'ın wxwidgets'ıyla çöküyordu). Derleme için `cargo` sağlayıcısı olarak pacman `rust` (1.100) kuruldu ve sahibinin isteğiyle kalıyor (makedeps kaldırılmadı: `rust`, `xdotool`, `xclip`, `libxtst` vb.).
- Paketin `.install`'ı `cap_dac_override=p` veriyor (`getcap /usr/bin/espanso`; Wayland'de `/dev/input` okumak için). Servis paketin `/usr/lib/systemd/user/espanso.service`'i; dotfiles'taki `symlink_espanso.service` ile açık (`systemctl --user is-enabled espanso` → enabled). Ayarlar dotfiles'tan (`keyboard_layout: tr`, `:date`, `:time`, `:mail`).
- Doğrulandı: `espanso status` → running, servis active; sahibi çalıştığını söyledi.
- Kalanlar: `~/.cargo` 247 MB (Rust kütüphane önbelleği), `~/.cache/yay/espanso` 82 MB (yay derleme klasörü; güncellemede yeniden kullanılır).
- Tamamen silmek: `yay -Rns espanso-wayland` (+ istenirse `rust` ve derleme bağımlılıkları), `rm -rf ~/.cargo ~/.cache/yay/espanso ~/.config/espanso`; dotfiles'taki espanso dosyaları ve servis bağlantısı.

### Krohnkite (döşeme KWin betiği; 25 Kasım 2026)

Sahibi kurdu: `~/.local/share/kwin/scripts/krohnkite` (Plasma 6 sürümü). Ayarlar `~/.config/kwinrc` `[Script-krohnkite]`'te (KDE ayarı; dotfiles'a henüz girmiyor, sahibi KDE ayarları için karar vermedi).
- `focusMoveVDesktopsNormal=false`: odak tuşları (Meta+yön) kenarda başka masaüstüne geçmesin (sahibi Sistem Ayarları'ndan kapattı; "Normal" bölümündeki 2. kutu).
- `noTileBorder=true`: döşenen pencerelerin kenarlığı/başlığı yok (Options sekmesi).
- **Emülatör istisnası denendi, geri alındı (sahibi vazgeçti):** Android emülatörü döşenip esnetiliyor. `ignoreClass=qemu-system-x86_64` yazılınca normal yüzen pencere gibi açılıyordu; sahibi istemedi, anahtar silindi (`kwriteconfig6 ... --key ignoreClass --delete`). Bilgi: bu sürümde `floatingClass` yok, `ignoreClass` Krohnkite'ın yönetmemesini sağlıyor; `resourceClass` ve `resourceName`'e bakıyor; emülatörün iki penceresi `class=Emulator name=qemu-system-x86_64`. Ayar değişince okunsun diye `[Plugins] krohnkiteEnabled` false/true + `org.kde.KWin.reconfigure`.

### Flutter + Android (25 Kasım 2026, sürüyor)

Sahibinin kararı: her araç **kendi varsayılan yerine** kursun (taşıma/yönlendirme yok); yeter ki nereye kurulduğu burada yazılı olsun ve gerekince hepsi iz bırakmadan silinebilsin. AUR'dan hiçbir şey yok: AUR `android-sdk*` paketleri root'a ait `/opt/android-sdk`'ya kuruyor, Gradle/Flutter eksik parçayı (NDK, build-tools sürümü) oraya yazamıyor, pacman'in ve Gradle'ın dosyaları karışıyor. Resmi depodaki `android-tools` (adb) da kurulmaz: SDK'nın adb'siyle sürüm çakışması. pacman'deki `gradle` gereksiz: Flutter her projenin `gradlew` başlatıcısını kullanıyor, o da projede yazan Gradle sürümünü kendisi indiriyor. Hedef sadece Android (emülatör şart, belki USB hata ayıklamayla telefon); web ve Linux masaüstü yok. Adım adım; sahibi demeden sonraki adıma geçilmez.

- **Java:** `jdk17-openjdk` (pacman; sahibi kurmuş, `archlinux-java` varsayılanı). Gradle 9 en az 17 istiyor.
- **FVM:** `extra/fvm` 4.3.2 (pacman). Varsayılan yer `~/fvm` (`versions/3.50.1`, `default` → ona, `cache.git` 504 MB: Flutter deposunun aynası). Sahibi önce `fvm config --cache-path ~/.local/share/fvm` yapmıştı; sonra varsayılana dönmek istedi: klasör `~/fvm`'e taşındı, `default` bağlantısı yeniden yapıldı (mutlak yol), `~/.config/fvm/.fvmrc` (sadece `cachePath` vardı) silindi. Sürümler bağımsız git kopyası (`objects/info/alternates` yok), taşıma sorunsuz; `flutter --version` çalıştı.
- **Android SDK:** `~/Android/Sdk` (Android Studio'nun ve Flutter'ın varsayılanı: Flutter `ANDROID_HOME` yoksa Linux'ta burayı arıyor, `android_sdk.dart`). Şu an içinde sadece cmdline-tools 23.0: `~/Android/Sdk/cmdline-tools/latest/` (Google'ın zip'i `commandlinetools-linux-16111833_latest.zip`, SHA-1 `repository2-3.xml`'deki değerle doğrulandı; önce `~/.local/share/android`'e açılmıştı, taşındı). 23.0'da `sdkmanager` "deprecated" uyarısı veriyor, yerini aynı klasördeki `android` aracı (`android sdk ...`) alıyor; Flutter `sdkmanager`'ı kullanabildiği için ikisi de duruyor.
- **Flutter 3.50.1'in istedikleri** (`flutter_tools` kaynağından): compileSdk/targetSdk 36, minSdk 24, NDK `28.2.13676358`; yeni proje şablonu Gradle 9.5.0, Android Gradle eklentisi 9.3.1, Kotlin 2.4.20; şablonun `gradle.properties`'i Gradle'a `-Xmx8G` veriyor (16 GB RAM'de büyük; ileride `~/.gradle/gradle.properties` ile düşürülebilir, sahibine anlatıldı). Gradle daemon 3 saat boşta kalınca kapanıyor (`./gradlew --stop`).
- **`~/.android` (341 MB, 25 Kasım 17:44):** cmdline-tools 23.0'daki `sdkmanager --version` (ilk çalıştırma) açtı: yeni "Android CLI" kendini `~/.android/bin/android-cli`'ye (79 MB) kopyalıyor ve `~/.android/cli/bundles/`'a açıyor, `cli/analytics/` + `analytics.settings` (`hasOptedIn: false`) yazıyor. `ANDROID_USER_HOME` verilmediği için varsayılan yer; sahibi varsayılanlara razı. Silme listesinde zaten var.
- **SDK parçaları (sahibi kurdu, 25 Kasım):** `platform-tools` 37.0.3, `emulator` 37.3.10, `platforms;android-36`, `build-tools;36.0.0`, `system-images;android-36;google_apis_playstore;x86_64` (Play Store'lu, root yok); lisanslar kabul edildi (`~/Android/Sdk/licenses`). `~/Android/Sdk` 3.6 GB. NDK ve CMake'i Gradle gerekince kendisi indiriyor. `sdkmanager --list_installed` elle açılan cmdline-tools'u `cmdline-tools/latest unknown -> 23.0.0` gösteriyor (zip'te `package.xml` yok); sahibi böyle kalmasını istedi. Düzeltmek istenirse `sdkmanager "cmdline-tools;latest"` (yanına `latest-2` açarsa elle taşınmalı). `emulator -accel-check`: KVM kullanılabilir (`/dev/kvm` 0666).
- **Flutter hedefleri:** sahibi web ve Linux masaüstünü kapattı (`~/.config/flutter/settings`: `enable-web: false`, `enable-linux-desktop: false`); `flutter doctor` Android'de temiz.
- **Emülatör (AVD) `pixel_8`:** `avdmanager create avd -n pixel_8 -d pixel_8 -k "system-images;android-36;google_apis_playstore;x86_64"` → `~/.android/avd/pixel_8.avd` + `pixel_8.ini` (1.1 GB ilk açılıştan sonra; veri bölümü en fazla 10 GB, RAM 2 GB, 1080×2400). `config.ini`'de iki değişiklik: `hw.keyboard=yes` (komutla oluşturulanda `no` geliyor, bilgisayar klavyesiyle yazılamıyor) ve `hw.gpu.enabled=yes` (`no` geliyordu: yazılımla çizim; `hw.gpu.mode=auto` kaldı). Denendi: ~20 sn'de açıldı, Android 16, `flutter devices`'ta görünüyor, GLES "Mesa Intel (RPL-P)" (NVIDIA'ya gitmiyor). Kapatınca durumu kaydediyor (hızlı açılış, ~RAM kadar yer). Açmak: VS Code cihaz seçicisi, `flutter emulators --launch pixel_8` ya da `emulator -avd pixel_8`.
- **Ortam değişkenleri (dotfiles `dot_config/plasma-workspace/env/flutter.sh`, `~/.config/plasma-workspace/env/`'ye elle de kopyalandı):** `ANDROID_HOME=$HOME/Android/Sdk` + `PATH`'in başına `~/fvm/default/bin`, SDK'nın `platform-tools`, `emulator`, `cmdline-tools/latest/bin` klasörleri (`case` ile iki kez eklenmiyor). Önce `~/.config/environment.d/flutter.conf`'taydı: `ANDROID_HOME` geldi ama `PATH` gelmedi (yeniden başlatmadan sonra da). Sebep: SDDM'nin `/usr/share/sddm/scripts/wayland-session`'ı fish kullanıcısında `/etc/profile` + `~/.profile` + `fish --login`'den `PATH`'i yeniden kuruyor, `startplasma-wayland` de (`KUpdateLaunchEnvironmentJob`) bütün ortamı systemd'ye geri yazıp environment.d'nin `PATH`'ini eziyor. **Bu yüzden `PATH` için environment.d kullanılmamalı.** Plasma `plasma-workspace/env/*.sh`'leri (`/usr/lib/plasma-sourceenv.sh` ile, `sh`) systemd'ye göndermeden önce okuyor; KDE oturumundaki her program (Konsole/fish, VS Code) alıyor. Plasma'nın yaptığı gibi elle denendi (`flutter --version` çalıştı); sahibinin yeniden girişi bekleniyor. Değişince oturumu kapatıp açmak gerekiyor; tty girişinde ve başka masaüstünde geçerli değil (o zaman `~/.profile`: SDDM fish kullanıcısı için de okuyor). Bilerek eklenmeyenler: `ANDROID_SDK_ROOT` (eskimiş; `ANDROID_HOME`'la farklı olursa araçlar hata veriyor), `JAVA_HOME` (Flutter/Gradle `PATH`'teki `java`'yı, yani `archlinux-java` varsayılanını buluyor), `ANDROID_USER_HOME`/`GRADLE_USER_HOME`/`PUB_CACHE` (sahibi varsayılan yerleri istedi). Global karşılık sahibine anlatıldı, istemedi.
- **İstatistik (telemetri) kapalı:** sahibi 25 Kasım 19:03'te `flutter/dart --disable-analytics` yaptı: `~/.dart-tool/dart-flutter-telemetry.config` `reporting=0`, `CLIENT_ID` ve gönderim kayıtları boşaltıldı. Dart ve Flutter'ın ortak dosyası; yeni Flutter sürümü bunu değiştirmez. `~/.dart-tool` silinirse ilk çalıştırmada yeniden açık başlar, silinmemeli. Eski `~/.flutter`/`~/.dart` yok. VS Code Dart eklentisi `telemetry.telemetryLevel`'a uyuyor (bakılmadı).
- **Henüz yapılmayanlar:** telefon için USB/udev.
- **Tamamen silmek için (hiç kurulmamış gibi):** `sudo pacman -Rns fvm jdk17-openjdk` ve `rm -rf ~/fvm ~/Android ~/.android ~/.gradle ~/.pub-cache ~/.dart-tool ~/.config/flutter`; varsa `~/.dartServer`, `~/.flutter-devtools`, `~/.kotlin` (VS Code Dart eklentisi, DevTools, Kotlin daemon) ve `~/.config/plasma-workspace/env/flutter.sh` (dotfiles'tan da: `dot_config/plasma-workspace/`). Yeni bir yer görülürse bu listeye eklenmeli.

### Uykudan sonra kararan ekran (25 Kasım 2026, sahibi şimdilik bıraktı)

Eski CLAUDE.md'deki sorun düz Arch'ta da var. Ekran Intel'de (i915, `eDP-1`) ama parlaklık EC üzerinden `nvidia_wmi_ec_backlight` (`type=firmware`, max 254); i915 "Skipping intel_backlight registration". Derin uykudan (`/sys/power/mem_sleep` `s2idle [deep]`, `PM: suspend entry (deep)`) sonra ekran karanlık kalıyor, yeniden başlatınca düzeliyor. Uykusuz açılışta da `brightness=77`, `actual_brightness=110` (ayrışık).
- Bilinen sorun: NVIDIA'nın Daniel Dadap'ı yazmış, bazı yazılımlar uykudan dönüşte EC parlaklığını sıfırlıyor, çekirdek eski değeri tutuyor; `restore_level_on_resume` yaması (lore 20220316012516.2233984-1-ddadap@nvidia.com) çekirdeğe girmemiş (7.3.5'te `modinfo -p nvidia_wmi_ec_backlight` sadece `force`). Acer Predator PH317-56'da aynı (NVIDIA forum 294917, 337768).
- **Denendi, işe yaramadı: `acpi_backlight=native`** (tek açılış, GRUB `e`): `intel_backlight` (max 19200) ve `nvidia_0` geliyor ama parlaklık çubuğu ekranı değiştirmiyor. Kalıcı yapılmadı.
- **Sıradaki deneme (önerildi, sahibi şimdilik denemedi):** tek açılışlık `echo s2idle | sudo tee /sys/power/mem_sleep` ile uyutup uyandırmak (derin uykudaki yazılım adımı çalışmaz). İşe yararsa pil tüketimi ölçülüp kalıcı olarak `mem_sleep_default=s2idle` (GRUB) düşünülür.

### GRUB yavaş çiziyordu (25 Kasım 2026)

`GRUB_GFXMODE=auto` 2560×1600'ü seçiyor, UEFI GOP çizimi çok yavaş (menü "donuyor"). Önerilen: `/etc/default/grub`'da `GRUB_GFXMODE=1280x800,auto` (aynı oran; desteklenmezse `auto`'ya düşer) + `sudo grub-mkconfig -o /boot/grub/grub.cfg`. `GRUB_GFXPAYLOAD_LINUX=keep` kalıyor; i915 yüklenince ekran tam çözünürlüğe geçiyor. Sahibi `/etc/default/grub`'u değiştirdi (doğrulandı). Aynı anda `GRUB_TIMEOUT=5` → `3` (sahibinin isteği). İkisi için `grub-mkconfig` çalıştırılmalı; sonuç bekleniyor. Geri almak: değerleri `auto`/`5` yapıp `grub-mkconfig`.

### GameMode ayarı (25 Kasım 2026)

**`/etc/gamemode.ini`** (eski sistemin `core/system_files/etc/gamemode.ini`'sinin aynısı; Claude geçici klasöre yazdı, sahibi `sudo install -Dm644` ile kopyaladı): `[general]` `desiredgov`/`defaultgov`/`igpu_desiredgov` = `powersave`. Sebep (eski CLAUDE.md "GameMode + power-profiles-daemon çakışması"): GameMode varsayılanda yöneticiyi `performance` yapıyor, intel_pstate'te EPP kilitleniyor, oyun açıkken KDE'den güç modu değişmiyordu. GameMode'un diğer işleri sürüyor. Dosya paketin değil (`gamemode` 1.8.2 `/etc`'ye ini koymuyor). Geri almak: `sudo rm /etc/gamemode.ini`.

### Güvenlik duvarı: ufw (25 Kasım 2026)

Sahibi `ufw` 0.36.2'yi kurdu; komutları sahibi çalıştırdı: `ufw default deny incoming`, `default allow outgoing`, `allow in on virbr0` (libvirt DHCP/DNS), `route allow in on virbr0` + `route allow out on virbr0` (sanal makinelerin interneti; `DEFAULT_FORWARD_POLICY="DROP"` yüzünden), `ufw enable` (`/etc/ufw/ufw.conf` `ENABLED=yes`), `systemctl enable ufw`. `ufw status verbose` doğrulandı (IPv4 + IPv6). KDE Connect kurulu değil, portları (1714–1764 TCP/UDP) açılmadı; kurulursa `ufw allow 1714:1764/tcp` ve `/udp` gerekir. Yerel bağlantılar (loopback: Ollama, adb, emülatör, Flutter) etkilenmiyor. `plasma-firewall` kurulmadı (sahibi terminal tercih ediyor). Not: `ufw.service` `--now` olmadan açıldığı için o oturumda `inactive` görünüyordu; duvar `ufw enable` ile zaten etkindi. Geri almak: `sudo ufw disable` + `sudo systemctl disable ufw`.

### dosfstools (25 Kasım 2026)

Sahibi kurdu. `/boot/efi` (vfat) fstab'da `passno 2` ama `fsck.vfat` olmadığı için açılış kontrolü sessizce atlanıyordu (systemd-fstab-generator fsck birimi oluşturmuyor). Ayrıca `mkfs.fat` (USB biçimlendirme, KDE bölüm yöneticisi).

### Ayna listesi: reflector (25 Kasım 2026)

Kurulumdan gelen `/etc/pacman.d/mirrorlist` (Haziran 2026, bütün aynalar ülke alfabetik) Türk aynalarıyla başlıyordu; sahibinin bazı ağlarında (sık ağ değiştiriyor: mobil veri, farklı Wi-Fi'ler) `tr.arch.niranjan.co` ve `mirror.timtal.com.tr` "Connection timed out after 10001 milliseconds" veriyordu. Sahibi `reflector` (2023-5) kurdu.
- **`/etc/xdg/reflector/reflector.conf`** (paketin düzenlenmek için koyduğu, `backup=` dosyası; Claude yazdı, sahibi `sudo install -m644` ile kopyaladı): `--save /etc/pacman.d/mirrorlist --protocol https --country Germany,Netherlands --age 12 --completion-percent 100 --sort score --number 10`. **`--sort rate` bilerek kullanılmadı:** hızı o anki ağda ölçüyor, ağ değişince yanlış olur; `score` Arch'ın aynı durum sunucusunun ağdan bağımsız puanı. Türkiye listede yok (takılıyordu).
- `reflector.service` bir kez çalıştırıldı, `reflector.timer` açık (haftalık). Sonuç: Frankfurt/Berlin `mirror.pkgbuild.com` + 8 Alman ayna. Elle yenilemek: `sudo systemctl start reflector.service`.
- Geri almak: `sudo systemctl disable reflector.timer`, `sudo pacman -Rns reflector` (mirrorlist kalır; başka liste için `pacman-mirrorlist` paketinin `.pacnew`'i ya da elle).

## Sonraki adım adayları

Sahibiyle adım adım konuşulacak, sorulmadan yapılmaz.

- Eski listelerde olup yeni sistemde olmayanlar (25 Kasım kontrolü; kurulu olanlar: `plasma-pa`, `kscreen`, `kde-gtk-config`, `breeze-gtk`, `btrfs-assistant`, `cloudflare-warp-bin`, `espanso-wayland`, `gamemode`, `keyd`, `nvidia-prime`, `ufw`, `dosfstools`):
  - **Sahibi şimdilik bekletiyor:** `zapret-git` (+ eski sistemdeki `/etc/zapret` ayarları ve engelli ağ notları) ve **snapper** (`btrfs-assistant` kurulu ama snapper yok, hiç görüntü alınmıyor; öneri: kök için snapper + `snap-pac` + GRUB'dan görüntüye açılış `grub-btrfs`; fstab'da `@snapshots` → `/.snapshots` alt birimi zaten var).
  - **Sahibi istemedi:** `switcheroo-control` (hiç kullanmamış; `prime-run` var), `plasma-firewall`.
  - **Şimdilik yok:** `kdeconnect` (kurulursa ufw portları). Sorulmadı ya da kararsız: `plasma-disks` (SMART uyarısı; önerildi), `discover` + `flatpak-kcm` (Flatpak kurulu), `plasma-systemmonitor`, `kinfocenter` (sahibi terminal tercih ediyor).
  - **Düz Arch'ta gerekmeyen:** `distrobox` (bootc yüzünden gerekiyordu), `systemd-resolved` (NetworkManager yetiyor; zapret notlarındaki DoT istenirse gerekir). Bootc/kurulum işi ya da başka donanım: `amd-ucode`, `dracut`, `skopeo`, `gum`, `xfsprogs`, `dbus-glib`.
- Eski CLAUDE.md'deki "Düz Arch'a taşınacaklar" listesi: paketler, AUR, servisler, ayar dosyaları, ufw, zram, snapper, keyd, espanso vb.
