package main

import (
	"fmt"
	"net"
)

func process(conn net.Conn){
	defer conn.Close()

	for{
		buf := make([]byte,1024)

		n,err := conn.Read(buf)
		if err != nil{
			fmt.Println("客户端退出" , conn.RemoteAddr().String())
			return
		}
		fmt.Println(string(buf[:n]))
	}
}

func main(){
	fmt.Println("服务器开始监听……")

	listen,err := net.Listen("tcp","0.0.0.0:8888")
	if err != nil{
		fmt.Println("listen err= ",err)
		return
	}
	defer listen.Close()
	for{
		fmt.Println("等待客户端连接")
		coon,err := listen.Accept()
		if err != nil{
			fmt.Println("Accept() err=",err)
		}else{
			fmt.Printf("Accept() suc con",coon,coon.RemoteAddr())
		}
		go process(coon)
	}
	fmt.Println("Listen",listen)
}