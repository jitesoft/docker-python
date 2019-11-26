# syntax=docker/dockerfile:experimental
FROM registry.gitlab.com/jitesoft/dockerfiles/alpine:latest
ARG PYTHON_VERSION
ARG PY_PIP_VERSION
LABEL maintainer="Johannes Tegnér <johannes@jitesoft.com>" \
      maintainer.org="Jitesoft" \
      maintainer.org.uri="https://jitesoft.com" \
      com.jitesoft.project.repo.type="git" \
      com.jitesoft.project.repo.uri="https://gitlab.com/jitesoft/dockerfiles/python" \
      com.jitesoft.project.repo.issues="https://gitlab.com/jitesoft/dockerfiles/python/issues" \
      com.jitesoft.project.registry.uri="registry.gitlab.com/jitesoft/dockerfiles/python" \
      com.jitesoft.app.python.version="${PYTHON_VERSION}" \
      com.jitesoft.app.pip.version="${PY_PIP_VERSION}"
ARG TARGETARCH
ARG PYTHON_VERSION
ARG PY_PIP_VERSION

RUN --mount=type=bind,source=./out,target=/tmp/py-bin \
    apk add --no-cache tar curl ca-certificates \
 && ARCH=$(cat /etc/apk/arch) && echo $ARCH \
 && tar -xzhf /tmp/py-bin/python-${ARCH}.tar.gz -C /usr/local \
&& find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    | xargs -rt apk add --no-cache --virtual .runtime-deps \
 && ln -s /usr/local/bin/idle${PYTHON_VERSION:0:1} /usr/local/bin/idle \
 && ln -s /usr/local/bin/pydoc${PYTHON_VERSION:0:1} /usr/local/bin/pydoc \
 && ln -s /usr/local/bin/python${PYTHON_VERSION:0:1} /usr/local/bin/python \
 && ln -s /usr/local/bin/idle${PYTHON_VERSION:0:1} /usr/local/bin/python-config \
 && wget -qO- https://bootstrap.pypa.io/get-pip.py | python - pip==${PY_PIP_VERSION} --disable-pip-version-check --no-cache-dir \
 && find /usr/local -type d \( -name test -o -name tests -o -name idle_test \) -exec rm -rf '{}' + \
 && find /usr/local -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete \
 && apk del tar curl \
 && python --version \
 && pip --version

CMD ["python"]
