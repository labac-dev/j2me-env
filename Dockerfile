ARG DEPS_IMAGE
FROM ${DEPS_IMAGE} AS deps

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=deps /deps /deps

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        ca-certificates \
        libc6:i386 \
        libxext6:i386 \
        libxrender1:i386 \
        libxtst6:i386 \
        libxi6:i386 \
        libxt6:i386 \
        libstdc++6:i386 \
        libx11-6:i386 \
        libice6:i386 \
        libsm6:i386 \
        libnsl-dev:i386 \
        libbsd0:i386 \
        wget \
        unzip \
        tar \
        make \
        && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/opt/jdk
ENV WTK_HOME=/opt/wtk
ENV ANT_HOME=/opt/ant
ENV PATH="${JAVA_HOME}/bin:${WTK_HOME}/bin:${ANT_HOME}/bin:${PATH}"

ARG ANT_VERSION=1.9.16
RUN set -ex \
    && mkdir -p ${ANT_HOME} \
    && tar -xzf /deps/apache-ant-${ANT_VERSION}-bin.tar.gz --strip-components=1 -C ${ANT_HOME}

RUN set -ex \
    && mkdir -p ${JAVA_HOME} \
    && cd ${JAVA_HOME} \
    && cp /deps/jdk-6u45-linux-i586.bin ./jdk.bin \
    && chmod +x jdk.bin \
    && yes | ./jdk.bin \
    && rm -rf jdk.bin \
    && mv jdk1.6.0_*/* ./ \
    && update-alternatives --install /usr/bin/java java   ${JAVA_HOME}/bin/java 100 \
    && update-alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 100

RUN set -ex \
    && tail -c +26625 /deps/sun_java_wireless_toolkit-2.5.2_01-linuxi486.bin.sh > /tmp/wtk.zip \
    && unzip -q /tmp/wtk.zip -d ${WTK_HOME}/ \
    && rm /tmp/wtk.zip

RUN echo '#!/bin/bash\n\
if [ -f "build.xml" ]; then\n\
    ant -Dsdk.home="${WTK_HOME}" -Djava.home="${JAVA_HOME}" "$@"\n\
else\n\
    echo "No build.xml found. Please provide a build script or use the WTK tools directly."\n\
    echo "Available tools:"\n\
    echo "  preverify - Preverify classes for J2ME"\n\
    echo "  jar - Create JAR files"\n\
    echo "  javac - Compile Java sources"\n\
fi' > /usr/local/bin/j2me-build && \
    chmod +x /usr/local/bin/j2me-build

RUN apt-get update && \
    apt-get install -y \
        git \
        python3 \
        sqlite3 \
        bubblewrap \
        ripgrep \
    && rm -rf /var/lib/apt/lists/*

RUN groupmod --new-name vscode $(getent group 1000 | cut -d: -f1) 2>/dev/null \
    || groupadd --gid 1000 vscode; \
    usermod --login vscode --move-home --home /home/vscode $(getent passwd 1000 | cut -d: -f1) 2>/dev/null \
    || useradd --uid 1000 --gid 1000 -m -s /bin/bash vscode; \
    apt-get update \
    && apt-get install -y sudo \
    && rm -rf /var/lib/apt/lists/* \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode

WORKDIR /workspace
RUN chown vscode:vscode /workspace

USER vscode

RUN java -version \
    && ant -version \
    && echo "J2ME SDK installed at: ${WTK_HOME}" \
    && ls -la ${WTK_HOME}/bin/

CMD ["/bin/bash"]
