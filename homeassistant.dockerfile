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

  # build wheels
  RUN set -ex; \
    pip wheel \
      --wheel-dir /pip/wheels \
      -f https://wheels.home-assistant.io/musllinux/ \
      homeassistant=="${WHEEL_VERSION}";

  RUN set -ex; \
    cd /pip/wheels; \
    curl https://11notes.github.io/python-wheels/ --output index.html; \
    for WHL in *.whl; do \
      if cat index.html | grep -q "${WHL}"; then \
        rm -f ${WHL}; \
        echo "removing wheel ${WHL} because it exists already in the repository"; \
      fi \
    done; \
    rm -f index.html; \
    mv /pip/wheels /.dist;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]