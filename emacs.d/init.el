;; Cygwin settings
;;(setq exec-path (cons "c:/cygwin/bin" exec-path))
;;(setenv "PATH" (concat "c:\\cygwin\\bin;" (getenv "PATH")))
;;(setq process-coding-system-alist '(("bash" . undecided-unix)))
;;(setq shell-file-name "bash")
;;(setq explicit-shell-file-name "bash")
;;(setq w32-quote-process-args ?\")

;; Colors
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'solarized-light t)

;; Set the default font and frame size for all frames
(if window-system (tool-bar-mode 0))
(if window-system (menu-bar-mode 0))


;; Must figure out cross-platform font
;; (set-default-font "-*-Consolas-normal-r-*-*-12-90-96-96-c-*-iso8859-1")


(setq initial-frame-alist
  `((top . 0)
    (left . ,(- (/ (display-pixel-width) 2) (* (frame-char-width) 40)))
    (width . 80)
    (height . ,(/ (- (display-pixel-height) 85) (frame-char-height)))))
(setq default-frame-alist
  (cons '(font . "-*-Lucida Console-normal-r-*-*-12-90-96-96-c-*-iso8859-1")
    default-frame-alist))

;(insert (prin1-to-string (w32-select-font)))
;(insert (prin1-to-string (current-frame-configuration)))

;; Include line numbers in print outs
(setq ps-line-number t)

;;; Scheme
(autoload 'run-scheme "cmuscheme" "Run an inferior scheme process." t)
(global-set-key "!" 'run-scheme)

(setq auto-mode-alist (append '(("\\.ms\\'" . scheme-mode)
				("\\.ss\\'" . scheme-mode)
				("\\.doc\\'" . text-mode)
				("\\.tex\\'" . latex-mode)
				("\\.html\\'" . text-mode))
			      auto-mode-alist))

(prefer-coding-system 'utf-8-unix)

(global-set-key "%" 'shell)

(add-hook 'text-mode-hook 
  (function
   (lambda ()
     (auto-fill-mode 1)
     (setq indent-tabs-mode nil)
     (local-set-key "" 'newline-and-indent))))

(add-hook 'fundamental-mode-hook
  (function
   (lambda ()
     (setq indent-tabs-mode nil)
     (local-set-key "" 'newline-and-indent))))

(add-hook 'c-mode-hook
  (function
   (lambda ()
     (setq indent-tabs-mode nil)
     (local-set-key "" 'newline-and-indent))))

(add-hook 'c++-mode-hook
  (function
   (lambda ()
     (setq indent-tabs-mode nil)
     (local-set-key "" 'newline-and-indent))))

(add-hook 'comint-mode-hook
  (function
   (lambda ()
     (setq comint-scroll-show-maximum-output nil)
     (add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)
     (local-set-key "p" 'comint-previous-matching-input-from-input)
     (local-set-key "n" 'comint-next-matching-input-from-input))))

(add-hook 'scheme-mode-hook 
  (function
   (lambda ()
     (setq indent-tabs-mode nil)
     (local-set-key "" 'newline-and-indent))))

(add-hook 'java-mode-hook 
  (function
   (lambda ()
     (local-set-key "" 'newline-and-indent))))

(setq explicit-cmdproxy.exe-args '("-- /q"))
(setq inhibit-startup-message t)
(setq require-final-newline nil)
(put 'eval-expression 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Man pages
(autoload 'woman "woman" "Decode and browse a UN*X man page." t)
(autoload 'woman-find-file "woman" "Find, decode and browse a specific UN*X man-page file." t)

;; Indentation stuff
(defvar c-basic-offset 2)  ; for c++
(defvar js-indent-level 2) ; for JavaScript
(defvar standard-indent 2) ; for most things
(setq c-default-style '((java-mode . "java")
			(awk-mode . "awk")
			(other . "bsd")))

;; Should be able to load multiple files into one emacs window
(server-start)

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

;; package.el
(require 'package)
(package-initialize)

;; Misc personal settings
(setq vc-follow-symlinks t)

