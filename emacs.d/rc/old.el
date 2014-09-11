(setq auto-mode-alist (append '(("\\.doc\\'" . text-mode)
				("\\.html\\'" . text-mode))
			      auto-mode-alist))

(prefer-coding-system 'utf-8-unix)

(global-set-key "%" 'shell)

(add-hook 'text-mode-hook
  (function
   (lambda ()
     (auto-fill-mode 1)
     (setq indent-tabs-mode nil)
     (local-set-key "
" 'newline-and-indent))))

(add-hook 'fundamental-mode
  (function
   (lambda ()
     (setq indent-tabs-mode nil)
     (local-set-key "
" 'newline-and-indent))))


(add-hook 'comint-mode-hook
  (function
   (lambda ()
     (setq comint-scroll-show-maximum-output nil)
     (add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)
     (local-set-key "p" 'comint-previous-matching-input-from-input)
     (local-set-key "n" 'comint-next-matching-input-from-input))))


(setq explicit-cmdproxy.exe-args '("-- /q"))
(setq inhibit-startup-message t)
(setq require-final-newline nil)
(put 'eval-expression 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)


;; Indentation stuff


(defvar standard-indent 2) ; for most things

;; Misc personal settings
(setq vc-follow-symlinks t)

(global-auto-revert-mode 1)
(delete-selection-mode 1)
