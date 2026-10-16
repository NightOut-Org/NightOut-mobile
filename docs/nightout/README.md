# NightOut — ส่งต่อทีม Flutter (ขึ้นโครงแอปมือถือ)

เอกสารนี้รวมของที่ต้องใช้ตอนขึ้นโปรเจกต์ Flutter ส่วนธีม (สี ฟอนต์ มุมโค้ง motion และโค้ด `ThemeData`) อยู่ที่ [`THEME.md`](THEME.md) โค้ดธีมจริงอยู่ใน `packages/nightout_core`

ถ้าเอกสารนี้ขัดกับโค้ดใน repo เว็บ ให้ยึดโค้ด แล้วแจ้งให้แก้เอกสารนี้

## 0. ไฟล์นี้อยู่ตรงไหนใน repo

repo นี้เป็น Dart pub workspace มี 2 แอปกับ 1 แพ็กเกจกลาง

| ที่อยู่ | คืออะไร |
|---|---|
| `apps/client` | แอปลูกค้า เทียบกับ `apps/frontend` ของเว็บ (ส่วนลูกค้า) |
| `apps/admin` | แอป Backoffice ของทีม NightOut เทียบกับ `apps/admin` ของเว็บ |
| `packages/nightout_core` | ธีม `Env` และวิดเจ็ตที่ทั้ง 2 แอปใช้ร่วมกัน |
| `docs/nightout/` | เอกสารนี้กับ [`THEME.md`](THEME.md) |
| `.env.dev` (root) | ค่าตั้งต้นจริง ไม่เข้า git (`.gitignore` กัน `.env*` ไว้แล้ว) — **ขอไฟล์นี้ทางแชตส่วนตัว อย่าแปะในที่สาธารณะ** |

กติกาสำหรับ AI agent อยู่ที่ `AGENTS.md` (root) และ `apps/<แอป>/AGENTS.md`

---

## 1. เอกสารที่ต้องอ่านก่อน

