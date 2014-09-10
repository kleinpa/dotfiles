
(defvar js-indent-level 2)

(eval-after-load 'js
  '(add-hook 'js-mode-hook
             (lambda ()
               (add-hook 'before-save-hook 'web-beautify-js-buffer t t))))
