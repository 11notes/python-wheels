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
    mkdir -p /tmp/.whl; \
    eleven git clone DeebotUniverse/client.py.git ${WHEEL_VERSION} /build; \
    cd /build; \
    sed -i 's|version = "0.0.0"|version = "'${WHEEL_VERSION}'"|' pyproject.toml; \
    gpep517 build-wheel \
      --wheel-dir /tmp/.whl \
      --output-fd 3 3>&1 >&2; \
    find /pip/wheels -name "*deebot_client*.whl" -exec cp "{}" /.dist ";"


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]