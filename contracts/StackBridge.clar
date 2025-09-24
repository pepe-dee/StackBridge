;; ------------------------------------------------------------
;; Cross-Chain Collateral Bridge (Clarity v2)
;; ------------------------------------------------------------
;; Purpose:
;; - Users lock sBTC on Stacks.
;; - They receive wBTC (wrapped BTC) minted by this contract.
;; - Later, they can burn wBTC to unlock their original sBTC.
;; ------------------------------------------------------------

;; ------------------ Errors ------------------
(define-constant ERR-NOT-ENOUGH   (err u100))
(define-constant ERR-NOT-FOUND    (err u101))
(define-constant ERR-NOT-OWNER    (err u102))

;; ------------------ Data ------------------
(define-fungible-token wBTC)

;; Track locked collateral balances
(define-map locked
  { user: principal }
  { amount: uint })

;; ------------------ Bridge: Lock ------------------
(define-public (lock (amount uint))
  (begin
    (asserts! (> amount u0) ERR-NOT-ENOUGH)

    ;; transfer sBTC from user to this contract
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      transfer-ok
      (let 
        ((record (map-get? locked { user: tx-sender })))
        ;; update locked record
        (if (is-some record)
            (map-set locked { user: tx-sender }
              { amount: (+ amount (get amount (unwrap-panic record))) })
            (map-set locked { user: tx-sender } { amount: amount }))
        ;; mint equivalent wBTC
        (match (ft-mint? wBTC amount tx-sender)
          mint-ok (ok true)
          mint-err (begin
            ;; If minting fails, we need to refund the transferred STX
            (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
            ERR-NOT-ENOUGH)))
      transfer-err
      ERR-NOT-ENOUGH)))

;; ------------------ Bridge: Unlock ------------------
(define-public (unlock (amount uint))
  (begin
    (asserts! (> amount u0) ERR-NOT-ENOUGH)

    (match (map-get? locked { user: tx-sender }) record
      (let ((locked-amt (get amount record)))
        (asserts! (>= locked-amt amount) ERR-NOT-ENOUGH)

        ;; burn wrapped BTC from user
        (match (ft-burn? wBTC amount tx-sender)
          success
          (begin
            ;; reduce locked collateral
            (map-set locked { user: tx-sender }
              { amount: (- locked-amt amount) })
            ;; return sBTC from contract to user
            (stx-transfer? amount (as-contract tx-sender) tx-sender))
          failure ERR-NOT-ENOUGH))
      ERR-NOT-FOUND)))

;; ------------------ Views ------------------
(define-read-only (get-locked (user principal))
  (default-to u0 (get amount (map-get? locked { user: user }))))

(define-read-only (get-wbtc-balance (user principal))
  (ft-get-balance wBTC user))
