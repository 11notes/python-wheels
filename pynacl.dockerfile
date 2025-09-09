# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# :: GLOBAL
  ARG PYTHON_VERSION=0 \
      WHEEL_NAME="" \
      WHEEL_VERSION=0

# :: APP SPECIFIC
  ARG BUILD_ROOT=/pynacl \
      BUILD_SRC=pyca/pynacl.git


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
    eleven git clone ${BUILD_SRC} ${WHEEL_VERSION};

  # add build requirements wheel specific
  RUN set -ex; \
    apk --no-cache --update add \
      make;

  # build wheels
  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    gpep517 build-wheel \
      --wheel-dir .dist \
      --output-fd 3 3>&1 >&2; \
    mv ${PWD}/.dist /;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]