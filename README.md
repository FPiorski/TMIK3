# TMIK 3
#### Generating a random number every sencond using an 8051
##### File list
  - prng.asm - Uses only timer 0 and counts overflows in software
  - prng2.asm - Uses both timers, timer 0 interrupt handler enables timer 1 for a single clock cycle