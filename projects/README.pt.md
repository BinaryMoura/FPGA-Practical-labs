# Projetos

Esta pasta contém projetos práticos de FPGA, desde o básico blink LED até implementações avançadas como processadores softcore RISC-V.

---

## Lista de Projetos

| Projeto | Dificuldade | Descrição |
|---------|-------------|-----------|
| [Toggle LED](./Toggle_led/) | Iniciante | Sistema de controle ON/OFF via botão com debounce e toggle |
| [Servo Control](./Servo_control/) | Iniciante | Controle de motor servo (Futaba S3003) com barra de LEDs sincronizada |

---

## Toggle LED

**Sistema de controle ON/OFF via botão com debounce e toggle em FPGA**

![Demonstração Toggle LED](./Toggle_led/Assets/running.gif)

Um botão físico alterna o estado de 6 LEDs entre ligado e desligado. Demonstra conceitos fundamentais de design digital síncrono incluindo sincronização de sinais externos, debounce de chave mecânica e lógica de toggle em Verilog.

**Conceitos Chave:**
- Design de clock síncrono
- Debounce de chave mecânica (~5.4ms)
- Detecção de borda de descida
- Lógica de toggle bit a bit

**Hardware:** Tang Nano 9K (Gowin GW1NR-9C)

**Localização:** [./Toggle_led/](./Toggle_led/)

---

## Servo Control

**Controle de motor servo com barra de LEDs sincronizada**

Um botão controla tanto uma barra de progresso de 6 LEDs quanto a posição de um motor servo. Demonstra geração de PWM (Modulação por Largura de Pulso), controle suave de movimento do servo e máquinas de estado bidirecionais.

**Comportamento:**
- Cliques 1-6: LEDs acendem progressivamente, servo move 0° → 90°
- Cliques 7+: LEDs apagam progressivamente, servo retorna 90° → 0°
- Em 0°: Ciclo reinicia automaticamente

**Conceitos Chave:**
- Geração de sinal PWM (50Hz, largura de pulso 0,5ms-2,0ms)
- Teoria de controle de motor servo
- Movimento suave com ajuste gradual do ciclo de trabalho
- Máquina de estado bidirecional (SUBINDO/DESCENDO)
- Debounce de botão (~10ms)

**Hardware:**
- Tang Nano 9K (Gowin GW1NR-9C)
- Motor Servo Futaba S3003

**Localização:** [./Servo_control/](./Servo_control/)

---

*Mais projetos em breve!*
