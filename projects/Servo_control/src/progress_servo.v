// ============================================================================
// MODULE: progress servo
// DESCRIPTION: Progress bar LED display with servo motor control (Futaba S3003)
// See our section Hardware / Components / Futaba-s3003.md 
// ============================================================================

/*
 * BEHAVIOR OVERVIEW
 * -----------------
 * This module creates an interactive display where button presses control both
 * a 6-LED progress bar and a servo motor position.
 *
 * Click 1-6: LEDs light up progressively (left to right), servo moves 0° to 90°
 * Click 7+:  LEDs turn off progressively (right to left), servo returns 90° to 0°
 * At 0°:     Cycle repeats, LEDs begin lighting up again
 *
 * Visual representation of LED states:
 *   Count 0: [ ] [ ] [ ] [ ] [ ] [ ]   (all off)
 *   Count 1: [X] [ ] [ ] [ ] [ ] [ ]   (1 LED on)
 *   Count 2: [X] [X] [ ] [ ] [ ] [ ]   (2 LEDs on)
 *   Count 3: [X] [X] [X] [ ] [ ] [ ]   (3 LEDs on)
 *   Count 4: [X] [X] [X] [X] [ ] [ ]   (4 LEDs on)
 *   Count 5: [X] [X] [X] [X] [X] [ ]   (5 LEDs on)
 *   Count 6: [X] [X] [X] [X] [X] [X]   (all on)
 *   Count 5: [ ] [X] [X] [X] [X] [X]   (descending...)
 *
 * SERVO MOTOR BASICS
 * ------------------
 * Servo motors are controlled using Pulse Width Modulation (PWM).
 * The position is determined by the width (duration) of a pulse sent every 20ms.
 *
 * Standard servo pulse widths:
 *   - 0.5ms pulse = 0 degrees (minimum position)
 *   - 1.5ms pulse = 90 degrees (center position)
 *   - 2.5ms pulse = 180 degrees (maximum position)
 *
 * For this project, we use 0° to 90° range:
 *   - 0.5ms  = 0°  (13,500 clock cycles @ 27MHz)
 *   - 2.0ms  = 90° (54,000 clock cycles @ 27MHz)
 *
 * PWM Signal Diagram (50Hz = 20ms period):
 *    ___________                                     ___________
 *   |           |___________________________________|           |_____
 *   |<--0.5ms-->|<-------------19.5ms-------------->|<--0.5ms-->|
 *   (0 degrees)                                     (next pulse)
 *
 *    _______________________                         ___________________
 *   |                       |_______________________|                   
 *   |<-------2.0ms--------->|<-------18.0ms-------->|
 *        (90 degrees)
 */

