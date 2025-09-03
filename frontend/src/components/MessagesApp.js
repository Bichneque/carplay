import React from "react";
import { useNavigate } from "react-router-dom";

const MessagesApp = () => {
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
        <h1 className="app-title">Messages</h1>
      </div>
      
      <div className="app-content">
        <div className="coming-soon">
          <h2>💬 Messages</h2>
          <p>Lecture et réponse aux messages</p>
          <p>Dictée vocale et réponses rapides</p>
        </div>
      </div>
    </div>
  );
};

export default MessagesApp;