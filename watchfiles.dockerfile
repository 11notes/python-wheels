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
  ARG TARGETARCH \
      TARGETVARIANT \
      WHEEL_VERSION \
      BUILD_SRC=samuelcolvin/watchfiles.git

  RUN set -ex; \
    uname -m;

  # get source of package
  RUN set -ex; \
    eleven git clone ${BUILD_SRC} v${WHEEL_VERSION};

  # build wheels
  RUN set -ex; \
    cd $(echo "${BUILD_SRC}" | awk -F '/' '{print $2}' | sed 's|.git$||'); \
    gpep517-build-wheel


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]