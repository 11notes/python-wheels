# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# :: GLOBAL
  ARG PYTHON_VERSION=0 \
      WHEEL_NAME="" \
      WHEEL_VERSION=0

# :: APP SPECIFIC
  ARG BUILD_ROOT=/cryptography \
      BUILD_SRC=pyca/cryptography.git

# :: FOREIGN IMAGES
  FROM 11notes/util:bin AS util-bin


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: WHEEL
  FROM 11notes/python:${PYTHON_VERSION} AS build
  COPY --from=util-bin / /
  ARG PYTHON_VERSION \
      WHEEL_NAME \
      WHEEL_VERSION \
      BUILD_ROOT \
      BUILD_SRC
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

  # add build requirements wheel specific
  RUN set -ex; \
    apk --no-cache --update add \
      py3-cffi \
      openssl-dev; \
    pip install -f https://11notes.github.io/python-wheels/ maturin;

  # get source of package
  RUN set -ex; \
    eleven git clone ${BUILD_SRC} ${WHEEL_VERSION};

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