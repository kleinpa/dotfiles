
(defvar js-indent-level 2)

(eval-after-load 'js
  '(add-hook 'js-mode-hook
             (lambda ()
	       (setq web-beautify-args
		     (add-to-list web-beautify-args "-s2" "-w80"))
               (add-hook 'before-save-hook 'web-beautify-js-buffer t t))))
