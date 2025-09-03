import React from "react";
import { useNavigate } from "react-router-dom";

const PhoneApp = () => {
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
        <h1 className="app-title">Téléphone</h1>
      </div>
      
      <div className="app-content">
        <div className="coming-soon">
          <h2>📞 Appels & Contacts</h2>
          <p>Gestion des appels et contacts</p>
          <p>Intégration Bluetooth smartphone</p>
        </div>
      </div>
    </div>
  );
};

export default PhoneApp;