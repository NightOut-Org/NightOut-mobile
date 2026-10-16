# Midnight Gold — ธีมสำหรับขึ้นโครง Flutter

ค่าด้านล่างคัดจากเว็บ NightOut ณ วันที่ดึงเอกสารนี้ แหล่งจริงของสีคือ `packages/ui/src/tokens.ts` และ `packages/ui/src/theme.css` ของเว็บ แอปดึงค่าจากสองไฟล์นี้ด้วย `tool/gen_tokens.mjs` (ดูหัวข้อ "โค้ด Flutter" ท้ายไฟล์)

ธีมเริ่มต้นคือ **มืด** ชื่อที่เก็บในเครื่องคือ `nightout-theme` ค่าที่เป็นไปได้คือ `DARK` · `LIGHT` · `SYSTEM`

---

## สีหลัก

ชื่อซ้ายคือชื่อในเว็บ ชื่อขวาคือช่องที่ควรใส่ใน `ColorScheme` ของ Flutter

| ชื่อในเว็บ | Dark | Light | ใช้กับ | ช่อง Flutter |
|---|---|---|---|---|
| background | `#07070D` | `#FAF8F3` | พื้นทั้งหน้า | `surface` |
| surface | `#11111A` | `#FFFFFF` | แถบบน แถบล่าง แถบข้าง | `surfaceContainer` |
| card | `#171520` | `#F4F1EA` | การ์ด แผง ชีต | `surfaceContainerHigh` |
| border | `#34283F` | `#E4DCCF` | ขอบ การ์ด ช่องกรอก เส้นแบ่ง | `outline` |
| text | `#F5F1E8` | `#1A1523` | ตัวอักษรหลัก | `onSurface` |
| muted | `#A7A1B3` | `#5E5670` | ตัวอักษรรอง placeholder | `onSurfaceVariant` |
| gold | `#E8B64C` | `#E8B64C` | พื้นปุ่มหลัก ป้ายโฆษณา | `primary` |
| goldHighlight | `#FFD77A` | `#F5C85E` | ตอนชี้ปุ่มทอง จุดสว่างในหัวข้อ | เก็บใน extension |
| goldText | `#E8B64C` | `#8A5A00` | ดาว คะแนน ยอดเงิน ตัวอักษรทอง | เก็บใน extension |
| onGold | `#07070D` | `#1A1523` | ตัวอักษรบนปุ่มทอง | `onPrimary` |
| purple | `#A738F5` | `#A738F5` | แท็บที่เลือก ชิปที่เลือก วงโฟกัส ไอคอนเน้น | `secondary` |
| link | `#B86BFA` | `#7E22CE` | ลิงก์ ข้อความม่วงขนาดเล็ก | `tertiary` |
| crowdAvailable | `#22C55E` | `#16A34A` | โต๊ะว่าง | `tertiary` ของสถานะ หรือ `primary` ของ success |
| crowdAlmostFull | `#EAB308` | `#CA8A04` | ใกล้เต็ม | warning |
| crowdFull | `#EF4444` | `#DC2626` | เต็ม | `error` |

ตัวอักษรบนชิปม่วงที่ใช้เลือกอยู่เป็นสีขาว `#FFFFFF`

### สีที่ไม่อยู่ในตารางหลัก แต่ใช้คู่กับธีม

| ชื่อ | Dark | Light | ใช้กับ |
|---|---|---|---|
| heroVia | `#1E0B33` | `#EFE3FF` | พื้นไล่ของฮีโร่ ต่อจาก background |
| titleFrom | `#FFD77A` | `#B07A12` | จุดเริ่มของตัวอักษรหัวข้อไล่สีทอง |
| titleTo | `#E8B64C` | `#8A5A00` | จุดจบของตัวอักษรหัวข้อไล่สีทอง |
| themeColor (แถบสถานะมือถือ) | `#07070D` | `#FAF8F3` | เท่ากับ background |

### ป้ายระดับร้าน (ใช้ในกราฟหลังบ้าน สีเดียวกันทั้งสองโหมด)

ผู้ใช้ฝั่งลูกค้าเห็นเป็นดาว 1–5 สี `goldText` สีป้ายนี้ใช้ในกราฟของแอดมิน

| ระดับ | พื้น | ตัวอักษร | ชื่อ |
|---|---|---|---|
| S | `#E8B64C` | `#07070D` | Legendary |
| A | `#963BE8` | `#F5F1E8` | Excellent |
| B | `#5869C8` | `#F5F1E8` | Good |
| C | `#74788B` | `#07070D` | Normal |

### เงา

มืด (glow ตอนชี้การ์ด):

- เส้นขอบทอง 1px สี `#E8B64C`
- เงาม่วง `offset (0, 8)` blur `32` สี `rgba(167, 56, 245, 0.25)` ซึ่งคือ `#A738F5` ที่ความทึบ 25%

สว่าง:

- เงานุ่ม `offset (0, 8)` blur `24` สี `rgba(26, 21, 35, 0.08)` ซึ่งคือ `#1A1523` ที่ความทึบ 8%

