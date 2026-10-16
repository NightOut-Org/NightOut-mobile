# NightOut Mobile

แอปมือถือของ NightOut 2 ตัวใน repo เดียว (Dart pub workspace) · ทำตามดีไซน์และ workflow ของเว็บ [`NightOut-Org/NightOut`](https://github.com/NightOut-Org/NightOut)

| โฟลเดอร์ | คืออะไร | เทียบกับเว็บ |
|---|---|---|
| `apps/client` | แอปลูกค้า (`com.night.nightout`) | `apps/frontend` ส่วนลูกค้า |
| `apps/admin` | แอป Backoffice ทีม NightOut (`com.night.admin`) | `apps/admin` |
| `packages/nightout_core` | ธีม, `Env`, วิดเจ็ตที่ใช้ร่วมกัน | `packages/ui` |
| `tool/` | สคริปต์สร้างธีมจากเว็บ และตรวจสีในแอป | |
| `docs/nightout/` | เอกสารส่งต่อจากทีมเว็บ (API, Auth, ธีม, กฎธุรกิจ) | |

กติกาการทำงาน (คนและ AI agent): [`AGENTS.md`](AGENTS.md)

## เริ่มต้น

ต้องใช้ **Flutter 3.41.x** (`>=3.41.9 <3.44.0`) · 3.44 ขึ้นไปยังใช้ไม่ได้เพราะ `phosphor_flutter` 2.1.0 ยังไม่รองรับ

```bash
flutter pub get                      # ที่ root ได้ครบทุกแพ็กเกจ
```

ขอไฟล์ `.env.dev` จากเจ้าของงานทางแชตส่วนตัว แล้ววางที่ root ของ repo (ไม่เข้า git)

```bash
cd apps/client                       # หรือ apps/admin
flutter run --dart-define-from-file=../../.env.dev
```

VS Code: เลือก launch config `client` หรือ `admin`

## ธีมจากเว็บ

สีและ token ของธีมสร้างจาก `packages/ui/src/tokens.ts` และ `theme.css` ของเว็บ ต้องมี repo เว็บอยู่ในเครื่องและ Node ที่อ่านไฟล์ `.ts` ได้เอง (ทดสอบกับ Node 22.22.2)

```bash
node tool/gen_tokens.mjs             # เขียน packages/nightout_core/lib/src/theme/tokens.g.dart
node tool/gen_tokens.mjs --check     # exit 1 ถ้าธีมในแอปไม่ตรงกับเว็บ
```

สคริปต์หา repo เว็บที่ `../../Nightout` (ข้างโฟลเดอร์ `NightOut-Mobile`) · ถ้าวางไว้ที่อื่นตั้ง `NIGHTOUT_WEB_DIR=/path/to/NightOut`

## ตรวจก่อนส่งงาน

```bash
flutter analyze
(cd packages/nightout_core && flutter test)
(cd apps/client && flutter test)
(cd apps/admin && flutter test)
node tool/gen_tokens.mjs --check
tool/check_raw_colors.sh
```
