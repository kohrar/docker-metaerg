FROM ubuntu:20.04
MAINTAINER Xiaoli Dong <xiaolid@gmail.com>
LABEL version="1.2.2"

WORKDIR /NGStools/

# TZdata on 20.04 requires noninteractive to work
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Edmonton apt-get update && apt-get install -y tzdata

#Install compiler and perl stuff
RUN apt-get update && apt-get install -y \
    #apt-utils \
    autoconf \
    #build-essential \
    cpanminus \
    gcc-multilib \
    git \
    make \
    openjdk-8-jdk \
    perl \
    python \
    sqlite3 \
    tar \
    unzip \
    wget \

# Install libraries that BioPerl dependencies depend on
    expat \
    graphviz \
    libdb-dev \
    libgdbm-dev \
    libexpat1 \
    libexpat-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev

#install perl modules
RUN cpanm Bio::Perl \
    DBI \
    Archive::Extract \
    DBD::SQLite \
    File::Copy::Recursive \
    Bio::DB::EUtilities \
    LWP::Protocol::https && \
    git clone https://git.code.sf.net/p/swissknife/git swissknife-git && \
    cd swissknife-git && \
    perl Makefile.PL && \
    make install && \
    cd /NGStools

#aragorn
RUN git clone https://github.com/TheSEED/aragorn.git && \
    cd aragorn && \
    gcc -O3 -ffast-math -finline-functions -o aragorn aragorn1.2.36.c && \
    cd /NGStools

#hmmer rRNAFinder need it
RUN git clone https://github.com/EddyRivasLab/hmmer && \
    cd hmmer && \
    git clone https://github.com/EddyRivasLab/easel && \
    autoconf && \
    ./configure && \
    make  && \
    cd /NGStools

#blast for classifying rRNA sequences
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.9.0/ncbi-blast-2.9.0+-x64-linux.tar.gz && \
    tar -xzf ncbi-blast-2.9.0+-x64-linux.tar.gz && \
    rm ncbi-blast-2.9.0+-x64-linux.tar.gz && \
    cd /NGStools

#prodigal
RUN git clone https://github.com/hyattpd/Prodigal.git && \
    cd Prodigal && \
    make && \
    cd /NGStools

#minced
RUN git clone https://github.com/ctSkennerton/minced.git && \
    cd minced && \
    make && \
    cd /NGStools

#diamond
RUN mkdir diamond && \
   cd diamond && \
    wget http://github.com/bbuchfink/diamond/releases/download/v0.9.24/diamond-linux64.tar.gz && \
    tar -xzf diamond-linux64.tar.gz && \
    rm diamond-linux64.tar.gz diamond_manual.pdf && \
    cd /NGStools

#MinPath
COPY minpath1.4.tar.gz /
RUN tar -xzf /minpath1.4.tar.gz && \
    rm /minpath1.4.tar.gz && \
    cd /NGStools


#metaerg
RUN git clone https://github.com/xiaoli-dong/metaerg.git
ENV MinPath /NGStools/MinPath

# tmhmm and signalp
COPY signalp-4.1g.Linux.tar.gz /
RUN cd /NGStools && \
    tar -zxvf /signalp-4.1g.Linux.tar.gz && \
    sed -i 's,/usr/cbs/bio/src/signalp-4.1,/home/linuxbrew/signalp-4.1,g' signalp-4.1/signalp && \
	sed -i 's,/usr/opt/www/pub/CBS/services/SignalP-4.1,/NGStools,g' signalp-4.1/signalp && \
    cd /NGStools && \
    cpanm Bio::DB::Fasta

COPY tmhmm-2.0c.Linux.tar.gz /
RUN cd /NGStools && \
    tar -zxvf /tmhmm-2.0c.Linux.tar.gz && \
    sed -i 's,#!/usr/local/bin/perl,#!/usr/bin/perl,g' tmhmm-2.0c/bin/tmhmm && \
    sed -i 's,#!/usr/local/bin/perl,#!/usr/bin/perl,g' tmhmm-2.0c/bin/tmhmmformat.pl && \
    cd /NGStools


# Clean
RUN apt-get remove -y autoconf \
    cpanminus \
    gcc-multilib \
    git \
    make && \
    apt-get autoclean -y


ENV PATH="/NGStools/tmhmm-2.0c/bin:/NGStools/signalp-4.1:/NGStools/aragorn:/NGStools/minced:/NGStools/Prodigal:/NGStools/ncbi-blast-2.9.0+/bin:/NGStools/diamond:/NGStools/hmmer/src:/NGStools/MinPath:/NGStools/metaerg/bin:${PATH}"

WORKDIR /NGStools/
