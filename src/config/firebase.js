import { initializeApp } from "firebase/app";
import { GoogleAuthProvider, getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
  apiKey: "AIzaSyB7UNdjnAJS1SxnFMjUGD1Vl9VR_59Wa-8",
  authDomain: "labooking-304c4.firebaseapp.com",
  projectId: "labooking-304c4",
  storageBucket: "labooking-304c4.firebasestorage.app",
  messagingSenderId: "893098163373",
  appId: "1:893098163373:web:ae3b44edb18d53df355a24",
  measurementId: "G-QGE8MZNNNK"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const storage = getStorage(app);
const auth = getAuth(app); // thêm dòng này
const googleProvider = new GoogleAuthProvider();

export { app, auth, storage, googleProvider };