ปุ่มทองในหน้าเข้าสู่ระบบใช้เงาเพิ่ม: `offset (0, 8)` blur `22` spread `-8` สี `rgba(232, 182, 76, 0.65)`

### กติกาคอนทราสต์

- ข้อความขนาดปกติต้องอ่านตัดกับพื้นได้อย่างน้อย 4.5:1
- ม่วง `#A738F5` บนพื้นดำอ่านได้ประมาณ 4.3:1 จึงใช้เป็นขอบ ไอคอน และตัวอักษรใหญ่ ลิงก์ขนาดเล็กใช้สี `link`
- โหมดสว่าง ห้ามใช้ทอง `#E8B64C` เป็นตัวอักษรบนพื้นขาว ใช้ `goldText` `#8A5A00`
- ทองกับม่วงเป็นสีเน้น ไม่ทาเต็มพื้นที่ใหญ่ ยกเว้นไล่สีในฮีโร่

---

## ตัวอักษร

| บทบาท | ฟอนต์ | น้ำหนัก | หมายเหตุ |
|---|---|---|---|
| เนื้อหา ภาษาไทยและ UI | IBM Plex Sans Thai แล้วตามด้วย Noto Sans Thai แล้ว system | 400, 500, 600, 700 | ฟอนต์ทั้งแอป |
| หัวข้อแบรนด์และชื่อร้าน (ภาษาอังกฤษ) | Playfair Display แล้วตามด้วย Georgia | 600, 700 | ใช้กับคำอังกฤษ |

บน Flutter ใช้แพ็กเกจ `google_fonts` แล้วเรียก `GoogleFonts.ibmPlexSansThai()` กับ `GoogleFonts.playfairDisplay()`

ขนาดที่หน้าเว็บใช้บ่อย ไม่ได้ล็อกเป็นสเกลเดียวในโทเคน:

| บทบาท | ขนาด | น้ำหนัก |
|---|---|---|
| หัวหน้าเพจบนจอกว้าง | 30 | 700 ฟอนต์ Playfair |
| หัวหน้าเพจบนมือถือของร้าน | 17 | 700 ฟอนต์เนื้อหา |
| ชื่อบนการ์ด | 24 | 700 |
| ป้ายหมวดเล็ก (เช่น COMMUNITY) | 13 ระยะตัวอักษร 0.14em | 400 สี goldText |
| ปุ่มหลัก | 15 | 700 |
| ป้ายช่องกรอก | 13 | 600 |

ระยะบรรทัดของหัวหน้าเพจบนจอกว้างใช้แบบ tight (ประมาณ 1.1–1.25)

---

## มุมโค้ง

| ชื่อ | ค่า | ใช้กับ |
|---|---|---|
| base | 12 | การ์ด ช่องกรอก ปุ่มทั่วไป ป๊อปอัปแผนที่ |
| pill | 9999 | ช่องค้นหา ชิป ปุ่มบางแบบ |
| authGlass | 24 | การ์ดกระจกของหน้าเข้าสู่ระบบ |

---

## จังหวะการเคลื่อน

| ชื่อ | ค่า |
|---|---|
| fast | 150 ms — ชี้ กด สลับ |
| base | 250 ms — เมนู แท็บ การ์ด |
| slow | 400 ms — เปลี่ยนหน้า ชีต สลับธีม |
| easeOut | cubic-bezier(0.22, 1, 0.36, 1) |
| sheet spring | stiffness 380, damping 32 |
| สลับธีมแบบวงกลม | 400 ms easeOut |
| สลับธีมแบบเฟดสี (สำรอง) | 300 ms ที่พื้น สีตัวอักษร และขอบ |
| กดการ์ด | scale 0.98 |
| ชี้การ์ด | ยกขึ้น 4 px |

ถ้าผู้ใช้เปิดลดการเคลื่อนไหว ให้เหลือเฟด 150 ms หรือเปลี่ยนทันที บน Flutter เช็กด้วย `context.reduceMotion` (ใน `nightout_core`)

เส้นโค้ง easeOut ใน Flutter:

```dart
const nightOutEaseOut = Cubic(0.22, 1, 0.36, 1);
```

---

## ปุ่มและชิป

- ปุ่มหลัก: พื้น `gold` ตัวอักษร `onGold` น้ำหนัก 600–700 มุม 12 หรือ pill
- ปุ่มรอง: ขอบทอง ตัวอักษร `goldText` พื้นโปร่ง
- ปุ่มข้อความ: ตัวอักษร `link`
- ชิปปกติ: ขอบ `border`
- ชิปที่เลือก: พื้น `purple` ตัวอักษรขาว
- เมนูที่เลือก: พื้นแคปซูลทอง `gold` ตัวอักษรและไอคอน `onGold` ไอคอนน้ำหนัก fill · เมนูปกติ: ตัวอักษรและไอคอน `muted` ไอคอนน้ำหนัก regular (ตามแถบเมนูล่าง `BottomIsland` และเมนูบนของเว็บ ใน `apps/frontend/src/ui/components/navbar.tsx` · เว็บไม่มีขีดล่างทอง) · `NavigationBar` ของ Flutter วางชื่อเมนูไว้นอกแคปซูล ชื่อเมนูที่เลือกจึงใช้ `goldText`
- ไอคอนปกติ: น้ำหนัก regular สี `muted` ไอคอนที่เลือก: น้ำหนัก fill สี `goldText` (ถ้าอยู่บนแคปซูลทอง ใช้ `onGold`)
- ดาวที่เติม: สี `goldText` ดาวที่ว่าง: สี `border`
- สถานะคนในร้านต้องมีทั้งจุดสีและคำว่า ว่าง / ใกล้เต็ม / เต็ม

