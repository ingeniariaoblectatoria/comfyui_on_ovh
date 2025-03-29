FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3-pip
RUN apt-get install -y python3.12-venv
RUN python3 -m venv /venv_for_comfyui
RUN /venv_for_comfyui/bin/pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
RUN cd /app/ComfyUI && git checkout v0.3.27
RUN /venv_for_comfyui/bin/pip install -r /app/ComfyUI/requirements.txt

WORKDIR /
RUN apt-get install -y wget
RUN wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.8.2/oauth2-proxy-v7.8.2.linux-amd64.tar.gz
RUN tar -xvf oauth2-proxy-v7.8.2.linux-amd64.tar.gz

COPY entrypoint.sh .

EXPOSE 443
CMD ["sh", "entrypoint.sh"]