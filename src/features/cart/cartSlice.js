import { createSlice } from "@reduxjs/toolkit";

const initialState = {
  items: [], // {id,title,price,quantity}
};

const cartSlice = createSlice({
  name: "cart",
  initialState,
  reducers: {
    addToCart: (state, action) => {
      const p = action.payload;
      const existing = state.items.find((i) => i.id === p.id);
      if (existing) existing.quantity += 1;
      else state.items.push({ id: p.id, title: p.title, price: p.price, quantity: 1 });
    },
    decreaseQty: (state, action) => {
      const id = action.payload;
      const existing = state.items.find((i) => i.id === id);
      if (!existing) return;
      if (existing.quantity > 1) existing.quantity -= 1;
      else state.items = state.items.filter((i) => i.id !== id);
    },
    removeFromCart: (state, action) => {
      const id = action.payload;
      state.items = state.items.filter((i) => i.id !== id);
    },
    clearCart: (state) => {
      state.items = [];
    },
  },
});

export const { addToCart, decreaseQty, removeFromCart, clearCart } = cartSlice.actions;

export const selectCartItems = (state) => state.cart.items;
export const selectCartCount = (state) => state.cart.items.reduce((sum, i) => sum + i.quantity, 0);
export const selectCartTotal = (state) => state.cart.items.reduce((sum, i) => sum + i.price * i.quantity, 0);

export default cartSlice.reducer;