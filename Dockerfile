# syntax=docker/dockerfile:1

FROM debian:bookworm AS builder

ARG BOWTIE2_REF=v2.5.4

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${BOWTIE2_REF}" https://github.com/BenLangmead/bowtie2.git bowtie2 \
    || (git clone https://github.com/BenLangmead/bowtie2.git bowtie2 && cd bowtie2 && git checkout "${BOWTIE2_REF}")

WORKDIR /src/bowtie2
RUN make -j"$(nproc)"

FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libbz2-1.0 \
        liblzma5 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/bowtie2/bowtie2 /usr/local/bin/bowtie2
COPY --from=builder /src/bowtie2/bowtie2-align-s /usr/local/bin/bowtie2-align-s
COPY --from=builder /src/bowtie2/bowtie2-align-l /usr/local/bin/bowtie2-align-l
COPY --from=builder /src/bowtie2/bowtie2-build /usr/local/bin/bowtie2-build
COPY --from=builder /src/bowtie2/bowtie2-build-s /usr/local/bin/bowtie2-build-s
COPY --from=builder /src/bowtie2/bowtie2-build-l /usr/local/bin/bowtie2-build-l
COPY --from=builder /src/bowtie2/bowtie2-inspect /usr/local/bin/bowtie2-inspect
COPY --from=builder /src/bowtie2/bowtie2-inspect-s /usr/local/bin/bowtie2-inspect-s
COPY --from=builder /src/bowtie2/bowtie2-inspect-l /usr/local/bin/bowtie2-inspect-l

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/bowtie2"]
