BINARY_NAME=aplz_client
.PHONY: build/win build/linux run clean

build-win:
	env GOOS=windows GOARCH=amd64 go build -o ../builds/${BINARY_NAME}.exe main.go

build:
	env GOOS=linux GOARCH=amd64 go build -o ../builds/${BINARY_NAME} main.go
	cp .env ../builds

run: $(CMAKE) build
	../builds/${BINARY_NAME}

clean:
	go clean
	rm ${BINARY_NAME}
