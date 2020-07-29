FROM jupyter/scipy-notebook:c094bb7219f9
COPY /jupyter_notebook_config.json /opt/conda/etc/jupyter/jupyter_notebook_config.json

USER root

RUN apt-get update \
    && apt-get install -y less vim htop libpq-dev lsb wget gnupg apt-transport-https python3.6 python-requests curl \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /usr/lib/apt/lists/* \
    && fix-permissions $CONDA_DIR

RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add - \
    && echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/renci-irods.list \
    && apt-get update \
    && apt-get install -y irods-runtime irods-icommands \
    && apt-get clean \
    && rm -rf /usr/lib/apt/lists/* \
    && fix-permissions $CONDA_DIR

RUN pip install ipython-sql jupyterlab==1.0.9 jupyterlab_sql psycopg2 \
    && conda update -n base conda \
    && conda install -c conda-forge nodejs \
    && jupyter serverextension enable jupyterlab_sql --py --sys-prefix \
    && jupyter lab build

# install the irods plugin for jupyter lab
RUN pip install jupyterlab_irods==3.0.2 \
    && jupyter serverextension enable --py jupyterlab_irods \
    && jupyter labextension install ijab

# install jupyterlab hub-extension, lab-manager, bokeh
RUN jupyter lab --version \
    && jupyter labextension install @jupyterlab/hub-extension \
                                    @jupyter-widgets/jupyterlab-manager 
                              
# install jupyterlab git extension
RUN jupyter labextension install @jupyterlab/git && \
        pip install --upgrade jupyterlab-git && \
        jupyter serverextension enable --py jupyterlab_git

# install jupyterlab github extension
RUN jupyter labextension install @jupyterlab/github

RUN apt-get update && apt-get install -y build-essential cmake zlib1g-dev libhdf5-dev

# install conda environment
RUN conda config --add channels bioconda && \
    conda config --add channels conda-forge 

# install kallisto
RUN conda install kallisto

# install java for fastqc
# RUN apt-get update && \
#     apt-get install -y openjdk-8-jdk && \
#     apt-get install -y ant && \
#     apt-get clean;

# install fastqc

# install fastx-toolkit
RUN sudo apt-get install -y fastx-toolkit

#intstall fastx matching script
COPY fastx_full.sh /bin/fastx_full

# wget the sample data and practice data 


# add Zsh kernel
#RUN python3 -mpip install notebook zsh_jupyter_kernel && python3 -mzsh_jupyter_kernel.install --sys-prefix

# add Bash kernel
RUN pip install bash_kernel && python3 -m bash_kernel.install 

#add TDM
RUN sudo apt-get install -y unzip
RUN wget -O /bin/tdm.zip https://www.csc.tntech.edu/pdcincs/resources/modules/tools/TDM-GCC-64.zip --no-check-certificate
RUN unzip /bin/tdm.zip -d /bin
RUN rm /bin/tdm.zip
ENV PATH "$PATH:/bin/TDM-GCC-64/bin"

#pull openmp
RUN git clone https://github.com/pdewan/OpenMPTraining.git /OpenMPTraining

#pull transcriptom
RUN mkdir /transcriptom \
    && wget ftp://ftp.ensembl.org/pub/release-100/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz -O /transcriptom/Homo_sapiens_transcriptom.fa.gz \
    && chmod 777 /transcriptom/Homo_sapiens_transcriptom.fa.gz \
    && gunzip /transcriptom/Homo_sapiens_transcriptom.fa.gz \
    && kallisto index -i /transcriptom/Homo_sapiens_transcriptom.index /transcriptom/Homo_sapiens_transcriptom.fa

#pull dylan_plugin
RUN git clone https://github.com/dylanjtastet/llvm-instr /llvm-instr \
    && sudo apt-get install -y clang \
    && sudo apt-get install -y llvm

#pull super shell and install
RUN git clone https://github.com/SaumyashreeRay/SuperShell.git /SuperShell \
    && sudo apt-get install -y jq
COPY linux_install_supershell_docker.sh /SuperShell/linux_install_supershell_docker.sh
#RUN chmod +x /SuperShell/linux_install_supershell_docker.sh \
#    && /SuperShell/linux_install_supershell_docker.sh 

#Clean Up Git
RUN sudo apt-get remove --auto-remove -y git 

#set User Permissions
RUN usermod -d /home/jovyan -u 1000 jovyan
RUN chown -R jovyan:users /home/jovyan

USER jovyan
 
#Setup Entry Points
COPY entry.sh /bin
RUN mkdir -p /home/jovyan/.irods

WORKDIR /home/jovyan
ENTRYPOINT ["bash", "/bin/entry.sh"]
