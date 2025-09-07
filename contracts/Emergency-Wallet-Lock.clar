;; Emergency Wallet Lock Contract
;; Temporarily freezes funds if suspicious activity is detected

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-locked (err u101))
(define-constant err-not-locked (err u102))
(define-constant err-insufficient-balance (err u103))
(define-constant err-unauthorized (err u104))

;; Data Variables
(define-data-var emergency-lock-active bool false)
(define-data-var lock-timestamp uint u0)
(define-data-var lock-duration uint u144) ;; 144 blocks = ~24 hours

;; Data Maps
(define-map frozen-balances principal uint)
(define-map user-permissions principal bool)
(define-map activity-thresholds principal uint)

;; Public Functions

;; Deposit funds to the wallet
(define-public (deposit (amount uint))
  (begin
    (asserts! (> amount u0) (err u105))
    (asserts! (not (var-get emergency-lock-active)) err-already-locked)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set frozen-balances tx-sender 
      (+ (default-to u0 (map-get? frozen-balances tx-sender)) amount))
    (ok amount)))

;; Emergency lock activation
(define-public (activate-emergency-lock)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (var-get emergency-lock-active)) err-already-locked)
    (var-set emergency-lock-active true)
    (var-set lock-timestamp block-height)
    (ok true)))

;; Unlock mechanism
(define-public (unlock-funds)
  (let ((user-balance (default-to u0 (map-get? frozen-balances tx-sender))))
    (asserts! (var-get emergency-lock-active) err-not-locked)
    (asserts! (> user-balance u0) err-insufficient-balance)
    (asserts! (or 
      (is-eq tx-sender contract-owner)
      (>= block-height (+ (var-get lock-timestamp) (var-get lock-duration)))
      (default-to false (map-get? user-permissions tx-sender))) 
      err-unauthorized)

    (try! (as-contract (stx-transfer? user-balance tx-sender tx-sender)))
    (map-delete frozen-balances tx-sender)
    (ok user-balance)))

;; Owner can grant permission to specific users to unlock early
(define-public (grant-unlock-permission (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set user-permissions user true)
    (ok true)))

;; Owner can revoke permission
(define-public (revoke-unlock-permission (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-delete user-permissions user)
    (ok true)))

;; Deactivate emergency lock (owner only)
(define-public (deactivate-emergency-lock)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set emergency-lock-active false)
    (var-set lock-timestamp u0)
    (ok true)))

;; Set lock duration in blocks (owner only)
(define-public (set-lock-duration (duration uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set lock-duration duration)
    (ok duration)))

;; Read-only functions

;; Check if emergency lock is active
(define-read-only (is-locked)
  (var-get emergency-lock-active))

;; Get user's frozen balance
(define-read-only (get-frozen-balance (user principal))
  (default-to u0 (map-get? frozen-balances user)))

;; Check if user has unlock permission
(define-read-only (has-unlock-permission (user principal))
  (default-to false (map-get? user-permissions user)))

;; Get time remaining until auto-unlock (in blocks)
(define-read-only (get-time-until-unlock)
  (if (var-get emergency-lock-active)
    (let ((unlock-height (+ (var-get lock-timestamp) (var-get lock-duration))))
      (if (>= block-height unlock-height)
        u0
        (- unlock-height block-height)))
    u0))

;; Get contract status
(define-read-only (get-contract-status)
  {
    locked: (var-get emergency-lock-active),
    lock-timestamp: (var-get lock-timestamp),
    lock-duration: (var-get lock-duration),
    current-block: block-height
  })