package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"os"

	_ "github.com/joho/godotenv/autoload"
)

var connHost = os.Getenv("aplz_SERVER_URL")
var connPort = os.Getenv("aplz_SERVER_PORT")
var connType = "tcp"

type aplzCommand struct {
	Room     string
	Comments []aplzComment `json:"comments"`
}

type aplzComment struct {
	Commenter string
	Comment   string
}

type aplzServer struct {
	rooms map[string]map[net.Conn]bool
}

var h = aplzServer{
	rooms: make(map[string]map[net.Conn]bool),
}

func main() {
	fmt.Println("Starting " + connType + " server on " + connHost + ":" + connPort)
	l, err := net.Listen(connType, connHost+":"+connPort)
	if err != nil {
		fmt.Println("Error listening:", err.Error())
		os.Exit(1)
	}
	defer l.Close()

	for {
		c, err := l.Accept()
		if err != nil {
			fmt.Println("Error connecting:", err.Error())
			return
		}
		fmt.Println("Client connected.")

		fmt.Println("Client " + c.RemoteAddr().String() + " connected.")

		go handleConnection(c)
	}
}

func handleConnection(conn net.Conn) {
	buffer, err := bufio.NewReader(conn).ReadBytes('\n')

	if err != nil {
		fmt.Println("Client left.")
		conn.Close()
		return
	}

	log.Println("Client message:", string(buffer[:len(buffer)-1]))

	var cmd aplzCommand
	json.Unmarshal(buffer, &cmd)

	fmt.Printf("JSON STRUT! %v", cmd)

	conn.Write(buffer)

	handleConnection(conn)
}
