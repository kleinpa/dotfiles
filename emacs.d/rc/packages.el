(when (>= emacs-major-version 24)
  ;; list of packages to install
  (setq package-list '(
		       auctex
		       go-mode
		       latex-preview-pane
		       less-css-mode
		       magit
		       web-beautify
		       multiple-cursors
		       smartparens
		       expand-region
		       solarized-theme
		       git-gutter
		       markdown-mode
		       ))

  (setq package-archives
	'(("marmalade" . "http://marmalade-repo.org/packages/")
	  ("gnu" . "http://elpa.gnu.org/packages/")
	  ("melpa" . "http://melpa.milkbox.net/packages/")))

  ;; activate all the packages (in particular autoloads)
  (package-initialize)

  ;; fetch the list of packages available
  (unless package-archive-contents
    (package-refresh-contents))

  ;; install the missing packages
  (dolist (package package-list)
    (unless (package-installed-p package)
      (package-install package)))
  )

;; (custom-set-variables
;;  '(git-gutter:unchanged-sign " "))

;; (set-face-attribute 'git-gutter:separator nil
;; 		    :background (face-background 'mode-line))

;; (set-face-attribute 'git-gutter:modified nil
;; 		    :background (face-background 'mode-line))

;; (set-face-attribute 'git-gutter:added nil
;; 		    :foreground "#00ff00x"
;; 		    :background (face-background 'mode-line))

;; (set-face-attribute 'git-gutter:deleted nil
;; 		    :background (face-background 'mode-line))

;; (set-face-attribute 'git-gutter:unchanged nil
;; 		    :background (face-background 'mode-line))
