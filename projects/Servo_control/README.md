# Servo Control with Progress LEDs

FPGA project for Tang Nano 9K that controls a servo motor (Futaba S3003) synchronized with a 6-LED progress bar, using a button for interaction.

## Behavior

- **Clicks 1-6**: LEDs light up progressively from left to right, servo moves from 0° to 90°
- **Clicks 7+**: LEDs turn off progressively from right to left, servo returns from 90° to 0°
- **At 0°**: Cycle restarts, LEDs begin lighting up again

## Visual Demonstration

```
LED State Progression:
Count 0: [ ] [ ] [ ] [ ] [ ] [ ]   Servo: 0°   (all LEDs off)
Count 1: [X] [ ] [ ] [ ] [ ] [ ]   Servo: 15°  (1 LED on)
Count 2: [X] [X] [ ] [ ] [ ] [ ]   Servo: 30°  (2 LEDs on)
Count 3: [X] [X] [X] [ ] [ ] [ ]   Servo: 45°  (3 LEDs on)
Count 4: [X] [X] [X] [X] [ ] [ ]   Servo: 60°  (4 LEDs on)
Count 5: [X] [X] [X] [X] [X] [ ]   Servo: 75°  (5 LEDs on)
Count 6: [X] [X] [X] [X] [X] [X]   Servo: 90°  (all LEDs on)
Count 5: [ ] [X] [X] [X] [X] [X]   Servo: 75°  (descending...)
Count 0: [ ] [ ] [ ] [ ] [ ] [ ]   Servo: 0°   (cycle restarts)
```

## Hardware Requirements

- **Board**: Tang Nano 9K (GW1NR-LV9QN88PC6/I5)
- **Servo**: Futaba S3003 (or compatible standard servo)
- **Button**: S1 (built-in button on the board)
- **Power**: USB 5V for the board, external 5V for servo recommended

## Pinout

| Signal      | Pin | Description                    |
|-------------|-----|--------------------------------|
| sys_clk     | 52  | 27MHz system clock             |
| switch_pin  | 3   | Button S1 (active-low)         |
| led[5]      | 16  | LED 0 (leftmost)               |
| led[4]      | 15  | LED 1                          |
| led[3]      | 14  | LED 2                          |
| led[2]      | 13  | LED 3                          |
| led[1]      | 11  | LED 4                          |
| led[0]      | 10  | LED 5 (rightmost)              |
| servo_pwm   | 76  | Servo PWM signal (orange wire) |

## Servo Wiring (Futaba S3003)

```
Futaba S3003 Servo Connector:
    ___________
   |  O   O   O |
   | Brown Red Orange|
    -----------
     |     |    |
     |     |    +-- Signal (PWM) -> Pin 76
     |     +------- VCC (+5V)
     +------------- GND
```

**Important**: The servo should be powered externally or from a separate 5V supply capable of handling the current draw. Do not power the servo directly from the FPGA board's 3.3V pins.

## Technical Details

### Clock and Timing

- **System Clock**: 27 MHz
- **Clock Period**: 37.037 ns

### Servo PWM Specifications

Servos use Pulse Width Modulation (PWM) to control position. The position is determined by the pulse width within a 20ms period (50Hz).

| Angle | Pulse Width | Clock Cycles (@27MHz) |
|-------|-------------|----------------------|
| 0°    | 0.5 ms      | 13,500               |
| 15°   | 0.75 ms     | 20,250               |
| 30°   | 1.0 ms      | 27,000               |
| 45°   | 1.25 ms     | 33,750               |
| 60°   | 1.5 ms      | 40,500               |
| 75°   | 1.75 ms     | 47,250               |
| 90°   | 2.0 ms      | 54,000               |

**PWM Period**: 20 ms = 540,000 clock cycles

### Smooth Motion

The servo moves smoothly between positions by incrementing/decrementing the duty cycle by 50 cycles per clock tick, rather than jumping directly to the target value.

### Button Debouncing

A 10ms debounce period (270,000 clock cycles) prevents false triggering from mechanical switch bounce.

## Project Structure

```
servo_control/
├── src/
│   ├── progress_servo.v    # Main Verilog module
│   └── servo_control.cst   # Physical constraints file
├── impl/                   # Implementation output
├── servo_control.gprj      # Gowin project file
└── README.md               # This file
```

## How to Build

1. Open `servo_control.gprj` in Gowin EDA
2. Click "Synthesize"
3. Click "Place & Route"
4. Click "Download" to program the board

## How It Works

### State Machine

The module uses a simple state machine with two states:
- **GOING_UP**: LED count increases (0→6), servo moves toward 90°
- **GOING_DOWN**: LED count decreases (6→0), servo moves toward 0°

### LED Mapping

The LEDs are active-low (0 = ON, 1 = OFF) and mapped as follows:

```verilog
case (led_count)
    3'd0: led = 6'b111111;  // All off
    3'd1: led = 6'b011111;  // LED 5 on
    3'd2: led = 6'b001111;  // LEDs 5-4 on
    3'd3: led = 6'b000111;  // LEDs 5-3 on
    3'd4: led = 6'b000011;  // LEDs 5-2 on
    3'd5: led = 6'b000001;  // LEDs 5-1 on
    3'd6: led = 6'b000000;  // All on
endcase
```

## License

This project is part of FPGA Practical Labs for educational purposes.
