ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION}-alpine

ARG VERSION=latest

ENV TZ=UTC
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.7.3/wait /wait

COPY files/local_settings.py /etc/patchman/local_settings.py
COPY files/requirements.txt /requirements.txt
COPY files/run.sh /run.sh

# hadolint ignore=DL3018
RUN apk add --no-cache \
      curl \
      libmagic \
      libpq \
      libstdc++ \
      libxslt \
    && apk add --no-cache --virtual .build-deps \
      build-base \
      git \
      libffi-dev \
      libxml2-dev \
      libxslt-dev \
      openssl-dev \
      postgresql-dev \
      python3-dev \
    && chmod +x /wait

RUN if [ $VERSION = "latest" ]; then git clone https://github.com/furlongm/patchman.git /repository; fi \
    && if [ $VERSION != "latest" ]; then git clone -b v$VERSION https://github.com/furlongm/patchman.git /repository; fi

# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir -r /repository/requirements.txt \
    && pip3 install --no-cache-dir -r /requirements.txt \
    && pip3 install --no-cache-dir /repository

RUN adduser -D patchman \
    && chown patchman: /etc/patchman/local_settings.py \
    && mkdir -p /var/lib/patchman/db \
    && lib=$(python3 -c "import site; print(site.getsitepackages()[0])") \
    && mkdir -p "$lib/run/static" \
    && chown -R patchman: /var/lib/patchman "$lib/run/static"

RUN apk del .build-deps \
    && rm -rf /repository /requirements.txt

USER patchman
WORKDIR /

EXPOSE 8000

CMD ["sh", "-c", "/wait && /run.sh"]
HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1

LABEL "org.opencontainers.image.documentation"="https://docs.osism.de" \
      "org.opencontainers.image.licenses"="ASL 2.0" \
      "org.opencontainers.image.source"="https://github.com/osism/docker-patchman" \
      "org.opencontainers.image.url"="https://www.osism.de" \
      "org.opencontainers.image.vendor"="Betacloud Solutions GmbH"
