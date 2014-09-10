(add-hook 'go-mode-hook
          (lambda ()
	    (setq indent-tabs-mode t)
            (setq tab-width 2)
	    (local-set-key "" 'newline-and-indent)))
