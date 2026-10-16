# AGENTS.md — แอป Backoffice (`apps/admin`)

อ่าน `../../AGENTS.md` ก่อน · ไฟล์นี้เพิ่มกติกาเฉพาะแอป Backoffice

## เทียบกับเว็บ
- แอปนี้คือ `apps/admin` ของเว็บ (Backoffice ของทีม NightOut · `admin.nightout.app`) · **ไม่ใช่** หน้าร้าน `/merchant`
- หน้าและสิ่งที่แต่ละหน้าทำ ตาม SITEMAP ข้อ 4 · กลุ่มเมนูตาม `apps/admin/src/configs/menu.tsx` ของเว็บ
- ข้อมูล ตัวกรอง ปุ่ม และเงื่อนไขของแต่ละ action ต้องเท่ากับเว็บ
- เว็บเป็นตาราง ProTable + Drawer สำหรับจอใหญ่ · **ยังไม่ได้ตกลงว่าบนมือถือจะแสดงแบบไหน** และจะทำหน้าไหนก่อน ให้ถามเจ้าของงานก่อนเริ่มหน้าแรก

## Auth
- ผู้ใช้คือทีม NightOut บทบาท ADMIN / SUPER_ADMIN เท่านั้น · ไม่มีสมัครสมาชิก · ไม่มี Google / Facebook
- ล็อกอินด้วย email + password แล้วยืนยัน **TOTP MFA (รหัส 6 หลัก · aal2)** ก่อนเข้าแอป
- อ่าน role จาก `GET /me/profile` ตอนล็อกอิน (ก่อน MFA) · บัญชีที่ไม่ใช่แอดมินห้ามเข้า
- ทุก endpoint `/admin/*` ผ่าน `AdminGuard` (ADMIN + aal2) · ได้ 401 = ให้ยืนยันรหัส 6 หลักใหม่ ไม่ใช่ล็อกเอาต์ทันที

## ข้อมูล
- อ่านผ่าน endpoint ของ Backoffice (ADR 0003 ของเว็บ): `GET /admin/dashboard`, `GET /admin/views/:view` (เฉพาะ view ใน whitelist), `GET /admin/master/:table` · สลิป/หลักฐานขอ URL ผ่าน `POST /storage/signed-urls`
- action ที่เว็บบังคับเหตุผล (แบน, ระงับร้าน, ตีกลับ, Blacklist ฯลฯ) ต้องบังคับเหมือนกันและใช้ข้อจำกัดเดียวกัน · ทุก action ลง audit log ที่ backend
- สิทธิ์ Admin กับ Super Admin ต่างกันบางหน้า (ทีมงาน, Audit Log, ค่าคอม) · ทำตาม SITEMAP ข้อ 4 ของหน้านั้น

## คำและการแสดงผล
- สถานะ `NO_SHOW` แสดงเป็น **"ปลดโต๊ะ (Forfeited)"**
- เงินที่ลูกค้าจ่ายเรียกว่า **"ค่าธรรมเนียมจองโต๊ะ (Table Fee)"** · ป้ายความปลอดภัยใช้ "ข้อมูลอ้างอิงจากร้านค้า (Merchant Declared)" เหมือนฝั่งลูกค้า
- ป้ายระดับร้าน S/A/B/C ใช้ `NightOutTier` ของ `nightout_core`
- ร้านแสดงสถานะคนในร้านด้วยจุดสีและคำเสมอ

## ยังไม่ทำ
หน้าเงินมัดจำ / การชำระเงิน (`/deposits`, `/payments`) — ระบบชำระกำลังเปลี่ยนเป็น Beam Payment ให้ถามก่อนเริ่ม · `/billing` ปิดไว้ถึง Phase 2
