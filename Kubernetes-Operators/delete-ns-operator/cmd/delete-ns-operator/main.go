package main

import (
	"context"
	"runtime"
	"strconv"
	"syscall"

	stub "github.com/agill17/delete-ns-operator/pkg/stub"
	sdk "github.com/operator-framework/operator-sdk/pkg/sdk"
	k8sutil "github.com/operator-framework/operator-sdk/pkg/util/k8sutil"
	sdkVersion "github.com/operator-framework/operator-sdk/version"

	"github.com/sirupsen/logrus"
)

// seconds
const defaultResyncPeriod = 5

func printVersion() {
	logrus.Infof("Go Version: %s", runtime.Version())
	logrus.Infof("Go OS/Arch: %s/%s", runtime.GOOS, runtime.GOARCH)
	logrus.Infof("operator-sdk Version: %v", sdkVersion.Version)
}

func main() {
	printVersion()

	sdk.ExposeMetricsPort()

	resource := "amritgill.alpha.coveros.com/v1alpha1"
	kind := "DeleteNs"
	namespace, err := k8sutil.GetWatchNamespace()
	if err != nil {
		logrus.Fatalf("Failed to get watch namespace: %v", err)
	}
	resyncPeriod := defaultResyncPeriod
	if pollTime, ok := syscall.Getenv("RESYNC_PERIOD"); ok {
		resyncPeriod, err = strconv.Atoi(pollTime)
		if err != nil {
			resyncPeriod = defaultResyncPeriod
			logrus.Warnf("ERROR!!!", err)
		}
	}
	logrus.Infof("Watching %s, %s, %s, %d", resource, kind, namespace, resyncPeriod)
	sdk.Watch(resource, kind, namespace, resyncPeriod)
	sdk.Handle(stub.NewHandler())
	sdk.Run(context.TODO())
}
