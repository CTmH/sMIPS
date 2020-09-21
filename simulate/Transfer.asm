.org 0x0
.set noat
.set noreorder
.set nomacro
.global _start

_start:
ori $1, $0, 0x0001
j   label1
ori $1, $0, 0x0002
ori $1, $0, 0x1111

label1:
ori $1, $0, 0x0003
ori $2, $0, 0x0004
beq $1, $2, label2
ori $1, $0, 0x0004
ori $1, $0, 0x1111
beq $1, $1, label3
ori $1, $0, 0x0006
ori $1, $0, 0x1111

label2:
ori $1, $0, 0x1111

label3:
ori $1, $0, 0x0007


