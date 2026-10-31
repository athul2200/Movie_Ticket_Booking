# Movix privileged account setup

This one-time Admin SDK tool assigns trusted custom claims to accounts that
already exist in Firebase Authentication. It never creates accounts or sets
passwords. It uses Google Application Default Credentials; do not put a service
account key in this repository or in the Flutter app.

## Provision the three accounts

1. Create the Admin and two Owner email/password accounts in Firebase Console.
2. Authenticate `gcloud` as an operator with Firebase Authentication Admin and
   Firestore write permissions for project `movix-294da`:

   ```powershell
   gcloud auth application-default login
   ```

3. From this directory, install the tool and set the three existing account
   emails. The Owner mapping uses the app's existing theater keys `Kairali` and
   `Nila`.

   ```powershell
   npm install
   $env:GOOGLE_CLOUD_PROJECT = 'movix-294da'
   $env:MOVIX_ADMIN_EMAIL = 'admin@example.com'
   $env:MOVIX_KAIRALI_OWNER_EMAIL = 'owner-one@example.com'
   $env:MOVIX_NILA_OWNER_EMAIL = 'owner-two@example.com'
   npm run provision
   ```

The tool fails if an account is missing, if the three emails are not distinct,
or if another account already holds one of the privileged assignments. It
updates `/users/{uid}`, `/theaterOwners/Kairali`, and `/theaterOwners/Nila` with
the Admin SDK, then sets the corresponding `movixRole` and `theaterId` claims.
Sign out and back in after provisioning so Firebase Auth refreshes the claims.

If it reports that an existing `/users/{uid}` profile has `isActive: false`,
the profile itself is inactive even if the Firebase Auth record is enabled.
After confirming in Firebase Console that the account is enabled and that you
intend to reactivate its Movix profile, explicitly confirm that change before
rerunning:

```powershell
$env:MOVIX_CONFIRM_REACTIVATE_PROFILES = 'true'
npm run provision
```

The tool still refuses disabled Firebase Auth accounts. Do not set this flag
for an account whose Movix profile should remain inactive.

## Deploy Firestore rules

From the repository root, install/login to the Firebase CLI if needed, then
deploy the checked-in rules:

```powershell
firebase login
firebase deploy --project movix-294da --only firestore:rules
```

The current Owner module stores its movie, schedule, screen, and seat data in
local `SharedPreferences`; it does not write those records to Firestore. The
`/theaters/{theaterId}` rules protect Firestore theater records if/when the app
stores them there, but server-side isolation of today's local data requires
migrating those owner operations to a Firestore-backed repository.
