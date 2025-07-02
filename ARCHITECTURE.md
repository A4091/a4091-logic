# A4091 Zorro III SCSI-2 Controller: High-Level Architectural Description

This document outlines the architecture of the Commodore A4091 Zorro III SCSI-2 controller Programmable Logic Device (PLD) source files. The design is partitioned across several PLDs, each responsible for a specific subset of the controller's functionality. Together, they manage the complex interactions between the Amiga's Zorro III bus and the NCR 53C710 SCSI controller chip.

The architecture can be broken down into the following key functional blocks:

1.  **Zorro III Bus Interface and Configuration**
2.  **Address Decoding and Device Mapping**
3.  **Data Bus and Buffer Management**
4.  **Interrupt Control**
5.  **DMA and Bus Arbitration**
6.  **SCSI Bus Interface Logic**

---

## 1. Zorro III Bus Interface and Configuration (U202)

This block is the primary interface to the Zorro III bus for autoconfiguration and basic bus cycle handling.

* **AutoConfig:** U202 manages the Zorro III autoconfiguration process. It handles the `CFGIN` (Configuration In) and `CFGOUT` (Configuration Out) chain, allowing the Amiga to recognize and configure the A4091 card. It contains logic to latch the board's base address when written to by the host.
* **Board Activation:** It includes a "SHUTUP" mechanism, which allows the host to disable the card if needed.
* **Slave Response:** It generates the `SLAVE` signal to the Zorro III bus, indicating that the A4091 is responding to a bus access.
* **Cache Inhibit:** It asserts the `CINH` signal to prevent the CPU from caching the A4091's address space, which is critical for I/O devices.

## 2. Address Decoding and Device Mapping (U203)

This PLD is responsible for decoding addresses from the Zorro III bus to select the various onboard devices.

* **Device Selects:** U203 decodes the upper address lines to generate chip select signals for:
    * `ROM`: The boot ROM containing the device driver.
    * `SCSI`: The NCR 53C710 SCSI controller chip.
    * `INTREG`: The interrupt control register.
    * `SID`: A read-only register for the SCSI ID jumpers.
* **Memory Map:** It partitions the board's 16MB address space, mapping the ROM to the lower portion and the SCSI chip and registers to the upper portion.

## 3. Data Bus and Buffer Management (U205)

This logic controls the flow of data between the Zorro III bus, the local data bus, and the SCSI chip.

* **Data Bus Direction:** U205 generates the `D2Z` (Data to Zorro) and `Z2D` (Zorro to Data) signals, which control the direction of the bidirectional data buffers. This is determined by whether the current cycle is a read or write, and whether the A4091 is acting as a bus master (DMA) or slave.
* **Buffer Enable:** It controls the output enable (`DBOE`) for the data transceivers, ensuring they are only active during valid data transfer phases.
* **Data Latching:** The `DBLT` (Data Bus Latch) signal is generated to latch data at the correct time during a bus cycle.
* **Address Buffer Control:** It also manages the address buffers (`ABOEL`, `ABOEH`), enabling them during slave cycles and disabling them when the SCSI chip is performing DMA.
* **Cycle Termination (`DTACK`):** U205 is responsible for generating the `DTACK` (Data Transfer Acknowledge) signal back to the Zorro III bus to terminate slave cycles. The timing of `DTACK` is determined by the device being accessed (e.g., fast for registers, delayed for ROM).

## 4. Interrupt Control (U203 & U207)

Interrupt handling is split between two PLDs.

* **Interrupt Generation (U207):**
    * Receives the interrupt request (`SINT`) from the SCSI chip.
    * Generates the `INT` signal for internal use and the open-drain `INT2` signal for the Zorro bus.
    * Logic ensures that the interrupt signal only changes between Zorro III bus cycles to maintain stability.
* **Interrupt Acknowledge and Vector Handling (U203):**
    * Detects an interrupt acknowledge cycle from the host CPU.
    * Manages the handshaking (`INTSERV`, `INTPOLL`, `INTVEC`) required to place the interrupt vector on the data bus.
    * It requires an interrupt vector to be written to its register (`INTREG`) before it will respond to acknowledge cycles.

## 5. DMA and Bus Arbitration (U303)

This block manages the A4091's role as a Zorro III bus master, which is essential for DMA transfers.

* **Bus Request:** When the SCSI chip requests the bus for a DMA transfer (`SBR`), U303 asserts the Zorro III bus request (`EBR`).
* **Bus Grant:** It waits for a bus grant (`EBG`) from the Zorro III arbiter.
* **Bus Ownership:** Once the grant is received, it asserts `MYBUS`, a signal indicating that the A4091 is now the bus master. It holds the bus until the transfer is complete.
* **Registration:** It manages the Zorro III master registration process, toggling `EBR` to register and unregister as a bus master.
* **Local Bus Grant:** It grants the local A4091 bus to the SCSI chip (`SBG`) so it can initiate a transfer.

## 6. SCSI Bus Interface Logic (U304, U305, U306)

This is the most complex part of the design, translating between Zorro III bus cycles and the specific signaling required by the NCR 53C710 SCSI chip.

* **Slave Interface (U304):**
    * Translates Zorro III slave read/write cycles into the address (`AS`) and data (`DS`) strobes required by the SCSI chip.
    * Converts Zorro III data strobes (`DS3`-`DS0`) into the 680x0-style size signals (`SIZ1`, `SIZ0`) and low address lines (`A1`, `A0`) that the SCSI chip expects.
* **Master Interface (U305):**
    * When the A4091 is the bus master, this PLD generates the Zorro III data strobes (`DS3`-`DS0`) based on the size and address signals from the SCSI chip.
    * It creates a qualified address strobe (`ASQ`) to initiate master cycles on the Zorro bus.
    * It generates a buffered version of the Full Cycle Strobe (`BFCS`) to drive the local bus cycle.
* **Burst and Cycle Control (U306):**
    * Generates the main Zorro III Full Cycle Strobe (`EFCS`) during DMA master cycles.
    * Controls the Data Output Enable (`DOE`) signal to time the enabling of data drivers during a master cycle.
    * Synchronizes and generates the termination signal (`STERM`) back to the SCSI chip based on the Zorro III `DTACK`.
    * Includes a `NOZ3` signal to disable the A4091 in case it is operated in a Zorro II only Amiga.
