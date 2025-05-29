// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
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
const analytics = getAnalytics(app);