# 🧠 Verilog SPI Interface for FPGA

A fully-featured SPI (Serial Peripheral Interface) implementation in Verilog, supporting both master and slave modes. Designed for FPGA use, this module is highly configurable and suitable for embedded communication between devices.

## ✨ Features

- ✅ Master and Slave modules  
- 🔁 Full-duplex communication  
- 🔄 Dual buffers for smooth data transmission  
- 🔧 All 4 SPI modes (0–3) supported via CPOL and CPHA settings  
- 🔼🔽 MSB-first / LSB-first configurable bit order  
- 🕒 Adjustable SCLK frequency  
- 🧩 Multiple slave support with dynamic selection  
- ⚙️ Parameterizable design for easy integration into larger systems  
- 🧪 Testbench and simulation-ready (ModelSim-compatible)

## 📦 Use Cases

- FPGA-based embedded systems  
- Communication with SPI sensors, memory chips, or other microcontrollers  
- Educational or prototyping projects needing customizable SPI logic

## 🛠 Tools & Technologies

- Verilog HDL  
- ModelSim (simulation)  
- Target: Any FPGA board with SPI-compatible I/O
