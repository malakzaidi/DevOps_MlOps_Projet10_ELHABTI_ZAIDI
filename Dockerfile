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

# Création des dossiers nécessaires
RUN mkdir -p models data app scripts

# --- CORRECTION CRUCIALE ---
# Copie de TOUS les fichiers .py à la racine (dont benchmark.py)
COPY *.py ./

# Copie des dossiers structurés
COPY app/ ./app/
COPY scripts/ ./scripts/
# Les modèles et data sont souvent gérés par DVC ou montés en volume, 
# mais on les copie s'ils sont présents lors du build
COPY models/ ./models/
COPY data/ ./data/

# On s'assure que benchmark.py est bien là où on l'attend
RUN ls -la /app/benchmark.py || echo "Warning: benchmark.py not found at root"

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
