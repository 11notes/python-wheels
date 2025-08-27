# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# :: GLOBAL
  ARG PYTHON_VERSION=0 \
      WHEEL_VERSION=0

# :: APP SPECIFIC
  ARG BUILD_ROOT=/python-xmlsec

# :: FOREIGN IMAGES
  FROM 11notes/util:bin AS util-bin


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: XMLSEC
  FROM 11notes/python:${PYTHON_VERSION} AS build
  COPY --from=util-bin / /
  ARG PYTHON_VERSION \
      WHEEL_VERSION \
      BUILD_ROOT
  USER root

  # add build requirements global
  RUN set -ex; \
    apk --no-cache --update add \
      git \
      python3-dev \
      py3-pkgconfig \
      py3-setuptools \
      py3-maturin \
      py3-gpep517 \
      py3-wheel;

  # add build requirements wheel specific
  RUN set -ex; \
    apk --no-cache --update add \
      build-base \
      libressl \
      libffi-dev \
      libressl-dev \
      libxslt-dev \
      libxml2-dev \
      xmlsec-dev \
      xmlsec \
      py3-lxml;

  # get source of package
  RUN set -ex; \
    eleven git clone xmlsec/python-xmlsec.git ${WHEEL_VERSION};

  # build wheels
  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    gpep517 build-wheel \
      --wheel-dir .dist \
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
  COPY --from=build /.dist /.dist
  ENTRYPOINT ["/bin/ls"]
  CMD ["-lah"]