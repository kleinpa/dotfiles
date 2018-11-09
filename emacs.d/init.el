(prefer-coding-system 'utf-8-unix)

(setq vc-follow-symlinks t)
(setq-default indent-tabs-mode nil)
(setq inhibit-startup-message t)
(setq require-final-newline nil)
(put 'eval-expression 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Should be able to load multiple files into one emacs window
(server-start)

;; Show matching paren or bracket when cursor is on or after it
(show-paren-mode 1)
(setq blink-matching-paren-distance nil)

;; User Load Path
(add-to-list 'load-path (concat user-emacs-directory
                                (convert-standard-filename "lisp/")))
(load "becls-scheme")

;;;; Platform-specific Settings
(when (eq system-type 'gnu/linux)
  (set-default-font "Source Code Pro-10")
    )
(when (eq system-type 'windows-nt)
  (setq explicit-cmdproxy.exe-args '("-- /q"))
  (set-default-font "Consolas-10")
  (setq exec-path (cons "c:/cygwin64/bin" exec-path))
  (setenv "PATH" (concat "c:\\cygwin64\\bin;" (getenv "PATH")))
  (setq process-coding-system-alist '(("bash" . undecided-unix)))
  (setq shell-file-name "bash")
  (setq explicit-shell-file-name "bash")
  (setq w32-quote-process-args ?\"))
  (setq w32-quote-process-args ?\")

;;;; Macros

;; This seems to be needed before 24.4.
(unless (fboundp 'with-eval-after-load)
  (defmacro with-eval-after-load (mode &rest body)
    "`eval-after-load' MODE evaluate BODY."
    (declare (indent defun))
    `(eval-after-load ,mode
       '(progn ,@body))))

;;;; Package Installation and Loading
(require 'package nil t)
(with-eval-after-load "package"
  (setq package-user-dir "~/.emacs.d/elpa/")
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  ;(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
  (package-initialize)

  (defvar my-packages
    '(
      auctex
      color-theme-sanityinc-tomorrow
      dockerfile-mode
      erlang
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
      pretty-lambdada
      projectile
      scad-mode
      smartparens
      web-beautify
      yaml-mode
      ))

  (defun install-my-packages ()
    "Install my packages."
    (interactive)
    (package-refresh-contents)
    (mapc (lambda (package)
	     (unless (package-installed-p package)
	       (package-install package)))
	  my-packages)))

;;;; Language Settings
(defvar c-basic-offset 2)  ; for c++
(defvar standard-indent 2) ; for most things
(setq c-default-style '((java-mode . "java")
			(awk-mode . "awk")
			(other . "bsd")))

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(global-auto-revert-mode 1)
(delete-selection-mode 1)

(with-eval-after-load "projectile-autoloads"
  (projectile-global-mode))

(with-eval-after-load "electric-autoloads"
  (electric-indent-mode 1))

(with-eval-after-load "smartparens-autoloads"
  (smartparens-global-mode t)
  (sp-local-pair '(scheme-mode emacs-lisp-mode) "'" nil :actions nil)
  (sp-local-pair '(scheme-mode emacs-lisp-mode) "`" nil :actions nil))

(with-eval-after-load "pretty-lambdada-autoloads"
  (pretty-lambda-for-modes))

(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

;; Scheme
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

;; Styles
(menu-bar-mode 0)

(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode 0))

(unless (display-graphic-p)
  (add-hook 'after-init-hook
            (lambda () (load-theme 'sanityinc-tomorrow-bright t))))

;;;; Global Key Bindings
(global-set-key (kbd "<C-prior>") 'previous-buffer)
(global-set-key (kbd "<C-next>") 'next-buffer)

(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-c C-m") 'compile)

(with-eval-after-load "multiple-cursors-autoloads"
  (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
  (global-set-key (kbd "C-S-c C-e") 'mc/edit-ends-of-lines)
  (global-set-key (kbd "C-S-c C-a") 'mc/edit-beginnings-of-lines)
  (global-set-key (kbd "M-.") 'mc/mark-next-like-this)
  (global-set-key (kbd "C->") 'mc/skip-to-next-like-this)
  (global-set-key (kbd "M-,") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-<") 'mc/skip-to-previos-like-this)
  (global-set-key (kbd "C-<return>") 'mc/mark-more-like-this-extended)
  (global-set-key (kbd "C-S-SPC") 'set-rectangular-region-anchor)
  (global-set-key (kbd "C-M-=") 'mc/insert-numbers)
  (global-set-key (kbd "C-*") 'mc/mark-all-like-this)
  (global-set-key (kbd "C-S-<mouse-1>") 'mc/add-cursor-on-click))

(with-eval-after-load "expand-region-autoloads"
    (global-set-key (kbd "C-=") 'er/expand-region))

(with-eval-after-load "magit-autoloads"
  (global-set-key (kbd "C-x g") 'magit-status)
  (global-set-key (kbd "C-x G") 'magit-blame-mode))

(with-eval-after-load "shell"
  (set-face-attribute 'comint-highlight-prompt nil :inherit nil)
  (setq comint-process-echoes t))

(with-eval-after-load "eshell"
  (add-hook
   'eshell-mode-hook
   (lambda ()
     (setq pcomplete-cycle-completions nil)))
  (setq eshell-prompt-function
	(lambda ()
	  (format (propertize "%s@%s:%s%s" 'face `(:foreground "gray"))
		   (propertize (user-login-name) 'face `(:foreground "dim gray"))
		   (propertize (car (split-string (system-name) "\\.")) 'face `(:foreground "dim gray"))
		   (propertize (file-name-base (eshell/pwd)) 'face `(:foreground "dim gray"))
		   (propertize (if (= (user-uid) 0) "# " "$ ") 'face `(:foreground nil))
		   )))
  (setq eshell-prompt-regexp "\\.*?[$#] ")
  (setq eshell-banner-message "")

  (defun eshell/e (&rest args)
    (mapc #'find-file (mapcar #'expand-file-name (eshell-flatten-list (reverse args)))))
  (defun eshell/dc () "docker-compose up") )

(global-set-key (kbd "C-c e") 'eshell)
(global-set-key (kbd "C-c s") 'shell)


(xterm-mouse-mode 1)
