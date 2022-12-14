FROM harbor.cyverse.org/vice/jupyter/datascience:latest
USER root

# Install a few dependencies for iCommands, text editing, and monitoring instances
RUN apt update && \
    apt-get install -y unzip clang llvm jq 

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

#add TDM
RUN sudo apt-get install -y unzip
RUN wget -O /bin/tdm.zip https://www.csc.tntech.edu/pdcincs/resources/modules/tools/TDM-GCC-64.zip --no-check-certificate
RUN unzip /bin/tdm.zip -d /bin
RUN rm /bin/tdm.zip
ENV PATH "$PATH:/bin/TDM-GCC-64/bin"

USER jovyan

#pull openmp
RUN git clone https://github.com/pdewan/OpenMPTraining.git /OpenMPTraining

#pull dylan_plugin
RUN git clone https://github.com/dylanjtastet/llvm-instr /llvm-instr \
    && sudo apt-get install -y clang \
    && sudo apt-get install -y llvm

#pull super shell and install
RUN git clone -b CyverseLogging https://github.com/pdewan/SuperShell.git /SuperShellInstall \
    && mv /SuperShellInstall /SuperShell \
    && sudo apt-get install -y jq
COPY linux_install_supershell_docker.sh /SuperShell/linux_install_supershell_docker.sh
