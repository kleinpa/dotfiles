(add-hook 'go-mode-hook
          (lambda ()
	    (setq indent-tabs-mode t)
            (setq tab-width 2)
	    (local-set-key "
            (add-hook 'before-save-hook #'gofmt-before-save)))