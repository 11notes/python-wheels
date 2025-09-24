# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# :: GLOBAL
  ARG PYTHON_VERSION=0 \
      WHEEL_NAME="" \
      WHEEL_VERSION=0

# :: APP SPECIFIC
  ARG BUILD_ROOT=/aiohttp \
      BUILD_SRC=aio-libs/aiohttp.git


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: WHEEL
  FROM 11notes/python:wheel-${PYTHON_VERSION} AS build
  ARG PYTHON_VERSION \
      WHEEL_NAME \
      WHEEL_VERSION \
      BUILD_ROOT \
      BUILD_SRC

  # get source of package
  RUN set -ex; \
    eleven git clone ${BUILD_SRC} v${WHEEL_VERSION};

  # build wheels
  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    pip-build-wheel \
      aiohttp==${WHEEL_VERSION}; \
    mv ${PWD}/.dist /;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]