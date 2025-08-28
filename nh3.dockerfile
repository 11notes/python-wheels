# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# :: GLOBAL
  ARG PYTHON_VERSION=0 \
      WHEEL_NAME="" \
      WHEEL_VERSION=0

# :: APP SPECIFIC
  ARG BUILD_ROOT=/nh3 \
      BUILD_SRC=messense/nh3.git

# :: FOREIGN IMAGES
  FROM 11notes/util:bin AS util-bin


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: XMLSEC
  FROM 11notes/python:${PYTHON_VERSION} AS build
  COPY --from=util-bin / /
  ARG PYTHON_VERSION \
      WHEEL_NAME \
      WHEEL_VERSION \
      BUILD_ROOT \
      BUILD_SRC
  ENV CFLAGS=-flto=auto
  USER root

  # add build requirements global
  RUN set -ex; \
    apk --no-cache --update add \
      git \
      cargo \
      python3-dev \
      py3-pkgconfig \
      py3-setuptools \
      py3-maturin \
      py3-gpep517 \
      py3-wheel;

  # get source of package
  RUN set -ex; \
    eleven git clone ${BUILD_SRC} v${WHEEL_VERSION};

  # build wheels
  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    gpep517 build-wheel \
      --wheel-dir .dist \
      --config-json '{"--build-option": ["--with-cython"]}' \
      --output-fd 3 3>&1 >&2;

  # push wheels
  RUN set -ex; \
    mkdir -p /dst; \
    mv ${BUILD_ROOT}/.dist /;

# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM alpine
  COPY --from=build --chown=1001:118 /.dist /.dist
  ENTRYPOINT ["/bin/cp"]
  CMD ["-af", "/.dist/.", "/whl"]