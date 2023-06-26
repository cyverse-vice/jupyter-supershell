FROM jupyter/base-notebook:lab-3.3.4

USER root

# Install a few dependencies for iCommands, text editing, and monitoring instances
RUN apt update && \
    apt install -y lsb-release apt-transport-https curl libfreetype6-dev pkg-config libx11-dev gcc less software-properties-common apt-utils glances htop nano 

RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add - && \
    echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/renci-irods.list && \
    apt-get update && \
    apt install -y irods-icommands 

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt update && \
    apt install -y gh 

# Install and configure jupyter lab.
COPY jupyter_notebook_config.json /opt/conda/etc/jupyter/jupyter_notebook_config.json

# install conda environment
RUN conda config --add channels bioconda && \
    conda config --add channels conda-forge \
    && conda install jupyterlab_widgets \
    && conda install ipywidgets \
    && conda install kallisto

#intstall fastx
RUN mkdir fastx_bin \
    && wget -O fastx_bin/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 \
    && tar -xjf fastx_bin/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 -C ./fastx_bin \
    && sudo cp fastx_bin/bin/* /usr/local/bin \ 
    && rm -r fastx_bin

#intstall fastx matching script
COPY fastx_full.sh /bin/fastx_full

# add Bash kernel
RUN pip install bash_kernel && python3 -m bash_kernel.install 

#pull openmp
RUN git clone https://github.com/pdewan/OpenMPTraining.git /OpenMPTraining

#pull dylan_plugin
RUN git clone https://github.com/dylanjtastet/llvm-instr /llvm-instr \
    && sudo apt-get install -y clang \
    && sudo apt-get install -y llvm

#pull super shell and install
RUN git clone -b CyverseLogging-v1.1 https://github.com/pdewan/SuperShell.git /SuperShellInstall \
    && mv /SuperShellInstall /SuperShell \
    && sudo apt-get install -y jq
COPY linux_install_supershell_docker.sh /SuperShell/linux_install_supershell_docker.sh

# Add sudo to jovyan user
RUN apt update && \
    apt install -y sudo && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

#Set Custom permissions
ENV PATH "$PATH:/home/jovyan/bin"

#Set Permissions 
RUN chmod 777 -R /SuperShell 
    
ARG LOCAL_USER=jovyan
ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum'

RUN usermod -aG sudo jovyan && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers

# Rebuild the Jupyter Lab with new tools
RUN jupyter lab build

RUN addgroup jovyan
RUN usermod -aG jovyan jovyan

USER jovyan
WORKDIR /home/jovyan
EXPOSE 8888

COPY entry.sh /bin
RUN mkdir -p /home/jovyan/.irods

ENTRYPOINT ["bash", "/bin/entry.sh"]
