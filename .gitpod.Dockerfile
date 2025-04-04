FROM gitpod/workspace-full:latest

USER root

# Install core build tools, R, Python, Quarto, TeX, Inkscape, Ghostscript
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    gcc-arm-none-eabi \
    make \
    r-base \
    python3 \
    python3-pip \
    ghostscript \
    wget \
    software-properties-common \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    texlive-pictures \
    texlive-luatex \
  && wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.13/quarto-1.7.13-linux-amd64.deb \
  && dpkg -i quarto-1.7.13-linux-amd64.deb \
  && rm quarto-1.7.13-linux-amd64.deb \
  && add-apt-repository ppa:inkscape.dev/stable -y \
  && apt-get update \
  && apt-get install -y inkscape \
  && pip3 install --upgrade pip \
  && pip3 install pikepdf ghostscript PyPDF2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/*

# Add quarto's TinyTeX
RUN quarto install tinytex \
  && echo 'export PATH=$HOME/.TinyTeX/bin/x86_64-linux:$PATH' >> /etc/bash.bashrc

USER gitpod

# Logging or testing directory creation
RUN mkdir -p /home/gitpod/logs \
  && echo "Installed Quarto, R, Python3, LaTeX, Inkscape, Ghostscript" >> /home/gitpod/logs/myDockerlog.txt
