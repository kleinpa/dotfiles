;;;; Text Editor Settings
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(prefer-coding-system 'utf-8-unix)
(setq vc-follow-symlinks t)
(setq-default indent-tabs-mode nil)
(setq inhibit-startup-message t)
(setq disabled-command-function nil)
(setq require-final-newline nil)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(show-paren-mode 1)
(setq blink-matching-paren-distance nil)

;;;; Package Management
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(package-initialize)

(customize-set-variable
 'package-selected-packages
 `(auctex
   color-theme-sanityinc-tomorrow
   company
   dockerfile-mode
   erlang
   elgot
   expand-region
   gist
   git-gutter
   go-mode
   js2-mode
   latex-preview-pane
   less-css-mode
   magit
   markdown-mode
   multiple-cursors
   powershell
   scad-mode
   smartparens
   web-beautify
   yaml-mode))

;;;; Global Key Bindings
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-c C-m") 'compile)

;;;; IDE Settings

;; Flyspell conflicts with company-mode :(
;; https://github.com/company-mode/company-mode/issues/760
;;   (add-hook 'text-mode-hook 'flyspell-mode)
;;   (add-hook 'prog-mode-hook 'flyspell-prog-mode)

;;;; Platform-specific Settings
(defun try-set-default-font (name)
  "Use specified font if available"
  (cond ((find-font (font-spec :name name)) (set-default-font name))))

(when (eq system-type 'gnu/linux)
  (try-set-default-font "Source Code Pro-10"))

(when (eq system-type 'windows-nt)
  (try-set-default-font "Consolas-10"))

;;;; Paths
;; User Load Path
(add-to-list 'load-path (concat user-emacs-directory
                                (convert-standard-filename "lisp/")))
;; Customize
(setq custom-file "~/.emacs.d/custom.el")
(and (file-exists-p custom-file) (load custom-file))

(require 'smartparens-config)
(with-eval-after-load "smartparens"
  (smartparens-global-mode 1))

;;;; UI
(xterm-mouse-mode 1)
(menu-bar-mode 0)

(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode 0))

(when (or (version< "26.1" emacs-version) (display-graphic-p))
  (add-hook 'after-init-hook
            (lambda () (load-theme 'sanityinc-tomorrow-bright t))))

;;;; Language Settings
(defvar c-basic-offset 2)  ; for c++
(defvar standard-indent 2) ; for most things
(setq c-default-style '((java-mode . "java")
			(awk-mode . "awk")
			(other . "bsd")))

;; Scheme
(load "becls-scheme")
(add-to-list 'auto-mode-alist '("\\.ms$" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.ss$" . scheme-mode))

(autoload 'run-scheme "cmuscheme" "Run an inferior scheme process." t)
(global-set-key "!" 'run-scheme)

;; Javascript
(defvar js-indent-level 2)

(with-eval-after-load "js2-mode-autoloads"
  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
  (add-hook 'js2-mode-hook
	    (lambda ()
	      (setq web-beautify-args
		    (add-to-list web-beautify-args "-s2" "-w80"))
	      (add-hook 'before-save-hook 'web-beautify-js-buffer t t))))

;; Go
(add-hook 'go-mode-hook
          (lambda ()
	    (setq indent-tabs-mode t)
            (setq tab-width 2)
            (add-hook 'before-save-hook #'gofmt-before-save)))

;; CSS
(setq css-indent-offset 2)

;; Shell
(add-to-list 'auto-mode-alist '("\\.?*shrc$" . sh-mode))
(add-to-list 'auto-mode-alist '("\*profile$" . sh-mode))

;; Make
(add-to-list 'auto-mode-alist '("\\/Mf-" . makefile-mode))

(with-eval-after-load "magit-autoloads"
  (global-set-key (kbd "C-x g") 'magit-status)
  (global-set-key (kbd "C-x G") 'magit-blame-mode))

(with-eval-after-load "shell"
  (set-face-attribute 'comint-highlight-prompt nil :inherit nil)
  (setq comint-process-echoes t))

;;;; IDE Features
(with-eval-after-load "company-autoloads"
  (add-hook 'after-init-hook 'global-company-mode)
  (setq company-tooltip-limit 20)                      ; bigger popup window
  (setq company-idle-delay 0.2)                         ; decrease delay before autocompletion popup shows
  (setq company-echo-delay 0)                          ; remove annoying blinking
  (setq company-transformers '(company-sort-by-occurrence)))
