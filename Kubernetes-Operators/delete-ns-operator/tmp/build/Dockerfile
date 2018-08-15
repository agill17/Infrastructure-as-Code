FROM alpine:3.6

RUN adduser -D delete-ns-operator
USER delete-ns-operator

ADD tmp/_output/bin/delete-ns-operator /usr/local/bin/delete-ns-operator
