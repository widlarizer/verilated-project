# verilator template

this is wip sample verilator template to clone and implement a verilated testbench using cpp.
mainly derived from the 4 tutorials provided by the itsembedded.com with quality of life improvements and additional stack changes

> different examples are implemented in different branches, main branch is the template

## directory structure

```text
--- obj_dir : where the verilated files end up (converted files from verilog to cpp)
--- alu.sv  : main module file
--- alu_tb  : testbench file with _tb added to main module file
--- makefile: command structuring to make easier execution of compilations
--- .clangd : clangd flags configurations to avoid verilator pitfalls and ease intellisense
--- .stamp.verilate : a temporaray file generated at a make step for tracking
--- .rules.verible_lint : adjust verible lint rules to suppress some annoying style guides
--- license
```

## getting started

note that your top level module name should be the name of the sv or v file you are creating (convention an ease).
your testbench file will be modulename_tb.cpp and it is assumed you have verilator, gtkwave and make and clangd in path.

1. go to makefile and assign the `MODULE` Vtope
2. that's it, write and change your code in the module and tb files and run `make waves`, if there is an error try to fix it and `make clean && make waves`
3. commands are available for each step separately too `make build`, `make sim`, `make lint`

> [!TIP]
> if you want to enable clangd debugging properly you might want to generate compile_commands.json, you can do this by running `make bear`, you must have installed bear for this to work
> another alternative is compiledb or you can do this manually using .clangd

## todo

- [ ] figure out a way to skip manually including `Vtop.h` and type files
- [ ] experiment with zig build system instead of make files
- [ ] move from make to just as the command runner
- [ ] vscode editor config branch - low priority
- [ ] initializer script for detecting or requesting and changing modulenames throughout files and commands
- [x] better way for verilator intellisense
