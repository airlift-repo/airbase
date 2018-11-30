# Build from the lastest of everything

# original:
# FROM jupyter/scipy-notebook:8ccdfc1da8d5

# local build:
# FROM jupyter_base:18.11.01

# docker hub build:
FROM airlift/jupyter_base

MAINTAINER King Shaw "kings@amazon.com"

LABEL base.name="airbase" base.version="v1"

USER root

RUN     \
    apt-get update                              && \
    apt-get install -y tshark                   && \
    apt-get install -y openjdk-11-jdk           && \
    apt-get install -y flex bison               && \
    apt-get install -y python3-pip

#    apt-get install -y libgtk2.0-0              && \
#    apt-get install -y libgconf-2-4             && \
#    apt-get install -y xvfb


#
# for Orca
#

RUN apt-get update && apt-get install -y --no-install-recommends \
        gnupg curl ca-certificates xz-utils wget libgtk2.0-0 libgconf-2-4 \
        && rm -rf /var/lib/apt/lists/* && apt-get clean

RUN apt-get install -y libgtk2.0-0              && \
    apt-get install -y libgconf-2-4             && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get update -y && \
    apt-get install -y google-chrome-stable xvfb poppler-utils && \
    rm -rf /var/lib/apt/lists/* && apt-get clean


USER $NB_UID

RUN \
    conda update -n base conda                  &&  \
    conda config --add channels conda-forge     &&  \
    jupyter labextension install @jupyterlab/plotly-extension           && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager    && \
    conda install -c plotly plotly              &&  \
    conda install -c plotly plotly-orca psutil poppler                  && \
    conda install -c conda-forge python-cufflinks                       && \
    pip install --upgrade pip                   &&  \
    conda install --quiet --yes                     \
        feather-format                              \
        networkx                                    \
        jupyter_kernel_gateway                  &&  \
    conda install -c damianavila82 rise         &&  \
    pip3 install transitions                    &&  \
    pip3 install line-profiler                  &&  \
    pip3 install memory_profiler                &&  \
    pip3 install antlr4-python3-runtime         &&  \
    pip3 install geoip2                         &&  \
    pip3 install dnspython



USER root

# Set up a wrapper for orca (see https://github.com/plotly/orca) in an X11-less environment

RUN \
    mv /opt/conda/bin/orca /opt/conda/bin/plotly-orca

COPY orca /opt/conda/bin/orca

RUN chmod a+x /opt/conda/bin/orca

USER $NB_UID

# 
# $ docker build -t airbase/v1 .
# $ docker run -p 9888:8888 --rm -e NB_USER=ubuntu airbase/v1 
# $ docker run --rm -it airbase/v1 /bin/bash
#

# problems:
#   pip3 install pygraphviz