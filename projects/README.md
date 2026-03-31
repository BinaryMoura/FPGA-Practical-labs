# Projects

This folder contains practical FPGA projects ranging from basic blink LED to advanced implementations like RISC-V softcore processors.

---

## Project List

| Project | Difficulty | Description |
|---------|------------|-------------|
| [Toggle LED](./Toggle_led/) | Beginner | ON/OFF control system via button with debounce and toggle |
| [Servo Control](./Servo_control/) | Beginner | Servo motor (Futaba S3003) control with synchronized LED progress bar |

---

## Toggle LED

**ON/OFF control system via button with debounce and toggle in FPGA**

![Toggle LED Demo](./Toggle_led/Assets/running.gif)

A physical button alternates the state of 6 LEDs between on and off. Demonstrates fundamental concepts of synchronous digital design including external signal synchronization, mechanical switch debouncing, and toggle logic in Verilog.

**Key Concepts:**
- Synchronous clock design
- Mechanical switch debouncing (~5.4ms)
- Falling edge detection
- Bitwise toggle logic

**Hardware:** Tang Nano 9K (Gowin GW1NR-9C)

**Location:** [./Toggle_led/](./Toggle_led/)

---

## Servo Control

**Servo motor control with synchronized LED progress bar**

A button press controls both a 6-LED progress bar and a servo motor position. Demonstrates PWM (Pulse Width Modulation) generation, smooth servo motion control, and bidirectional state machines.

**Behavior:**
- Clicks 1-6: LEDs light up progressively, servo moves 0° → 90°
- Clicks 7+: LEDs turn off progressively, servo returns 90° → 0°
- At 0°: Cycle repeats automatically

**Key Concepts:**
- PWM signal generation (50Hz, 0.5ms-2.0ms pulse width)
- Servo motor control theory
- Smooth motion with gradual duty cycle adjustment
- Bidirectional state machine (GOING_UP/GOING_DOWN)
- Button debouncing (~10ms)

**Hardware:**
- Tang Nano 9K (Gowin GW1NR-9C)
- Futaba S3003 Servo Motor

**Location:** [./Servo_control/](./Servo_control/)

---

*More projects coming soon!*
