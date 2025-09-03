import React from "react";
import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import CarPlayHome from "./components/CarPlayHome";
import MapsApp from "./components/MapsApp";
import MusicApp from "./components/MusicApp";
import PhoneApp from "./components/PhoneApp";
import MessagesApp from "./components/MessagesApp";
import SettingsApp from "./components/SettingsApp";

function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<CarPlayHome />} />
          <Route path="/maps" element={<MapsApp />} />
          <Route path="/music" element={<MusicApp />} />
          <Route path="/phone" element={<PhoneApp />} />
          <Route path="/messages" element={<MessagesApp />} />
          <Route path="/settings" element={<SettingsApp />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;