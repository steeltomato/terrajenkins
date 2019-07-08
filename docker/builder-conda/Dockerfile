# The most basic, simple builder image you can use
FROM jenkins/jnlp-slave

USER root

RUN apt-get update && \
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda_install.sh && \
    bash miniconda_install.sh -b -p $HOME/miniconda && \
    echo "export PATH=\"$HOME/miniconda/bin:$PATH\"" >> ~/.bashrc
