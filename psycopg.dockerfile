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
      BUILD_SRC=psycopg/psycopg.git

  # get source of package
  RUN set -ex; \
    eleven git clone ${BUILD_SRC} ${WHEEL_VERSION};

  # add build requirements wheel specific
  RUN set -ex; \
    apk --no-cache --update add \
      libpq-dev;

  # build wheels
  RUN set -ex; \
    cd $(echo "${BUILD_SRC}" | awk -F '/' '{print $2}' | sed 's|.git$||')/psycopg_c; \
    gpep517 build-wheel \
      --wheel-dir .dist \
      --output-fd 3 3>&1 >&2; \
    mv ${PWD}/.dist /;

  RUN set -ex; \
    cd $(echo "${BUILD_SRC}" | awk -F '/' '{print $2}' | sed 's|.git$||')/psycopg; \
    gpep517 build-wheel \
      --wheel-dir .dist \
      --output-fd 3 3>&1 >&2; \
    cp -af ${PWD}/.dist/. /.dist;

  RUN set -ex; \
    cd $(echo "${BUILD_SRC}" | awk -F '/' '{print $2}' | sed 's|.git$||')/psycopg_pool; \
    gpep517 build-wheel \
      --wheel-dir .dist \
      --output-fd 3 3>&1 >&2; \
    cp -af ${PWD}/.dist/. /.dist;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]