หน้าเข้าสู่ระบบมีปุ่มทองแบบไล่สีเพิ่ม จาก `#FFD77A` ไป `#E8B64C` ตัวอักษร `#1A1206` มุม 12 สูง 46 นี่เป็นของหน้านั้นโดยเฉพาะ ปุ่มหลักของแอปที่เหลือใช้พื้นทองทึบ `#E8B64C`

---

## โค้ด Flutter

โค้ดธีมอยู่ใน `packages/nightout_core` แล้ว **ไม่ต้องคัดโค้ดจากเอกสารนี้ไปวาง**

- สีทุกตัวในตาราง "สีหลัก" รวม `heroVia` `titleFrom` `titleTo` เงา glow ป้ายระดับร้าน มุมโค้ง และจังหวะการเคลื่อน สร้างจาก `packages/ui/src/tokens.ts` กับ `theme.css` ของเว็บด้วย `node tool/gen_tokens.mjs` ไปที่ `lib/src/theme/tokens.g.dart` ห้ามแก้ไฟล์นั้นด้วยมือ
- เว็บเปลี่ยนสีเมื่อไหร่ รัน `node tool/gen_tokens.mjs` ใหม่ · `node tool/gen_tokens.mjs --check` บอกได้ว่าไฟล์ในแอปตามเว็บทันหรือยัง
- ค่าที่เว็บไม่ได้เก็บใน `tokens.ts` (`themeFade` 300 ms, กดการ์ด scale 0.98, มุม `authGlass` 24, ขั้นความโปร่ง `NightOutAlpha`) เขียนไว้ใน `lib/src/theme/tokens.dart`
- `NightOutAlpha` คือขั้นความโปร่งแทนเลขหลัง `/` ของ Tailwind บนเว็บ (`purple/45`): `faint` 0.05 · `subtle` 0.12 · `medium` 0.45 · `strong` 0.65 · ใช้ `colors.purple.withValues(alpha: NightOutAlpha.medium)`
- สีของหน้าเข้าสู่ระบบ (การ์ดกระจก ช่องกรอก ปุ่มทองไล่สี ตัวอักษร `#1A1206`) อยู่ใน `AuthColors` (`lib/src/theme/auth_colors.dart`) อ่านด้วย `context.authColors` · ค่ามาจาก `.auth-glass` / `.auth-modal` / `.btn-gold` ใน `apps/frontend/src/styles/index.css` ของเว็บ · เว็บใช้การ์ดกระจกมืดทั้งสองโหมด `AuthColors.light` จึงเท่ากับ `dark`
- ถ้าตารางในเอกสารนี้ไม่ตรงกับ `tokens.g.dart` ให้ยึด `tokens.g.dart` (มาจากเว็บโดยตรง) แล้วแก้เอกสารนี้

ใช้ในแอป:

```dart
import 'package:nightout_core/nightout_core.dart';

// main.dart: อ่านธีมที่เก็บไว้ก่อน runApp จะได้ไม่กะพริบเป็นธีมมืดตอนเปิดแอป
final mode = await loadNightOutThemeMode();
runApp(ProviderScope(
  overrides: [nightOutInitialThemeModeProvider.overrideWithValue(mode)],
  child: const App(),
));

// app.dart
MaterialApp(
  theme: nightOutTheme(Brightness.light),
  darkTheme: nightOutTheme(Brightness.dark),
  themeMode: ref.watch(nightOutThemeModeProvider).material,
  themeAnimationDuration: context.themeFadeDuration, // 300 ms · 0 ถ้าลดการเคลื่อนไหว
  themeAnimationCurve: NightOutMotion.easeOut,
)

const NightOutThemeModeMenu(); // ปุ่มเลือก มืด / สว่าง / ตามเครื่อง ใส่ใน actions ของแถบบน

final colors = context.colors; // NightOutColors ของธีมที่ใช้อยู่
NightOutText.display(context.textTheme.headlineMedium, colors); // Playfair Display
NightOutTier.s.background; // สีป้ายระดับร้าน S/A/B/C
```

หัวข้อไล่สีทองใช้ `ShaderMask` จาก `colors.titleFrom` ไป `colors.titleTo` บน `NightOutText.display`

ไอคอนบนเว็บใช้ Phosphor บน Flutter ใช้แพ็กเกจ `phosphor_flutter` น้ำหนัก regular กับ fill ตามกติกาด้านบน
