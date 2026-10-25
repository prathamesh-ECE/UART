# UART (8N1) in Verilog

A UART made of three modules: a baud generator, a receiver and a transmitter. Written for FPGA use (Sipeed Tang Nano 20K, Gowin FPGA Designer) and used to load programs into the 8-bit CPU.

## Modules

| File | Module | Role |
|---|---|---|
| `baud_generator.v` | `baud_gen` | Produces the transmit enable pulse and the 16x oversampled receive enable pulse |
| `reciver.v` | `uart_rx` | Receives one 8N1 frame and raises `ready` with the byte on `data_out` |
| `transmittor.v` | `transimt` | Sends one 8N1 frame when `wr_en` is pulsed, with a `busy` flag |

## Frame format

- 1 start bit (low), 8 data bits (LSB first), 1 stop bit (high), no parity
- Idle line level is high

## Baud generator

| Output | Divider | Meaning |
|---|---|---|
| `tx_en` | 5209 clock cycles per pulse | One pulse per bit period |
| `rx_en` | 326 clock cycles per pulse | 16 pulses per bit period (16x oversampling) |

With a 50 MHz clock these dividers give 9600 baud. For another clock frequency or baud rate, change the two compare values: `clk_freq / baud` for `tx_en` and `clk_freq / (baud * 16)` for `rx_en`.

## Receiver (`uart_rx`)

| Port | Dir | Description |
|---|---|---|
| `clk` | in | System clock |
| `rst` | in | Synchronous reset |
| `rx` | in | Serial input |
| `clk_en` | in | 16x oversample enable from `baud_gen.rx_en` |
| `ready_clr` | in | Clears `ready` |
| `ready` | out | High when a new byte is available |
| `data_out[7:0]` | out | Received byte |

State machine: `start`, `data_out_state`, `stop`. Each bit is sampled in the middle of its period (sample count 8 of 16).

## Transmitter (`transimt`)

| Port | Dir | Description |
|---|---|---|
| `clk` | in | System clock |
| `rst` | in | Reset |
| `enb` | in | Bit-rate enable from `baud_gen.tx_en` |
| `wr_en` | in | Pulse to start sending `data_in` |
| `data_in[7:0]` | in | Byte to send |
| `tx` | out | Serial output |
| `busy` | out | High while a frame is being sent |

State machine: `ideal`, `start`, `data`, `stop`.

## Wiring

```
clk -> baud_gen -> rx_en -> uart_rx.clk_en
                -> tx_en -> transimt.enb
rx_pin -> uart_rx.rx
transimt.tx -> tx_pin
```

## Status

Work in progress, not yet verified in simulation or on hardware.

## Tools

- Board: Sipeed Tang Nano 20K
- Toolchain: Gowin FPGA Designer
- Language: Verilog HDL

## Author

Prathamesh Tambe, B.Tech ECE (AI & ML), MIT World Peace University, Pune.
