help:
	@echo "build - build the project"
	@echo "clean - remove the binary file"
	@echo "run - run the binary file"

build: 
	gleam run -m gleescript && chmod +x ./life

clean: 
	rm -rf life build

test:
	gleam test

run: 
	./life