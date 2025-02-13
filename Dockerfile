FROM ghcr.io/homalg-project/gap-docker-base:latest

ENV GAP_BRANCH=master

# download and build GAP
RUN    mkdir -p /home/gap/inst/ \
    && cd /home/gap/inst/ \
    && git clone --depth=1 -b ${GAP_BRANCH} https://github.com/gap-system/gap gap-${GAP_BRANCH} \
    && cd gap-${GAP_BRANCH} \
    && ./autogen.sh \
    && ./configure \
    && make

# download and build GAP packages

# NormalizInterface: switch to C++14 to work around https://github.com/gap-packages/NormalizInterface/issues/110

RUN    cd /home/gap/inst/gap-${GAP_BRANCH}/ \
    && make bootstrap-pkg-full \
    && rm packages.tar.gz \
    && cd pkg/ \
    && rm normalizinterface/prerequisites.sh \
    && sed -i 's/AX_CXX_COMPILE_STDCXX(11, ,mandatory)/AX_CXX_COMPILE_STDCXX(14, ,mandatory)/' normalizinterface/configure.ac \
    && sed -i 's/-std=gnu++11/-std=gnu++14/' normalizinterface/Makefile.in \
    && (cd normalizinterface && ./autogen.sh) \
    && ../bin/BuildPackages.sh \
    && cd .. \
    && make doc

## workaround for until new digraphs version is released
RUN    cd /home/gap/inst/gap-${GAP_BRANCH}/ \
    && touch pkg/digraphs/gap/doc.g

## build JupyterKernel
#RUN    cd /home/gap/inst/gap-${GAP_BRANCH}/pkg \
#    && mv JupyterKernel-* JupyterKernel \
#    && cd JupyterKernel \
#    && pip3 install . --user

#RUN jupyter serverextension enable --py jupyterlab --user

#ENV PATH /home/gap/inst/gap-${GAP_BRANCH}/pkg/JupyterKernel/bin:${PATH}
#ENV JUPYTER_GAP_EXECUTABLE /home/gap/inst/gap-${GAP_BRANCH}/bin/gap.sh

ENV GAP_HOME /home/gap/inst/gap-${GAP_BRANCH}
ENV PATH ${GAP_HOME}:${PATH}
