# life

Conway's Game of Life implementation in Gleam

[![Package Version](https://img.shields.io/hexpm/v/life)](https://hex.pm/packages/life)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/life/)

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
