INCLUDE "constants.asm"
INCLUDE "wram.asm"

; rst vectors go unused
SECTION "rst00",HOME[0]
    ret

SECTION "rst08",HOME[8]
    ret

SECTION "rst10",HOME[$10]
    ret

SECTION "rst18",HOME[$18]
    ret

SECTION "rst20",HOME[$20]
    ret

SECTION "rst30",HOME[$30]
    ret

SECTION "rst38",HOME[$38]
    ret

SECTION "vblank",HOME[$40]
    reti
	;jp VBlankHandler
SECTION "lcdc",HOME[$48]
    reti
SECTION "timer",HOME[$50]
	reti
SECTION "serial",HOME[$58]
	reti
SECTION "joypad",HOME[$60]
	reti

SECTION "bank0",HOME[$61]

SECTION "romheader",HOME[$100]
    nop
    jp Start150

Section "start",HOME[$150]

Start150:
    jp Start

Start:

    ; fill the memory with zeroes
    ld hl, $C000
.loop
    ld a, 0
    ld [hli], a
    ld a, h
    cp $e0
    jr nz, .loop
    
    pop af
    ; set up the stack pointer
    ld sp, $dffe
    push af

    ld hl, $ff80
.loop2
    ld a, 0
    ld [hli], a
    ld a, l
    cp $fe
    jr nz, .loop2

    ; palettes
    ld a, %11100100
    ld [rBGP], a
    ld a, %11010000
    ld [rOBP0], a
    
    
    ld a, %11100111
    ld [rLCDC], a
    ld a, %00001000
    ld [rSTAT], a
    
    
    xor a
    ld [$ffff], a
    ld a, %00000001
    ld [$ffff], a
    ei
    
Player:
    lda [$ff10], $00
    lda [$ff11], $8f
    lda [$ff12], $f0
    lda [$ff13], $00
    lda [$ff14], %11110000
    
    lda [$ff15], $00
    lda [$ff16], $8f
    lda [$ff17], $f0
    lda [$ff18], $00
    lda [$ff19], %11110000
    
    lda [$ff1a], $00
    lda [$ff1b], $8f
    lda [$ff1c], $f0
    lda [$ff1d], $00
    lda [$ff1e], %11110000
    
    ld a, $ff
    ld [$ff24], a
    ld [$ff25], a
    ld a, $f1
    ld [$ff26], a
    
    
    ld hl, $4040
ReadCommand:
    ld a, [hli]
    cp $50
    jp z, CmdPSG
    cp $61
    jp z, CmdWait
    cp $62
    jp z, CmdWaitFrame
    cp $66
    jp z, End
    cp $00
    jr nz, .unknown    
    ld a, [H_BANK]
    inc a
    ld [H_BANK], a
    ld [$2000], a
    ld hl, $4000
    jr ReadCommand
.unknown
    ld b, b
    jr ReadCommand
    
CmdPSG:
    ld a, [hl]
    bit 7, a
    jr z, .data
.latchdata
    rlca
    rlca
    rlca
    and %00000011
    ld [H_CHANNEL], a
    ld a, [hl]
    bit 4, a ; type
    jr nz, .volume
.tone
    ld a, 1
    ld [H_TYPE], a
    ld d, ChannelDataLow>>8
    ld a, [H_CHANNEL]
    ld e, a
    ld a, [hl]
    and $0f
    ld [de], a
    call UpdateChannel
    inc hl
    jp ReadCommand
.volume
    xor a
    ld [H_TYPE], a
    ld d, ChannelVolume>>8
    ld a, [H_CHANNEL]
    ld e, a
    ld a, [hl]
    and $0f
    ld [de], a
    call UpdateChannelVolume
    inc hl
    jp ReadCommand

.data
    ld a, [H_TYPE]
    and a
    jr nz, .data_ ; XXX
.volume_
    ld d, ChannelVolume>>8
    ld a, [H_CHANNEL]
    ld e, a
    ld a, [hl]
    and %00001111
    ld [de], a
    call UpdateChannelVolume
    inc hl
    jp ReadCommand
.data_
    ld d, ChannelDataHigh>>8
    ld a, [H_CHANNEL]
    ld e, a
    ld a, [hl]
    and %00111111
    ld [de], a
    call UpdateChannel
    inc hl
    jp ReadCommand

UpdateChannel:
    ld a, [H_CHANNEL]
    cp $4
    ret nc
    ;ld c, $13
    ;jr .x
    
    rlca
    rlca
    ld c, a
    ld a, [H_CHANNEL]
    add c
    add $13
    ld c, a

    
    ld a, [H_CHANNEL]
    ld e, a
    ld d, ChannelDataLow>>8
    ld a, [de]
    ld b, a
    ld d, ChannelDataHigh>>8
    ld a, [de]
    and $0f
    swap a
    or b
    ld b, a
    
    ld a, [de]
    swap a
    and %00000011
    or FreqLUT>>9
    ld d, a
    ld e, b
    sla e
    rl d
    
    ld a, [de]
    inc de
    ld [c], a
    inc c
    ld a, [de]
    or  %10000000
    ld [c], a
    ret

UpdateChannelVolume: ret
    ld a, [H_CHANNEL]
    rlca
    rlca
    ld c, a
    ld a, [H_CHANNEL]
    add c
    add $12
    ld c, a
    
    ld a, [H_CHANNEL]
    ld e, a
    ld d, ChannelVolume>>8
    ld a, [de]
    cpl
    and $0f
    swap a
    ld [c], a
    ret

CmdWait:
    ; TODO
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    halt
    halt
    halt
    halt
    jp ReadCommand

CmdWaitFrame:
    halt
    jp ReadCommand

End:
    halt
    jr End


SECTION "freqlut", HOME[$3000]
FreqLUT:
;x = 0
;rept 1024
;printf MUL(DIV((x<<16)<<5, 3579545.0), 1.0) ; 131072.0
;printt "\n"
;dw (-(MUL(DIV((x<<16)<<5, 3579545.0), 131072.0)-2048.0)) >> 16
;x=x+1
;endr
INCLUDE "freqlut.asm"


SECTION "vgm", ROMX, BANK[$1]
;INCBIN "s1title.vgm"
INCBIN "s1ghz.vgm", 0, $4000
SECTION "vgm1", ROMX, BANK[$2]
;INCBIN "s1ghz.vgm", $4000, $53d0-$4000
;SECTION "vgm2", ROMX, BANK[$3]
;INCBIN "s1ghz.vgm", $8000, $c000
;SECTION "vgm3", ROMX, BANK[$4]
;INCBIN "s1ghz.vgm", $c000, $10000












