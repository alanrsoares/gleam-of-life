help:
	@echo "build - build the project"
	@echo "clean - remove the binary file"
	@echo "run - run the binary file"

bin:
	@echo "Building binary..."
	@gleam run -m gleescript && chmod +x ./life

clean: 
	@rm -rf life build

t:
	@gleam test

run: 
	./life