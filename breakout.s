.segment "HEADER"
    .byte $4E, $45, $53, $1A
    .byte $02   ; 16K PRG data count
    .byte $01   ; 8K CHR data count

.segment "VECTORS"
    .addr NMI   ; Non Maskable Interrupt, once per frame if enabled 
    .addr RESET ; jump point on power on/reset
    .addr 0     ; external interrupt IRQ

.segment "STARTUP"  ; linker requires STArtup even if empty

.segment "CODE" ; program code down here

vblankwait:    ; wait for vblank to make sure PPU is ready
    BIT $2002
    BPL vblankwait
    RTS

RESET:
    SEI         ; disable IRQs
    CLD         ; disable decimal mode
    LDX #$40
    STX $4017   ; disable APU frame IRQ
    LDX #$FF
    TXS         ; set up STAck
    INX         ; now X = 0
    STX $2000   ; disable NMI
    STX $2001   ; disable rendering
    STX $4010   ; disable DMC IRQs

    JSR vblankwait

clrmem:
    LDA #$00
    STA $0000, x
    STA $0100, x
    STA $0200, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
    INX
    BNE clrmem

    JSR vblankwait

main:
load_palettes:
    LDA $2002
    LDA #$3f
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
@loop:
    LDA palettes, x
    STA $2007
    INX
    CPX #$20
    BNE @loop

    LDA #%10000000
    STA $2000

forever:
    JMP forever     ; infinite loop

NMI:
    ; INC $0000
    ; LDA $0000
    ; STA $2001
    RTI

palettes:
  ; background palettes
  .byte $30, $3D, $2D, $1D
  .byte $30, $3D, $2D, $1D
  .byte $30, $3D, $2D, $1D
  .byte $30, $3D, $2D, $1D

  ; sprite palettes
  .byte $30, $3D, $2D, $1D
  .byte $30, $3D, $2D, $1D
  .byte $30, $3D, $2D, $1D
  .byte $30, $3D, $2D, $1D

; Character memory
.segment "CHARS"
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111

    .byte %11111101
    .byte %11111010
    .byte %11110100
    .byte %11101000
    .byte %11010000
    .byte %10100000
    .byte %01000000
    .byte %10000000
    .byte %11111110
    .byte %11111100
    .byte %11111000
    .byte %11110000
    .byte %11100000
    .byte %11000000
    .byte %10000000
    .byte %00000000