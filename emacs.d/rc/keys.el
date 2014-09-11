;; For multiple-cursors
;; Like Sublime
(global-set-key (kbd "C-S-l") 'mc/edit-lines)
(global-set-key (kbd "C-d") 'mc/mark-next-like-this)

;; Better way
(global-set-key (kbd "C-c C-,") 'mc/edit-lines)
(global-set-key (kbd "C-.") 'mc/mark-next-like-this)
(global-set-key (kbd "C-,") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-.") 'mc/mark-all-like-this)

;; For Expand Region
(global-set-key (kbd "C-@") 'er/expand-region)
