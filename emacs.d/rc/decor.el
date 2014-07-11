;; Colors
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'solarized-light t)

;; Set the default font and frame size for all frames
(if window-system (tool-bar-mode 0))
(if window-system (menu-bar-mode 0))
(if window-system (scroll-bar-mode 0))

;; Must figure out cross-platform font
;; (set-default-font "-*-Consolas-normal-r-*-*-12-90-96-96-c-*-iso8859-1")





(setq initial-frame-alist
  `((top . 0)
    (left . ,(- (/ (display-pixel-width) 2) (* (frame-char-width) 40)))
    (width . 80)
    (height . ,(/ (- (display-pixel-height) 85) (frame-char-height)))))
;(setq default-frame-alist
;  (cons '(font . "-*-Lucida Console-normal-r-*-*-12-90-96-96-c-*-iso8859-1")
;    default-frame-alist))


;; Include line numbers in print outs
(setq ps-line-number t)

;(insert (prin1-to-string (w32-select-font)))
;(insert (prin1-to-string (current-frame-configuration)))

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

