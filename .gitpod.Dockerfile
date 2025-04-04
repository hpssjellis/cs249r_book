FROM gitpod/workspace-full

# Install system dependencies
RUN sudo apt-get update && sudo apt-get install -y \
    r-base \
    texlive-latex-recommended texlive-fonts-recommended texlive-latex-extra \
    texlive-pictures texlive-luatex \
    inkscape \
    ghostscript 

# Install R remotes package and link Rscript
RUN R -e "install.packages('remotes', repos='http://cran.us.r-project.org')"

RUN ln -s /usr/bin/Rscript /usr/local/bin/Rscript

# Set up the workspace directory
WORKDIR /workspace
