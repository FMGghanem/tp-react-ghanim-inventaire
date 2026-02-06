import { createSlice } from "@reduxjs/toolkit";

const initialState = {
  items: [
    { id: 1, title: "PC Portable Lenovo i5", price: 2499, category: "PC", stock: 7, description: "Portable polyvalent pour travail et Ã©tudes.", image: "https://via.placeholder.com/420x260?text=PC+Lenovo" },
    { id: 2, title: "TÃ©lÃ©phone Samsung A54", price: 1299, category: "TÃ©lÃ©phone", stock: 12, description: "Bon appareil photo + autonomie.", image: "https://via.placeholder.com/420x260?text=Samsung+A54" },
    { id: 3, title: "iPhone 13 (reconditionnÃ©)", price: 1899, category: "TÃ©lÃ©phone", stock: 4, description: "ReconditionnÃ©, garanti, trÃ¨s bon Ã©tat.", image: "https://via.placeholder.com/420x260?text=iPhone+13" },
    { id: 4, title: "Casque Bluetooth JBL", price: 199, category: "Accessoires", stock: 20, description: "Son clair, confortable.", image: "https://via.placeholder.com/420x260?text=Casque+JBL" },
    { id: 5, title: "Souris Logitech MX", price: 169, category: "Accessoires", stock: 15, description: "PrÃ©cision + ergonomie.", image: "https://via.placeholder.com/420x260?text=Souris+Logitech" },
    { id: 6, title: "Ã‰cran 27 pouces IPS", price: 699, category: "PC", stock: 6, description: "Confort visuel, parfait pour dev.", image: "https://via.placeholder.com/420x260?text=Ecran+27" },
  ],
};

const productsSlice = createSlice({
  name: "products",
  initialState,
  reducers: {
    adminAddProduct: (state, action) => {
      state.items.unshift(action.payload);
    },
    adminDeleteProduct: (state, action) => {
      const id = action.payload;
      state.items = state.items.filter((p) => p.id !== id);
    },
    adminUpdateProduct: (state, action) => {
      const updated = action.payload;
      const idx = state.items.findIndex((p) => p.id === updated.id);
      if (idx !== -1) state.items[idx] = { ...state.items[idx], ...updated };
    },
    adminAdjustStock: (state, action) => {
      const { id, delta } = action.payload;
      const p = state.items.find((x) => x.id === id);
      if (!p) return;
      p.stock = Math.max(0, Number(p.stock) + Number(delta));
    },
  },
});

export const {
  adminAddProduct,
  adminDeleteProduct,
  adminUpdateProduct,
  adminAdjustStock,
} = productsSlice.actions;

export const selectAllProducts = (state) => state.products.items;
export const selectProductById = (state, id) =>
  state.products.items.find((p) => String(p.id) === String(id));

export default productsSlice.reducer;