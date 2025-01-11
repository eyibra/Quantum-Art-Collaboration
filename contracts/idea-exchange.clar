;; Idea Exchange Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-idea-owner (err u102))

;; Data Variables
(define-data-var idea-counter uint u0)
(define-map ideas uint {
    project-id: uint,
    content: (string-utf8 1000),
    creator: principal,
    timestamp: uint
})

;; Public Functions
(define-public (share-idea (project-id uint) (content (string-utf8 1000)))
    (let
        (
            (idea-id (+ (var-get idea-counter) u1))
        )
        (map-set ideas idea-id {
            project-id: project-id,
            content: content,
            creator: tx-sender,
            timestamp: block-height
        })
        (var-set idea-counter idea-id)
        (ok idea-id)
    )
)

(define-public (update-idea (idea-id uint) (new-content (string-utf8 1000)))
    (let
        (
            (idea (unwrap! (map-get? ideas idea-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator idea)) err-not-idea-owner)
        (map-set ideas idea-id
            (merge idea {
                content: new-content,
                timestamp: block-height
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-idea (idea-id uint))
    (map-get? ideas idea-id)
)

(define-read-only (get-idea-count)
    (var-get idea-counter)
)

