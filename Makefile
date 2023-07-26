.PHONY: build/win build run clean

build-win:
	$(MAKE) -C client build-win
	$(MAKE) -C server build-win

build:
	$(MAKE) -C client build
	$(MAKE) -C server build

run: 
	$(MAKE) build
	cd builds
	$(MAKE) -C server run &
	$(MAKE) -C client run

clean:
	go clean
	rm ${SERVER_NAME}
