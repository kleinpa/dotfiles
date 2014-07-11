;; Cygwin settings
(setq exec-path (cons "c:/cygwin64/bin" exec-path))
(setenv "PATH" (concat "c:\\cygwin64\\bin;" (getenv "PATH")))

(setq process-coding-system-alist '(("zsh" . undecided-unix)))

(setq explicit-shell-file-name "C:\\cygwin64\\bin\\zsh.exe")
(setq shell-file-name explicit-shell-file-name)
(setq explicit-zsh.exe-args '("--login" "-i"))
(setq w32-quote-process-args ?\")
