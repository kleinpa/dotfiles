(tool-bar-mode 0)
(scroll-bar-mode 0)
(menu-bar-mode 0)

(prefer-coding-system 'utf-8-unix)

(global-set-key "%" 'shell)

(setq explicit-cmdproxy.exe-args '("-- /q"))
(setq inhibit-startup-message t)
(setq require-final-newline nil)
(put 'eval-expression 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Man pages
(autoload 'woman "woman" "Decode and browse a UN*X man page." t)
(autoload 'woman-find-file "woman" "Find, decode and browse a specific UN*X man-page file." t)

;; Should be able to load multiple files into one emacs window
(server-start)

;; Show matching paren or bracket when cursor is on or after it
(show-paren-mode 1)
(setq blink-matching-paren-distance nil)

;;;; Platform-specific Settings
(when (eq system-type 'gnu/linux)
    )
(when (eq system-type 'windows-nt)
  (set-default-font "Consolas-9")
  (setq exec-path (cons "c:/cygwin/bin" exec-path))
  (setenv "PATH" (concat "c:\\cygwin\\bin;" (getenv "PATH")))
  (setq process-coding-system-alist '(("bash" . undecided-unix)))
  (setq shell-file-name "bash")
  (setq explicit-shell-file-name "bash")
  (setq w32-quote-process-args ?\"))

;;;; Package Installation and Loading
(require 'package)
(setq package-user-dir "~/.emacs.d/elpa/")
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(defvar my-packages
  '(auctex
    go-mode
    latex-preview-pane
    less-css-mode
    magit
    web-beautify
    multiple-cursors
    smartparens
    expand-region
    color-theme-solarized
    git-gutter
    markdown-mode
    js2-mode
    erlang
    ))

(defun install-my-packages ()
  "Install my packages."
  (interactive)
  (package-refresh-contents)
  (mapc '(lambda (package)
	   (unless (package-installed-p package)
	     (package-install package)))
	my-packages))

;;;; Macros
(defmacro after (mode &rest body)
  "`eval-after-load' MODE evaluate BODY."
  (declare (indent defun))
  `(eval-after-load ,mode
     '(progn ,@body)))

;;;; Global Key Bindings
(global-set-key (kbd "<C-prior>") 'previous-buffer)
(global-set-key (kbd "<C-next>") 'next-buffer)

(after 'multiple-cursors-autoloads
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C-S-c C-e") 'mc/edit-ends-of-lines)
  (global-set-key (kbd "C-S-c C-a") 'mc/edit-beginnings-of-lines)
  (global-set-key (kbd "C-.") 'mc/mark-next-like-this)
  (global-set-key (kbd "C->") 'mc/skip-to-next-like-this)
  (global-set-key (kbd "C-,") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-<") 'mc/skip-to-previos-like-this)
  (global-set-key (kbd "C-<return>") 'mc/mark-more-like-this-extended)
  (global-set-key (kbd "C-S-SPC") 'set-rectangular-region-anchor)
  (global-set-key (kbd "C-M-=") 'mc/insert-numbers)
  (global-set-key (kbd "C-*") 'mc/mark-all-like-this)
  (global-set-key (kbd "C-S-<mouse-1>") 'mc/add-cursor-on-click))

(after 'expand-region-autoloads
    (global-set-key (kbd "C-=") 'er/expand-region))

;;;; Language Settings
(defvar c-basic-offset 2)  ; for c++
(defvar standard-indent 2) ; for most things
(setq c-default-style '((java-mode . "java")
			(awk-mode . "awk")
			(other . "bsd")))

(after 'electric-autoloads
  (electric-indent-mode 1))

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(after 'smartparens-autoloads
  (smartparens-global-mode t)
  (sp-local-pair 'emacs-lisp-mode "'" nil :actions nil)
  (sp-local-pair 'scheme-mode "'" nil :actions nil)
  (add-hook 'scheme-mode-hook (lambda () (sp-pair "'" nil)))
  (add-hook 'emacs-lisp-mode-hook (lambda () (sp-pair "'" nil))))

;;; Scheme
(add-to-list 'auto-mode-alist '("\\.ms$" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.ss$" . scheme-mode))

(autoload 'run-scheme "cmuscheme" "Run an inferior scheme process." t)
(global-set-key "!" 'run-scheme)

;;; Lisp

;; Javascript
(defvar js-indent-level 2)

(after 'js2-mode-autoloads
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

(after 'color-theme-solarized-autoloads
  (load-theme 'solarized-light t))

;; Custom
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
