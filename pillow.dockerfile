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
  ARG WHEEL_VERSION

  # add build requirements wheel specific
  RUN set -ex; \
    apk --no-cache --update add \
      zlib-dev \
      libjpeg-turbo-dev; \
    pip install -f https://11notes.github.io/python-wheels/ \
      pybind11;


  # build wheels
  RUN set -ex; \
    gpep517-build-wheel https://github.com/python-pillow/Pillow.git ${WHEEL_VERSION};


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]