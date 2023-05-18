(setq inhibit-startup-buffer-menu t
      inhibit-startup-screen t
      make-backup-files nil
      sentence-end-double-space nil
      vc-handled-backends nil
      vc-make-backup-files nil
      warning-minimum-level :error
      warning-minimum-log-level :error)

(setq-default indicate-empty-lines t
              show-trailing-whitespace t)

(column-number-mode t)
(electric-indent-mode 0)

(and window-system
     (progn (blink-cursor-mode 0)
            (tooltip-mode 0)
            (tool-bar-mode 0)
            (setq font-use-system-font t)
            (set-face-background 'fringe "#eeeeee")))
