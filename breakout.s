.segment "HEADER"
    .byte $4E, $45, $53, $1A
    .byte $02   ; 16K PRG data count
    .byte $01   ; 8K CHR data count

.segment "VECTORS"
    .addr NMI   ; Non Maskable Interrupt, once per frame if enabled 
    .addr RESET ; jump point on power on/reset
    .addr 0     ; external interrupt IRQ

.segment "STARTUP"  ; linker requires startup even if empty

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
    TXS         ; Set up stack
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
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
    LDA #$FE
    STA $0300, x
    INX
    BNE clrmem

    JSR vblankwait

    LDA #%00000000
    STA $0000

    LDA #%10000000
    STA $2000

forever:
    JMP forever     ; infinite loop

NMI:
    INC $0000
    LDA $0000
    STA $2001
    RTI

; Character memory
.segment "CHARS"