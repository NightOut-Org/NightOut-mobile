# AGENTS.md — แอปลูกค้า (`apps/client`)

อ่าน `../../AGENTS.md` ก่อน · ไฟล์นี้เพิ่มกติกาเฉพาะแอปลูกค้า

## เทียบกับเว็บ
- แอปนี้คือ `apps/frontend` ของเว็บ **ส่วนลูกค้า** (SITEMAP ข้อ 2) · หน้าร้าน `/merchant` ไม่อยู่ในแอปนี้
- โครงหน้าและ navigation ตาม SITEMAP ข้อ 2 และข้อ 5 (Bottom nav มือถือ: เมนูที่แอดมินจัดจาก `GET /public/site-nav` · "โปรไฟล์" อยู่ท้ายสุดเสมอ)
- flow หลักตาม SITEMAP ข้อ 6

## Auth
- มีแค่ email + password และ Google / Facebook (Supabase OAuth) · **ห้ามเพิ่ม OTP หรือ provider อื่น**
- redirect กลับแอปด้วย `Env.authRedirectUrl` (`nightout://auth-callback`) ทุกครั้งที่เรียก `signInWithOAuth` และ `resetPasswordForEmail`

## กฎธุรกิจที่ห้ามพลาด
- จองได้**เฉพาะโต๊ะ** + เลือกโปรของร้านได้ 1 อย่าง · ไม่มีสั่งอาหาร/เครื่องดื่มล่วงหน้า · เมนูแสดงไว้ประเมินงบเท่านั้น
- เงินที่จ่ายผ่านแอปเรียกว่า **"ค่าธรรมเนียมจองโต๊ะ (Table Fee)"** เท่านั้น
- ห้ามคำว่า "ขายเหล้า/เบียร์" · โปรโมชันห้ามลด/แถมแอลกอฮอล์
- ป้ายความปลอดภัย: **"ข้อมูลอ้างอิงจากร้านค้า (Merchant Declared)"** + วันที่ตรวจล่าสุด · ห้ามใช้ "Safety Verified" / "ยืนยันโดย NightOut"
- Checkout ต้องกรอกเบอร์โทร + ติ๊กยอมรับเงื่อนไขริบมัดจำ (ข้อความดึงจาก backend · มีเวอร์ชัน)
- QR เช็กอิน = `NIGHTOUT:<booking id>`
- สถานะคนในร้านแสดงทั้งจุดสีและคำ (ว่าง / ใกล้เต็ม / เต็ม) · สีจาก `crowdAvailable` / `crowdAlmostFull` / `crowdFull`
- ระดับร้านแสดงเป็นดาว 1–5 สี `goldText` (สีป้าย S/A/B/C เป็นของ Backoffice)
- แผนที่: `maplibre_gl` + OpenFreeMap · ห้ามใช้ Google Maps API
- **ห้ามทำ flow โอนเงิน + แนบสลิป** — มัดจำจะเปลี่ยนเป็น Beam Payment (Escrow) ให้รอ API

## ยังไม่ทำ
แจ้งเตือน 15 นาทีก่อนเวลา, ขอต่อเวลา, ปลดโต๊ะเมื่อสาย, Party Set, push notification — ดูสถานะล่าสุดใน REQUIREMENTS ของเว็บและถามก่อนเริ่ม
