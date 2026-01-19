# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# :: GLOBAL
  ARG PYTHON_VERSION=0


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: WHEEL
  FROM 11notes/python:wheel-${PYTHON_VERSION} AS build
  ARG WHEEL_VERSION \
      TARGETARCH \
      TARGETVARIANT

  # add build requirements wheel specific
  RUN set -ex; \
    export CHROMIUM_VERSION=$(curl -s https://api.github.com/repos/bblanchon/pdfium-binaries/releases/latest | jq -r '.tag_name' | sed 's/v//'); \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      "arm64") eleven github asset bblanchon/pdfium-binaries ${CHROMIUM_VERSION} pdfium-linux-musl-arm64.tgz;; \
      "amd64") eleven github asset bblanchon/pdfium-binaries ${CHROMIUM_VERSION} pdfium-linux-musl-x64.tgz;; \
    esac;

  # build wheels
  RUN set -ex; \
    wheel-build pypdfium2 ${WHEEL_VERSION};


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]