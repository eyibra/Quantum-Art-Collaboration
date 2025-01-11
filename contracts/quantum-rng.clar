;; Quantum Random Number Generator Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))

;; Data Variables
(define-data-var last-random uint u0)
(define-data-var last-random-buff (buff 32) 0x0000000000000000000000000000000000000000000000000000000000000000)

;; Private Functions
(define-private (xorshift (seed uint))
    (let
        (
            (x (xor seed (bit-shift-left seed u13)))
            (y (xor x (bit-shift-right x u17)))
            (z (xor y (bit-shift-left y u5)))
        )
        z
    )
)

;; Public Functions
(define-public (generate-random)
    (let
        (
            (new-random (xorshift (+ (var-get last-random) block-height)))
        )
        (var-set last-random new-random)
        (ok new-random)
    )
)

(define-public (generate-random-buff)
    (let
        (
            (new-random (generate-random))
            (new-buff (unwrap! (to-consensus-buff? (ok new-random)) (err u0)))
        )
        (var-set last-random-buff new-buff)
        (ok new-buff)
    )
)

;; Read-only Functions
(define-read-only (get-last-random)
    (ok (var-get last-random))
)

(define-read-only (get-last-random-buff)
    (ok (var-get last-random-buff))
)

