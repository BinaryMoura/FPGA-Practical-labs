# Controle de Servo com LEDs de Progresso

Projeto FPGA para Tang Nano 9K que controla um motor servo (Futaba S3003) sincronizado com uma barra de progresso de 6 LEDs, usando um botão para interação.

## Comportamento

- **Cliques 1-6**: LEDs acendem progressivamente da esquerda para direita, servo move de 0° a 90°
- **Cliques 7+**: LEDs apagam progressivamente da direita para esquerda, servo retorna de 90° a 0°
- **Em 0°**: Ciclo reinicia, LEDs começam a acender novamente

## Demonstração Visual

```
Progressão dos Estados dos LEDs:
Contagem 0: [ ] [ ] [ ] [ ] [ ] [ ]   Servo: 0°   (todos LEDs apagados)
Contagem 1: [X] [ ] [ ] [ ] [ ] [ ]   Servo: 15°  (1 LED aceso)
Contagem 2: [X] [X] [ ] [ ] [ ] [ ]   Servo: 30°  (2 LEDs acesos)
Contagem 3: [X] [X] [X] [ ] [ ] [ ]   Servo: 45°  (3 LEDs acesos)
Contagem 4: [X] [X] [X] [X] [ ] [ ]   Servo: 60°  (4 LEDs acesos)
Contagem 5: [X] [X] [X] [X] [X] [ ]   Servo: 75°  (5 LEDs acesos)
Contagem 6: [X] [X] [X] [X] [X] [X]   Servo: 90°  (todos LEDs acesos)
Contagem 5: [ ] [X] [X] [X] [X] [X]   Servo: 75°  (descendo...)
Contagem 0: [ ] [ ] [ ] [ ] [ ] [ ]   Servo: 0°   (ciclo reinicia)
```

## Requisitos de Hardware

- **Placa**: Tang Nano 9K (GW1NR-LV9QN88PC6/I5)
- **Servo**: Futaba S3003 (ou servo padrão compatível)
- **Botão**: S1 (botão integrado na placa)
- **Alimentação**: USB 5V para a placa, 5V externo para o servo recomendado

## Mapeamento de Pinos

| Sinal       | Pino | Descrição                      |
|-------------|------|--------------------------------|
| sys_clk     | 52   | Clock do sistema 27MHz         |
| switch_pin  | 3    | Botão S1 (ativo-baixo)         |
| led[5]      | 16   | LED 0 (mais à esquerda)        |
| led[4]      | 15   | LED 1                          |
| led[3]      | 14   | LED 2                          |
| led[2]      | 13   | LED 3                          |
| led[1]      | 11   | LED 4                          |
| led[0]      | 10   | LED 5 (mais à direita)         |
| servo_pwm   | 76   | Sinal PWM do servo (fio laranja)|

## Ligação do Servo (Futaba S3003)

```
Conector do Servo Futaba S3003:
    ___________
   |  O   O   O |
   | Marrom Vermelho Laranja|
    -----------
     |      |      |
     |      |      +-- Sinal (PWM) -> Pino 76
     |      +--------- VCC (+5V)
     +---------------- GND
```

**Importante**: O servo deve ser alimentado externamente ou por uma fonte 5V separada capaz de fornecer a corrente necessária. Não alimente o servo diretamente dos pinos de 3.3V da placa FPGA.

## Detalhes Técnicos

### Clock e Temporização

- **Clock do Sistema**: 27 MHz
- **Período do Clock**: 37,037 ns

### Especificações PWM do Servo

Servos usam Modulação por Largura de Pulso (PWM) para controle de posição. A posição é determinada pela largura do pulso dentro de um período de 20ms.

| Ângulo | Largura do Pulso | Ciclos de Clock (@27MHz) |
|--------|------------------|-------------------------|
| 0°     | 0,5 ms           | 13.500                  |
| 15°    | 0,75 ms          | 20.250                  |
| 30°    | 1,0 ms           | 27.000                  |
| 45°    | 1,25 ms          | 33.750                  |
| 60°    | 1,5 ms           | 40.500                  |
| 75°    | 1,75 ms          | 47.250                  |
| 90°    | 2,0 ms           | 54.000                  |

**Período PWM**: 20 ms = 540.000 ciclos de clock

### Movimento Suave

O servo se move suavemente entre as posições incrementando/decrementando o ciclo de trabalho em 50 ciclos por tick de clock, ao invés de pular diretamente para o valor alvo.

### Debounce do Botão

Um período de debounce de 10ms (270.000 ciclos de clock) previne acionamentos falsos causados pelo bounce mecânico da chave.

## Estrutura do Projeto

```
servo_control/
├── src/
│   ├── progress_servo.v    # Módulo principal em Verilog
│   └── servo_control.cst   # Arquivo de restrições físicas
├── impl/                   # Saída da implementação
├── servo_control.gprj      # Arquivo de projeto Gowin
└── README.ptbr.md          # Este arquivo
```

## Como Compilar

1. Abra `servo_control.gprj` no Gowin EDA
2. Clique em "Synthesize" (Sintetizar)
3. Clique em "Place & Route" (Posicionar e Roteizar)
4. Clique em "Download" para programar a placa

## Como Funciona

### Máquina de Estados

O módulo usa uma máquina de estados simples com dois estados:
- **GOING_UP (SUBINDO)**: Contagem de LEDs aumenta (0→6), servo move em direção a 90°
- **GOING_DOWN (DESCENDO)**: Contagem de LEDs diminui (6→0), servo move em direção a 0°

### Mapeamento dos LEDs

Os LEDs são ativos-baixo (0 = LIGADO, 1 = DESLIGADO) e mapeados da seguinte forma:

```verilog
case (led_count)
    3'd0: led = 6'b111111;  // Todos apagados
    3'd1: led = 6'b011111;  // LED 5 aceso
    3'd2: led = 6'b001111;  // LEDs 5-4 acesos
    3'd3: led = 6'b000111;  // LEDs 5-3 acesos
    3'd4: led = 6'b000011;  // LEDs 5-2 acesos
    3'd5: led = 6'b000001;  // LEDs 5-1 acesos
    3'd6: led = 6'b000000;  // Todos acesos
endcase
```

## Licença

Este projeto faz parte dos Laboratórios Práticos de FPGA para fins educacionais.
