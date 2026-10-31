'use strict';

const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');

const PROJECT_ID = 'movix-294da';
const THEATERS = ['Kairali', 'Nila'];

function requiredEmail(name) {
  const value = process.env[name]?.trim().toLowerCase();
  if (!value || !value.includes('@')) {
    throw new Error(`Set ${name} to the email of an existing Firebase Auth account.`);
  }
  return value;
}

async function listAllUsers(auth) {
  const users = [];
  let pageToken;
  do {
    const page = await auth.listUsers(1000, pageToken);
    users.push(...page.users);
    pageToken = page.pageToken;
  } while (pageToken);
  return users;
}

async function main() {
  if (process.env.GOOGLE_CLOUD_PROJECT !== PROJECT_ID) {
    throw new Error(`Set GOOGLE_CLOUD_PROJECT=${PROJECT_ID} before running this tool.`);
  }

  const emailAssignments = [
    { email: requiredEmail('MOVIX_ADMIN_EMAIL'), role: 'admin' },
    { email: requiredEmail('MOVIX_KAIRALI_OWNER_EMAIL'), role: 'owner', theaterId: 'Kairali' },
    { email: requiredEmail('MOVIX_NILA_OWNER_EMAIL'), role: 'owner', theaterId: 'Nila' },
  ];
  if (new Set(emailAssignments.map((item) => item.email)).size !== 3) {
    throw new Error('Admin and both Owner accounts must use three different email addresses.');
  }
  const confirmReactivateProfiles =
    process.env.MOVIX_CONFIRM_REACTIVATE_PROFILES === 'true';

  initializeApp({
    credential: applicationDefault(),
    projectId: PROJECT_ID,
  });
  const auth = getAuth();
  const db = getFirestore();

  // Resolve only accounts already created in Firebase Console. This tool never
  // creates Auth users and never reads or changes passwords.
  for (const assignment of emailAssignments) {
    assignment.user = await auth.getUserByEmail(assignment.email);
    if (assignment.user.disabled) {
      throw new Error(`The configured account ${assignment.email} is disabled.`);
    }
  }
  const expectedUidForRole = new Map(emailAssignments.map((item) => [item.role === 'admin' ? 'admin' : item.theaterId, item.user.uid]));

  const currentUsers = await listAllUsers(auth);
  for (const user of currentUsers) {
    const claims = user.customClaims ?? {};
    if (claims.movixRole === 'admin' && user.uid !== expectedUidForRole.get('admin')) {
      throw new Error('A different account already has the Movix Admin claim. Resolve it before provisioning.');
    }
    if (claims.movixRole === 'owner' &&
        (!THEATERS.includes(claims.theaterId) ||
          user.uid !== expectedUidForRole.get(claims.theaterId))) {
      throw new Error('An account outside the configured two Owners already has an Owner claim. Resolve it before provisioning.');
    }
  }

  const ownerRefs = Object.fromEntries(
    THEATERS.map((theaterId) => [theaterId, db.collection('theaterOwners').doc(theaterId)]),
  );
  for (const theaterId of THEATERS) {
    const snapshot = await ownerRefs[theaterId].get();
    const expectedUid = expectedUidForRole.get(theaterId);
    if (snapshot.exists && snapshot.get('uid') !== expectedUid) {
      throw new Error(`The ${theaterId} theater is already assigned to a different account.`);
    }
  }

  const profileRefs = new Map(
    emailAssignments.map((item) => [item.user.uid, db.collection('users').doc(item.user.uid)]),
  );
  await db.runTransaction(async (transaction) => {
    const profileSnapshots = new Map();
    for (const assignment of emailAssignments) {
      profileSnapshots.set(
        assignment.user.uid,
        await transaction.get(profileRefs.get(assignment.user.uid)),
      );
    }
    for (const theaterId of THEATERS) {
      const snapshot = await transaction.get(ownerRefs[theaterId]);
      const expectedUid = expectedUidForRole.get(theaterId);
      if (snapshot.exists && snapshot.get('uid') !== expectedUid) {
        throw new Error(`The ${theaterId} theater was assigned to another account during setup.`);
      }
    }

    for (const assignment of emailAssignments) {
      const profile = profileSnapshots.get(assignment.user.uid).data();
      if (profile?.isActive === false && !confirmReactivateProfiles) {
        throw new Error(
          `The Firestore profile for ${assignment.email} has isActive=false. ` +
          'If Firebase Auth shows this account enabled and you intend to reactivate its Movix profile, set MOVIX_CONFIRM_REACTIVATE_PROFILES=true and rerun.',
        );
      }
    }

    for (const assignment of emailAssignments) {
      const profileSnapshot = profileSnapshots.get(assignment.user.uid);
      const currentProfile = profileSnapshot.data() ?? {};
      const email = assignment.user.email ?? assignment.email;
      transaction.set(profileRefs.get(assignment.user.uid), {
        role: assignment.role,
        email,
        displayName: assignment.user.displayName ?? currentProfile.displayName ?? email.split('@')[0],
        phoneNumber: assignment.user.phoneNumber ?? currentProfile.phoneNumber ?? '',
        assignedTheater: assignment.theaterId ?? null,
        // This is only true after the explicit confirmation check above when
        // the existing app-level profile flag was false. Disabled Firebase
        // Auth users are rejected before any writes take place.
        isActive: true,
        ...(profileSnapshot.exists ? {} : { createdAt: FieldValue.serverTimestamp() }),
      }, { merge: true });
    }
    for (const theaterId of THEATERS) {
      transaction.set(ownerRefs[theaterId], {
        uid: expectedUidForRole.get(theaterId),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  });

  // Claims are trusted; matching Firestore profile fields alone cannot grant
  // Admin or Owner access. Preserve unrelated custom claims.
  for (const assignment of emailAssignments) {
    const claims = { ...(assignment.user.customClaims ?? {}) };
    delete claims.theaterId;
    claims.movixRole = assignment.role;
    if (assignment.theaterId) claims.theaterId = assignment.theaterId;
    await auth.setCustomUserClaims(assignment.user.uid, claims);
    console.log(`Provisioned ${assignment.role}${assignment.theaterId ? ` for ${assignment.theaterId}` : ''}: ${assignment.email}`);
  }

  console.log('Movix privileged accounts are configured. Sign out and back in to refresh ID tokens.');
}

main().catch((error) => {
  console.error(`Privileged account provisioning failed: ${error.message}`);
  process.exitCode = 1;
});
