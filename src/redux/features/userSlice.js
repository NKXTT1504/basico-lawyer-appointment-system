import { createSlice } from "@reduxjs/toolkit";

const userSlice = createSlice({
    name: "user",
    initialState: null,
    reducers: {
        login: (state, actions) => {
            state = actions.payload; 
            return state;
        },

        logout: () => {
            return null;
        },

        updateUser: (state, action) => {
            if (state) {
                return {
                    ...state,
                    ...action.payload,
              };
            }
            return state;
        }
    }
});

export const { login, logout, updateUser } = userSlice.actions;
export default userSlice.reducer;