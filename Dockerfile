FROM harbor.cyverse.org/vice/jupyter/datascience:3.6.1

USER root

# non-interactive frontend
ENV DEBIAN_FRONTEND noninteractive

# Install and configure jupyter lab.
COPY jupyter_notebook_config.json /opt/conda/etc/jupyter/jupyter_notebook_config.json

#intstall fastx
RUN mkdir fastx_bin \
    && wget -O fastx_bin/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 \
    && tar -xjf fastx_bin/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 -C ./fastx_bin \
    && cp fastx_bin/bin/* /usr/local/bin \ 
    && rm -r fastx_bin

# install clang
RUN apt-get update && apt-get install -y clang jq llvm

# Rebuild the Jupyter Lab with new tools
RUN jupyter lab build

USER jovyan

# install conda environment
RUN conda config --add channels bioconda \
    && mamba install ipywidgets jupyterlab_widgets kallisto -y

#Clone SuperShell and Prepare to Install
RUN git clone -b CyverseLogging-v1.2 https://github.com/pdewan/SuperShell.git /home/jovyan/RawSuper \ 
    && cp -r /home/jovyan/RawSuper/DockerSuperShell/SuperShellV2 /home/jovyan/SuperShell \
    && rm -r /home/jovyan/RawSuper \
    && chmod -R 755 /home/jovyan/SuperShell

# Entrypoint is already set in base container, examples retained below:
#
# EXPOSE 8888
# 
# COPY entry.sh /bin
# RUN mkdir -p /home/jovyan/.irods
# 
# ENTRYPOINT ["bash", "/bin/entry.sh"]
