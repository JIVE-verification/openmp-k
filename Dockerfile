FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive

# ============================================================
# Debian Jessie is EOL.
# Use the Debian archive repositories.
# ============================================================

RUN printf '%s\n' \
    'deb [trusted=yes] http://archive.debian.org/debian jessie main' \
    'deb [trusted=yes] http://archive.debian.org/debian-security jessie/updates main' \
    'deb [trusted=yes] http://archive.debian.org/debian jessie-backports main' \
    > /etc/apt/sources.list


# ============================================================
# Configure APT for archived repositories
# ============================================================

RUN printf '%s\n' \
    'Acquire::Check-Valid-Until "false";' \
    'Acquire::AllowInsecureRepositories "true";' \
    'Acquire::AllowDowngradeToInsecureRepositories "true";' \
    > /etc/apt/apt.conf.d/99archive


# ============================================================
# Update package lists
# ============================================================

RUN apt-get update -o Acquire::Check-Valid-Until=false


# ============================================================
# Basic development tools
# ============================================================

RUN apt-get install -y --allow-unauthenticated \
    wget \
    curl \
    git \
    make \
    m4 \
    build-essential \
    ca-certificates \
    perl


# ============================================================
# GCC 4.9
# ============================================================

RUN apt-get install -y --allow-unauthenticated \
    gcc-4.9 \
    g++-4.9


# Make GCC 4.9 the default compiler
RUN update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 100

RUN update-alternatives \
    --install /usr/bin/g++ g++ /usr/bin/g++-4.9 100


# ============================================================
# GraphViz
#
# graphviz      -> dot executable
# libgraphviz-perl -> Perl GraphViz.pm module
# ============================================================

RUN apt-get install -y --allow-unauthenticated \
    graphviz \
    libgraphviz-perl


# ============================================================
# Java 8
#
# Java 8 is obtained from Jessie backports.
# ============================================================

RUN apt-get install -y \
    -t jessie-backports \
    --allow-unauthenticated \
    openjdk-8-jdk

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PATH}


# ============================================================
# OCaml 4.00.0
# ============================================================

WORKDIR /tmp

RUN wget https://caml.inria.fr/distrib/ocaml-4.00/ocaml-4.00.0.tar.gz

RUN tar -xzf ocaml-4.00.0.tar.gz

WORKDIR /tmp/ocaml-4.00.0

RUN ./configure

RUN make world

RUN make install


# ============================================================
# Verify GCC
# ============================================================

RUN echo "========================================"
RUN echo "GCC version:"
RUN gcc --version

RUN echo "========================================"
RUN echo "G++ version:"
RUN g++ --version


# ============================================================
# Verify Java
# ============================================================

RUN echo "========================================"
RUN echo "Java version:"
RUN java -version

RUN echo "========================================"
RUN echo "Javac version:"
RUN javac -version


# ============================================================
# Verify OCaml
# ============================================================

RUN echo "========================================"
RUN echo "OCaml version:"
RUN ocaml -version


# ============================================================
# Verify Perl
# ============================================================

RUN echo "========================================"
RUN echo "Perl version:"
RUN perl -v


# ============================================================
# Verify GraphViz
# ============================================================

RUN echo "========================================"
RUN echo "GraphViz version:"
RUN dot -V

RUN echo "========================================"
RUN echo "Perl GraphViz module:"
RUN perl -MGraphViz -e 'print "GraphViz.pm OK\n"'


# ============================================================
# Working directory
# ============================================================

WORKDIR /workspace

CMD ["/bin/bash"]
