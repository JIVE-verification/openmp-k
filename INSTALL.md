# INSTALL.md

## c-semantics: Installation & Usage Guide

This project uses a pre-built Docker image for c-semantics.  
Follow the steps below to set up and use the semantics with minimal hassle.

---

### Quick Start (Recommended): Using the Pre-Built Docker Image

1. **Clone this repository**

    ```bash
    git clone https://github.com/JIVE-verification/openmp-k.git
    cd openmp-k
    git submodule update --init --recursive
    cd c-semantics
    ```

2. **Run the Docker image with your project directory mounted**

    ```bash
    docker run -it --rm \
      -v $(pwd -P):/home/user/mounted \
      -w /home/user/mounted \
      ghcr.io/sukeerth3/updated-c-semantics:1.0.0
    ```

    - This mounts your current project directory to `/home/user/mounted` inside the container.
    - You are now inside a Docker container with all c-semantics dependencies and binaries pre-installed and compiled.

3. **Build the semantics inside the container**

    ```bash
    # Set up the environment (if necessary)
    eval $(opam config env)
    eval $(perl -I "~/perl5/lib/perl5" -Mlocal::lib)
    export PATH=$K_BIN:$PATH
    make
    ```

    - This will build the semantics with the latest source.
    - You must perform this step before using the tools.

4. **Use c-semantics tools as needed**

    You can run any analysis, scripts, or tools directly inside this directory after building.

---


