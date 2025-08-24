;; Aircraft Maintenance Tracker
;; Decentralized maintenance record system for aircraft

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_AIRCRAFT_NOT_FOUND (err u201))
(define-constant ERR_INVALID_MAINTENANCE_TYPE (err u202))
(define-constant ERR_MAINTENANCE_OVERDUE (err u203))

(define-map aircraft-registry
  { tail-number: (string-ascii 10) }
  {
    owner: principal,
    model: (string-ascii 20),
    manufacture-year: uint,
    total-flight-hours: uint,
    last-inspection: uint,
    is-airworthy: bool
  }
)

(define-map maintenance-records
  { record-id: uint }
  {
    tail-number: (string-ascii 10),
    maintenance-type: (string-ascii 20),
    performed-by: principal,
    date-performed: uint,
    flight-hours-at-service: uint,
    next-due-hours: uint,
    cost: uint,
    is-certified: bool
  }
)

(define-map maintenance-providers
  { provider: principal }
  { is-certified: bool, certification-date: uint }
)

(define-data-var record-counter uint u0)

(define-public (register-aircraft (tail-number (string-ascii 10)) (model (string-ascii 20)) (manufacture-year uint))
  (begin
    (map-set aircraft-registry
      { tail-number: tail-number }
      {
        owner: tx-sender,
        model: model,
        manufacture-year: manufacture-year,
        total-flight-hours: u0,
        last-inspection: u0,
        is-airworthy: true
      }
    )
    (ok true)
  )
)

(define-public (certify-maintenance-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set maintenance-providers
      { provider: provider }
      { is-certified: true, certification-date: block-height }
    )
    (ok true)
  )
)

(define-public (record-maintenance 
  (tail-number (string-ascii 10)) 
  (maintenance-type (string-ascii 20)) 
  (flight-hours-at-service uint)
  (next-due-hours uint)
  (cost uint))
  (let (
    (record-id (+ (var-get record-counter) u1))
    (aircraft (unwrap! (map-get? aircraft-registry { tail-number: tail-number }) ERR_AIRCRAFT_NOT_FOUND))
    (provider-cert (default-to { is-certified: false, certification-date: u0 } 
                   (map-get? maintenance-providers { provider: tx-sender })))
  )
    (map-set maintenance-records
      { record-id: record-id }
      {
        tail-number: tail-number,
        maintenance-type: maintenance-type,
        performed-by: tx-sender,
        date-performed: block-height,
        flight-hours-at-service: flight-hours-at-service,
        next-due-hours: next-due-hours,
        cost: cost,
        is-certified: (get is-certified provider-cert)
      }
    )
    (var-set record-counter record-id)
    (ok record-id)
  )
)

(define-public (update-flight-hours (tail-number (string-ascii 10)) (new-hours uint))
  (let (
    (aircraft (unwrap! (map-get? aircraft-registry { tail-number: tail-number }) ERR_AIRCRAFT_NOT_FOUND))
  )
    (asserts! (is-eq tx-sender (get owner aircraft)) ERR_UNAUTHORIZED)
    (map-set aircraft-registry
      { tail-number: tail-number }
      (merge aircraft { total-flight-hours: new-hours })
    )
    (ok true)
  )
)

(define-public (update-airworthiness (tail-number (string-ascii 10)) (is-airworthy bool))
  (let (
    (aircraft (unwrap! (map-get? aircraft-registry { tail-number: tail-number }) ERR_AIRCRAFT_NOT_FOUND))
  )
    (asserts! (is-eq tx-sender (get owner aircraft)) ERR_UNAUTHORIZED)
    (map-set aircraft-registry
      { tail-number: tail-number }
      (merge aircraft { is-airworthy: is-airworthy, last-inspection: block-height })
    )
    (ok true)
  )
)

(define-read-only (get-aircraft-info (tail-number (string-ascii 10)))
  (map-get? aircraft-registry { tail-number: tail-number })
)

(define-read-only (get-maintenance-record (record-id uint))
  (map-get? maintenance-records { record-id: record-id })
)

(define-read-only (is-maintenance-due (tail-number (string-ascii 10)) (maintenance-type (string-ascii 20)))
  (let (
    (aircraft (unwrap! (map-get? aircraft-registry { tail-number: tail-number }) (some false)))
  )
    (some (> (get total-flight-hours aircraft) u500))
  )
)

(define-read-only (get-provider-certification (provider principal))
  (map-get? maintenance-providers { provider: provider })
)