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
