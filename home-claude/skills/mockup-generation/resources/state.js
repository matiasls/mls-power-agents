// state.js — Estado del prototipo persistido en localStorage (modo interactivo)
// Template para mocks/prototype/state.js. Adaptar las operaciones de dominio al proyecto.
// IMPORTANTE: esto es prototipo. La lógica real la implementa el Backend Developer.

const STORAGE_KEY = 'prototype_state_v1';

function loadState() {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (!raw) return getSeedState();
  try {
    return JSON.parse(raw);
  } catch {
    return getSeedState();
  }
}

function saveState(state) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function getSeedState() {
  // Lee desde seed-data.js
  return window.SEED_DATA || { items: [], users: [] };
}

function resetPrototype() {
  localStorage.removeItem(STORAGE_KEY);
  location.reload();
}

// API simple para usar desde las pantallas
window.proto = {
  load: loadState,
  save: saveState,
  reset: resetPrototype,

  // Ejemplos de operaciones de dominio
  addItem(item) {
    const state = loadState();
    state.items.push({ ...item, id: crypto.randomUUID(), createdAt: new Date().toISOString() });
    saveState(state);
    return state;
  },

  removeItem(id) {
    const state = loadState();
    state.items = state.items.filter(i => i.id !== id);
    saveState(state);
    return state;
  },
};
