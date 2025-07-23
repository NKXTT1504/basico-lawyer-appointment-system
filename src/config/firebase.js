import { initializeApp } from "firebase/app";
import { GoogleAuthProvider, getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
  apiKey: "AIzaSyBFskytdtI1_tZPl7yq9xQzeVjXlaQXYuk",
  authDomain: "hairsalon-11f3e.firebaseapp.com",
  projectId: "hairsalon-11f3e",
  storageBucket: "hairsalon-11f3e.appspot.com",
  messagingSenderId: "1090704917144",
  appId: "1:1090704917144:web:d20d6d500aace155d786ed",
  measurementId: "G-R0ZG2S9FE4"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const storage = getStorage(app);
const auth = getAuth(app); // thêm dòng này
const googleProvider = new GoogleAuthProvider();

export { app, auth, storage, googleProvider };
