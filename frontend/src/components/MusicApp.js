import React from "react";
import { useNavigate } from "react-router-dom";

const MusicApp = () => {
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
        <h1 className="app-title">Musique</h1>
      </div>
      
      <div className="app-content">
        <div className="coming-soon">
          <h2>🎵 Lecteur Audio</h2>
          <p>Contrôles de lecture musicale</p>
          <p>Intégration Spotify, Apple Music, Radio</p>
        </div>
      </div>
    </div>
  );
};

export default MusicApp;