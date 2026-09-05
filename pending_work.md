# sq_appt_app_2 — Pending Work (live, crash-safe)

> Updated incrementally during the session, right after each change lands — not just at
> session end. This is the file to trust if a session gets cut off mid-work; `DEVLOG.md` is
> the polished write-up folded in from this file when the session ends cleanly (create it if it
> doesn't exist yet). See `D:\Claude\CLAUDE.md`'s Session SOP.

---

## Fixed, not yet committed (as of 2026-09-05 — Data Capture bookings missing from Home's Queue Status card)

> Reported: "current day service booking does not appear in App Queue Status Card." Investigated
> as a CareConnect/node_app_server bug first (see that repo's own `pending_work.md` for the
> discarded false lead); the user corrected the root cause and it turned out to live here.

- **Root cause**: `home_dashboard.dart`'s `_activeQueueBooking` decided "is this booking today's
  active queue" by comparing `booking.bookingDate` (this table's `booking_date` column) against
  today. Per the user: `booking_date` is when the booking was originally *made* (whatever the
  client happened to send at `/create-booking`), not the actual appointment date — `appt_time` is
  the real, CareConnect-confirmed appointment date, already populated correctly at confirm time
  by `node_app_server`'s `applyCareConnectOutcome` for every CareConnect-routed booking regardless
  of type. `form_page.dart` (the Data Capture flow — CareConnect's Service Industry hallmark, no
  date/time collected at all) never sends `booking_date`, so it stayed permanently null there —
  meaning a Data Capture booking's queue card could never trigger, CareConnect outcome
  notwithstanding, even though its `appt_time` was set correctly all along.
- **Fix**: `_activeQueueBooking` now parses and compares `booking.apptTime` (`DateTime.tryParse
  (booking.apptTime.toString())`, same idiom `my_booking.dart` already uses for this field)
  instead of `bookingDate`. Only ever evaluated once `handledBy == "CARECONNECT"` is already true
  (checked in the same condition), by which point `appt_time` is guaranteed set.
- **`dart analyze lib/view/home/home_dashboard.dart` clean** (only 4 pre-existing info-level
  lints, unrelated to this change).
- **Not committed.** This repo is a live-published app (Play Store/App Store) — per the
  established pattern for this project, needs the user's explicit go-ahead before commit/build/
  republish, not just a normal push (see the 2026-08-19/2026-08-01 precedent in `SQ_CareConnect`'s
  own `DEVLOG.md`, this exact repo/branch).
- **Requires an actual app rebuild + store release to reach real users** — unlike the
  backend-only fixes elsewhere this session, this is client-side Dart code; no server-side change
  can retroactively apply it to already-installed app instances.
- **Not live-verified on a device.**
