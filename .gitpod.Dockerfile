FROM gitpod/workspace-full:latest

# Use root for installation
USER root

# Environment vars to fix Quarto + Deno cache issues
ENV QUARTO_USER_CACHE_DIR=/tmp/.quarto-cache
ENV DENO_DIR=/tmp/.deno-cache

# Install build tools + Quarto + R + Python + LaTeX + Inkscape + Ghostscript
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    r-base \
    ghostscript \
    software-properties-common \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    texlive-pictures \
    texlive-luatex \
    libfontconfig1 \
    libfreetype6 \
    && add-apt-repository ppa:inkscape.dev/stable -y \
    && apt-get update \
    && apt-get install -y inkscape

# Install Quarto CLI
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.550/quarto-1.4.550-linux-amd64.deb \
    && dpkg -i quarto-1.4.550-linux-amd64.deb \
    && rm quarto-1.4.550-linux-amd64.deb

# Install TinyTeX via Quarto
RUN quarto install tinytex

# Install core R packages for Quarto
RUN Rscript -e "install.packages(c('remotes', 'knitr', 'rmarkdown'), repos='https://cloud.r-project.org')"

# Copy and run book-specific R packages
COPY install_packages.R /home/gitpod/install_packages.R
RUN Rscript -e "source('/home/gitpod/install_packages.R')"


# Create writable cache dirs and set permissions
RUN mkdir -p /tmp/.quarto-cache /tmp/.deno-cache \
    && chown -R gitpod:gitpod /tmp/.quarto-cache /tmp/.deno-cache

# Fix Quarto/deno cache permission issues by pre-creating cache directories
RUN mkdir -p /home/gitpod/.cache/deno && \
    mkdir -p /home/workspace/cs249r_book/public && \
    mkdir -p /home/gitpod/.cache/quarto/sass && \
    chown -R gitpod:gitpod /home/gitpod/.cache

# Clean up
RUN apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

# Switch back to gitpod user
USER gitpod

# Create logs and confirm install
RUN mkdir -p /home/gitpod/logs \
    && touch /home/gitpod/logs/myDockerlog.txt \
    && echo "✅ Quarto dev environment installed" >> /home/gitpod/logs/myDockerlog.txt

# Add to .bashrc so it's always active
RUN echo 'export QUARTO_USER_CACHE_DIR=/tmp/.quarto-cache' >> /home/gitpod/.bashrc \
    && echo 'export DENO_DIR=/tmp/.deno-cache' >> /home/gitpod/.bashrc

# Clean up
USER root
RUN apt-get clean && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

USER gitpod
