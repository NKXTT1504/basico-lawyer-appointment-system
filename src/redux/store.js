import storage from "redux-persist/lib/storage";
import { persistStore, persistReducer } from 'redux-persist'
import { rootReducer } from "./rootReducer";
import { configureStore } from "@reduxjs/toolkit";


const persistConfig = {
    key: 'root',
    storage,

}
const persistedReducer = persistReducer(persistConfig, rootReducer)


export const store = configureStore({
    reducer: persistedReducer,
    middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware({
          serializableCheck: {
            // Ignore specific paths or actions that contain non-serializable values
            ignoredActions: ['persist/PERSIST', 'persist/REHYDRATE'],
            ignoredPaths: ['register', 'rehydrate'], // or any path in state/actions that might hold functions or non-serializable data
          },
        }),
});
export const persistor = persistStore(store);