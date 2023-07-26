SERVER_NAME=aplz_server
.PHONY: build/win build/linux run clean

build-win:
	env GOOS=windows GOARCH=amd64 go build -o ../builds/${SERVER_NAME}.exe main.go

build:
	env GOOS=linux GOARCH=amd64 go build -o ../builds/${SERVER_NAME} main.go

run: $(CMAKE) build
	../builds/${SERVER_NAME}

clean:
	go clean
	rm ${SERVER_NAME}
