FROM madduci/docker-linux-cpp:latest

LABEL maintainer="Michele Adduci <adduci@tutanota.com>" \
      license="Copyright (c) 2012-2024, Matt Godbolt"

EXPOSE 10240

ENV DEBIAN_FRONTEND=noninteractive

# Make sure necessary tools are available first
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gnupg ca-certificates

# Install LLVM key in dearmor format
RUN echo "*** Update and sign use trusted sources ***" \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /etc/apt/keyrings/llvm.gpg \
    && chmod 644 /etc/apt/keyrings/llvm.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main" > /etc/apt/sources.list.d/llvm.list \
    && echo "deb [signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" >> /etc/apt/sources.list.d/llvm.list \
    && echo "deb [signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-19 main" >> /etc/apt/sources.list.d/llvm.list \
    && apt-get update

# Download the GPG key into the trusted.gpg.d directory
RUN echo "*** Installing Compiler Explorer ***" \
    && curl -sL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y \
        ca-certificates \
        clang-16 \
        clang-17 \
        clang-18 \
        clang-19 \
        file \
        g++-10 \
        g++-11 \
        g++-9 \
        git \
        make \
        nodejs \
        rsync \
        wget \
    && apt-get autoremove --purge -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && git clone https://github.com/compiler-explorer/compiler-explorer.git /compiler-explorer \
    && cd /compiler-explorer \
    && echo "Add missing dependencies" \
    && npm i @sentry/node \
    && make prebuild

ADD cpp.properties /compiler-explorer/etc/config/c++.local.properties

WORKDIR /compiler-explorer

ENTRYPOINT [ "make" ]

CMD ["run-only"]
