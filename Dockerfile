FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive

# ============================================================
# Debian Jessie is EOL.
# Use Debian archive repositories.
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
    perl \
    perl-modules


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
# graphviz          -> dot executable
# libgraphviz-perl  -> Perl GraphViz.pm
# ============================================================

RUN apt-get install -y --allow-unauthenticated \
    graphviz \
    libgraphviz-perl


# ============================================================
# Perl DBI / SQLite
#
# libdbi-perl       -> DBI.pm
# libdbd-sqlite3-perl -> DBD/SQLite.pm
# sqlite3           -> sqlite3 executable
# libsqlite3-dev    -> SQLite development headers
# ============================================================

RUN apt-get install -y --allow-unauthenticated \
    libdbi-perl \
    libdbd-sqlite3-perl \
    sqlite3 \
    libsqlite3-dev


# ============================================================
# Additional Perl build dependencies
# ============================================================

RUN apt-get install -y --allow-unauthenticated \
    libssl-dev \
    zlib1g-dev \
    libxml2-dev \
    libxml-libxml-perl


# ============================================================
# Java 8
#
# Java 8 comes from Jessie backports.
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

# ------------------------------------------------------------
# Additional Perl modules
# ------------------------------------------------------------
RUN cpan -i Text::Diff Getopt::Declare

# ============================================================
# Verify GCC
# ============================================================

RUN echo "========================================" && \
    echo "GCC version:" && \
    gcc --version


# ============================================================
# Verify G++
# ============================================================

RUN echo "========================================" && \
    echo "G++ version:" && \
    g++ --version


# ============================================================
# Verify Java
# ============================================================

RUN echo "========================================" && \
    echo "Java version:" && \
    java -version


RUN echo "========================================" && \
    echo "Javac version:" && \
    javac -version


# ============================================================
# Verify OCaml
# ============================================================

RUN echo "========================================" && \
    echo "OCaml version:" && \
    ocaml -version


# ============================================================
# Verify Perl
# ============================================================

RUN echo "========================================" && \
    echo "Perl version:" && \
    perl -v


# ============================================================
# Verify GraphViz
# ============================================================

RUN echo "========================================" && \
    echo "GraphViz version:" && \
    dot -V


RUN echo "========================================" && \
    echo "Perl GraphViz module:" && \
    perl -MGraphViz \
         -e 'print "GraphViz.pm OK\n"'


# ============================================================
# Verify DBI
# ============================================================

RUN echo "========================================" && \
    echo "DBI:" && \
    perl -MDBI \
         -e 'print "DBI version: $DBI::VERSION\n"'


# ============================================================
# Verify DBD::SQLite
# ============================================================

RUN echo "========================================" && \
    echo "DBD::SQLite:" && \
    perl -MDBD::SQLite \
         -e 'print "DBD::SQLite version: $DBD::SQLite::VERSION\n"'


# ------------------------------------------------------------
# Verify Text::Diff
# ------------------------------------------------------------
RUN echo "========================================" && \
    echo "Text::Diff:" && \
    perl -MText::Diff \
        -e 'print "Text::Diff OK\n"'

# ------------------------------------------------------------
# Verify Getopt::Declare
# ------------------------------------------------------------
RUN echo "========================================" && \
    echo "Getopt::Declare:" && \
    perl -MGetopt::Declare \
        -e 'print "Getopt::Declare OK\n"'

# ============================================================
# Clean temporary OCaml source and APT cache
# ============================================================

RUN rm -rf /tmp/ocaml-4.00.0 \
           /tmp/ocaml-4.00.0.tar.gz \
           /var/lib/apt/lists/*


# ============================================================
# Working directory
# ============================================================

WORKDIR /workspace

CMD ["/bin/bash"]