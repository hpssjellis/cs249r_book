FROM gitpod/workspace-full:latest

USER root

# Install build tools and Quarto dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    gcc-arm-none-eabi \
    make \
    r-base \
    ghostscript \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    texlive-pictures \
    texlive-luatex \
    software-properties-common \
    gpg \
    ca-certificates \
    libgl1 \
    libxrender1 \
    libsm6 \
  && wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.13/quarto-1.7.13-linux-amd64.deb \
  && dpkg -i quarto-1.7.13-linux-amd64.deb \
  && rm quarto-1.7.13-linux-amd64.deb \
  && bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" \
  && install-packages \
    clang \
    clangd \
    clang-format \
    clang-tidy \
    gdb \
    lld

# Install Inkscape from PPA
RUN add-apt-repository ppa:inkscape.dev/stable -y \
  && apt-get update \
  && apt-get install -y inkscape

# Fix Quarto + Deno cache permissions
RUN mkdir -p /home/gitpod/.cache/quarto/sass \
  && mkdir -p /home/gitpod/.cache/deno \
  && chown -R gitpod:gitpod /home/gitpod/.cache

# Create logs for debug
RUN mkdir -p /home/gitpod/logs \
  && touch /home/gitpod/logs/myDockerlog.txt \
  && echo "✅ Quarto dev environment installed" >> /home/gitpod/logs/myDockerlog.txt

# Optional: add env vars to reduce cache issues during runtime
RUN echo 'export QUARTO_USER_CACHE_DIR=/tmp/.quarto-cache' >> /home/gitpod/.bashrc \
  && echo 'export DENO_DIR=/tmp/.deno-cache' >> /home/gitpod/.bashrc

# Final cleanup
RUN apt-get clean \
  && rm -rf /var/cache/apt/* \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*

# Give back control
USER gitpod
