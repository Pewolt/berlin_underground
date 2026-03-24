# **🚇 Berlin Underground \- Subway Simulator**

**Berlin Underground** ist eine in Flutter entwickelte, web-basierte Geodaten-Simulation und ein Strategie-Spiel, das auf dem realen U-Bahn-Netz der Berliner Verkehrsbetriebe (BVG) basiert.

Das Projekt kombiniert spielerische Elemente (Progression, In-Game Economy) mit echten Geoinformatik-Konzepten wie topologischem Pathfinding, dynamischen Graphen-Gewichten und Vektorkarten-Rendering.

## **🎮 Das Spielprinzip**

Der Spieler schlüpft in die Rolle eines U-Bahn-Fahrers. Das Ziel ist es, in vorgegebener Zeit von einem Startbahnhof zu einem Zielbahnhof zu navigieren. Dabei muss der Spieler das Liniennetz analysieren, intelligente Umstiege planen und – im späteren Spielverlauf – dynamisch auf Netzstörungen reagieren.

### **Kern-Features**

* **Dynamische Vektorkarte:** Das Berliner U-Bahn-Netz wird live auf einer interaktiven CartoDB-Vektorkarte gerendert.  
* **Smartes Pathfinding:** Die In-Game-Vorgabezeiten werden nicht hartcodiert, sondern durch einen integrierten Dijkstra-Algorithmus berechnet, der das aktuelle Level und verfügbare Linien des Spielers berücksichtigt.  
* **Responsive UI:** Die Oberfläche passt sich nahtlos an Desktop-Browser und mobile Endgeräte an (inklusive adaptiver Dialoge und Menüs).  
* **DAISY-Anzeiger:** Ein authentischer, animierter LED-Lauftext im HUD warnt den Spieler in Echtzeit vor Streckensperrungen.  
* **In-Game Economy:** Spieler verdienen durch erfolgreiche Schichten "BVG-Token", mit denen sie im Betriebshof neue Züge (Skins) wie die historische DDR-Baureihe GI kaufen und ausrüsten können.

## **🚦 Spielmodi**

Das Spiel bietet verschiedene Modi, um sowohl Gelegenheitsspieler als auch Strategen anzusprechen:

1. **Die Kampagne (Schichtplan):**  
   Ein progressiver Modus, der den Spieler Schritt für Schritt in das Netz einführt. Linien werden logisch und topologisch korrekt freigeschaltet (eine neue Linie kreuzt immer das bereits bekannte Netz). Spieler müssen Sterne sammeln (basierend auf ihrer Fahrzeit), um im Level aufzusteigen.  
2. **Entspannte Schicht (Endlos-Modus):**  
   Zufallsgenerierte Routen durch das gesamte freigeschaltete Netz. Keine Störungen, ideal zum Grinden von Token und zum Kennenlernen der Berliner Topologie.  
3. **Berufsverkehr (Realismus-Modus):**  
   Der Hardcore-Modus. Das Backend generiert zufällige Streckensperrungen (z.B. Notarzteinsätze, Baustellen). Diese Sperrungen werden visuell auf der Karte markiert. Der Dijkstra-Algorithmus kalkuliert die optimale Zeit anhand von Umleitungen. Der Spieler muss das blockierte Kanten-Netzwerk im Kopf umplanen, um nicht in Sackgassen zu stranden.

## **🏗️ Software-Architektur & Code-Struktur**

Das Projekt folgt einer sauberen Trennung von UI, State Management und Business Logik.

### **1\. State Management (Riverpod)**

Die App nutzt **Riverpod** als reaktiven State-Manager.

* progress\_provider.dart: Verwaltet persistente Daten wie Spieler-Level, Sterne, gekaufte Skins und Token. Er berechnet Delta-Updates (z.B. Level-Ups) am Ende einer Schicht.  
* game\_provider.dart: Die zentrale "Game Engine". Hier läuft die State-Machine (Idle \-\> Briefing \-\> Moving \-\> Decision \-\> GameOver). Er kontrolliert die Bewegung des Zuges und das Auto-Continue-Feature an Bahnhöfen.

### **2\. Geoinformatik & Routing (Core Engine)**

Das Herzstück der App liegt im core/math/subway\_graph.dart.

* Das Netz ist als ungerichteter, gewichteter Graph modelliert. Stationen sind Knoten (Nodes), Verbindungen sind Kanten (Edges). Das Gewicht einer Kante ist die Fahrzeit in Minuten.  
* Der modifizierte **Dijkstra-Algorithmus** nimmt nicht nur Start und Ziel entgegen, sondern auch zwei Filter:  
  1. allowedLines: Der Algorithmus ignoriert Kanten, die der Spieler noch nicht freigeschaltet hat (Level-Cap).  
  2. disruptions: Im Realismus-Modus ignoriert der Algorithmus temporär gesperrte Kanten, um realistische Ausweich-Routen (Benchmarks) zu berechnen.

### **3\. Rendering & Map-Performance (Flutter Map)**

Da die App für das Web via CanvasKit (WebGL) kompiliert wird, lag der Fokus stark auf Performance-Optimierung:

* **Statische Layer:** Das Liniennetz (\_StaticNetworkLayer) und die Stationen (\_StaticStationLayer) sind als const Widgets ausgelagert. Sie werden beim Rendern des 60-FPS fahrenden Zuges vom Flutter-Engine-Rebuild komplett ignoriert. Das senkt den Rechenaufwand drastisch.  
* **Tween-Animationen:** Die Kamera-Fahrten und Zug-Bewegungen nutzen mathematische Interpolationen (CurvedAnimation / Sinus-Kurven) zwischen Geokoordinaten (LatLng), um "Spatial Disorientation" beim Spieler zu vermeiden.  
* **Bounding Boxes:** Die Karte ist auf die Koordinaten von Berlin limitiert, um ein Verlaufen im GIS-Raum zu verhindern.

### **4\. Dynamische UI-Komponenten**

* **HUD & Responsive Grid:** Das Overlay reagiert auf Bildschirmgrößen. Das Umsteigemenü verschiebt sich auf Smartphones in den Daumen-Bereich.  
* **Fast-Forward:** Ein onTapDown/onTapUp Listener erlaubt es, den AnimationController on-the-fly zu beschleunigen, um Fahrzeiten zu überspringen, ohne die Game-Loop-Logik zu brechen.

*Gebaut mit Flutter Web | Entwickelt für Geoinformatik & UX-Design*