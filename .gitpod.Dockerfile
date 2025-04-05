FROM gitpod/workspace-full:latest

USER root

# Install R
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    r-base \
    ghostscript \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-latex-extra \
    texlive-pictures \
    texlive-luatex \

# Install Quarto CLI
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.13/quarto-1.7.13-linux-amd64.deb && \
    dpkg -i quarto-1.7.13-linux-amd64.deb && \
    rm quarto-1.7.13-linux-amd64.deb


# Install Inkscape and Ghostscript
RUN add-apt-repository ppa:inkscape.dev/stable -y && \
    apt-get update && \
    apt-get install -y inkscape ghostscript

# Fix Quarto/deno cache permission issues by pre-creating cache directories
RUN mkdir -p /home/gitpod/.cache/deno && \
    mkdir -p /home/gitpod/.cache/quarto/sass && \
    chown -R gitpod:gitpod /home/gitpod/.cache

USER gitpod

# Install core R packages for Quarto
RUN Rscript -e "install.packages(c('remotes', 'knitr', 'rmarkdown'), repos='https://cloud.r-project.org')"

# Copy and run book-specific R packages
COPY install_packages.R /home/gitpod/install_packages.R
RUN Rscript -e "source('/home/gitpod/install_packages.R')"

# Optional logging folder
RUN mkdir -p /home/gitpod/logs && \
    mkdir -p /home/public && \
    touch /home/gitpod/logs/myDockerlog.txt && \
    echo 'Docker setup completed!' >> /home/gitpod/logs/myDockerlog.txt

# Clean up
USER root
RUN apt-get clean && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

USER gitpod
