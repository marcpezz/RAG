FROM quay.io/uninuvola/base:main

# DO NOT EDIT USER VALUE
USER root

## -- ADD YOUR CODE HERE !! -- ##
FROM quay.io/uninuvola/base:main

# DO NOT EDIT USER VALUE
USER root

## -- ADD YOUR CODE HERE !! -- ##

# ── Ollama ───────────────────────────────────────────────────────────────────
RUN curl -fsSL https://ollama.com/install.sh | sh

# ── Pull models at build time ─────────────────────────────────────────────────
ENV OLLAMA_MODELS=/home/jovyan/.ollama/models

RUN ollama serve > /var/log/ollama.log 2>&1 & \
    for i in $(seq 1 30); do \
        curl -sf http://127.0.0.1:11434/api/tags > /dev/null 2>&1 && break; \
        [ "$i" -eq 30 ] && echo "Ollama failed to start" && exit 1; \
        sleep 1; \
    done && \
    ollama pull llama3 && \
    ollama pull nomic-embed-text && \
    pkill ollama || true

# ── Conda environment with all RAG dependencies ──────────────────────────────
RUN conda create -n rag -y python=3.11 && \
    conda clean -afy && \
    /opt/conda/envs/rag/bin/pip install --no-cache-dir \
        llama-index-core \
        llama-index-llms-ollama \
        llama-index-embeddings-ollama \
        llama-index-vector-stores-chroma \
        llama-index-readers-file \
        chromadb \
        pymupdf ipykernel \
        numpy tqdm && \
    /opt/conda/envs/rag/bin/python -m ipykernel install --name rag --display-name "RAG (papers)"

## --------------------------- ##

# DO NOT EDIT USER VALUE
USER jovyan

WORKDIR /home/jovyan 

