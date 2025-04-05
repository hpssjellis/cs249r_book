# Base image
FROM gitpod/workspace-full:latest

# Use root for installation
USER root

# Environment vars to fix Quarto + Deno cache issues
ENV QUARTO_USER_CACHE_DIR=/tmp/.quarto-cache
ENV DENO_DIR=/tmp/.deno-cache

# Install system dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg \
    ca-certificates \
    software-properties-common \
    libfontconfig1 \
    libfreetype6 \
    ghostscript \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    texlive-pictures \
    texlive-luatex \
    r-base \
    inkscape



# Install Quarto CLI (Latest Version)
RUN wget https://github.com/quarto-dev/quarto-cli/releases/latest/download/quarto-linux-amd64.deb && \
    dpkg -i quarto-linux-amd64.deb && \
    rm quarto-linux-amd64.deb

# Install TinyTeX via Quarto
RUN quarto install tinytex
RUN quarto install chromium

# Install required R packages in one step to reduce layers
# RUN Rscript -e 'install.packages(c("remotes", "devtools", "attempt", "dockerfiler"), repos="https://cloud.r-project.org")'
# RUN install.packages("remotes")
# RUN source("install_packages.R")

# Create cache directories with correct permissions
RUN mkdir -p /tmp/.quarto-cache /tmp/.deno-cache \
    /home/gitpod/.cache/deno \
    /home/gitpod/.cache/quarto/sass \
    /home/workspace/cs249r_book/public && \
    chown -R gitpod:gitpod /tmp/.quarto-cache /tmp/.deno-cache /home/gitpod/.cache /home/workspace/cs249r_book/public

# Final cleanup
RUN apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

# Switch back to gitpod user
USER gitpod

# Persist environment vars for shell
RUN echo 'export QUARTO_USER_CACHE_DIR=/tmp/.quarto-cache' >> /home/gitpod/.bashrc && \
    echo 'export DENO_DIR=/tmp/.deno-cache' >> /home/gitpod/.bashrc
