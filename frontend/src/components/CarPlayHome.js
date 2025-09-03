import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";

const CarPlayHome = () => {
  const [currentTime, setCurrentTime] = useState(new Date());
  const [batteryLevel, setBatteryLevel] = useState(85);

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  const formatTime = (date) => {
    return date.toLocaleTimeString('fr-FR', { 
      hour: '2-digit', 
      minute: '2-digit',
      hour12: false 
    });
  };

  const apps = [
    {
      name: "Plans",
      path: "/maps",
      icon: "🗺️",
      className: "maps-icon"
    },
    {
      name: "Musique",
      path: "/music", 
      icon: "🎵",
      className: "music-icon"
    },
    {
      name: "Téléphone",
      path: "/phone",
      icon: "📞",
      className: "phone-icon"
    },
    {
      name: "Messages",
      path: "/messages",
      icon: "💬", 
      className: "messages-icon"
    },
    {
      name: "Réglages",
      path: "/settings",
      icon: "⚙️",
      className: "settings-icon"
    }
  ];

  return (
    <div className="carplay-container">
      {/* Status Bar */}
      <div className="status-bar">
        <div className="status-left">
          <div className="time">{formatTime(currentTime)}</div>
        </div>
        <div className="status-right">
          <div className="signal-strength">
            <div className="signal-bars">
              <div className="signal-bar"></div>
              <div className="signal-bar"></div>
              <div className="signal-bar"></div>
              <div className="signal-bar"></div>
            </div>
          </div>
          <div className="battery">
            <div className="battery-indicator">
              <div 
                className="battery-fill" 
                style={{ width: `${batteryLevel}%` }}
              ></div>
              <div className="battery-tip"></div>
            </div>
            <span>{batteryLevel}%</span>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="main-content">
        <div className="app-grid">
          {apps.map((app, index) => (
            <Link 
              key={index}
              to={app.path} 
              className="app-icon"
              style={{ animationDelay: `${index * 0.1}s` }}
            >
              <div className={`app-icon-image ${app.className}`}>
                {app.icon}
              </div>
              <span className="app-name">{app.name}</span>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
};

export default CarPlayHome;