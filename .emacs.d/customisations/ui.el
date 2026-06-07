;; These customizations change the way emacs looks and disable/enable
;; some user interface elements. Some useful customizations are
;; commented out, and begin with the line "CUSTOMIZE". These are more
;; a matter of preference and may require some fiddling to match your
;; preferences

;; Turn off the menu bar at the top of each frame because it's distracting
(menu-bar-mode -1)

;; Show line numbers
;(global-linum-mode)

;(column-number-mode 1)


;; 1. Enable line numbers globally
(global-display-line-numbers-mode t)

;; 2. Customize the appearance
(custom-set-faces
 ;; The "Faint" style for most line numbers
 '(line-number ((t (:foreground "#5c6370"    ; Dark slate gray
                    :background "#21252b"    ; Slightly darker than standard backgrounds
                    :slant normal
                    :weight normal))))
 
 ;; The "Active" style for the current line
 '(line-number-current-line ((t (:foreground "#abb2bf" ; Brighter silver/white
                                 :background "#2c313a" ; Subtle highlight
                                 :weight bold)))))

;; 3. Better Demarcation & UX
(setq-default 
 ;; Ensure the gutter has at least 3 characters of space to avoid "shaking"
 display-line-numbers-width 2
 ;; Don't shrink the gutter if you scroll to a section with fewer lines
 display-line-numbers-grow-only t)



;; dark terminal colours
(setq frame-background-mode 'dark)


