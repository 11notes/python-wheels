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
  ENV CYTHONIZE=1

  # add build requirements wheel specific
  RUN set -ex; \
    apk --no-cache --update --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community add \
      ffmpeg-dev=~8 \
      ffmpeg=~8;

  # build wheels
  RUN set -ex; \
    wheel-build https://github.com/PyAV-Org/PyAV.git ${WHEEL_VERSION};


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]