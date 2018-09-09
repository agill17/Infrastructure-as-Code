package main

import (
	"fmt"
	"syscall"
)

func getSecrets() (string, string, string) {

	var accessKey string
	var secretKey string
	var warn string
	if a, ok := syscall.Getenv("AWS_ACCESS"); ok {
		accessKey = a
	} else {
		warn += fmt.Sprintf("AWS_ACCESS env var is nil in operator deployment. Please set up AWS_ACCESS as an environment variable in operator deployment\n")
	}

	if s, ok := syscall.Getenv("AWS_SECRET"); ok {
		secretKey = s
	} else {
		warn += fmt.Sprintf("AWS_SECRET env var is nil in operator deployment. Please set up AWS_SECRET as an environment variable in operator deployment\n")
	}

	return accessKey, secretKey, warn

}
