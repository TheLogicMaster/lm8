; Utilities


; Sets the C flag if running in memory, clears it otherwise
is_in_memory:
    push A
    push H
    push L

    lda is_in_memory
    ldr $7F,A
    cmp H

    pop L
    pop H
    pop A
    ret