ไฟล์ในตารางนี้ (ยกเว้น `THEME.md`) อยู่ใน repo เว็บ [`NightOut-Org/NightOut`](https://github.com/NightOut-Org/NightOut)

| ไฟล์ | ใช้ทำอะไร |
|---|---|
| [`THEME.md`](THEME.md) | ธีม Midnight Gold และที่มาของสีแต่ละตัว |
| [`REQUIREMENTS.md`](https://github.com/NightOut-Org/NightOut/blob/main/docs/REQUIREMENTS.md) | ขอบเขตงาน Phase และกฎธุรกิจ (ข้อ 0 "ข้อตัดสินของเจ้าของ" มีผลเหนือข้ออื่น) |
| [`SITEMAP.md`](https://github.com/NightOut-Org/NightOut/blob/main/docs/SITEMAP.md) | รายชื่อหน้าและ route ของเว็บ ใช้วางโครง navigation |
| [`DATABASE.md`](https://github.com/NightOut-Org/NightOut/blob/main/docs/DATABASE.md) | โครงตาราง สถานะการจอง และรายชื่อ endpoint |
| [`packages/contracts/src/*.ts`](https://github.com/NightOut-Org/NightOut/tree/main/packages/contracts/src) | body / response / รหัส error ของทุก endpoint แยกตามโดเมน |

---

## 2. Asset

ทุกไฟล์อยู่ที่ `apps/frontend/public/` ของ repo เว็บ

| ไฟล์ | ใช้ทำ |
|---|---|
| `images/brand/logo-on-dark.webp` | โลโก้บนพื้นมืด |
| `images/brand/logo-on-light.webp` | โลโก้บนพื้นสว่าง |
| `favicon.svg` | ต้นฉบับสำหรับทำ app icon / adaptive icon |
| `apple-touch-icon.png` | ไอคอนขนาดใหญ่สำหรับอ้างอิง |
| `images/boot/boot-bg.webp`, `boot-bg-sm.webp` | พื้นหลังหน้าโหลด (splash) |
| `images/bars/placeholder.webp` | รูปแทนเมื่อร้านไม่มีรูปปก |

- ฟอนต์ของแอป: IBM Plex Sans Thai + Playfair Display (`google_fonts`) ดูรายละเอียดใน `THEME.md`
- หน้าโหลดของเว็บใช้ Kanit 300 (`public/fonts/kanit-*`) เฉพาะหน้านั้นหน้าเดียว
- ไอคอน: Phosphor → แพ็กเกจ `phosphor_flutter` (ปกติใช้ regular / ตอนเลือกใช้ fill)

---

## 3. ค่าตั้งต้น (env)

ค่าจริงอยู่ในไฟล์ `.env.dev` ที่ root ของ repo รันจากโฟลเดอร์ของแอปด้วย:

```bash
cd apps/client   # หรือ apps/admin
flutter run --dart-define-from-file=../../.env.dev
```

อ่านค่าในโค้ดผ่าน `Env` ของ `nightout_core` (อย่าสร้างคลาสซ้ำในแอป):

```dart
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const authRedirectUrl = String.fromEnvironment('AUTH_REDIRECT_URL');
}
```

| ค่า | ใน `.env.dev` | หมายเหตุ |
|---|---|---|
| `SUPABASE_URL` | URL โปรเจกต์ Supabase จริง | ใช้กับ Auth |
| `SUPABASE_ANON_KEY` | publishable key (`sb_publishable_…`) | key เดียวกับที่เว็บใช้ ใส่ในแอปได้ · **ห้ามใส่ `service_role` ในแอปเด็ดขาด** |
| `API_BASE_URL` | `https://night-out-demo.vercel.app/api` | API ที่ deploy แล้ว ใช้ข้อมูลชุดเดียวกับเว็บ — **ไม่ต้องรัน backend เอง** · ถ้ารันเองด้วย `pnpm dev`: iOS Simulator `http://localhost:3000/api` · Android Emulator `http://10.0.2.2:3000/api` · เครื่องจริง `http://<IP>:3000/api` |
| `AUTH_REDIRECT_URL` | `nightout://auth-callback` | deep link ที่ Supabase ส่งกลับเข้าแอป (ข้อ 5) |

- แอปมือถือไม่ติด CORS (`CORS_ORIGINS` ของ backend ไม่ต้องแก้)
- เว็บยังไม่ได้ใช้ Cloudflare Turnstile (ค่ายังว่าง) มือถือจึงยังไม่ต้องทำ captcha
- เว็บที่ deploy: https://night-out-demo.vercel.app (เทียบหน้าจอกับแอปได้) · Swagger: https://night-out-demo.vercel.app/api/docs
- ข้อมูลที่เขียนผ่าน API นี้คือข้อมูลจริงของโปรเจกต์ (จองโต๊ะ/รีวิว) ให้ทดสอบกับบัญชีทดสอบและร้านเดโมเท่านั้น

---

## 4. การเรียก API

### กติกา

- **ข้อมูลทุกอย่างอ่านและเขียนผ่าน NestJS API** ห้ามเรียก `supabase.from()` / `.rpc()` / `.storage` จากแอปตรงๆ (ADR 0002) `supabase_flutter` ใช้แค่ `supabase.auth.*`
- ทุก request ที่ต้องล็อกอินส่ง header `Authorization: Bearer <session.accessToken ของ Supabase>`
- ใช้ `ApiClient` ของ `nightout_core` (ใส่ Bearer และแกะ envelope ให้) ดูกติกาใน `AGENTS.md` หัวข้อ "ข้อมูลและ API"
- key ใน body / query / response เป็น **snake_case ทั้งหมด** → ถ้าใช้ `json_serializable` ให้ตั้ง `fieldRename: FieldRename.snake`

### Swagger / OpenAPI

- รัน backend ในเครื่อง (`pnpm dev`) แล้วเปิด `http://localhost:3000/api/docs`
- generate client ได้ด้วย `openapi-generator` (generator `dart-dio`) หรือเขียน client เองโดยอ้างอิงจาก `packages/contracts`

### รูปแบบคำตอบ

ทุก endpoint ตอบแบบนี้ HTTP status เป็นค่าจริง:

```json
{ "status": "ok", "status_code": 200, "data": { }, "code": null, "err_msg": null }
{ "status": "no", "status_code": 409, "data": null, "code": "ZONE_FULL", "err_msg": "ข้อความภาษาไทย" }
```

- ทำ interceptor ตัวเดียว: สำเร็จให้คืน `data` · ไม่สำเร็จให้ throw `ApiError(code, errMsg, statusCode)`
- `err_msg` เป็นภาษาไทยจาก backend อยู่แล้ว **แสดงให้ผู้ใช้ได้เลย** ส่วน `code` เอาไว้ให้โค้ดแยกเคส (เช่น `ZONE_FULL`, `MFA_REQUIRED`)
- รายชื่อ `code` ทั้งหมดอยู่ใน `<DOMAIN>_ERRORS` ของ `packages/contracts/src/<domain>.ts`

### อัปโหลดไฟล์ (รูป/วิดีโอรีวิว)

1. `POST /storage/upload-url` ขอ URL สำหรับอัปโหลด
2. `PUT` ตัวไฟล์ตรงไปที่ URL ที่ได้มา
3. ส่ง path ที่ได้ไปพร้อมกับ body ของ endpoint ที่ใช้ไฟล์นั้น

รูปที่เป็นไฟล์ส่วนตัวขอ URL สำหรับอ่านผ่าน `POST /storage/signed-urls`
รีวิวแนบไฟล์ได้สูงสุด 6 ไฟล์ · วิดีโอยาวไม่เกิน 60 วินาที / 60MB

---

## 5. เข้าสู่ระบบ

- มีแค่ **email + password** และ **Google / Facebook** (Supabase OAuth) ห้ามเพิ่ม OTP หรือ provider อื่นถ้าไม่ได้ตกลงกันก่อน
- deep link ของแอปคือ `nightout://auth-callback` (ค่า `AUTH_REDIRECT_URL`) · ฝั่งแอปต้องลงทะเบียน scheme `nightout` ทั้ง iOS (`Info.plist` → `CFBundleURLTypes`) และ Android (`intent-filter` ใน `AndroidManifest.xml`)
- ส่ง `redirectTo: Env.authRedirectUrl` ทุกครั้งที่เรียก `signInWithOAuth` และ `resetPasswordForEmail`
- URL นี้ต้องอยู่ใน Supabase Dashboard → Authentication → URL Configuration → Redirect URLs (เจ้าของ repo เป็นคนเพิ่ม) ถ้ายังไม่มี Supabase จะส่งกลับไปที่เว็บแทน
- deep link นี้ใช้กับ OAuth และลิงก์รีเซ็ตรหัสผ่าน (บนเว็บไปที่ `/reset-password`)
- Google / Facebook บนมือถือต้องลงทะเบียน bundle id / package name + SHA-1 ใน console ของ Google และ Facebook ด้วย

---

## 6. กฎที่แอปต้องทำตาม

- **ธีมมืดเป็นค่าเริ่มต้น** · key ที่เก็บในเครื่องขึ้นต้นด้วย `nightout-` (เช่น `nightout-theme` = `DARK` / `LIGHT` / `SYSTEM`)
- **QR เช็กอิน** ใช้รูปแบบ `NIGHTOUT:<booking id>` (หน้าร้านรับรหัส `NL-XXXXXX` ที่พิมพ์เองได้ด้วย)
- **แผนที่** ใช้ vector tiles ของ OpenFreeMap (`https://tiles.openfreemap.org/styles/positron`) แล้วแทนสีตามพาเลตใน `apps/frontend/src/ui/utils/mapStyle.ts` · ไม่ใช้ Google Maps API → ใช้แพ็กเกจ `maplibre_gl` ได้ · หมุดแสดงรูปร้าน (ไม่มีรูปใช้ `placeholder.webp`)
- **คำที่ต้องใช้ / ห้ามใช้**
  - เงินที่จ่ายผ่านแอปเรียกว่า **"ค่าธรรมเนียมจองโต๊ะ (Table Fee)"** เท่านั้น
  - ป้ายความปลอดภัยใช้ **"ข้อมูลอ้างอิงจากร้านค้า (Merchant Declared)"** + วันที่ตรวจล่าสุด · ห้ามใช้คำว่า "Safety Verified" / "ยืนยันโดย NightOut"
  - ห้ามใช้คำว่า "ขายเหล้า/เบียร์" · โปรโมชันต้องไม่ใช่การลดราคาหรือแถมแอลกอฮอล์
- **จองได้เฉพาะโต๊ะ** + เลือกโปรของร้านได้ 1 อย่าง ไม่มีการสั่งอาหารหรือเครื่องดื่มล่วงหน้า เมนูแสดงไว้ให้ประเมินงบเท่านั้น
- **Checkout** ต้องกรอกเบอร์โทร + ติ๊กยอมรับเงื่อนไขริบมัดจำ (ข้อความดึงจาก backend · มีเวอร์ชัน)
- **สถานะคนในร้าน** ต้องแสดงทั้งจุดสีและคำ: ว่าง / ใกล้เต็ม / เต็ม

---

## 7. ยังไม่ต้องทำ / รอเคาะ

- **การชำระมัดจำ**: ตอนนี้ในโค้ดยังเป็น PromptPay + อัปโหลดสลิป (DRAFT) และ**กำลังจะเปลี่ยนเป็น Beam Payment แบบ Escrow** → แอปมือถือ**ไม่ต้องทำ flow สลิป** ให้รอ API ของ Beam
- เรื่องที่ยังไม่ได้ทำในโค้ด (แจ้งเตือน 15 นาทีก่อนเวลา, ขอต่อเวลา, ปลดโต๊ะเมื่อสาย 30 นาที, Party Set) ให้ดูสถานะล่าสุดใน `REQUIREMENTS.md` ก่อนเริ่มทำ
- Push notification ยังไม่มีใน backend ต้องคุยกันก่อน
