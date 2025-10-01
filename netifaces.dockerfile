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
    git clone --recurse-submodules https://github.com/al45tair/netifaces.git -b release_0_11_0 /build; \
    cd /build; \
    wget https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/community/py3-netifaces/gcc14.patch; \
    git apply gcc14.patch; \
    gpep517 build-wheel \
      --wheel-dir /.dist \
      --output-fd 3 3>&1 >&2;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]
