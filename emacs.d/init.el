(defun rc (fn)
  (concat (file-name-directory load-file-name) (convert-standard-filename "rc/") fn ".el"))

(load-file (rc "server"))

;; Appearance Settings
(load-file (rc "decor"))

;; Language Modes
(load-file (rc "c"))
(load-file (rc "java"))
(load-file (rc "javascript"))
(load-file (rc "latex"))
(load-file (rc "lua"))
(load-file (rc "markdown"))
(load-file (rc "scheme"))

;; Other
(load-file (rc "common-hooks"))
(load-file (rc "woman"))

;; Platform Specific Settings
(let ((platform-rc (rc (concat "platform-" (symbol-name system-type)))))
  (when (file-readable-p platform-rc)
    (load-file platform-rc)))

(load-file (rc "old"))
