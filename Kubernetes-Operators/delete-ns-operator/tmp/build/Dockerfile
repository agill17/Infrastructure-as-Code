FROM alpine
ENV HELM_VERSION="v2.10.0"

RUN apk add --no-cache ca-certificates \
    && wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

RUN adduser -D delete-ns-operator
USER delete-ns-operator

ADD tmp/_output/bin/delete-ns-operator /usr/local/bin/delete-ns-operator
