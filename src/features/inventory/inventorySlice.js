import { createSlice } from "@reduxjs/toolkit";

const initialState = {
  products: [
    { id: 1, name: "Chaise", quantity: 5, price: 50 },
    { id: 2, name: "Table", quantity: 3, price: 150 },
  ],
};

const inventorySlice = createSlice({
  name: "inventory",
  initialState,
  reducers: {
    addProduct: (state, action) => {
      state.products.push(action.payload);
    },
    deleteProduct: (state, action) => {
      const id = action.payload.id;
      state.products = state.products.filter((p) => p.id !== id);
    },
    updateProduct: (state, action) => {
      const updated = action.payload;
      const idx = state.products.findIndex((p) => p.id === updated.id);
      if (idx !== -1) state.products[idx] = { ...state.products[idx], ...updated };
    },
  },
});

export const { addProduct, deleteProduct, updateProduct } = inventorySlice.actions;
export const selectInventoryProducts = (state) => state.inventory.products;
export default inventorySlice.reducer;
