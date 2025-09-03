import React from "react";
import { useNavigate } from "react-router-dom";

const SettingsApp = () => {
  const navigate = useNavigate();

  return (
    <div className="app-container">
      <div className="app-header">
        <button 
          className="back-button"
          onClick={() => navigate("/")}
        >
          ← Retour
        </button>
        <h1 className="app-title">Réglages</h1>
      </div>
      
      <div className="app-content">
        <div className="coming-soon">
          <h2>⚙️ Paramètres</h2>
          <p>Configuration du système CarPlay</p>
          <p>Thèmes, connexions, préférences</p>
        </div>
      </div>
    </div>
  );
};

export default SettingsApp;