module led_servo_futaba (
    input sys_clk,          // System clock: 27MHz from board oscillator
    input switch_pin,       // Switch S1 input (active-low, pin 3)
    output reg [5:0] led,   // 6-bit LED output (active-low: 0 = ON, 1 = OFF)
    output reg servo_pwm    // PWM output for servo control (pin 76, orange wire)
);

    // =========================================================================
    // DIRECTION STATE DEFINITIONS
    // =========================================================================
    localparam GOING_UP   = 1'b0;  // LEDs lighting up progressively
    localparam GOING_DOWN = 1'b1;  // LEDs turning off progressively

    // =========================================================================
    // REGISTER DECLARATIONS
    // =========================================================================
    
    reg        direction;       // Current direction: GOING_UP or GOING_DOWN
    reg [2:0]  led_count;       // LED counter: 0 to 6 (3 bits needed)
    reg        switch_prev;     // Previous switch state for edge detection
    reg [19:0] debounce_cnt;    // Debounce counter (~10ms at 27MHz)

    // PWM servo control registers
    reg [19:0] pwm_counter;     // PWM period counter (0 to 539,999 for 20ms)
    reg [19:0] pwm_duty;        // Current duty cycle (smooth transition value)
    reg [19:0] target_duty;     // Target duty cycle (based on led_count)

    // =========================================================================
    // SERVO TIMING CALCULATIONS (Futaba S3003 @ 27MHz)
    // =========================================================================
    /*
     * CLOCK CALCULATION:
     * ------------------
     * System clock frequency: 27 MHz
     * Clock period: 1 / 27,000,000 Hz = 37.037 nanoseconds
     *
     * PWM PERIOD (50Hz = 20ms):
     * -------------------------
     * Servo expects a pulse every 20 milliseconds
     * Cycles per period = 0.020 / 0.000000037037 = 540,000 cycles
     *
     * PULSE WIDTH CALCULATIONS:
     * -------------------------
     * 0° position:  0.5ms = 0.0005 / 0.000000037037 = 13,500 cycles
     * 90° position: 2.0ms = 0.0020 / 0.000000037037 = 54,000 cycles
     *
     * STEP CALCULATION (6 steps from 0° to 90°):
     * ------------------------------------------
     * Step size = (54,000 - 13,500) / 6 = 6,750 cycles per LED step
     *
     * LED Count to Servo Position Mapping:
     *   Count 0: 13,500 cycles = 0°
     *   Count 1: 20,250 cycles = 15°
     *   Count 2: 27,000 cycles = 30°
     *   Count 3: 33,750 cycles = 45°
     *   Count 4: 40,500 cycles = 60°
     *   Count 5: 47,250 cycles = 75°
     *   Count 6: 54,000 cycles = 90°
     */

    // =========================================================================
    // INITIALIZATION
    // =========================================================================
    initial begin
        led          = 6'b111111;   // All LEDs OFF (active-low: 1 = off)
        led_count    = 3'd0;        // Start with 0 LEDs lit
        direction    = GOING_UP;    // Initial direction: increasing
        switch_prev  = 1'b1;        // Switch not pressed (active-low)
        debounce_cnt = 20'd0;       // Clear debounce counter
        pwm_counter  = 20'd0;       // Reset PWM counter
        pwm_duty     = 20'd13500;   // Start at 0° position (13,500 cycles)
        target_duty  = 20'd13500;   // Target also at 0°
    end

    // =========================================================================
    // MAIN SEQUENTIAL LOGIC
    // =========================================================================
    always @(posedge sys_clk) begin

        // =====================================================================
        // PWM GENERATOR (50Hz = 20ms period)
        // =====================================================================
        /*
         * The PWM counter cycles from 0 to 539,999 to create a 20ms period.
         * The servo_pwm output is HIGH when counter < pwm_duty, LOW otherwise.
         * 
         * Duty cycle determines servo position:
         *   - pwm_duty = 13,500: 0.5ms pulse = 0°
         *   - pwm_duty = 54,000: 2.0ms pulse = 90°
         */
        if (pwm_counter < 20'd539999)
            pwm_counter <= pwm_counter + 1'b1;
        else
            pwm_counter <= 20'd0;

        // Generate PWM output: HIGH while counter < duty, LOW otherwise
        servo_pwm <= (pwm_counter < pwm_duty) ? 1'b1 : 1'b0;

        // =====================================================================
        // SMOOTH SERVO MOVEMENT
        // =====================================================================
        /*
         * Instead of jumping directly to the target position, we gradually
         * adjust pwm_duty toward target_duty by adding/subtracting 50 cycles.
         * This creates smooth servo motion rather than jerky movements.
         *
         * At 50 cycles per clock and 27MHz clock:
         *   - Full sweep (0° to 90°): (54,000 - 13,500) / 50 = 810 steps
         *   - Time for full sweep: 810 / 27,000,000 = 30 microseconds
         *   - This happens every PWM period (20ms), so motion appears smooth
         */
        if (pwm_duty < target_duty)
            pwm_duty <= pwm_duty + 20'd50;  // Move toward target (increase)
        else if (pwm_duty > target_duty)
            pwm_duty <= pwm_duty - 20'd50;  // Move toward target (decrease)

        // =====================================================================
        // SWITCH DEBOUNCING (10ms @ 27MHz)
        // =====================================================================
        /*
         * DEBOUNCE PRINCIPLE:
         * -------------------
         * Mechanical switches bounce when pressed, creating multiple rapid
         * transitions. We wait 10ms after a transition before accepting
         * the new state as valid.
         *
         * Calculation: 10ms / (1/27MHz) = 270,000 clock cycles
         *
         * EDGE DETECTION:
         * ---------------
         * Falling edge (1 -> 0) indicates button press for active-low switch.
         * This is detected when switch_prev=1 AND switch_pin=0.
         */
        if (debounce_cnt < 20'd270000) begin
            // Still in debounce period - continue counting
            debounce_cnt <= debounce_cnt + 1'b1;
        end else begin
            // Debounce period complete (~10ms elapsed)
            debounce_cnt <= 20'd0;      // Reset for next debounce
            switch_prev  <= switch_pin; // Update previous state

            // Detect falling edge (button press on active-low switch)
            if (switch_prev && !switch_pin) begin
                if (direction == GOING_UP) begin
                    // Currently increasing LED count
                    if (led_count < 3'd6) begin
                        // Haven't reached maximum yet - keep going up
                        led_count <= led_count + 1'b1;
                    end else begin
                        // Reached maximum (6) - reverse direction
                        direction <= GOING_DOWN;
                        led_count <= led_count - 1'b1;
                    end
                end else begin // GOING_DOWN
                    // Currently decreasing LED count
                    if (led_count > 3'd0) begin
                        // Haven't reached minimum yet - keep going down
                        led_count <= led_count - 1'b1;
                    end else begin
                        // Reached minimum (0) - reverse direction
                        direction <= GOING_UP;
                        led_count <= led_count + 1'b1;
                    end
                end
            end
        end

        // =====================================================================
        // SERVO POSITION CALCULATION
        // =====================================================================
        /*
         * Calculate target PWM duty cycle based on led_count.
         * Formula: target_duty = 13,500 + (led_count × 6,750)
         *
         * This maps LED count (0-6) to servo angle (0°-90°):
         *   led_count=0: 13,500 + 0     = 13,500 cycles (0°)
         *   led_count=1: 13,500 + 6,750 = 20,250 cycles (15°)
         *   led_count=2: 13,500 + 13,500= 27,000 cycles (30°)
         *   led_count=3: 13,500 + 20,250= 33,750 cycles (45°)
         *   led_count=4: 13,500 + 27,000= 40,500 cycles (60°)
         *   led_count=5: 13,500 + 33,750= 47,250 cycles (75°)
         *   led_count=6: 13,500 + 40,500= 54,000 cycles (90°)
         */
        target_duty <= 20'd13500 + (led_count * 20'd6750);

        // =====================================================================
        // LED DISPLAY LOGIC (Active-Low)
        // =====================================================================
        /*
         * The LEDs on Tang Nano 9K are active-low:
         *   - Writing 0 turns the LED ON
         *   - Writing 1 turns the LED OFF
         *
         * LED to pin mapping on the board:
         *   led[5] = pin 16 (leftmost LED on the board)
         *   led[4] = pin 15
         *   led[3] = pin 14
         *   led[2] = pin 13
         *   led[1] = pin 11
         *   led[0] = pin 10 (rightmost LED on the board)
         *
         * Progress bar fills from left (led[5]) to right (led[0]).
         */
        case (led_count)
            3'd0: led <= 6'b111111;  // 0 LEDs on (all off)
            3'd1: led <= 6'b011111;  // 1 LED on  (led[5])
            3'd2: led <= 6'b001111;  // 2 LEDs on (led[5:4])
            3'd3: led <= 6'b000111;  // 3 LEDs on (led[5:3])
            3'd4: led <= 6'b000011;  // 4 LEDs on (led[5:2])
            3'd5: led <= 6'b000001;  // 5 LEDs on (led[5:1])
            3'd6: led <= 6'b000000;  // 6 LEDs on (all on)
            default: led <= 6'b111111; // Safety default (all off)
        endcase

    end

endmodule
