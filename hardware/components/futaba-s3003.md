# Futaba S3003 Servo Motor

The **Futaba S3003** is a standard-sized servo motor designed for robotics projects and prototyping platforms such as Arduino, PIC, AVR, ARM, and FPGAs. It provides reliable angular positioning with a 180° rotation range and adequate torque for most hobbyist and educational applications.

## Overview

The S3003 is one of the most popular standard servos in the maker community due to its affordability, reliability, and ease of use. It is commonly used in:

- Remote-controlled vehicles (cars, boats, aircraft)
- Robotic arms and grippers
- Automated camera mounts
- Educational robotics projects
- FPGA-controlled positioning systems

## Technical Specifications

| Parameter | Specification |
|-----------|---------------|
| **Model** | Futaba S3003 |
| **Motor Type** | DC motor with plastic gears |
| **Bearing Type** | Bushing (plastic) |
| **Operating Voltage** | 4.8V - 6.0V DC |
| **Stall Torque (4.8V)** | 3.2 kg·cm (44 oz·in) |
| **Stall Torque (6.0V)** | 4.2 kg·cm (58 oz·in) |
| **Rotation Range** | 180° (±90° from center) |
| **Operating Speed (4.8V)** | 0.23 sec / 60° |
| **Operating Speed (6.0V)** | 0.19 sec / 60° |
| **Idle Current** | ~8 mA |
| **Stall Current** | ~130 mA |
| **Connector Wire Length** | 28 cm |
| **Weight** | ~37g |
| **Dimensions** | 40.0 × 20.0 × 36.5 mm |

## Control Signal

The S3003 uses standard PWM (Pulse Width Modulation) control:

| Pulse Width | Position |
|-------------|----------|
| 0.5 ms | 0° (full left) |
| 1.5 ms | 90° (center) |
| 2.5 ms | 180° (full right) |

**PWM Period:** 50 Hz (20 ms)

### Wiring

```
Futaba S3003 Connector:
    ___________
   |  O   O   O |
   | Brown Red Orange|
    -----------
     |     |    |
     |     |    +-- Signal (PWM control input)
     |     +------- VCC (+4.8V to +6.0V)
     +------------- GND (Ground)
```

**Wire Colors:**
- **Brown** - Ground (GND)
- **Red** - Power (+4.8V to +6.0V)
- **Orange** - Control Signal (PWM input)

## Usage Notes

### Power Supply
- **Do not power directly from FPGA I/O pins** - servos require more current than GPIO pins can provide
- Use an external 5V power supply or a dedicated servo driver board
- Ensure the power supply can provide at least 1A for stable operation
- Connect the ground of the servo power supply to the FPGA ground

### Control Signal Connection
- The control signal (orange wire) can be connected directly to an FPGA I/O pin
- The signal is 3.3V or 5V logic compatible (TTL level)
- Use a current-limiting resistor (220Ω - 1kΩ) in series if desired for protection

### Torque Considerations
- The rated torque (4.2 kg·cm at 6V) is the maximum under stall conditions
- Continuous operation near stall current will overheat and damage the servo
- For continuous load applications, use at most 20-30% of stall torque

## Comparison: 4.8V vs 6.0V Operation

| Parameter | 4.8V | 6.0V | Notes |
|-----------|------|------|-------|
| Torque | 3.2 kg·cm | 4.2 kg·cm | 31% more torque at 6V |
| Speed | 0.23s/60° | 0.19s/60° | 17% faster at 6V |
| Current | Lower | Higher | Higher power consumption at 6V |

**Recommendation:** Use 6V for better performance when possible, but ensure your power supply can handle the increased current draw.

## Dimensional Drawing

```
        40.0 mm
     <------------>
     +------------+  ---
     |            |   |
     |   MOTOR    |  20.0 mm
     |   BODY     |   |
     |            |   |
     +------------+  ---
          ||
          || Output Shaft
          ||
     +------------+
     |  MOUNTING  |
     |   FLANGE   |  36.5 mm (total height)
     +------------+
     o          o  Mounting holes (spacing: ~10mm)
```

## Resources

- [Futaba Official Website](https://www.futaba.co.jp)
- Datasheet: Search "Futaba S3003 datasheet" for official specifications

## Related Projects

- [Servo Control with Progress LEDs](../../projects/Servo_control/) - FPGA implementation example for Tang Nano 9K
