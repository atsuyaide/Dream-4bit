FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TRANSFORMERS_NO_ADVISORY_WARNINGS=1 \
    CUDA_VISIBLE_DEVICES=0 \
    # PyTorch のアロケータを安定化
    PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:64

# --- 必要ツール ---
RUN apt-get update && apt-get install -y \
        python3-pip git curl && \
    rm -rf /var/lib/apt/lists/*

# --- Python パッケージ ---
RUN pip3 install --no-cache-dir \
        torch==2.5.1+cu121 \
        --index-url https://download.pytorch.org/whl/cu121
RUN pip3 install --no-cache-dir \
        transformers==4.46.2 \
        bitsandbytes==0.43.2 \
        accelerate>=0.26.0 \
        gradio==5.31.0

# --- 作業ディレクトリ & アプリ ---
WORKDIR /workspace
COPY app.py .

# --- 一般ユーザを作成 ---
RUN useradd -m user && \
    chown -R user:user /workspace
# ユーザを切り替え
USER user

CMD ["python3", "app.py"]
