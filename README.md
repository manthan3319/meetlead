# MeetLead Pro — Complete SaaS Platform

> **Never forget a meeting. Never lose a lead.**
> Smart Meeting & Lead Management SaaS — Backend + Web + Mobile App.

This monorepo contains:

| Folder | Tech | Purpose |
|--------|------|---------|
| [`backend/`](./backend) | Node.js + Express + MongoDB | REST API, auth, Razorpay, reminders cron |
| [`web/`](./web) | Next.js 14 + Tailwind | Landing page, Admin panel, User checkout |
| [`mobile/`](./mobile) | Flutter | End-user mobile app (Android/iOS) |

---

## 🎨 Brand Colors

```
primary:   #008088   ← main brand
dark:      #005555
light:     #e6f7f7
teal700:   #0d9488
red:       #880808
black:     #000000
white:     #ffffff
textgrey:  #6b7280
fildbg:    #f5f8fa
```

These are wired into both Tailwind ([`web/tailwind.config.js`](./web/tailwind.config.js)) and Flutter ([`mobile/lib/config/theme.dart`](./mobile/lib/config/theme.dart)).

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────┐
│  WEB (Next.js)                               │
│  - Landing page  (/)                         │
│  - Signup/Login  (/signup, /login)           │
│  - User Dashboard (/dashboard/*)             │
│  - Razorpay Checkout (/checkout?plan=...)    │
│  - Admin Panel (/admin/*)                    │
└──────────────────────┬───────────────────────┘
                       │ REST + Socket.io
┌──────────────────────▼───────────────────────┐
│  BACKEND (Node.js + Express)                 │
│  - JWT Auth                                  │
│  - 14 Mongoose Models                        │
│  - Razorpay (keys from DB Settings)          │
│  - Cron jobs (reminders)                     │
│  - Socket.io (live notifications)            │
└──────────────────────┬───────────────────────┘
                       │
              ┌────────▼────────┐
              │   MongoDB       │
              └─────────────────┘
                       ▲
                       │ REST + Socket.io
┌──────────────────────┴───────────────────────┐
│  MOBILE (Flutter)                            │
│  - Login / Signup                            │
│  - Subscription gate (NO in-app payment)     │
│  - Dashboard, Leads, Meetings, Services      │
│  - Alarm-style reminders                     │
│  - Voice assistant (offline)                 │
│  - WhatsApp / Call deep-links                │
└──────────────────────────────────────────────┘
```

**Important design choices:**
- ❌ **No in-app payment** → payment only on web (`/checkout`)
- ❌ **No email sending** (per your requirement)
- ✅ **Razorpay keys managed from Admin → Settings** (not env vars)
- ✅ **All plans, settings, content** managed from Admin Panel
- ✅ **Subscription gate** on mobile: if no active sub, user is sent to website to pay

---

## 🚀 Quick Start

### 1. Prerequisites
- Node.js 18+ and npm
- MongoDB (local or Atlas)
- Flutter SDK 3.3+
- Android Studio / Xcode for mobile

### 2. Backend Setup

```bash
cd backend
cp .env.example .env
# edit .env — set MONGODB_URI and JWT_SECRET

npm install
npm run seed         # Creates admin, plans, settings, templates
npm run dev          # Runs on http://localhost:5050
```

**Default admin credentials** (from `.env`):
```
Email:    admin@meetlead.com
Password: Admin@123
```

### 3. Web Setup

```bash
cd web
cp .env.local.example .env.local
# default API URL is http://localhost:5050/api

npm install
npm run dev          # Runs on http://localhost:3000
```

Visit:
- Landing → http://localhost:3000
- Login → http://localhost:3000/login
- Admin panel (after login as admin) → http://localhost:3000/admin

### 4. Configure Razorpay (Admin)

1. Get Razorpay keys from https://dashboard.razorpay.com/app/keys
2. Login as admin in the web app
3. Go to **Admin → Settings**
4. Paste `razorpay_key_id` and `razorpay_key_secret`
5. Save

Now users can buy plans! Until you do this, the checkout will show "Payment gateway not configured."

### 5. Mobile Setup

```bash
cd mobile
flutter pub get
flutter run
```

By default, the app points to `http://10.0.2.2:5050/api` (Android emulator → host machine). For iOS simulator or physical devices, edit [`mobile/lib/config/constants.dart`](./mobile/lib/config/constants.dart).

---

## 📊 Default Plans (seeded)

| Plan | Duration | Price | Users | Leads |
|------|----------|-------|-------|-------|
| Free Trial | 7 days | ₹0 | 1 | 50 |
| Starter | 3 months | ₹999 | 1 | 500 |
| Professional ⭐ | 6 months | ₹2,499 | 3 | 2,000 |
| Business | 12 months | ₹4,999 | 10 | Unlimited |

Admin can create/edit/delete plans from **Admin → Plans**.

---

## 🔐 Admin Panel Features

| Section | What you can do |
|---------|-----------------|
| **Overview** | Total users, orgs, revenue, leads, meetings, charts |
| **Users** | List, search, disable/enable, change role |
| **Plans** | Full CRUD on subscription plans |
| **Subscriptions** | View all subs, filter by status |
| **Payments** | Full payment history with Razorpay IDs |
| **Analytics** | Revenue trends, growth charts |
| **Settings** | Razorpay keys, site name, support email, currency |

---

## 📱 Mobile App Features

| Screen | What's in it |
|--------|--------------|
| **Login/Signup** | Same credentials as web |
| **Subscription Gate** | If trial expired → opens website to buy |
| **Home** | Today's meetings, leads, follow-ups, stats |
| **Leads** | List, search, filter by status, WhatsApp, call |
| **Meetings** | Calendar view, schedule with auto-alarms |
| **Services** | Manage your service catalog |
| **Voice (FAB)** | Tap mic, speak commands |
| **Settings** | Profile, subscription, logout |

### Smart Reminders
For every meeting, the app automatically schedules:
- 🔔 1 hour before — notification
- 🔔 15 min before — notification
- ⏰ At meeting time — **alarm-style** (full-screen, sound, wake screen)

### Voice Assistant
Tap the mic button (center of bottom bar). Says "Yes, kya kaam hai?", then:
- "Schedule meeting with Manav on 13 May at 5pm" → parses
- "Add lead Priya, 9876543210" → parses
- "Today ki meetings" → shows
- Uses **device's native STT** — no API cost, works offline

---

## 🛣️ API Routes (Backend)

### Public
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/plans/public`
- `GET /api/settings/public`
- `GET /api/payments/config`

### User (requires JWT)
- `GET /api/auth/me`
- `PUT /api/auth/me`
- `GET /api/dashboard/summary`
- `GET /api/leads` · `POST /api/leads` · `PUT /api/leads/:id` · `DELETE /api/leads/:id`
- `GET /api/meetings` · `POST /api/meetings` · ...
- `GET /api/meetings/upcoming`
- `GET /api/services` · CRUD
- `GET /api/followups/today`
- `POST /api/payments/order` (creates Razorpay order)
- `POST /api/payments/verify` (verifies signature)
- `GET /api/subscriptions/current`
- `GET /api/reminders/pending`

### Admin (requires admin role)
- `GET /api/admin/stats`
- `GET /api/admin/users`
- `GET /api/admin/revenue-chart`
- `POST /api/plans` · `PUT /api/plans/:id`
- `GET /api/subscriptions/admin/all`
- `GET /api/payments/admin/all`
- `GET /api/settings`
- `PUT /api/settings/:key`
- `POST /api/settings/bulk`

---

## 🧩 Tech Stack Details

### Backend dependencies
- `express`, `mongoose`, `jsonwebtoken`, `bcryptjs`
- `razorpay` (official SDK)
- `socket.io` (live reminder push)
- `node-cron` (every-minute reminder dispatcher)
- `helmet`, `cors`, `morgan`, `express-rate-limit`

### Web dependencies
- `next` 14, `react` 18, `tailwindcss`
- `axios`, `js-cookie` (auth)
- `recharts` (charts), `lucide-react` (icons)
- `react-hot-toast` (notifications)

### Mobile dependencies
- `dio` (HTTP), `provider` (state)
- `awesome_notifications` (alarm-style reminders)
- `speech_to_text` + `flutter_tts` (voice)
- `url_launcher` (WhatsApp/Call)
- `table_calendar`, `fl_chart`
- `flutter_secure_storage`

---

## 🧪 Testing the Flow End-to-End

1. **Start backend**: `cd backend && npm run dev`
2. **Start web**: `cd web && npm run dev`
3. **Open** http://localhost:3000 → click "Start Free Trial"
4. **Sign up** as user. You're auto-given 7-day trial.
5. **Logout** → **Login as admin** (`admin@meetlead.com` / `Admin@123`)
6. Go to **Admin → Settings** → paste Razorpay TEST keys → Save
7. **Logout** → **Login as user** → **Dashboard → Plans** → Pick a plan → Pay
8. Use Razorpay test card: `4111 1111 1111 1111`, any future expiry, any CVV
9. Payment succeeds → subscription activated → mobile app login works!

---

## 📁 Project Structure

```
metting lead/
├── PROJECT_OVERVIEW.md       ← Detailed product spec
├── README.md                  ← This file
│
├── backend/
│   ├── src/
│   │   ├── config/db.js
│   │   ├── models/            (13 Mongoose models)
│   │   ├── controllers/       (auth, lead, meeting, payment, admin, settings, ...)
│   │   ├── routes/            (14 route files)
│   │   ├── middleware/        (auth, error, subscription)
│   │   ├── services/          (razorpay)
│   │   ├── jobs/              (reminder cron)
│   │   ├── utils/             (seed, token, asyncHandler)
│   │   └── server.js
│   ├── package.json
│   └── .env.example
│
├── web/
│   ├── app/
│   │   ├── page.tsx           ← Landing
│   │   ├── login/             ← Login
│   │   ├── signup/            ← Signup
│   │   ├── checkout/          ← Razorpay checkout
│   │   ├── dashboard/         ← User: dashboard, plans, billing, settings
│   │   └── admin/             ← Admin: overview, users, plans, subs, payments, settings
│   ├── components/            ← Navbar, Footer, Pricing, AppShell
│   ├── lib/api.ts             ← Axios + auth helpers
│   ├── styles/globals.css     ← Tailwind layers
│   ├── tailwind.config.js     ← Brand colors
│   └── package.json
│
└── mobile/
    ├── lib/
    │   ├── config/            ← theme, constants
    │   ├── models/            ← user, lead, meeting
    │   ├── services/          ← api, auth, lead, meeting, voice, notifications
    │   ├── providers/         ← auth state
    │   ├── screens/
    │   │   ├── auth/          ← login, signup, subscription-gate
    │   │   ├── dashboard/     ← main_shell, home
    │   │   ├── leads/         ← list + form
    │   │   ├── meetings/      ← calendar + form
    │   │   ├── services/
    │   │   └── settings/
    │   ├── widgets/           ← voice_button
    │   └── main.dart
    └── pubspec.yaml
```

---

## 🐛 Common Issues

**Q: "Razorpay keys not configured" error**
→ Login as admin → Settings → add Razorpay keys → save.

**Q: Mobile can't connect to backend**
→ Edit `mobile/lib/config/constants.dart`. Use:
- `http://10.0.2.2:5050/api` for Android emulator
- `http://localhost:5050/api` for iOS simulator
- `http://<your-machine-ip>:5000/api` for physical devices

**Q: Reminders not firing on Android**
→ The app requests notification permissions on first launch. Also enable "Allow exact alarms" in app settings (Android 12+).

**Q: MongoDB connection fails**
→ Make sure MongoDB is running locally, or update `MONGODB_URI` in `backend/.env` to an Atlas connection string.

---

## 📜 Next Steps (Phase 2)

- [ ] Follow-up automation screen in mobile
- [ ] Team/staff invite & role management UI
- [ ] WhatsApp Business API integration (optional, paid)
- [ ] Pre-meeting brief AI screen
- [ ] Call log auto-import (Android)
- [ ] Web admin: detailed user analytics page
- [ ] Export reports (PDF/CSV)
- [ ] Push notifications via FCM
- [ ] White-label option for agencies

---

## 📄 License

Proprietary — © MeetLead Pro 2026
