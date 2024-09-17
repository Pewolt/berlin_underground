import geopandas as gpd
import networkx as nx
import pandas as pd

# GeoDataFrame aus der GeoJSON-Datei laden
gdf = gpd.read_file('underground.geojson')

# Graphen initialisieren
G = nx.Graph()

# Kanten in den Graphen importieren
for index, row in gdf.iterrows():
    u = row['fromStation']
    v = row['toStation']
    line = row['line']
    km = row['km']
    time = row['time']
    
    if G.has_edge(u, v):
        # Linie zur bestehenden Menge hinzufügen
        G[u][v]['line'].add(line)
    else:
        # Neue Kante erstellen und Linie als Menge initialisieren
        G.add_edge(u, v, line={line}, km=km, time=time)

# Funktion zur Zählung der Umstiege (Linienwechsel)
def count_line_changes(path):
    line_changes = 0
    previous_lines = None

    for i in range(len(path) - 1):
        u, v = path[i], path[i + 1]
        current_lines = G[u][v]['line']

        if previous_lines is not None:
            # Prüfen, ob es eine gemeinsame Linie gibt
            if previous_lines.isdisjoint(current_lines):
                line_changes += 1  # Linienwechsel notwendig
            # Wenn nicht, bleibt man auf der gleichen Linie

        previous_lines = current_lines

    return line_changes

# Liste der Knoten (Stationen)
stations = list(G.nodes())

# Initialisiere eine DataFrame-Matrix für die kürzesten Zeiten
shortest_time_matrix = pd.DataFrame(index=stations, columns=stations)

# Fülle die Matrix mit den kürzesten Fahrzeiten
for u in stations:
    for v in stations:
        if u == v:
            shortest_time_matrix.at[u, v] = 0  # Gleiche Station, Zeit ist 0
        else:
            try:
                # Berechne den kürzesten Pfad basierend auf der Zeit (ohne Umstiege)
                path = nx.shortest_path(G, source=u, target=v, weight='time')

                # Berechne die Gesamtzeit für den kürzesten Pfad
                total_time = sum(G[path[i]][path[i + 1]]['time'] for i in range(len(path) - 1))

                # Berechne die Anzahl der Umstiege (Linienwechsel)
                line_changes = count_line_changes(path)

                # Füge die Umstiegszeit (2 Minuten pro Umstieg) zur Gesamtzeit hinzu
                total_time_with_line_changes = total_time + (line_changes * 2)

                # Trage die kürzeste Zeit in die Matrix ein
                shortest_time_matrix.at[u, v] = total_time_with_line_changes
            except nx.NetworkXNoPath:
                # Falls keine Verbindung vorhanden ist, setze auf unendlich
                shortest_time_matrix.at[u, v] = float('inf')

# Speichere die Matrix als JSON-Datei mit korrekter Darstellung der Umlaute
shortest_time_matrix.to_json('times.json', orient='split', force_ascii=False)

print("Die Matrix der kürzesten Fahrzeiten wurde erfolgreich als JSON-Datei gespeichert.")
