;;;; Cygwin settings
;; Ugg this is a mess. To get things to work here, I need my .emacs.d
;; windows-linked into my cygwin home so when the HOME variable is
;; updated for the inferior shells, emacs can still find it's home.

(defun first-where (fn ds)
  (cond
   ((null ds) nil)
   ((funcall fn (car ds)) (car ds))
   (t (first-where fn (cdr ds)))))

(let ((cygwin-root (first-where 'file-exists-p
				'("c:\\cygwin64"
				  "c:\\cygwin"))))
  (when cygwin-root
    (setq process-coding-system-alist '(("zsh" . undecided-unix)))
    (setq explicit-zsh.exe-args '("-i"))
    (setq w32-quote-process-args ?\")
    (setq comint-scroll-show-maximum-output 'this)

    (setenv "HOME" (concat (file-name-as-directory cygwin-root)
			    (file-name-as-directory "home")
			    user-login-name))
    (setenv "PATH" (concat
		    (replace-regexp-in-string "/" "\\\\" (concat (file-name-as-directory cygwin-root) "bin;"))
		    (getenv "PATH")))

    (setq exec-path (cons (concat (file-name-as-directory cygwin-root) "bin") exec-path))
    (setq explicit-shell-file-name "zsh")
    (setq comint-eol-on-send t)))

;; Use miktex instead of whatever the normal default is
(require 'tex-mik)
