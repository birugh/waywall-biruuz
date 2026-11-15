# waywall-biruuz

Fork dari [waywall_generic_config](https://github.com/arjuncgore/waywall_generic_config) yang diubah untuk kebutuhan speedrunning pribadi.

> Panduan setup dan konfigurasi lengkap ada di `README-CONFIG.md` (README asli). Di bawah ini cuma perubahan yang dilakukan di sini.

## Perubahan untuk speedrunning

1. Saat remaps dimatikan, thin, wide, dan tall tetap bisa dipakai. Biasanya kalau remaps dimatikan (misalnya pas lagi chat), macro resolusi ikut mati. Di sini nggak. Thin/wide/tall tetap jalan kapan pun, jadi nggak perlu toggle-togglan lagi pas F3 search atau measuring.

2. E-counter dan persen mirror diatur terpisah untuk mode thin dan tall. Posisi e-counter bisa di-set masing-masing buat kondisi thin dan tall. Angka persen juga bisa tampil bersih tanpa background, jadi lebih gampang dibaca pas ngukur.

3. Remap keyboard lengkap untuk crafting cepat. Semua craft penting sudah di-remap biar nggak perlu buka crafting table manual. Tombol toggle remaps dipindah ke `Shift-T`.

4. Ninjabrain Bot sudah disetting. Config Ninjabrain Bot (buat hitung eye) tinggal pakai, nggak perlu set manual lagi.

5. Kalkulator sensitivitas di-bundle. Kalkulator sens mcsr (buat ngitung sens boat eye) ikut dibawa sebagai submodule, jadi tinggal clone langsung kebawa.

## Instalasi

```bash
git clone --recurse-submodules git@github.com:birugh/waywall-biruuz.git ~/.config/waywall
# atau kalau sudah clone biasa:
git submodule update --init --recursive
```
