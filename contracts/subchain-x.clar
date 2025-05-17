;; SubChainX - Micro-Payment Subscription Protocol

(define-map plans
  uint
  {
    provider: principal,
    fee: uint,
    interval: uint,
    metadata: (string-ascii 100)
  }
)

(define-map subscriptions
  { subscriber: principal, plan-id: uint }
  {
    start-block: uint,
    next-payment-block: uint,
    active: bool
  }
)

(define-data-var plan-counter uint u1)

;; Create a new subscription plan
(define-public (create-plan (fee uint) (interval uint) (metadata (string-ascii 100)))
  (let ((id (var-get plan-counter)))
    (begin
      (map-set plans id {
        provider: tx-sender,
        fee: fee,
        interval: interval,
        metadata: metadata
      })
      (var-set plan-counter (+ id u1))
      (ok id)
    )
  )
)

;; Subscribe to an existing plan
(define-public (subscribe (plan-id uint))
  (match (map-get? plans plan-id)
    plan
    (match (stx-transfer? (get fee plan) tx-sender (get provider plan))
      success
      (begin
        (map-set subscriptions { subscriber: tx-sender, plan-id: plan-id } {
          start-block: stacks-block-height,
          next-payment-block: (+ stacks-block-height (get interval plan)),
          active: true
        })
        (ok true)
      )
      error (err u104)
    )
    (err u100) ;; Plan does not exist
  )
)

;; Process a payment (can be called by off-chain automation)
(define-public (process-payment (subscriber principal) (plan-id uint))
  (match (map-get? subscriptions { subscriber: subscriber, plan-id: plan-id })
      subscription
      (if (and (get active subscription) (>= stacks-block-height (get next-payment-block subscription)))
          (match (map-get? plans plan-id)
            plan
            (match (stx-transfer? (get fee plan) subscriber (get provider plan))
              success
              (begin
                (map-set subscriptions { subscriber: subscriber, plan-id: plan-id } {
                  start-block: (get start-block subscription),
                  next-payment-block: (+ stacks-block-height (get interval plan)),
                  active: true
                })
                (ok true))
              error (err u104)) ;; Payment failed
            (err u101)) ;; Plan removed
          (err u102)) ;; Too early or inactive
      (err u103)) ;; No subscription
)

;; Cancel subscription
(define-public (cancel-subscription (plan-id uint))
  (let ((key { subscriber: tx-sender, plan-id: plan-id }))
    (match (map-get? subscriptions key)
      subscription
      (begin
        (map-set subscriptions key {
          start-block: (get start-block subscription),
          next-payment-block: (get next-payment-block subscription),
          active: false
        })
        (ok true)
      )
      (err u103) ;; No subscription
    )
  )
)
