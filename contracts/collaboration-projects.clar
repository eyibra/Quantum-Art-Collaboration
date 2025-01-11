;; Collaboration Projects Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-collaborator (err u102))

;; Data Variables
(define-data-var project-counter uint u0)
(define-map projects uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    creator: principal,
    collaborators: (list 10 principal),
    status: (string-ascii 20)
})

;; Public Functions
(define-public (create-project (name (string-ascii 100)) (description (string-utf8 1000)))
    (let
        (
            (project-id (+ (var-get project-counter) u1))
        )
        (map-set projects project-id {
            name: name,
            description: description,
            creator: tx-sender,
            collaborators: (list tx-sender),
            status: "active"
        })
        (var-set project-counter project-id)
        (ok project-id)
    )
)

(define-public (join-project (project-id uint))
    (let
        (
            (project (unwrap! (map-get? projects project-id) err-invalid-parameters))
            (current-collaborators (get collaborators project))
        )
        (asserts! (< (len current-collaborators) u10) err-invalid-parameters)
        (map-set projects project-id
            (merge project {
                collaborators: (unwrap! (as-max-len? (append current-collaborators tx-sender) u10) err-invalid-parameters)
            })
        )
        (ok true)
    )
)

(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
    (let
        (
            (project (unwrap! (map-get? projects project-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator project)) err-owner-only)
        (map-set projects project-id
            (merge project {
                status: new-status
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-project (project-id uint))
    (map-get? projects project-id)
)

(define-read-only (get-project-count)
    (var-get project-counter)
)

