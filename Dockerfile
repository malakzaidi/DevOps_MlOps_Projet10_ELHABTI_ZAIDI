FROM python:3.9-slim

WORKDIR /app

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copie et installation des dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Création préventive de TOUTE la structure
RUN mkdir -p models data app scripts results

# Copie du code source de manière sécurisée
# On utilise COPY . . pour tout prendre, puis on nettoie ou on cible
# Mais pour être ultra-propre, on copie les éléments racines un par un
COPY *.py ./

# Pour les dossiers, on utilise une astuce : on copie le contenu s'il existe
# sans faire échouer le build si le dossier est absent localement.
# Note: Dans GitHub Actions, on va s'assurer que ces dossiers existent.
COPY app/ ./app/
# On ne COPY pas scripts/ ici si on n'est pas sûr qu'il existe.
# On le fera via le pipeline CI/CD ou on l'inclut seulement s'il est là.

# Commande par défaut
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
