# Implementation Plan: Pemindahan File Artifact ke Folder Backend

Dokumen ini merinci rencana teknis untuk menyalin/memindahkan seluruh file artifact markdown (`.md`) yang telah dibuat dari direktori *brain artifact* ke dalam repositori kode [`backend/`](file:///C:/Users/acer/Documents/hackaton/git-hero-backend/backend). Sesuai instruksi, dokumen ini **hanya berupa rencana (draft plan) dan belum dieksekusi**.

---

## 1. Goal Description

Menyimpan dokumen analisis, arsitektur AI, dan rencana integrasi LiteLLM langsung ke dalam struktur folder project `backend/` agar dapat diakses oleh seluruh anggota tim melalui version control (Git), dibaca langsung di repositori, atau didokumentasikan bersama file PRD dan spesifikasi yang sudah ada.

### Daftar File Artifact Sumber:
1. [`analisis_dan_mitigasi_ai_litellm.md`](file:///C:/Users/acer/.gemini/antigravity-cli/brain/09309319-a3d8-4743-a555-39141abbab2f/analisis_dan_mitigasi_ai_litellm.md) (Analisis peran AI, kalkulasi deterministik vs generatif, risiko kegagalan, dan solusi LiteLLM).
2. [`implementation_plan_litellm_integration.md`](file:///C:/Users/acer/.gemini/antigravity-cli/brain/09309319-a3d8-4743-a555-39141abbab2f/implementation_plan_litellm_integration.md) (Spesifikasi teknis integrasi LiteLLM Router, multi-model Gemini, daftar free-tier provider, dan skema kode).

---

## 2. User Review Required

> [!IMPORTANT]
> **Metode Pemindahan: `Copy` (Salin) vs `Move` (Pindah Bersih):**
> - **Opsi Direkomendasikan: Copy (Salin)**: File disalin ke folder `backend/`, sementara file asli tetap tersimpan di direktori artifact. Ini memastikan UI viewer Antigravity tetap dapat menampilkan tab artifact tanpa terjadi broken link di chat session.
> - **Opsi Alternatif: Move (Pindah Bersih)**: File dipindahkan secara permanen dan dihapus dari direktori artifact Antigravity.

> [!NOTE]
> **Struktur Lokasi Target di Folder Backend:**
> - **Opsi A (Root Folder Backend):** Sejajar dengan [`backend/PRD GERDHero.md`](file:///C:/Users/acer/Documents/hackaton/git-hero-backend/backend/PRD%20GERDHero.md) dan [`backend/Pemetaan Fitur_ MVP dan Fitur Lengkap.md`](file:///C:/Users/acer/Documents/hackaton/git-hero-backend/backend/Pemetaan%20Fitur_%20MVP%20dan%20Fitur%20Lengkap.md).
> - **Opsi B (Subfolder Dokumentasi Khusus):** Dimasukkan ke dalam folder baru `backend/docs/ai/` untuk menjaga kerapihan root folder backend.

---

## 3. Proposed Changes

Berikut adalah target file yang akan dibuat di dalam workspace setelah disetujui:

### Opsi A (Target Root: `backend/`)
#### [NEW] [`backend/analisis_dan_mitigasi_ai_litellm.md`](file:///C:/Users/acer/Documents/hackaton/git-hero-backend/backend/analisis_dan_mitigasi_ai_litellm.md)
Salinan dokumen analisis peran AI, risiko kegagalan, dan solusi mitigasi LiteLLM.

#### [NEW] [`backend/implementation_plan_litellm_integration.md`](file:///C:/Users/acer/Documents/hackaton/git-hero-backend/backend/implementation_plan_litellm_integration.md)
Salinan panduan implementasi teknis LiteLLM Router, multi-key Gemini, dan daftar free-tier provider.

---

## 4. Verification Plan

Setelah Anda memberikan persetujuan untuk eksekusi, langkah-langkah verifikasi yang akan dijalankan meliputi:

### Automated Verification
Memeriksa keberadaan file dan kesamaan ukuran byte data:
```powershell
# Verifikasi file ada di backend/
Get-ChildItem -Path "backend" -Filter "*litellm*.md" | Select-Object Name, Length, FullName
```
**Kriteria Lolos:**
- File `analisis_dan_mitigasi_ai_litellm.md` berukuran ~18.3 KB.
- File `implementation_plan_litellm_integration.md` berukuran ~16.7 KB.

### Manual Verification
- Membuka kedua file di editor untuk memastikan formatting markdown, tabel, dan diagram mermaid tetap utuh dan terbaca sempurna.
