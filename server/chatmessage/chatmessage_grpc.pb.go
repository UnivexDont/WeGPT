// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.2.0
// - protoc             v3.19.4
// source: chatmessage/chatmessage.proto

package chatmessage

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

// ChatMessagerClient is the client API for ChatMessager service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type ChatMessagerClient interface {
	// Sends a greeting
	SendMessage(ctx context.Context, in *ChatMessageRequest, opts ...grpc.CallOption) (ChatMessager_SendMessageClient, error)
}

type chatMessagerClient struct {
	cc grpc.ClientConnInterface
}

func NewChatMessagerClient(cc grpc.ClientConnInterface) ChatMessagerClient {
	return &chatMessagerClient{cc}
}

func (c *chatMessagerClient) SendMessage(ctx context.Context, in *ChatMessageRequest, opts ...grpc.CallOption) (ChatMessager_SendMessageClient, error) {
	stream, err := c.cc.NewStream(ctx, &ChatMessager_ServiceDesc.Streams[0], "/chatmessage.ChatMessager/SendMessage", opts...)
	if err != nil {
		return nil, err
	}
	x := &chatMessagerSendMessageClient{stream}
	if err := x.ClientStream.SendMsg(in); err != nil {
		return nil, err
	}
	if err := x.ClientStream.CloseSend(); err != nil {
		return nil, err
	}
	return x, nil
}

type ChatMessager_SendMessageClient interface {
	Recv() (*ChatMessageReply, error)
	grpc.ClientStream
}

type chatMessagerSendMessageClient struct {
	grpc.ClientStream
}

func (x *chatMessagerSendMessageClient) Recv() (*ChatMessageReply, error) {
	m := new(ChatMessageReply)
	if err := x.ClientStream.RecvMsg(m); err != nil {
		return nil, err
	}
	return m, nil
}

// ChatMessagerServer is the server API for ChatMessager service.
// All implementations must embed UnimplementedChatMessagerServer
// for forward compatibility
type ChatMessagerServer interface {
	// Sends a greeting
	SendMessage(*ChatMessageRequest, ChatMessager_SendMessageServer) error
	mustEmbedUnimplementedChatMessagerServer()
}

// UnimplementedChatMessagerServer must be embedded to have forward compatible implementations.
type UnimplementedChatMessagerServer struct {
}

func (UnimplementedChatMessagerServer) SendMessage(*ChatMessageRequest, ChatMessager_SendMessageServer) error {
	return status.Errorf(codes.Unimplemented, "method SendMessage not implemented")
}
func (UnimplementedChatMessagerServer) mustEmbedUnimplementedChatMessagerServer() {}

// UnsafeChatMessagerServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to ChatMessagerServer will
// result in compilation errors.
type UnsafeChatMessagerServer interface {
	mustEmbedUnimplementedChatMessagerServer()
}

func RegisterChatMessagerServer(s grpc.ServiceRegistrar, srv ChatMessagerServer) {
	s.RegisterService(&ChatMessager_ServiceDesc, srv)
}

func _ChatMessager_SendMessage_Handler(srv interface{}, stream grpc.ServerStream) error {
	m := new(ChatMessageRequest)
	if err := stream.RecvMsg(m); err != nil {
		return err
	}
	return srv.(ChatMessagerServer).SendMessage(m, &chatMessagerSendMessageServer{stream})
}

type ChatMessager_SendMessageServer interface {
	Send(*ChatMessageReply) error
	grpc.ServerStream
}

type chatMessagerSendMessageServer struct {
	grpc.ServerStream
}

func (x *chatMessagerSendMessageServer) Send(m *ChatMessageReply) error {
	return x.ServerStream.SendMsg(m)
}

// ChatMessager_ServiceDesc is the grpc.ServiceDesc for ChatMessager service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var ChatMessager_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "chatmessage.ChatMessager",
	HandlerType: (*ChatMessagerServer)(nil),
	Methods:     []grpc.MethodDesc{},
	Streams: []grpc.StreamDesc{
		{
			StreamName:    "SendMessage",
			Handler:       _ChatMessager_SendMessage_Handler,
			ServerStreams: true,
		},
	},
	Metadata: "chatmessage/chatmessage.proto",
}
