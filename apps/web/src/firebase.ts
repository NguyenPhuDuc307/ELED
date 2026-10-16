import { initializeApp } from "firebase/app";
import {
  getAuth,
  GoogleAuthProvider,
  onAuthStateChanged,
  signInWithPopup,
  signOut,
  type User,
} from "firebase/auth";
const app = initializeApp({
  projectId: "eled-aaf5c",
  appId: "1:775823694514:web:b909bc50e573eaf94e47ab",
  storageBucket: "eled-aaf5c.firebasestorage.app",
  apiKey: "AIzaSyBy88G5O2Mmd_pwDvLuI_7nA0fpu8pqWAs",
  authDomain: "eled-aaf5c.firebaseapp.com",
  messagingSenderId: "775823694514",
  measurementId: "G-WERN4RBS4L",
});
const auth = getAuth(app);
export function observe(fn: (user: User | null) => void) {
  return onAuthStateChanged(auth, fn);
}
export async function login() {
  return signInWithPopup(auth, new GoogleAuthProvider());
}
export async function logout() {
  return signOut(auth);
}
export async function readLegacy(uid: string) {
  const { getFirestore, doc, getDoc, getDocs, collection } = await import(
    "firebase/firestore"
  );
  const db = getFirestore(app);
  const [profile, collections] = await Promise.all([
    getDoc(doc(db, "users", uid)),
    getDocs(collection(db, "users", uid, "collections")),
  ]);
  return {
    ...profile.data(),
    collections: Object.fromEntries(
      collections.docs.map((d) => [d.id, d.data().words as string[]]),
    ),
  } as {
    knownWords?: string[];
    settings?: any;
    collections: Record<string, string[]>;
  };
}
