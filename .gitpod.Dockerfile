FROM gitpod/workspace-full:latest

# Use root for installation
USER root

# Environment vars to fix Quarto + Deno cache issues
ENV QUARTO_USER_CACHE_DIR=/tmp/.quarto-cache
ENV DENO_DIR=/tmp/.deno-cache

# Install system build tools and dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    curl \
    dirmngr \
    gnupg \
    ca-certificates \
    software-properties-common \
    libfontconfig1 \
    libfreetype6 \
    ghostscript

# Add CRAN repository and install R
RUN wget -qO- https://cloud.r-project.org/bin/linux/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/cran-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cran-archive-keyring.gpg] https://cloud.r-project.org/bin/linux/debian bookworm-cran40/" > /etc/apt/sources.list.d/cran.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends r-base

# Install LaTeX and Inkscape
RUN add-apt-repository ppa:inkscape.dev/stable -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    texlive-pictures \
    texlive-luatex \
    inkscape

# Install Quarto CLI
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.550/quarto-1.4.550-linux-amd64.deb && \
    dpkg -i quarto-1.4.550-linux-amd64.deb && \
    rm quarto-1.4.550-linux-amd64.deb

# Install TinyTeX via Quarto (for lean LaTeX)
RUN quarto install tinytex

# Install core R packages for Quarto
RUN Rscript -e "install.packages(c('remotes', 'knitr', 'rmarkdown'), repos='https://cloud.r-project.org')"

# Copy and install project-specific R packages
COPY install_packages.R /home/gitpod/install_packages.R
RUN Rscript /home/gitpod/install_packages.R

# Create writable cache dirs and set permissions
RUN mkdir -p /tmp/.quarto-cache /tmp/.deno-cache && \
    chown -R gitpod:gitpod /tmp/.quarto-cache /tmp/.deno-cache

RUN mkdir -p /home/gitpod/.cache/deno && \
    mkdir -p /home/gitpod/.cache/quarto/sass && \
    mkdir -p /home/workspace/cs249r_book/public && \
    chown -R gitpod:gitpod /home/gitpod/.cache

# Final cleanup
RUN apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

# Switch back to gitpod user
USER gitpod

# Logs and helpful flags
RUN mkdir -p /home/gitpod/logs && \
    echo "✅ Quarto dev environment installed" >> /home/gitpod/logs/myDockerlog.txt

# Persist environment vars for shell
RUN echo 'export QUARTO_USER_CACHE_DIR=/tmp/.quarto-cache' >> /home/gitpod/.bashrc && \
    echo 'export DENO_DIR=/tmp/.deno-cache' >> /home/gitpod/.bashrc
