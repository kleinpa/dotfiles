(defun rc (fn)
  (concat (file-name-directory load-file-name) (convert-standard-filename "rc/") fn))

(load-file (rc "server.el"))
(load-file (rc "packages.el"))

;; Appearance Settings
(load-file (rc "decor.el"))

;; Language Modes
(load-file (rc "c.el"))
(load-file (rc "css.el"))
(load-file (rc "java.el"))
(load-file (rc "javascript.el"))
(load-file (rc "latex.el"))
(load-file (rc "lua.el"))
(load-file (rc "markdown.el"))
(load-file (rc "scheme.el"))

;; Other
(load-file (rc "common-hooks.el"))
(load-file (rc "woman.el"))

;; Platform Specific Settings
(let ((platform-rc (rc (concat "platform-" (symbol-name system-type) ".el"))))
  (when (file-readable-p platform-rc)
    (load-file platform-rc)))

(load-file (rc "old.el"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-archives (quote (("marmalade" . "http://marmalade-repo.org/packages/") ("gnu" . "http://elpa.gnu.org/packages/") ("melpa" . "http://melpa.milkbox.net/packages/")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
