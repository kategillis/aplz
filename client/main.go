package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/exec"

	"github.com/fsnotify/fsnotify"
	_ "github.com/joho/godotenv/autoload"
)

var connHost = os.Getenv("aplz_SERVER_URL")
var connPort = os.Getenv("aplz_SERVER_PORT")
var connType = "tcp"

type aplzFle struct {
	Name     string
	Comments []aplzComment
}

type aplzComment struct {
	CommenterName string
	Comment       string
}

func main() {
	fmt.Println("Connecting to " + connType + " server " + connHost + ":" + connPort)

	conn, err := net.Dial(connType, connHost+":"+connPort)
	if err != nil {
		fmt.Println("Error connecting:", err.Error())
		os.Exit(1)
	}

	scoreName := os.Getenv("aplz_SCORENAME")
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err)
	}
	defer watcher.Close()

	// Start listening for events.
	go func() {
		for {
			select {
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				log.Println("event:", event)
				if event.Has(fsnotify.Write) {
					log.Println("modified file:", event.Name)

					if event.Name != fmt.Sprintf("%s/%s.json", os.Getenv("aplz_PATH"), scoreName) {
						break
					}
					file, err := os.Open(event.Name)
					if err != nil {
						return
					}
					defer file.Close()

					// Get the file size
					stat, err := file.Stat()
					if err != nil {
						return
					}

					// Read the file into a byte slice
					bs := make([]byte, stat.Size())
					_, err = bufio.NewReader(file).Read(bs)
					if err != nil && err != io.EOF {
						return
					}

					var input aplzFle
					json.Unmarshal(bs, &input)

					//reader := bufio.NewReader(os.Stdin)

					fmt.Print("Text to send: ")
					conn.Write(bs)

					message, _ := bufio.NewReader(conn).ReadString('\n')

					log.Print("Server relay:", message)

				}
			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				log.Println("error:", err)
			}
		}
	}()

	log.Printf("WATCH PATH %s", os.Getenv("aplz_PATH"))

	cmd := exec.Command("ls", os.Getenv("aplz_PATH"))

	// The `Output` method executes the command and
	// collects the output, returning its value
	out, err := cmd.Output()
	if err != nil {
		// if there was any error, print it here
		fmt.Println("could not run command: ", err)
	}
	// otherwise, print the output from running the command
	fmt.Println("Output: ", string(out))

	err = watcher.Add(os.Getenv("aplz_PATH"))

	if err != nil {
		fmt.Printf("Cats %s || %s ||  %s", scoreName, os.Getenv("aplz_PATH"), err.Error())
		log.Fatal(err)
	}

	// Block main goroutine forever.
	<-make(chan struct{})

}
