set dotenv-load
set shell := ["nu", "-c"]
MODULE := "alu"
alias s := sim
tmpdir  := `mktemp -d`
version := "0.2.7"
tardir  := tmpdir / "awesomesauce-" + version
tarball := tardir + ".tar.gz"
@default:
    just -f verilator.justfile

default:
    just --list

# simulate
sim:

# recipe param as env variable with $ sign
# hello $name:
#    echo $name

# Verilate
verilate: .stamp.verilate

# Build
build: "obj_dir/V{{MODULE}}"

# View waveforms
waves: waveform.vcd
    @echo
    @echo "### WAVES ###"
    gtkwave -6 waveform.vcd

# Generate waveform
waveform.vcd: "./obj_dir/V{{MODULE}}"
    @echo
    @echo "### SIMULATING ###"
    @./obj_dir/V{{MODULE}} +verilator+rand+reset+2

# Build simulation
"./obj_dir/V{{MODULE}}": .stamp.verilate
    @echo
    @echo "### BUILDING SIM ###"
    make -C obj_dir -f V{{MODULE}}.mk V{{MODULE}}

# Verilate
.stamp.verilate: "{{MODULE}}.sv" "tb_{{MODULE}}.cpp"
    @echo
    @echo "### VERILATING ###"
    verilator -CFLAGS -std=c++14 -Wall --trace --x-assign unique --x-initial unique -cc {{MODULE}}.sv --exe tb_{{MODULE}}.cpp
    @touch .stamp.verilate

# Lint
lint: "{{MODULE}}.sv"
    verilator --lint-only {{MODULE}}.sv

# clang database gen
bear:
  bear -- make sim

# Clean
clean:
    rm -rf .stamp.*
    rm -rf ./obj_dir
    rm -rf waveform.vcd
