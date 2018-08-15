package main

import (
	"context"
	"runtime"
	"strconv"
	"syscall"

	stub "github.com/agill17/s3-operator/pkg/stub"
	sdk "github.com/operator-framework/operator-sdk/pkg/sdk"
	sdkVersion "github.com/operator-framework/operator-sdk/version"

	"github.com/sirupsen/logrus"
)

func printVersion() {
	logrus.Infof("Go Version: %s", runtime.Version())
	logrus.Infof("Go OS/Arch: %s/%s", runtime.GOOS, runtime.GOARCH)
	logrus.Infof("operator-sdk Version: %v", sdkVersion.Version)
}

const (
	// seconds
	defaultResyncPeriod = 5
)

func main() {
	printVersion()

	sdk.ExposeMetricsPort()

	resource := "amritgill.alpha.coveros.com/v1alpha1"
	kind := "S3"
	var resyncPeriod = defaultResyncPeriod
	if pollTime, exists := syscall.Getenv("RESYNC_PERIOD"); exists {
		resyncPeriod, _ = strconv.Atoi(pollTime)
	}
	logrus.Infof("Watching %s, %s, %s, %d", resource, kind, "", resyncPeriod)
	sdk.Watch(resource, kind, "", resyncPeriod)
	sdk.Handle(stub.NewHandler())
	sdk.Run(context.TODO())
}
