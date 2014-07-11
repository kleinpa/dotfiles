

;;; Scheme
(autoload 'run-scheme "cmuscheme" "Run an inferior scheme process." t)
(global-set-key "!" 'run-scheme)

(add-to-list 'auto-mode-alist '("\\.ms$" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.ss$" . scheme-mode))

(add-hook 'scheme-mode-hook 
  (function
   (lambda ()
     (setq indent-tabs-mode nil)
     (local-set-key "" 'newline-and-indent))))
