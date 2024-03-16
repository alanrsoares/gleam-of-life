# life

Conway's Game of Life implementation in [Gleam](https://gleam.run)

[![Package Version](https://img.shields.io/hexpm/v/life)](https://hex.pm/packages/life)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/life/)


![image](https://github.com/alanrsoares/gleam-of-life/assets/273334/f5548c0d-731c-453e-ba50-e6a2efc5a88d)


## Development

```sh
gleam run -g 50 # runs the game for 50 generations
gleam test  # Run the tests
```

## Compiling

```sh
# Compile the program to an escript
gleam run -m gleescript

# Make the escript executable
chmod +x ./life

# Run the program
./life -g 50
```
