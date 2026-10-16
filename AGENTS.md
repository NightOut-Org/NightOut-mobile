# AGENTS.md — NightOut mobile workspace

กติกาสำหรับ AI agent (Cursor / Claude Code) และคนที่ทำงานใน repo นี้ · กติกาเฉพาะแอปอยู่ที่ `apps/client/AGENTS.md` และ `apps/admin/AGENTS.md` (อ่านคู่กับไฟล์นี้เสมอ)

## แอปมือถือตามเว็บ
แอปมือถือทำตามดีไซน์และ workflow ของเว็บ repo [`NightOut-Org/NightOut`](https://github.com/NightOut-Org/NightOut) · เมื่อข้อมูลขัดกัน ยึดตามลำดับนี้:
1. โค้ดใน repo เว็บ: `packages/contracts/src/<domain>.ts` (body / response / error code), `packages/ui/src/tokens.ts` + `theme.css` (ธีม), `apps/frontend` (ลูกค้า), `apps/admin` (Backoffice)
2. `docs/REQUIREMENTS.md` ของเว็บ (ข้อ 0 "ข้อตัดสินของเจ้าของ" ชนะข้ออื่น) และ `docs/SITEMAP.md`
3. เอกสารใน `docs/nightout/` ของ repo นี้
4. โค้ดมือถือที่มีอยู่

เจอข้อขัดกัน: ทำตามเว็บ แล้วแจ้งให้แก้เอกสาร/โค้ดมือถือ · ห้ามเดาเอง · เว็บที่ deploy (เทียบหน้าจอ): https://night-out-demo.vercel.app · Swagger: https://night-out-demo.vercel.app/api/docs

## โครง repo
- Dart pub workspace: `apps/client` (ลูกค้า), `apps/admin` (Backoffice ทีม NightOut), `packages/nightout_core` (ของที่ใช้ร่วมกัน)
- โค้ดที่ทั้ง 2 แอปใช้ (ธีม, `Env`, HTTP client, auth, model ของ API, วิดเจ็ตพื้นฐาน) อยู่ใน `nightout_core` เท่านั้น · **ห้ามคัดลอกโค้ดข้ามแอป** — ถ้าแอปที่สองต้องใช้ ย้ายเข้า core
- แอปห้าม import กันเอง
- Flutter ล็อกที่ `>=3.41.9 <3.44.0` (ใน `pubspec.yaml` ของ root) เพราะ `phosphor_flutter` 2.1.0 ใช้กับ 3.44+ ไม่ได้ · ห้ามเพิ่มแพ็กเกจที่ต้องใช้ Flutter 3.44+
- `flutter pub get` ที่ root ครั้งเดียวได้ทุกแพ็กเกจ · `pubspec.lock` มีไฟล์เดียวที่ root

## เอกสารอ้างอิง
- `docs/nightout/README.md` — env, การเรียก API, Auth, asset, กฎธุรกิจ
- `docs/nightout/THEME.md` — ธีม Midnight Gold

## ติดตามงาน
- งานที่วางแผนไว้และสถานะอยู่ที่ `plans/` (ดู `plans/README.md`) · อ่านก่อนเริ่มงาน
- เริ่มทำแผนไหน ให้ตั้ง Status เป็น `IN PROGRESS` + Owner · จบหรือหยุดกลางทาง ให้อัปเดต Status / Progress notes ในไฟล์แผนและตารางใน `plans/README.md`

## ภาษา
- ข้อความ UI เป็นภาษาไทย · โค้ด ชื่อตัวแปร และ commit เป็นภาษาอังกฤษ
- Conventional Commits โดย scope เป็นแอปหรือแพ็กเกจ: `feat(client): …`, `fix(admin): …`, `refactor(core): …`, `chore(workspace): …`

## ธีม
- สีมาจาก `context.colors` (`NightOutColors`) หรือ `Theme.of(context).colorScheme` เท่านั้น · **ห้ามพิมพ์ `Color(0x…)` ในแอป** (`tool/check_raw_colors.sh` ตรวจให้)
- สีเฉพาะหน้าที่ token ไม่มี: (1) ถ้าเป็นสีจางของ token ใช้ `colors.x.withValues(alpha: NightOutAlpha.subtle)` ห้ามพิมพ์ตัวเลข alpha เอง · (2) ถ้าเป็นสีใหม่ของฟีเจอร์ ทำ `ThemeExtension` ใน `nightout_core` ที่มีค่าทั้งมืดและสว่าง แล้วลงทะเบียนใน `nightOutTheme()` (ตัวอย่าง: `AuthColors` / `context.authColors` ของหน้าเข้าสู่ระบบ) · (3) สีที่มากับข้อมูลจาก API แปลงใน model ไม่นับเป็นสีดีไซน์
- `packages/nightout_core/lib/src/theme/tokens.g.dart` สร้างจากเว็บด้วย `node tool/gen_tokens.mjs` · ห้ามแก้มือ · เว็บเปลี่ยนสีเมื่อไหร่ให้รันใหม่
- ธีมมืดเป็นค่าเริ่มต้น · ผู้ใช้เลือก DARK / LIGHT / SYSTEM ได้ เก็บใน key `nightout-theme` (`nightOutThemeStorageKey`) · state อยู่ที่ `nightOutThemeModeProvider` ใน core ห้ามเก็บซ้ำในแอป
- ฟอนต์: IBM Plex Sans Thai (`NightOutText.sans`) · Playfair Display สำหรับหัวข้อภาษาอังกฤษ (`NightOutText.display`) · ไอคอน: `phosphor_flutter` เท่านั้น
- ทอง / ม่วงเป็นสีเน้น ห้ามทาพื้นที่ใหญ่ · โหมดสว่างตัวอักษรทองใช้ `goldText` ห้ามใช้ `gold`
- เคารพการตั้งค่าลดการเคลื่อนไหว: animation ใหม่ทุกตัวเช็ก `context.reduceMotion` แล้วเปลี่ยนทันทีหรือเฟด `NightOutMotion.fast` · ระยะเวลา/เส้นโค้งใช้ `NightOutMotion`

## ข้อมูลและ API
- **อ่านและเขียนข้อมูลผ่าน NestJS (`Env.apiBaseUrl`) เท่านั้น** · `supabase_flutter` ใช้ได้เฉพาะ `supabase.auth.*` ห้ามเรียก `from()` / `rpc()` / `storage` (ADR 0002 / 0003 ของเว็บ)
- HTTP client มีตัวเดียว (Dio) **ยังไม่ได้สร้าง** · ตัวแรกที่ทำให้สร้างใน `nightout_core` (ห้ามสร้างในแอป) ตามนี้:
  - ใส่ `Authorization: Bearer <accessToken ของ Supabase>`
  - แกะ `{ status, status_code, data, code, err_msg }` → สำเร็จคืน `data` · ไม่สำเร็จ throw `ApiException(code, errMsg, statusCode)`
  - `err_msg` เป็นภาษาไทยแล้ว แสดงให้ผู้ใช้ได้เลย · ตัดสินใจในโค้ดจาก `code`
- JSON เป็น snake_case → `@JsonSerializable(fieldRename: FieldRename.snake)`
- อัปโหลดไฟล์: `POST /storage/upload-url` แล้ว PUT ไฟล์ตรงไปที่ URL ที่ได้
- ข้อมูลที่เขียนผ่าน API คือข้อมูลจริงของโปรเจกต์ ทดสอบกับบัญชีทดสอบและร้านเดโมเท่านั้น

## Env
- อ่านค่าผ่าน `Env` ของ `nightout_core` · รันจากโฟลเดอร์แอปด้วย `flutter run --dart-define-from-file=../../.env.dev`
- ห้าม hardcode URL / key · ห้าม commit ไฟล์ `.env*` · ห้ามใส่ `service_role`, `DATABASE_URL` หรือ secret ของ backend ในแอป

## ก่อนบอกว่าเสร็จ
```bash
flutter analyze                       # ที่ root
(cd packages/nightout_core && flutter test)
(cd apps/client && flutter test)
(cd apps/admin && flutter test)
node tool/gen_tokens.mjs --check      # ธีมตรงกับเว็บ
tool/check_raw_colors.sh              # ไม่มีสี hex ในแอป
```

## ของนอกแผน
ฟีเจอร์ที่ไม่มีใน `docs/nightout/README.md`, SITEMAP หรือ requirement ของเว็บ **ให้ถามเจ้าของงานก่อนเริ่มทำ** ห้ามเดาเอง
