import React from "react";
import { useNavigate } from "react-router-dom";

const MapsApp = () => {
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
        <h1 className="app-title">Plans</h1>
      </div>
      
      <div className="app-content">
        <div className="coming-soon">
          <h2>🗺️ Navigation GPS</h2>
          <p>Interface de navigation avec cartes intégrées</p>
          <p>Intégration Google Maps / Apple Maps</p>
        </div>
      </div>
    </div>
  );
};

export default MapsApp;