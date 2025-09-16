import os
import json

# Dossier contenant les fichiers
f = "ctl/"

for folder in os.scandir(f):
    if folder.is_dir():
        for filename in os.listdir(folder):
            if filename.endswith(".txt"):
                txt_path = os.path.join(folder, filename)
    
                # Lire la ligne de texte du fichier
                with open(txt_path, "r", encoding="utf-8") as f:
                    content = f.readline().strip()
    
                # Préparer le dictionnaire
                data = {"property": content}
    
                # Nouveau nom de fichier
                json_filename = os.path.splitext(filename)[0] + ".json"
                json_path = os.path.join(folder, json_filename)
    
                # Écrire en JSON
                with open(json_path, "w", encoding="utf-8") as f:
                    json.dump(data, f, indent=4, ensure_ascii=False)
    
                # Supprimer l'ancien fichier .txt si nécessaire
                os.remove(txt_path)

print("Conversion terminée !")
