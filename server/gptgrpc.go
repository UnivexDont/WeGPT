package main

import (
	"flag"
	"fmt"
	"log"
	"net"

	"github.com/golang-jwt/jwt"
	"google.golang.org/grpc"
	pb "univex.com/wegpt/chatmessage"
	"univex.com/wegpt/grpccontrollers"
)

type WeGPTClaims struct {
	Time   int64  `json:"time"`
	AppKey string `json:"appKey"`
	jwt.StandardClaims
}

const (
	rateLimit    = 58
	maxQueueSize = rateLimit * 3
)

func Launch() {
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *grpccontrollers.Port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	interceptor := grpccontrollers.NewRateAuthLimiterInterceptor(rateLimit, maxQueueSize)
	s := grpc.NewServer(
		grpc.StreamInterceptor(interceptor.StreamInterceptor))
	pb.RegisterChatMessagerServer(s, &grpccontrollers.Server{})
	log.Printf("server listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
