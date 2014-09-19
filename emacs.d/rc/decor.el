;; Colors
(when window-system
  (tool-bar-mode 0)
  (menu-bar-mode 0)
  (scroll-bar-mode 0)
  (when (>= emacs-major-version 24)
    (load-theme 'solarized-light t)
    ))

(setq initial-frame-alist
  `((top . 0)
    (left . ,(- (/ (display-pixel-width) 2) (* (frame-char-width) 40)))
    (width . 80)
    (height . ,(/ (- (display-pixel-height) 85) (frame-char-height)))))

;; Include line numbers in print outs
(setq ps-line-number t)

;; Highlight mark (selection)
(transient-mark-mode t)

;; Show matching paren or bracket when cursor is on or after it
(show-paren-mode 1)
(setq blink-matching-paren-distance nil)

;; Font lock
(require 'font-lock)

(setq font-lock-maximum-decoration t)
(global-font-lock-mode t)
(setq font-lock-global-modes '(not shell-mode))
(setq font-lock-use-colors t)
(setq font-lock-use-default-maximal-decoration t)
