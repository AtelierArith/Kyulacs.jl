FROM julia:1.7.1

# create user with a home directory
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    python3 \
    python3-dev \
    python3-distutils \
    curl \
    ca-certificates \
    git \
    zip \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# Dependencies for development
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    htop \
    nano \
    openssh-server \
    tig \
    tree \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# install NodeJS
RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# We need install jupyterlab with sudo user, NOT ${USER}
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python3 && \
    pip3 install \
    jupyter \
    jupyterlab \
    jupytext \
    ipywidgets \
    jupyter-contrib-nbextensions \
    jupyter-nbextensions-configurator \
    jupyter-server-proxy \
    nbconvert \
    ipykernel \
    isort \
    black \
    git+https://github.com/IllumiDesk/jupyter-pluto-proxy.git \
    jupyterlab_code_formatter autopep8 black \
    webio_jupyter_extension \
    webio-jupyterlab-provider \
    && \
    echo Done

# Install/enable extension for Jupyter Notebook users
RUN pip3 install jupyter-resource-usage && \
    jupyter contrib nbextension install --user && \
    jupyter nbextensions_configurator enable --user && \
    # enable extensions what you want
    jupyter nbextension enable select_keymap/main && \
    jupyter nbextension enable highlight_selected_word/main && \
    jupyter nbextension enable toggle_all_line_numbers/main && \
    jupyter nbextension enable varInspector/main && \
    jupyter nbextension enable toc2/main && \
    jupyter nbextension enable equation-numbering/main && \
    jupyter nbextension enable execute_time/ExecuteTime && \
    echo Done

# Install/enable extension for JupyterLab users
RUN jupyter labextension install jupyterlab-topbar-extension && \
    jupyter labextension install jupyterlab-system-monitor && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter labextension install @z-m-k/jupyterlab_sublime --no-build && \
    jupyter labextension install @ryantam626/jupyterlab_code_formatter --no-build && \
    jupyter serverextension enable --py jupyterlab_code_formatter && \
    jupyter labextension install @hokyjack/jupyterlab-monokai-plus --no-build && \
    jupyter labextension install @jupyterlab/server-proxy --no-build && \
    jupyter labextension install jupyterlab-plotly --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf ~/.cache/yarn && \
    rm -rf ~/.node-gyp && \
    echo Done

WORKDIR ${HOME}
USER ${USER}

USER root
RUN mkdir -p ${HOME}/.local ${HOME}/.jupyter
# Set color theme Monokai++ by default
RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension && \
    echo '{"theme": "Monokai++"}' >> \
    ${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings

RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension && \
    echo '{"codeCellConfig": {"lineNumbers": true, "fontFamily": "JuliaMono"}}' \
    >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings

RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension && \
    echo '{"shortcuts": [{"command": "runmenu:restart-and-run-all", "keys": ["Alt R"], "selector": "[data-jp-code-runner]"}]}' \
    >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/shortcuts.jupyterlab-settings
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

RUN mkdir -p ${HOME}/.julia/config && \
    echo '\
    # set environment variables\n\
    ENV["PYTHON"]=Sys.which("python3")\n\
    ENV["JUPYTER"]=Sys.which("jupyter")\n\
    ' >> ${HOME}/.julia/config/startup.jl && cat ${HOME}/.julia/config/startup.jl

RUN julia -e 'using Pkg; Pkg.add(["Revise", "LiveServer", "Pluto", "PlutoUI", "WebIO"])'
RUN julia --threads auto -e '\
    using Pkg; \
    using Base.Threads; \
    Pkg.add("IJulia"); \
    using IJulia; \
    installkernel("julia");\
    installkernel("julia-$(nthreads())-threads", env=Dict("JULIA_NUM_THREADS"=>"$(nthreads())")); \
    ' && \
    echo "Done"

ENV JULIA_PROJECT "@."
WORKDIR /workspace/Kyulacs.jl

RUN mkdir -p /workspace/Kyulacs.jl/src && echo "module ML3D end" > /workspace/Kyulacs.jl/src/Kyulacs.jl
COPY ./Project.toml /workspace/Kyulacs.jl

ENV PATH=${PATH}:${HOME}/.local/bin

USER root
RUN chown -R ${NB_UID} /workspace/Kyulacs.jl
USER ${USER}

RUN rm -f Manifest.toml && julia -e 'using Pkg; \
    Pkg.instantiate(); \
    Pkg.precompile()' && \
    # Check Julia version \
    julia -e 'using InteractiveUtils; versioninfo()'

USER ${USER}
EXPOSE 8000
EXPOSE 8888
EXPOSE 1234

CMD ["julia"]
