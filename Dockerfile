FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04


RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3-pip wget libcap2-bin  python3.12-venv
RUN groupadd -g 42420 OVHcloud && useradd -u 42420 -g 42420 -m OVHcloud 
RUN python3 -m venv /venv_for_comfyui
RUN chown -R OVHcloud:OVHcloud /venv_for_comfyui
USER OVHcloud 
RUN /venv_for_comfyui/bin/pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
USER root
RUN mkdir app
RUN chown -R OVHcloud:OVHcloud /app
USER OVHcloud
WORKDIR /app
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
RUN cd /app/ComfyUI && git checkout v0.3.27
RUN /venv_for_comfyui/bin/pip install -r /app/ComfyUI/requirements.txt
WORKDIR /
USER root
RUN wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.8.2/oauth2-proxy-v7.8.2.linux-amd64.tar.gz
RUN tar -xvf oauth2-proxy-v7.8.2.linux-amd64.tar.gz
RUN chown -R OVHcloud:OVHcloud /oauth2-proxy-v7.8.2.linux-amd64
RUN setcap 'cap_net_bind_service=+ep' /oauth2-proxy-v7.8.2.linux-amd64/oauth2-proxy
COPY entrypoint.sh .
RUN chown OVHcloud:OVHcloud /entrypoint.sh
USER OVHcloud 
EXPOSE 443
CMD ["sh", "/entrypoint.sh"]